package com.designstudio.chat.service;

import com.designstudio.chat.domain.DsChatMessage;

import java.util.List;
import java.util.Map;

/**
 * 聊天业务 Service
 */
public interface ChatService {

    /**
     * C端 - 获取我的聊天记录（同时标记管理员消息已读）
     */
    List<DsChatMessage> getClientMessages(Long userId, Long orderId);

    /**
     * B端 - 获取所有会话列表
     */
    List<Map<String, Object>> getConversations();

    /**
     * B端 - 获取某客户的聊天记录
     */
    List<DsChatMessage> getAdminMessages(Long userId, Long orderId);

    /**
     * B端 - 标记某客户的消息为已读
     */
    void markAsRead(Long userId, Long orderId);

    /**
     * B端 - 获取聊天客户的全景意向/订单一览
     */
    Map<String, Object> getChatUserSummary(Long userId);

    /**
     * 持久化消息并返回消息ID
     */
    DsChatMessage saveMessage(Long chatUserId, int senderType, Long senderId,
                              String content, int contentType, Long orderId);
}
