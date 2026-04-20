package com.designstudio.common.service;

import java.util.List;

/**
 * AI 客服服务接口
 */
public interface AiCustomerService {

    /**
     * 根据用户消息获取 AI 回复
     * @param userId 用户ID（可能为null，游客）
     * @param messages 消息历史，格式：[{"role":"user","content":"xxx"},...]
     * @return AI 回复文本
     */
    String getResponse(Long userId, List<Message> messages);

    /**
     * 检查 AI 客服是否启用
     */
    boolean isEnabled();

    record Message(String role, String content) {}
}