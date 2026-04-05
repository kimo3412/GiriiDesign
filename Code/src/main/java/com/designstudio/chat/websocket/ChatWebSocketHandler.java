package com.designstudio.chat.websocket;

import cn.hutool.json.JSONObject;
import cn.hutool.json.JSONUtil;
import com.designstudio.chat.domain.DsChatMessage;
import com.designstudio.chat.mapper.DsChatMessageMapper;
import com.designstudio.common.security.JwtUtils;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.*;
import org.springframework.web.socket.handler.TextWebSocketHandler;
import org.springframework.web.util.UriComponentsBuilder;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Map;

/**
 * 聊天 WebSocket 核心处理器
 * 连接地址: ws://host:port/ws/chat?token=xxx
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class ChatWebSocketHandler extends TextWebSocketHandler {

    private final SessionManager sessionManager;
    private final DsChatMessageMapper messageMapper;
    private final JwtUtils jwtUtils;

    private static final DateTimeFormatter FMT = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");

    /**
     * 连接建立：解析 Token，注册在线会话
     */
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

        // 存入 session 属性供后续使用
        session.getAttributes().put("userId", userId);
        session.getAttributes().put("userType", userType);
        session.getAttributes().put("sessionKey", key);

        sessionManager.add(key, session);
        log.info("WebSocket 连接建立: {} ({})", key, session.getId());
    }

    /**
     * 收到消息：解析 JSON，持久化并路由推送
     */
    @Override
    protected void handleTextMessage(WebSocketSession session, TextMessage message) throws Exception {
        String payload = message.getPayload();
        JSONObject json = JSONUtil.parseObj(payload);

        String type = json.getStr("type");
        if (!"SEND".equals(type)) return;

        Long userId = (Long) session.getAttributes().get("userId");
        String userType = (String) session.getAttributes().get("userType");
        Long orderId = json.getLong("orderId");
        String content = json.getStr("content");
        String msgType = json.getStr("msgType", "text");
        // sender_type: 0=客户, 1=设计师/管理员
        int senderTypeInt = "client".equals(userType) ? 0 : 1;
        // content_type: 0=文本, 1=图片
        int contentTypeInt = "image".equals(msgType) ? 1 : 0;

        // 1. 持久化消息
        DsChatMessage msg = new DsChatMessage();
        msg.setOrderId(orderId);
        msg.setSenderType(senderTypeInt);
        msg.setSenderId(userId);
        msg.setContent(content);
        msg.setContentType(contentTypeInt);
        msg.setIsRead(0);
        msg.setDelFlag(0);
        msg.setCreateTime(LocalDateTime.now());
        messageMapper.insert(msg);

        // 2. 构建推送 JSON
        JSONObject pushJson = new JSONObject();
        pushJson.set("type", "NEW_MSG");
        pushJson.set("messageId", msg.getMsgId());
        pushJson.set("orderId", orderId);
        pushJson.set("senderType", userType);
        pushJson.set("senderId", userId);
        pushJson.set("content", content);
        pushJson.set("msgType", msgType);
        pushJson.set("contentType", contentTypeInt);
        pushJson.set("createTime", msg.getCreateTime().format(FMT));

        String pushText = pushJson.toString();

        // 3. 推送给对方
        //    客户发的 → 广播给所有在线 admin（任何管理员都可能处理）
        //    管理员发的 → 精确推送给该订单的客户
        if ("client".equals(userType)) {
            sessionManager.broadcastToAdmins(pushText);
        } else {
            // 查找该订单的客户 userId
            Long clientUserId = messageMapper.selectClientUserIdByOrderId(orderId);
            if (clientUserId != null) {
                String clientKey = sessionManager.buildKey("client", clientUserId);
                sessionManager.sendTo(clientKey, pushText);
            }
        }

        // 4. 回声确认给发送方
        pushJson.set("type", "SEND_ACK");
        session.sendMessage(new TextMessage(pushJson.toString()));

        log.debug("消息已处理: {} -> orderId={}", userType, orderId);
    }

    /**
     * 连接关闭
     */
    @Override
    public void afterConnectionClosed(WebSocketSession session, CloseStatus status) {
        String key = (String) session.getAttributes().get("sessionKey");
        if (key != null) {
            sessionManager.remove(key);
            log.info("WebSocket 连接关闭: {}", key);
        }
    }

    /**
     * 异常处理
     */
    @Override
    public void handleTransportError(WebSocketSession session, Throwable exception) {
        log.error("WebSocket 传输异常: {}", exception.getMessage());
        String key = (String) session.getAttributes().get("sessionKey");
        if (key != null) {
            sessionManager.remove(key);
        }
    }
}
