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
    public List<DsChatMessage> getClientMessages(Long userId, Long orderId) {
        LambdaQueryWrapper<DsChatMessage> wrapper = new LambdaQueryWrapper<DsChatMessage>()
                .eq(DsChatMessage::getUserId, userId);
        if (orderId != null) {
            wrapper.eq(DsChatMessage::getOrderId, orderId);
        } else {
            wrapper.isNull(DsChatMessage::getOrderId);
        }
        wrapper.orderByAsc(DsChatMessage::getCreateTime);
        List<DsChatMessage> list = messageMapper.selectList(wrapper);

        // 标记管理员消息已读
        LambdaUpdateWrapper<DsChatMessage> updateWrapper = new LambdaUpdateWrapper<DsChatMessage>()
                .eq(DsChatMessage::getUserId, userId)
                .eq(DsChatMessage::getSenderType, 1)
                .eq(DsChatMessage::getIsRead, 0);
        if (orderId != null) {
            updateWrapper.eq(DsChatMessage::getOrderId, orderId);
        } else {
            updateWrapper.isNull(DsChatMessage::getOrderId);
        }
        updateWrapper.set(DsChatMessage::getIsRead, 1);
        messageMapper.update(null, updateWrapper);

        return list;
    }

    @Override
    public List<Map<String, Object>> getConversations() {
        return messageMapper.selectConversationList();
    }

    @Override
    public List<DsChatMessage> getAdminMessages(Long userId, Long orderId) {
        LambdaQueryWrapper<DsChatMessage> wrapper = new LambdaQueryWrapper<DsChatMessage>()
                .eq(DsChatMessage::getUserId, userId);
        if (orderId != null) {
            wrapper.eq(DsChatMessage::getOrderId, orderId);
        } else {
            wrapper.isNull(DsChatMessage::getOrderId);
        }
        wrapper.orderByAsc(DsChatMessage::getCreateTime);
        return messageMapper.selectList(wrapper);
    }

    @Override
    public void markAsRead(Long userId, Long orderId) {
        LambdaUpdateWrapper<DsChatMessage> wrapper = new LambdaUpdateWrapper<DsChatMessage>()
                .eq(DsChatMessage::getUserId, userId)
                .eq(DsChatMessage::getSenderType, 0)
                .eq(DsChatMessage::getIsRead, 0);
        if (orderId != null) {
            wrapper.eq(DsChatMessage::getOrderId, orderId);
        } else {
            wrapper.isNull(DsChatMessage::getOrderId);
        }
        wrapper.set(DsChatMessage::getIsRead, 1);
        messageMapper.update(null, wrapper);
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
                                     String content, int contentType, Long orderId) {
        DsChatMessage msg = new DsChatMessage();
        msg.setUserId(chatUserId);
        msg.setOrderId(orderId);
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

    @Override
    public List<DsChatMessage> getRecentMessages(Long chatUserId, int limit) {
        LambdaQueryWrapper<DsChatMessage> wrapper = new LambdaQueryWrapper<DsChatMessage>()
                .eq(DsChatMessage::getUserId, chatUserId)
                .orderByDesc(DsChatMessage::getCreateTime)
                .last("LIMIT " + limit);
        List<DsChatMessage> list = messageMapper.selectList(wrapper);
        // 反转，按时间正序
        java.util.Collections.reverse(list);
        return list;
    }
}
