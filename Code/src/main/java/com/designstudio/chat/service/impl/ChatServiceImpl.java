package com.designstudio.chat.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.designstudio.chat.domain.DsChatMessage;
import com.designstudio.chat.mapper.DsChatMessageMapper;
import com.designstudio.chat.service.ChatService;
import com.designstudio.order.domain.DsOrder;
import com.designstudio.order.domain.DsOrderRequest;
import com.designstudio.order.mapper.DsOrderMapper;
import com.designstudio.order.mapper.DsOrderRequestMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 聊天业务 Service 实现
 */
@Service
@RequiredArgsConstructor
public class ChatServiceImpl implements ChatService {

    private final DsChatMessageMapper messageMapper;
    private final DsOrderMapper orderMapper;
    private final DsOrderRequestMapper requestMapper;

    @Override
    public List<DsChatMessage> getClientMessages(Long userId) {
        List<DsChatMessage> list = messageMapper.selectList(
                new LambdaQueryWrapper<DsChatMessage>()
                        .eq(DsChatMessage::getUserId, userId)
                        .orderByAsc(DsChatMessage::getCreateTime));

        messageMapper.update(null, new LambdaUpdateWrapper<DsChatMessage>()
                .eq(DsChatMessage::getUserId, userId)
                .eq(DsChatMessage::getSenderType, 1)
                .eq(DsChatMessage::getIsRead, 0)
                .set(DsChatMessage::getIsRead, 1));

        return list;
    }

    @Override
    public List<Map<String, Object>> getConversations() {
        return messageMapper.selectConversationList();
    }

    @Override
    public List<DsChatMessage> getAdminMessages(Long userId) {
        return messageMapper.selectList(
                new LambdaQueryWrapper<DsChatMessage>()
                        .eq(DsChatMessage::getUserId, userId)
                        .orderByAsc(DsChatMessage::getCreateTime));
    }

    @Override
    public void markAsRead(Long userId) {
        messageMapper.update(null, new LambdaUpdateWrapper<DsChatMessage>()
                .eq(DsChatMessage::getUserId, userId)
                .eq(DsChatMessage::getSenderType, 0)
                .eq(DsChatMessage::getIsRead, 0)
                .set(DsChatMessage::getIsRead, 1));
    }

    @Override
    public Map<String, Object> getChatUserSummary(Long userId) {
        List<DsOrderRequest> requests = requestMapper.selectList(
                new LambdaQueryWrapper<DsOrderRequest>()
                        .eq(DsOrderRequest::getUserId, userId)
                        .orderByDesc(DsOrderRequest::getCreateTime));
        List<DsOrder> orders = orderMapper.selectList(
                new LambdaQueryWrapper<DsOrder>()
                        .eq(DsOrder::getUserId, userId)
                        .orderByDesc(DsOrder::getCreateTime));

        Map<String, Object> map = new HashMap<>();
        map.put("requests", requests);
        map.put("orders", orders);
        return map;
    }

    @Override
    public DsChatMessage saveMessage(Long chatUserId, int senderType, Long senderId,
                                     String content, int contentType) {
        DsChatMessage msg = new DsChatMessage();
        msg.setUserId(chatUserId);
        msg.setSenderType(senderType);
        msg.setSenderId(senderId);
        msg.setContent(content);
        msg.setContentType(contentType);
        msg.setIsRead(0);
        msg.setDelFlag(0);
        msg.setCreateTime(LocalDateTime.now());
        messageMapper.insert(msg);
        return msg;
    }
}
