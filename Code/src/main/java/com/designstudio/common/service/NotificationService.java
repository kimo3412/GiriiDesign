package com.designstudio.common.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.designstudio.common.domain.Notification;

import java.util.List;

/**
 * 站内通知 Service 接口
 */
public interface NotificationService {

    /**
     * C端：分页获取我的通知列表
     */
    Page<Notification> getUserNotifications(Long userId, int pageNum, int pageSize);

    /**
     * C端：获取未读数
     */
    long getUnreadCount(Long userId);

    /**
     * C端：标记单条已读
     */
    void markAsRead(Long userId, Long notificationId);

    /**
     * C端：全部已读
     */
    void markAllAsRead(Long userId);

    /**
     * 发送通知（内部各Service调用）
     */
    void sendToUser(Long userId, String title, String content, String type, Long relatedId, String relatedType);

    /**
     * B端：后台发送通知
     */
    void sendNotification(Long userId, String title, String content, String type, Long relatedId, String relatedType);
}
