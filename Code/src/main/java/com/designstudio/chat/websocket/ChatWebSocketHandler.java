package com.designstudio.chat.websocket;

import cn.hutool.json.JSONObject;
import cn.hutool.json.JSONUtil;
import com.designstudio.chat.domain.DsChatMessage;
import com.designstudio.chat.service.ChatService;
import com.designstudio.common.security.JwtUtils;
import com.designstudio.common.service.AiCustomerService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.*;
import org.springframework.web.socket.handler.TextWebSocketHandler;
import org.springframework.web.util.UriComponentsBuilder;

import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Map;
import java.util.concurrent.CompletableFuture;

/**
 * 聊天 WebSocket 核心处理器
 * 连接地址: ws://host:port/ws/chat?token=xxx
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class ChatWebSocketHandler extends TextWebSocketHandler {

    private final SessionManager sessionManager;
    private final ChatService chatService;
    private final JwtUtils jwtUtils;
    private final AiCustomerService aiCustomerService;

    private static final DateTimeFormatter FMT = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");

    @Override
    public void afterConnectionEstablished(WebSocketSession session) throws Exception {
        Map<String, String> params = UriComponentsBuilder.fromUri(session.getUri()).build().getQueryParams().toSingleValueMap();
        String token = params.get("token");

        if (token == null || !jwtUtils.validateToken(token)) {
            session.close(CloseStatus.NOT_ACCEPTABLE);
            log.warn("WebSocket 连接被拒绝：无效 Token");
            return;
        }

        Long userId = jwtUtils.getUserIdFromToken(token);
        String userType = jwtUtils.getUserTypeFromToken(token);
        String key = sessionManager.buildKey(userType, userId);

        session.getAttributes().put("userId", userId);
        session.getAttributes().put("userType", userType);
        session.getAttributes().put("sessionKey", key);

        sessionManager.add(key, session);
        log.info("WebSocket 连接建立: {} ({})", key, session.getId());
    }

    @Override
    protected void handleTextMessage(WebSocketSession session, TextMessage message) throws Exception {
        String payload = message.getPayload();
        JSONObject json = JSONUtil.parseObj(payload);

        String type = json.getStr("type");
        if (!"SEND".equals(type)) return;

        Long currentUserId = (Long) session.getAttributes().get("userId");
        String userType = currentUserId != null
                ? (String) session.getAttributes().get("userType") : "client";

        Long targetUserId = json.getLong("userId");
        Long chatUserId = "client".equals(userType) ? currentUserId : targetUserId;
        String content = json.getStr("content");
        String msgType = json.getStr("msgType", "text");
        Long orderId = json.getLong("orderId");
        int senderTypeInt = "client".equals(userType) ? 0 : 1;
        int contentTypeInt = "image".equals(msgType) ? 1 : 0;

        // 持久化消息
        DsChatMessage msg = chatService.saveMessage(chatUserId, senderTypeInt, currentUserId, content, contentTypeInt, orderId);

        // 构建推送 JSON
        JSONObject pushJson = new JSONObject();
        pushJson.set("type", "NEW_MSG");
        pushJson.set("messageId", msg.getMsgId());
        pushJson.set("userId", chatUserId);
        pushJson.set("orderId", orderId);
        pushJson.set("senderType", userType);
        pushJson.set("senderId", currentUserId);
        pushJson.set("content", content);
        pushJson.set("msgType", msgType);
        pushJson.set("contentType", contentTypeInt);
        pushJson.set("createTime", msg.getCreateTime().format(FMT));

        String pushText = pushJson.toString();

        // 推送给对方
        if ("client".equals(userType)) {
            sessionManager.broadcastToAdmins(pushText);
        } else {
            if (chatUserId != null) {
                String clientKey = sessionManager.buildKey("client", chatUserId);
                sessionManager.sendTo(clientKey, pushText);
            }
        }

        // 回声确认给发送方
        pushJson.set("type", "SEND_ACK");
        session.sendMessage(new TextMessage(pushJson.toString()));

        // AI 自动回复（仅当客户端发消息时触发）
        if (aiCustomerService.isEnabled() && "client".equals(userType)) {
            CompletableFuture.runAsync(() -> {
                try {
                    List<DsChatMessage> recent = chatService.getRecentMessages(chatUserId, 10);
                    List<AiCustomerService.Message> messages = recent.stream()
                            .map(m -> new AiCustomerService.Message(
                                    m.getSenderType() == 0 ? "user" : "assistant",
                                    m.getContent() != null ? m.getContent() : ""))
                            .toList();
                    // 加入当前消息
                    messages.add(new AiCustomerService.Message("user", content));

                    String aiReply = aiCustomerService.getResponse(chatUserId, messages);
                    if (aiReply != null && !aiReply.isBlank()) {
                        // 持久化 AI 消息
                        DsChatMessage aiMsg = chatService.saveMessage(
                                chatUserId, 2, null, aiReply, 0, orderId);

                        JSONObject aiPush = new JSONObject();
                        aiPush.set("type", "NEW_MSG");
                        aiPush.set("messageId", aiMsg.getMsgId());
                        aiPush.set("userId", chatUserId);
                        aiPush.set("orderId", orderId);
                        aiPush.set("senderType", "ai");
                        aiPush.set("senderId", null);
                        aiPush.set("content", aiReply);
                        aiPush.set("msgType", "text");
                        aiPush.set("contentType", 0);
                        aiPush.set("createTime", aiMsg.getCreateTime().format(FMT));

                        String clientKey = sessionManager.buildKey("client", chatUserId);
                        sessionManager.sendTo(clientKey, aiPush.toString());
                        sessionManager.broadcastToAdmins(aiPush.toString());
                    }
                } catch (Exception e) {
                    log.error("AI 自动回复失败: {}", e.getMessage());
                }
            });
        }

        log.debug("消息已处理: {} -> chatUserId={}", userType, chatUserId);
    }

    @Override
    public void afterConnectionClosed(WebSocketSession session, CloseStatus status) {
        String key = (String) session.getAttributes().get("sessionKey");
        if (key != null) {
            sessionManager.remove(key);
            log.info("WebSocket 连接关闭: {}", key);
        }
    }

    @Override
    public void handleTransportError(WebSocketSession session, Throwable exception) {
        log.error("WebSocket 传输异常: {}", exception.getMessage());
        String key = (String) session.getAttributes().get("sessionKey");
        if (key != null) {
            sessionManager.remove(key);
        }
    }
}
