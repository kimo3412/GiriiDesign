package com.designstudio.chat.controller;

import com.designstudio.chat.domain.DsChatMessage;
import com.designstudio.chat.service.ChatService;
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

    private final ChatService chatService;

    @GetMapping("/api/v1/app/chat")
    @Operation(summary = "C端-获取我的聊天记录")
    public R<List<DsChatMessage>> getClientMessages(
            @RequestParam(required = false) Long orderId) {
        Long userId = LoginHelper.getUserId();
        if (userId == null) return R.fail("未登录");
        return R.ok(chatService.getClientMessages(userId, orderId));
    }

    @GetMapping("/api/v1/admin/chat/conversations")
    @Operation(summary = "B端-获取所有会话列表（含未读数，按订单分组）")
    public R<List<Map<String, Object>>> getConversations() {
        return R.ok(chatService.getConversations());
    }

    @GetMapping("/api/v1/admin/chat/{userId}")
    @Operation(summary = "B端-获取某客户的聊天记录")
    public R<List<DsChatMessage>> getAdminMessages(
            @PathVariable Long userId,
            @RequestParam(required = false) Long orderId) {
        return R.ok(chatService.getAdminMessages(userId, orderId));
    }

    @PutMapping("/api/v1/admin/chat/{userId}/read")
    @Operation(summary = "B端-标记某客户的消息为已读")
    public R<Void> markAsRead(
            @PathVariable Long userId,
            @RequestParam(required = false) Long orderId) {
        chatService.markAsRead(userId, orderId);
        return R.ok();
    }

    @GetMapping("/api/v1/admin/chat/user-summary/{userId}")
    @Operation(summary = "B端-获取聊天客户的全景意向/订单一览")
    public R<Map<String, Object>> getChatUserSummary(@PathVariable Long userId) {
        return R.ok(chatService.getChatUserSummary(userId));
    }
}
