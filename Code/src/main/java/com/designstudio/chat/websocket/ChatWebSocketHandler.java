package com.designstudio.chat.websocket;

import cn.hutool.json.JSONObject;
import cn.hutool.json.JSONUtil;
import com.designstudio.chat.domain.DsChatMessage;
import com.designstudio.chat.service.ChatService;
import com.designstudio.common.security.JwtUtils;
import com.designstudio.common.service.AiCustomerService;
import com.designstudio.config.domain.DsCategory;
import com.designstudio.config.domain.DsWorkflowStep;
import com.designstudio.config.mapper.DsCategoryMapper;
import com.designstudio.order.controller.AppOrderController;
import com.designstudio.order.domain.DsOrder;
import com.designstudio.order.service.OrderService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.CloseStatus;
import org.springframework.web.socket.TextMessage;
import org.springframework.web.socket.WebSocketSession;
import org.springframework.web.socket.handler.TextWebSocketHandler;
import org.springframework.web.util.UriComponentsBuilder;

import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.CompletableFuture;

/**
 * Chat WebSocket handler.
 * Connect with: ws://host:port/ws/chat?token=xxx
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class ChatWebSocketHandler extends TextWebSocketHandler {

    private final SessionManager sessionManager;
    private final ChatService chatService;
    private final JwtUtils jwtUtils;
    private final AiCustomerService aiCustomerService;
    private final OrderService orderService;
    private final DsCategoryMapper categoryMapper;

    private static final DateTimeFormatter FMT = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
    private static final int CONTENT_TYPE_TEXT = 0;
    private static final int CONTENT_TYPE_IMAGE = 1;
    private static final int CONTENT_TYPE_PROGRESS_CARD = 3;
    private static final int CONTENT_TYPE_ACTION_CARD = 4;

    @Override
    public void afterConnectionEstablished(WebSocketSession session) throws Exception {
        Map<String, String> params = UriComponentsBuilder.fromUri(session.getUri()).build().getQueryParams().toSingleValueMap();
        String token = params.get("token");

        if (token == null || !jwtUtils.validateToken(token)) {
            session.close(CloseStatus.NOT_ACCEPTABLE);
            log.warn("WebSocket connection rejected: invalid token");
            return;
        }

        Long userId = jwtUtils.getUserIdFromToken(token);
        String userType = jwtUtils.getUserTypeFromToken(token);
        String key = sessionManager.buildKey(userType, userId);

        session.getAttributes().put("userId", userId);
        session.getAttributes().put("userType", userType);
        session.getAttributes().put("sessionKey", key);

        sessionManager.add(key, session);
        log.info("WebSocket connected: {} ({})", key, session.getId());
    }

    @Override
    protected void handleTextMessage(WebSocketSession session, TextMessage message) throws Exception {
        JSONObject json = JSONUtil.parseObj(message.getPayload());
        if (!"SEND".equals(json.getStr("type"))) {
            return;
        }

        Long currentUserId = (Long) session.getAttributes().get("userId");
        String userType = currentUserId != null ? (String) session.getAttributes().get("userType") : "client";
        Long targetUserId = json.getLong("userId");
        Long chatUserId = "client".equals(userType) ? currentUserId : targetUserId;
        String content = json.getStr("content");
        String msgType = json.getStr("msgType", "text");
        Long orderId = json.getLong("orderId");
        int senderTypeInt = "client".equals(userType) ? 0 : 1;
        int contentTypeInt = "image".equals(msgType) ? CONTENT_TYPE_IMAGE : CONTENT_TYPE_TEXT;

        DsChatMessage msg = chatService.saveMessage(chatUserId, senderTypeInt, currentUserId, content, contentTypeInt, orderId);
        JSONObject pushJson = buildMessagePush("NEW_MSG", msg, chatUserId, orderId, userType, currentUserId, content, msgType, contentTypeInt, null);
        String pushText = pushJson.toString();

        if ("client".equals(userType)) {
            sessionManager.broadcastToAdmins(pushText);
        } else if (chatUserId != null) {
            sessionManager.sendTo(sessionManager.buildKey("client", chatUserId), pushText);
        }

        pushJson.set("type", "SEND_ACK");
        session.sendMessage(new TextMessage(pushJson.toString()));

        boolean clientMessage = "client".equals(userType);
        boolean humanHandoffActive = clientMessage && chatService.isHumanHandoffActive(chatUserId, orderId);
        if (clientMessage && !humanHandoffActive && shouldPushProgressCard(content, orderId)) {
            pushOrderProgressCard(chatUserId, orderId);
        }
        if (clientMessage && !humanHandoffActive) {
            pushHelpfulActionCards(chatUserId, orderId, content);
        }

        if (aiCustomerService.isEnabled() && clientMessage && !humanHandoffActive) {
            triggerAiReply(chatUserId, orderId, content);
        }

        log.debug("message handled: {} -> chatUserId={}", userType, chatUserId);
    }

    private void triggerAiReply(Long chatUserId, Long orderId, String content) {
        CompletableFuture.runAsync(() -> {
            try {
                if (chatService.isHumanHandoffActive(chatUserId, orderId)) {
                    return;
                }
                List<AiCustomerService.Message> messages = new ArrayList<>();
                String orderContext = buildOrderContextPrompt(chatUserId, orderId);
                if (orderContext != null && !orderContext.isBlank()) {
                    messages.add(new AiCustomerService.Message("system", orderContext));
                }
                chatService.getRecentMessages(chatUserId, 20).stream()
                        .map(m -> new AiCustomerService.Message(
                                m.getSenderType() == 0 ? "user" : "assistant",
                                m.getContent() == null ? "" : m.getContent()))
                        .forEach(messages::add);
                String aiReply = aiCustomerService.getResponse(chatUserId, messages);
                if (aiReply == null || aiReply.isBlank()) {
                    return;
                }
                if (chatService.isHumanHandoffActive(chatUserId, orderId)) {
                    return;
                }

                DsChatMessage aiMsg = chatService.saveMessage(chatUserId, 2, 0L, aiReply, CONTENT_TYPE_TEXT, orderId);
                JSONObject aiPush = buildMessagePush("NEW_MSG", aiMsg, chatUserId, orderId, "ai", 0L,
                        aiReply, "text", CONTENT_TYPE_TEXT, null);
                sessionManager.sendTo(sessionManager.buildKey("client", chatUserId), aiPush.toString());
                sessionManager.broadcastToAdmins(aiPush.toString());
            } catch (Exception e) {
                log.error("AI auto reply failed: {}", e.getMessage());
            }
        });
    }

    private JSONObject buildMessagePush(String type, DsChatMessage msg, Long chatUserId, Long orderId,
                                        String senderType, Long senderId, String content, String msgType,
                                        int contentType, Object extraJson) {
        JSONObject pushJson = new JSONObject();
        pushJson.set("type", type);
        pushJson.set("messageId", msg.getMsgId());
        pushJson.set("userId", chatUserId);
        pushJson.set("orderId", orderId);
        pushJson.set("senderType", senderType);
        pushJson.set("senderId", senderId);
        pushJson.set("content", content);
        pushJson.set("msgType", msgType);
        pushJson.set("contentType", contentType);
        if (extraJson != null) {
            pushJson.set("extraJson", extraJson);
        }
        pushJson.set("createTime", msg.getCreateTime().format(FMT));
        return pushJson;
    }

    private boolean shouldPushProgressCard(String content, Long orderId) {
        if (orderId == null || content == null) {
            return false;
        }
        String lower = content.toLowerCase();
        return lower.contains("进度")
                || lower.contains("订单")
                || lower.contains("节点")
                || lower.contains("到哪")
                || lower.contains("状态")
                || lower.contains("交付")
                || lower.contains("付款")
                || lower.contains("尾款")
                || lower.contains("progress")
                || lower.contains("status")
                || lower.contains("order");
    }

    private void pushHelpfulActionCards(Long chatUserId, Long orderId, String content) {
        if (chatUserId == null || content == null) {
            return;
        }
        String lower = content.toLowerCase();
        if (containsAny(lower, "人工", "客服", "设计师", "联系", "转人工", "human", "service")) {
            pushActionCard(chatUserId, orderId,
                    "需要人工帮助吗？",
                    "你可以直接进入专属沟通页，设计师和客服会看到你的消息上下文。",
                    "联系人工客服",
                    "/pages/chat/index" + (orderId == null ? "" : "?orderId=" + orderId),
                    "service");
        }
        if (containsAny(lower, "案例", "作品", "参考", "灵感", "portfolio", "case")) {
            pushActionCard(chatUserId, orderId,
                    "看看作品案例",
                    "这里整理了近期作品，你可以把喜欢的风格发给设计师作为参考。",
                    "查看作品集",
                    "/pages/portfolio/list/index",
                    "portfolio");
        }
        if (containsAny(lower, "定制", "下单", "填写", "表单", "需求", "开始", "custom", "brief")) {
            pushActionCard(chatUserId, orderId,
                    "开始新的定制需求",
                    "选择品类后填写定制 Brief，设计师会根据你的描述给出方案。",
                    "去填写定制需求",
                    "/pages/custom/category/index",
                    "custom");
        }
        if (containsAny(lower, "通知", "提醒", "消息", "未读", "notification")) {
            pushActionCard(chatUserId, orderId,
                    "查看通知中心",
                    "订单节点、付款提醒和交付动态都会集中在通知中心。",
                    "打开通知中心",
                    "/pages/user/notification/index",
                    "notification");
        }
        if (orderId != null && containsAny(lower, "支付", "定金", "尾款", "付款", "pay", "deposit", "balance")) {
            AppOrderController.OrderTimelineVO timeline = safeGetTimeline(orderId, chatUserId);
            DsOrder order = timeline == null ? null : timeline.getOrder();
            String actionTitle = order != null && Integer.valueOf(6).equals(order.getStatus())
                    ? "支付尾款提醒"
                    : "支付订单款项";
            String actionDesc = order != null && Integer.valueOf(0).equals(order.getStatus())
                    ? "当前订单待支付定金，进入详情页即可完成模拟支付。"
                    : "进入订单详情页，可以查看应付金额并完成支付操作。";
            pushActionCard(chatUserId, orderId,
                    actionTitle,
                    actionDesc,
                    "去订单详情支付",
                    "/pages/order/detail/index?id=" + orderId,
                    "payment");
        }
    }

    private boolean containsAny(String content, String... keywords) {
        for (String keyword : keywords) {
            if (content.contains(keyword)) {
                return true;
            }
        }
        return false;
    }

    private String buildOrderContextPrompt(Long chatUserId, Long orderId) {
        if (chatUserId == null || orderId == null) {
            return null;
        }
        AppOrderController.OrderTimelineVO timeline = safeGetTimeline(orderId, chatUserId);
        if (timeline == null || timeline.getOrder() == null) {
            return null;
        }
        DsOrder order = timeline.getOrder();
        String categoryName = resolveCategoryName(order.getCategoryId());
        StringBuilder sb = new StringBuilder();
        sb.append("当前用户正在咨询订单，请基于以下实时订单信息回答，不要编造不存在的信息。");
        sb.append("订单号：").append(nullToDash(order.getOrderSn())).append("；");
        sb.append("品类：").append(nullToDash(categoryName)).append("；");
        sb.append("订单状态：").append(resolveOrderStatus(order.getStatus())).append("；");
        sb.append("当前节点：").append(nullToDash(timeline.getCurrentStepName())).append("；");
        sb.append("预计交付：").append(order.getExpectedDate() == null ? "未设置" : order.getExpectedDate()).append("；");
        sb.append("已支付：").append(order.getPaidAmount() == null ? "0" : order.getPaidAmount()).append("；");
        sb.append("总金额：").append(order.getTotalAmount() == null ? "未设置" : order.getTotalAmount()).append("。");
        if (timeline.getTimelineEvents() != null && !timeline.getTimelineEvents().isEmpty()) {
            sb.append("最近进度：");
            timeline.getTimelineEvents().stream()
                    .skip(Math.max(0, timeline.getTimelineEvents().size() - 3))
                    .forEach(event -> sb.append("[")
                            .append(nullToDash(event.getStepName()))
                            .append("] ")
                            .append(nullToDash(event.getDescription()))
                            .append("；"));
        }
        sb.append("如果用户询问进度，引导用户点击聊天中的进度卡片查看完整订单详情。");
        return sb.toString();
    }

    private void pushOrderProgressCard(Long chatUserId, Long orderId) {
        CompletableFuture.runAsync(() -> {
            try {
                AppOrderController.OrderTimelineVO timeline = safeGetTimeline(orderId, chatUserId);
                if (timeline == null || timeline.getOrder() == null) {
                    return;
                }
                JSONObject extra = buildProgressCardJson(timeline);
                String content = "已为你整理当前订单进度，点击卡片可查看完整详情。";
                DsChatMessage cardMsg = chatService.saveMessage(chatUserId, 2, 0L, content,
                        CONTENT_TYPE_PROGRESS_CARD, orderId, extra.toString());

                JSONObject cardPush = buildMessagePush("NEW_MSG", cardMsg, chatUserId, orderId, "ai", 0L,
                        content, "progress_card", CONTENT_TYPE_PROGRESS_CARD, extra);
                sessionManager.sendTo(sessionManager.buildKey("client", chatUserId), cardPush.toString());
                sessionManager.broadcastToAdmins(cardPush.toString());
            } catch (Exception e) {
                log.error("order progress card push failed: {}", e.getMessage());
            }
        });
    }

    private void pushActionCard(Long chatUserId, Long orderId, String title, String description,
                                String actionText, String actionUrl, String iconType) {
        CompletableFuture.runAsync(() -> {
            try {
                JSONObject extra = new JSONObject();
                extra.set("cardType", "action_card");
                extra.set("title", title);
                extra.set("description", description);
                extra.set("actionText", actionText);
                extra.set("actionUrl", actionUrl);
                extra.set("iconType", iconType);
                extra.set("orderId", orderId);

                DsChatMessage cardMsg = chatService.saveMessage(chatUserId, 2, 0L, title,
                        CONTENT_TYPE_ACTION_CARD, orderId, extra.toString());
                JSONObject push = buildMessagePush("NEW_MSG", cardMsg, chatUserId, orderId, "ai", 0L,
                        title, "action_card", CONTENT_TYPE_ACTION_CARD, extra);
                sessionManager.sendTo(sessionManager.buildKey("client", chatUserId), push.toString());
                sessionManager.broadcastToAdmins(push.toString());
            } catch (Exception e) {
                log.error("action card push failed: {}", e.getMessage());
            }
        });
    }

    private AppOrderController.OrderTimelineVO safeGetTimeline(Long orderId, Long userId) {
        try {
            return orderService.getOrderTimeline(orderId, userId);
        } catch (Exception e) {
            log.warn("failed to load order context: orderId={}, userId={}, err={}", orderId, userId, e.getMessage());
            return null;
        }
    }

    private JSONObject buildProgressCardJson(AppOrderController.OrderTimelineVO timeline) {
        DsOrder order = timeline.getOrder();
        JSONObject extra = new JSONObject();
        extra.set("cardType", "progress_card");
        extra.set("title", "订单进度");
        extra.set("orderId", order.getOrderId());
        extra.set("orderSn", order.getOrderSn());
        extra.set("categoryName", resolveCategoryName(order.getCategoryId()));
        extra.set("status", order.getStatus());
        extra.set("statusText", resolveOrderStatus(order.getStatus()));
        extra.set("currentStepName", timeline.getCurrentStepName());
        extra.set("currentStepIndex", timeline.getCurrentStepIndex());
        extra.set("totalSteps", timeline.getWorkflowSteps() == null ? 0 : timeline.getWorkflowSteps().size());
        extra.set("expectedDate", order.getExpectedDate() == null ? null : order.getExpectedDate().toString());
        extra.set("expectedDateText", timeline.getExpectedDateText());
        extra.set("isOverdue", timeline.getIsOverdue());
        extra.set("overdueDays", timeline.getOverdueDays());
        extra.set("paidAmount", order.getPaidAmount());
        extra.set("totalAmount", order.getTotalAmount());
        extra.set("actionText", "查看订单详情");
        extra.set("actionUrl", "/pages/order/detail/index?id=" + order.getOrderId());

        List<Map<String, Object>> steps = timeline.getWorkflowSteps() == null
                ? List.of()
                : timeline.getWorkflowSteps().stream().map(this::buildStepMap).toList();
        extra.set("steps", steps);

        if (timeline.getTimelineEvents() != null && !timeline.getTimelineEvents().isEmpty()) {
            AppOrderController.TimelineEventVO latest = timeline.getTimelineEvents().get(timeline.getTimelineEvents().size() - 1);
            extra.set("latestProgress", nullToDash(latest.getDescription()));
            extra.set("latestProgressTime", latest.getCreateTime() == null ? null : latest.getCreateTime().format(FMT));
        }
        return extra;
    }

    private Map<String, Object> buildStepMap(DsWorkflowStep step) {
        Map<String, Object> map = new HashMap<>();
        map.put("stepId", step.getStepId());
        map.put("stepName", step.getStepName());
        map.put("stepOrder", step.getStepOrder());
        return map;
    }

    private String resolveCategoryName(Long categoryId) {
        if (categoryId == null) {
            return null;
        }
        DsCategory category = categoryMapper.selectById(categoryId);
        return category == null ? null : category.getName();
    }

    private String resolveOrderStatus(Integer status) {
        if (status == null) {
            return "未知状态";
        }
        return switch (status) {
            case 0 -> "待支付";
            case 1 -> "生产中";
            case 2 -> "待发货";
            case 3 -> "待收货";
            case 4 -> "已完成";
            case 5 -> "已取消";
            case 6 -> "待付尾款";
            default -> "未知状态";
        };
    }

    private String nullToDash(Object value) {
        return value == null ? "-" : String.valueOf(value);
    }

    @Override
    public void afterConnectionClosed(WebSocketSession session, CloseStatus status) {
        String key = (String) session.getAttributes().get("sessionKey");
        if (key != null) {
            sessionManager.remove(key);
            log.info("WebSocket closed: {}", key);
        }
    }

    @Override
    public void handleTransportError(WebSocketSession session, Throwable exception) {
        log.error("WebSocket transport error: {}", exception.getMessage());
        String key = (String) session.getAttributes().get("sessionKey");
        if (key != null) {
            sessionManager.remove(key);
        }
    }
}
