package com.designstudio.chat.websocket;

import cn.hutool.json.JSONObject;
import cn.hutool.json.JSONUtil;
import com.designstudio.chat.domain.DsChatMessage;
import com.designstudio.chat.service.ChatService;
import com.designstudio.common.security.JwtUtils;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.*;
import org.springframework.web.socket.handler.TextWebSocketHandler;
import org.springframework.web.util.UriComponentsBuilder;

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
    private final ChatService chatService;
    private final JwtUtils jwtUtils;

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
        int senderTypeInt = "client".equals(userType) ? 0 : 1;
        int contentTypeInt = "image".equals(msgType) ? 1 : 0;

        // 持久化消息
        DsChatMessage msg = chatService.saveMessage(chatUserId, senderTypeInt, currentUserId, content, contentTypeInt);

        // 构建推送 JSON
        JSONObject pushJson = new JSONObject();
        pushJson.set("type", "NEW_MSG");
        pushJson.set("messageId", msg.getMsgId());
        pushJson.set("userId", chatUserId);
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
