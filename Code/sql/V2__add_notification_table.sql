-- ----------------------------
-- Table structure for ds_notification
-- ----------------------------
DROP TABLE IF EXISTS `ds_notification`;
CREATE TABLE `ds_notification` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `user_id` bigint NOT NULL COMMENT '接收用户ID',
  `title` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '通知标题',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '通知内容',
  `type` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '通知类型: order_status/payment/workbench/system',
  `related_id` bigint NULL COMMENT '关联ID（如订单ID）',
  `related_type` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '关联类型: order/request',
  `is_read` tinyint(1) NULL DEFAULT 0 COMMENT '是否已读 (0=未读, 1=已读)',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `del_flag` tinyint(1) NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_user_read`(`user_id` ASC, `is_read` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '站内通知表' ROW_FORMAT = Dynamic;
