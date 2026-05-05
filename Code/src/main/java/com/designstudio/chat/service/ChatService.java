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

    /**
     * 保存带结构化扩展数据的消息。
     */
    DsChatMessage saveMessage(Long chatUserId, int senderType, Long senderId,
                              String content, int contentType, Long orderId, String extraJson);

    /**
     * 获取最近 N 条聊天记录（用于 AI 上下文）
     */
    List<DsChatMessage> getRecentMessages(Long chatUserId, int limit);

    /**
     * 判断当前会话是否已转人工。转人工后 AI 不再自动回复，直到后台恢复 AI。
     */
    boolean isHumanHandoffActive(Long chatUserId, Long orderId);

    /**
     * 后台人工处理完毕后恢复 AI 自动接待，并写入一条会话状态消息。
     */
    DsChatMessage resolveHumanHandoff(Long chatUserId, Long orderId, Long adminId);
}
