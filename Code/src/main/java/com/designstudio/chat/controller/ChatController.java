package com.designstudio.chat.controller;

import cn.hutool.json.JSONObject;
import com.designstudio.chat.domain.DsChatMessage;
import com.designstudio.chat.service.ChatService;
import com.designstudio.chat.websocket.SessionManager;
import com.designstudio.common.result.R;
import com.designstudio.common.security.LoginHelper;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Map;

/**
 * Chat history, read-state and handoff APIs.
 */
@RestController
@RequiredArgsConstructor
@Tag(name = "聊天消息")
public class ChatController {

    private final ChatService chatService;
    private final SessionManager sessionManager;

    private static final DateTimeFormatter FMT = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");

    @GetMapping("/api/v1/app/chat")
    @Operation(summary = "C端获取我的聊天记录")
    public R<List<DsChatMessage>> getClientMessages(@RequestParam(required = false) Long orderId) {
        Long userId = LoginHelper.getUserId();
        if (userId == null) return R.fail("未登录");
        return R.ok(chatService.getClientMessages(userId, orderId));
    }

    @PostMapping("/api/v1/app/chat/handoff")
    @Operation(summary = "C端请求转人工客服")
    public R<DsChatMessage> requestHandoff(@RequestBody(required = false) HandoffDTO dto) {
        Long userId = LoginHelper.getUserId();
        if (userId == null) return R.fail("未登录");
        Long orderId = dto == null ? null : dto.getOrderId();

        String content = "用户请求转人工客服，请尽快接入处理。";
        JSONObject extra = new JSONObject();
        extra.set("cardType", "handoff_request");
        extra.set("title", "转人工请求");
        extra.set("description", content);
        extra.set("orderId", orderId);

        DsChatMessage msg = chatService.saveMessage(userId, 0, userId, content, 4, orderId, extra.toString());

        JSONObject push = new JSONObject();
        push.set("type", "NEW_MSG");
        push.set("msgId", msg.getMsgId());
        push.set("messageId", msg.getMsgId());
        push.set("userId", userId);
        push.set("orderId", orderId);
        push.set("senderType", "client");
        push.set("senderId", userId);
        push.set("content", content);
        push.set("msgType", "handoff_request");
        push.set("contentType", 4);
        push.set("extraJson", extra);
        push.set("createTime", msg.getCreateTime().format(FMT));
        sessionManager.broadcastToAdmins(push.toString());

        return R.ok(msg);
    }

    @GetMapping("/api/v1/admin/chat/conversations")
    @Operation(summary = "B端获取所有会话列表")
    public R<List<Map<String, Object>>> getConversations() {
        return R.ok(chatService.getConversations());
    }

    @GetMapping("/api/v1/admin/chat/{userId}")
    @Operation(summary = "B端获取某客户聊天记录")
    public R<List<DsChatMessage>> getAdminMessages(
            @PathVariable Long userId,
            @RequestParam(required = false) Long orderId) {
        return R.ok(chatService.getAdminMessages(userId, orderId));
    }

    @PutMapping("/api/v1/admin/chat/{userId}/read")
    @Operation(summary = "B端标记某客户消息为已读")
    public R<Void> markAsRead(
            @PathVariable Long userId,
            @RequestParam(required = false) Long orderId) {
        chatService.markAsRead(userId, orderId);
        return R.ok();
    }

    @PutMapping("/api/v1/admin/chat/{userId}/handoff/resolve")
    @Operation(summary = "B端恢复AI客服自动接待")
    public R<DsChatMessage> resolveHandoff(
            @PathVariable Long userId,
            @RequestParam(required = false) Long orderId) {
        Long adminId = LoginHelper.getUserId();
        DsChatMessage msg = chatService.resolveHumanHandoff(userId, orderId, adminId);

        JSONObject extra = new JSONObject();
        extra.set("cardType", "handoff_resolved");
        extra.set("title", "AI客服已恢复");
        extra.set("description", msg.getContent());

        JSONObject push = new JSONObject();
        push.set("type", "NEW_MSG");
        push.set("msgId", msg.getMsgId());
        push.set("messageId", msg.getMsgId());
        push.set("userId", userId);
        push.set("orderId", orderId);
        push.set("senderType", "admin");
        push.set("senderId", adminId);
        push.set("content", msg.getContent());
        push.set("msgType", "handoff_resolved");
        push.set("contentType", 4);
        push.set("extraJson", extra);
        push.set("createTime", msg.getCreateTime().format(FMT));
        sessionManager.sendTo(sessionManager.buildKey("client", userId), push.toString());
        sessionManager.broadcastToAdmins(push.toString());

        return R.ok(msg);
    }

    @GetMapping("/api/v1/admin/chat/user-summary/{userId}")
    @Operation(summary = "B端获取聊天客户的全景意向和订单摘要")
    public R<Map<String, Object>> getChatUserSummary(@PathVariable Long userId) {
        return R.ok(chatService.getChatUserSummary(userId));
    }

    @Data
    public static class HandoffDTO {
        private Long orderId;
    }
}
