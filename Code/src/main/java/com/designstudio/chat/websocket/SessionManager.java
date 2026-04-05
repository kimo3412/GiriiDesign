package com.designstudio.chat.websocket;

import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.TextMessage;
import org.springframework.web.socket.WebSocketSession;

import java.io.IOException;
import java.util.concurrent.ConcurrentHashMap;

/**
 * WebSocket 会话管理器
 * key 格式: {userType}_{userId}  例如 client_1, admin_2
 */
@Slf4j
@Component
public class SessionManager {

    private final ConcurrentHashMap<String, WebSocketSession> sessions = new ConcurrentHashMap<>();

    public String buildKey(String userType, Long userId) {
        return userType + "_" + userId;
    }

    public void add(String key, WebSocketSession session) {
        sessions.put(key, session);
    }

    public void remove(String key) {
        sessions.remove(key);
    }

    public WebSocketSession get(String key) {
        return sessions.get(key);
    }

    public boolean isOnline(String key) {
        WebSocketSession session = sessions.get(key);
        return session != null && session.isOpen();
    }

    /**
     * 广播给所有在线管理员/设计师
     */
    public void broadcastToAdmins(String message) {
        broadcast("admin", message);
    }

    /**
     * 广播给所有在线客户
     */
    public void broadcastToClients(String message) {
        broadcast("client", message);
    }

    /**
     * 精确推送：向指定 key 的用户发消息
     */
    public void sendTo(String key, String message) {
        WebSocketSession session = sessions.get(key);
        if (session != null && session.isOpen()) {
            try {
                session.sendMessage(new TextMessage(message));
            } catch (IOException e) {
                log.error("精确推送失败: key={}", key, e);
            }
        }
    }

    /**
     * 向指定类型的所有在线用户广播消息
     */
    private void broadcast(String userTypePrefix, String message) {
        sessions.forEach((key, session) -> {
            if (key.startsWith(userTypePrefix + "_") && session.isOpen()) {
                try {
                    session.sendMessage(new TextMessage(message));
                } catch (IOException e) {
                    log.error("推送消息失败: key={}", key, e);
                }
            }
        });
    }
}
