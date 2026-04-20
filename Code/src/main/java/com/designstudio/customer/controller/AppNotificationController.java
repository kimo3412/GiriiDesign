package com.designstudio.customer.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.designstudio.common.domain.Notification;
import com.designstudio.common.result.R;
import com.designstudio.common.security.LoginHelper;
import com.designstudio.common.service.NotificationService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/app/notifications")
@RequiredArgsConstructor
@Tag(name = "C端通知中心")
public class AppNotificationController {

    private final NotificationService notificationService;

    @GetMapping
    @Operation(summary = "分页获取我的通知列表")
    public R<Page<Notification>> list(
            @RequestParam(defaultValue = "1") int pageNum,
            @RequestParam(defaultValue = "20") int pageSize) {
        Long userId = LoginHelper.getUserId();
        if (userId == null) return R.fail("未登录");
        return R.ok(notificationService.getUserNotifications(userId, pageNum, pageSize));
    }

    @GetMapping("/unread-count")
    @Operation(summary = "获取未读通知数量")
    public R<Long> unreadCount() {
        Long userId = LoginHelper.getUserId();
        if (userId == null) return R.fail("未登录");
        return R.ok(notificationService.getUnreadCount(userId));
    }

    @PutMapping("/{id}/read")
    @Operation(summary = "标记单条通知为已读")
    public R<Void> markRead(@PathVariable Long id) {
        Long userId = LoginHelper.getUserId();
        if (userId == null) return R.fail("未登录");
        notificationService.markAsRead(userId, id);
        return R.ok();
    }

    @PutMapping("/read-all")
    @Operation(summary = "全部标记为已读")
    public R<Void> markAllRead() {
        Long userId = LoginHelper.getUserId();
        if (userId == null) return R.fail("未登录");
        notificationService.markAllAsRead(userId);
        return R.ok();
    }
}
