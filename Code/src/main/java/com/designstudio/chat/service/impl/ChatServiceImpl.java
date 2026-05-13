package com.designstudio.chat.service.impl;

import cn.hutool.json.JSONObject;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.designstudio.chat.domain.DsChatMessage;
import com.designstudio.chat.mapper.DsChatMessageMapper;
import com.designstudio.chat.service.ChatService;
import com.designstudio.common.result.PageResult;
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

@Service
@RequiredArgsConstructor
public class ChatServiceImpl implements ChatService {

    private final DsChatMessageMapper messageMapper;
    private final DsOrderMapper orderMapper;
    private final DsOrderRequestMapper requestMapper;

    private static final int SENDER_TYPE_CLIENT = 0;
    private static final int SENDER_TYPE_ADMIN = 1;
    private static final int CONTENT_TYPE_ACTION_CARD = 4;
    private static final String HANDOFF_REQUEST = "handoff_request";
    private static final String HANDOFF_RESOLVED = "handoff_resolved";

    @Override
    public List<DsChatMessage> getClientMessages(Long userId, Long orderId) {
        LambdaQueryWrapper<DsChatMessage> wrapper = new LambdaQueryWrapper<DsChatMessage>()
                .eq(DsChatMessage::getUserId, userId);
        appendOrderFilter(wrapper, orderId);
        wrapper.orderByAsc(DsChatMessage::getCreateTime);
        List<DsChatMessage> list = messageMapper.selectList(wrapper);

        LambdaUpdateWrapper<DsChatMessage> updateWrapper = new LambdaUpdateWrapper<DsChatMessage>()
                .eq(DsChatMessage::getUserId, userId)
                .eq(DsChatMessage::getSenderType, SENDER_TYPE_ADMIN)
                .eq(DsChatMessage::getIsRead, 0);
        appendOrderFilter(updateWrapper, orderId);
        updateWrapper.set(DsChatMessage::getIsRead, 1);
        messageMapper.update(null, updateWrapper);

        return list;
    }

    @Override
    public List<Map<String, Object>> getConversations() {
        List<Map<String, Object>> conversations = messageMapper.selectConversationList();
        conversations.forEach(item -> {
            Long userId = toLong(item.get("userId"));
            Long orderId = toLong(item.get("orderId"));
            item.put("handoffActive", isHumanHandoffActive(userId, orderId));
        });
        return conversations;
    }

    @Override
    public PageResult<Map<String, Object>> getConversations(Long pageNum, Long pageSize) {
        long safePageNum = pageNum == null || pageNum < 1 ? 1L : pageNum;
        long safePageSize = pageSize == null || pageSize < 1 ? 12L : Math.min(pageSize, 50L);
        long total = messageMapper.countConversationList();
        long offset = (safePageNum - 1) * safePageSize;
        List<Map<String, Object>> conversations = messageMapper.selectConversationPage(offset, safePageSize);
        conversations.forEach(item -> {
            Long userId = toLong(item.get("userId"));
            Long orderId = toLong(item.get("orderId"));
            item.put("handoffActive", isHumanHandoffActive(userId, orderId));
        });
        return PageResult.of(conversations, total, safePageNum, safePageSize);
    }

    @Override
    public List<DsChatMessage> getAdminMessages(Long userId, Long orderId) {
        LambdaQueryWrapper<DsChatMessage> wrapper = new LambdaQueryWrapper<DsChatMessage>()
                .eq(DsChatMessage::getUserId, userId);
        appendOrderFilter(wrapper, orderId);
        wrapper.orderByAsc(DsChatMessage::getCreateTime);
        return messageMapper.selectList(wrapper);
    }

    @Override
    public void markAsRead(Long userId, Long orderId) {
        LambdaUpdateWrapper<DsChatMessage> wrapper = new LambdaUpdateWrapper<DsChatMessage>()
                .eq(DsChatMessage::getUserId, userId)
                .eq(DsChatMessage::getSenderType, SENDER_TYPE_CLIENT)
                .eq(DsChatMessage::getIsRead, 0);
        appendOrderFilter(wrapper, orderId);
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
        return saveMessage(chatUserId, senderType, senderId, content, contentType, orderId, null);
    }

    @Override
    public DsChatMessage saveMessage(Long chatUserId, int senderType, Long senderId,
                                     String content, int contentType, Long orderId, String extraJson) {
        DsChatMessage msg = new DsChatMessage();
        msg.setUserId(chatUserId);
        msg.setOrderId(orderId);
        msg.setSenderType(senderType);
        msg.setSenderId(senderId);
        msg.setContent(content);
        msg.setContentType(contentType);
        msg.setExtraJson(extraJson);
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
        java.util.Collections.reverse(list);
        return list;
    }

    @Override
    public boolean isHumanHandoffActive(Long chatUserId, Long orderId) {
        if (chatUserId == null) {
            return false;
        }
        DsChatMessage latestRequest = findLatestStructuredMessage(chatUserId, orderId, SENDER_TYPE_CLIENT, HANDOFF_REQUEST);
        if (latestRequest == null) {
            return false;
        }
        DsChatMessage latestResolved = findLatestStructuredMessage(chatUserId, orderId, null, HANDOFF_RESOLVED);
        return latestResolved == null || latestResolved.getCreateTime().isBefore(latestRequest.getCreateTime());
    }

    @Override
    public DsChatMessage resolveHumanHandoff(Long chatUserId, Long orderId, Long adminId) {
        String content = "人工服务已处理，AI客服已恢复自动接待。";
        JSONObject extra = new JSONObject();
        extra.set("cardType", HANDOFF_RESOLVED);
        extra.set("title", "AI客服已恢复");
        extra.set("description", content);
        extra.set("orderId", orderId);
        return saveMessage(chatUserId, SENDER_TYPE_ADMIN, adminId, content, CONTENT_TYPE_ACTION_CARD, orderId, extra.toString());
    }

    private DsChatMessage findLatestStructuredMessage(Long chatUserId, Long orderId, Integer senderType, String cardType) {
        LambdaQueryWrapper<DsChatMessage> wrapper = new LambdaQueryWrapper<DsChatMessage>()
                .eq(DsChatMessage::getUserId, chatUserId)
                .eq(DsChatMessage::getContentType, CONTENT_TYPE_ACTION_CARD)
                .like(DsChatMessage::getExtraJson, "\"" + cardType + "\"");
        if (senderType != null) {
            wrapper.eq(DsChatMessage::getSenderType, senderType);
        }
        appendOrderFilter(wrapper, orderId);
        wrapper.orderByDesc(DsChatMessage::getCreateTime).last("LIMIT 1");
        return messageMapper.selectOne(wrapper);
    }

    private void appendOrderFilter(LambdaQueryWrapper<DsChatMessage> wrapper, Long orderId) {
        if (orderId != null) {
            wrapper.eq(DsChatMessage::getOrderId, orderId);
        } else {
            wrapper.isNull(DsChatMessage::getOrderId);
        }
    }

    private void appendOrderFilter(LambdaUpdateWrapper<DsChatMessage> wrapper, Long orderId) {
        if (orderId != null) {
            wrapper.eq(DsChatMessage::getOrderId, orderId);
        } else {
            wrapper.isNull(DsChatMessage::getOrderId);
        }
    }

    private Long toLong(Object value) {
        if (value == null) {
            return null;
        }
        if (value instanceof Number number) {
            return number.longValue();
        }
        try {
            return Long.parseLong(String.valueOf(value));
        } catch (NumberFormatException e) {
            return null;
        }
    }
}
