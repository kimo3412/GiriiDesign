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

import java.util.List;
import java.util.Map;

/**
 * 聊天消息 REST API（历史消息查询 + 已读标记）
 */
@RestController
@RequiredArgsConstructor
@Tag(name = "聊天消息")
public class ChatController {

    private final DsChatMessageMapper messageMapper;

    // ============================
    // C 端接口
    // ============================

    @GetMapping("/api/v1/app/chat/{orderId}")
    @Operation(summary = "C端-获取某订单的聊天记录")
    public R<List<DsChatMessage>> getClientMessages(@PathVariable Long orderId) {
        Long userId = LoginHelper.getUserId();
        if (userId == null) return R.fail("未登录");

        List<DsChatMessage> list = messageMapper.selectList(
                new LambdaQueryWrapper<DsChatMessage>()
                        .eq(DsChatMessage::getOrderId, orderId)
                        .orderByAsc(DsChatMessage::getCreateTime)
        );

        // 标记管理员发给客户的消息为已读
        messageMapper.update(null, new LambdaUpdateWrapper<DsChatMessage>()
                .eq(DsChatMessage::getOrderId, orderId)
                .eq(DsChatMessage::getSenderType, "admin")
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

    @GetMapping("/api/v1/admin/chat/{orderId}")
    @Operation(summary = "B端-获取某订单的聊天记录")
    public R<List<DsChatMessage>> getAdminMessages(@PathVariable Long orderId) {
        List<DsChatMessage> list = messageMapper.selectList(
                new LambdaQueryWrapper<DsChatMessage>()
                        .eq(DsChatMessage::getOrderId, orderId)
                        .orderByAsc(DsChatMessage::getCreateTime)
        );
        return R.ok(list);
    }

    @PutMapping("/api/v1/admin/chat/{orderId}/read")
    @Operation(summary = "B端-标记某订单的客户消息为已读")
    public R<Void> markAsRead(@PathVariable Long orderId) {
        messageMapper.update(null, new LambdaUpdateWrapper<DsChatMessage>()
                .eq(DsChatMessage::getOrderId, orderId)
                .eq(DsChatMessage::getSenderType, "client")
                .eq(DsChatMessage::getIsRead, 0)
                .set(DsChatMessage::getIsRead, 1));
        return R.ok();
    }
}
