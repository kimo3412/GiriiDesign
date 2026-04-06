package com.designstudio.chat.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.designstudio.chat.domain.DsChatMessage;
import com.designstudio.chat.mapper.DsChatMessageMapper;
import com.designstudio.common.result.R;
import com.designstudio.common.security.LoginHelper;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import com.designstudio.order.domain.DsOrder;
import com.designstudio.order.domain.DsOrderRequest;
import com.designstudio.order.mapper.DsOrderMapper;
import com.designstudio.order.mapper.DsOrderRequestMapper;

/**
 * 聊天消息 REST API（历史消息查询 + 已读标记）
 */
@RestController
@RequiredArgsConstructor
@Tag(name = "聊天消息")
public class ChatController {

    private final DsChatMessageMapper messageMapper;
    private final DsOrderMapper orderMapper;
    private final DsOrderRequestMapper requestMapper;

    // ============================
    // C 端接口
    // ============================

    @GetMapping("/api/v1/app/chat")
    @Operation(summary = "C端-获取我的聊天记录")
    public R<List<DsChatMessage>> getClientMessages() {
        Long userId = LoginHelper.getUserId();
        if (userId == null) return R.fail("未登录");

        List<DsChatMessage> list = messageMapper.selectList(
                new LambdaQueryWrapper<DsChatMessage>()
                        .eq(DsChatMessage::getUserId, userId)
                        .orderByAsc(DsChatMessage::getCreateTime)
        );

        // 标记管理员发给客户的消息为已读
        messageMapper.update(null, new LambdaUpdateWrapper<DsChatMessage>()
                .eq(DsChatMessage::getUserId, userId)
                .eq(DsChatMessage::getSenderType, 1)
                .eq(DsChatMessage::getIsRead, 0)
                .set(DsChatMessage::getIsRead, 1));

        return R.ok(list);
    }

    // ============================
    // B 端接口
    // ============================

    @GetMapping("/api/v1/admin/chat/conversations")
    @Operation(summary = "B端-获取所有会话列表（含未读数）")
    public R<List<Map<String, Object>>> getConversations() {
        return R.ok(messageMapper.selectConversationList());
    }

    @GetMapping("/api/v1/admin/chat/{userId}")
    @Operation(summary = "B端-获取某客户的聊天记录")
    public R<List<DsChatMessage>> getAdminMessages(@PathVariable Long userId) {
        List<DsChatMessage> list = messageMapper.selectList(
                new LambdaQueryWrapper<DsChatMessage>()
                        .eq(DsChatMessage::getUserId, userId)
                        .orderByAsc(DsChatMessage::getCreateTime)
        );
        return R.ok(list);
    }

    @PutMapping("/api/v1/admin/chat/{userId}/read")
    @Operation(summary = "B端-标记某客户的消息为已读")
    public R<Void> markAsRead(@PathVariable Long userId) {
        messageMapper.update(null, new LambdaUpdateWrapper<DsChatMessage>()
                .eq(DsChatMessage::getUserId, userId)
                .eq(DsChatMessage::getSenderType, 0)
                .eq(DsChatMessage::getIsRead, 0)
                .set(DsChatMessage::getIsRead, 1));
        return R.ok();
    }

    @GetMapping("/api/v1/admin/chat/user-summary/{userId}")
    @Operation(summary = "B端-获取聊天客户的全景意向/订单一览")
    public R<Map<String, Object>> getChatUserSummary(@PathVariable Long userId) {
        List<DsOrderRequest> requests = requestMapper.selectList(
                new LambdaQueryWrapper<DsOrderRequest>()
                        .eq(DsOrderRequest::getUserId, userId)
                        .orderByDesc(DsOrderRequest::getCreateTime)
        );
        List<DsOrder> orders = orderMapper.selectList(
                new LambdaQueryWrapper<DsOrder>()
                        .eq(DsOrder::getUserId, userId)
                        .orderByDesc(DsOrder::getCreateTime)
        );

        Map<String, Object> map = new HashMap<>();
        map.put("requests", requests);
        map.put("orders", orders);
        return R.ok(map);
    }
}
