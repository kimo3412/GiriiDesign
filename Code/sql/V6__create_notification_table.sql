-- =====================================================
-- V6: create notification table
-- Date: 2026-04-20
-- =====================================================

CREATE TABLE IF NOT EXISTS `ds_notification` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'Primary key',
  `user_id` bigint NOT NULL COMMENT 'Receiver user id',
  `title` varchar(100) NOT NULL COMMENT 'Notification title',
  `content` text COMMENT 'Notification content',
  `type` varchar(30) DEFAULT NULL COMMENT 'Notification type: order_status/payment/workbench/system',
  `related_id` bigint DEFAULT NULL COMMENT 'Related entity id, such as order id',
  `related_type` varchar(30) DEFAULT NULL COMMENT 'Related entity type: order/request',
  `is_read` tinyint(1) DEFAULT 0 COMMENT 'Read flag (0 unread, 1 read)',
  `create_by` bigint DEFAULT NULL COMMENT 'Created by',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT 'Created time',
  `update_by` bigint DEFAULT NULL COMMENT 'Updated by',
  `update_time` datetime DEFAULT NULL COMMENT 'Updated time',
  `del_flag` tinyint(1) DEFAULT 0 COMMENT 'Logical delete flag',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_notification_user_id` (`user_id`) USING BTREE,
  KEY `idx_notification_user_read` (`user_id`, `is_read`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='In-app notification table';
