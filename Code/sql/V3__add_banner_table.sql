-- =====================================================
-- V3: 添加轮播图表 ds_banner
-- 日期: 2026-04-14
-- =====================================================

-- 轮播图表
CREATE TABLE IF NOT EXISTS `ds_banner` (
  `banner_id` bigint NOT NULL AUTO_INCREMENT COMMENT '轮播图ID',
  `title` varchar(100) NOT NULL COMMENT '轮播图标题',
  `image_url` varchar(500) NOT NULL COMMENT '图片地址',
  `link_url` varchar(500) DEFAULT NULL COMMENT '跳转链接（可选）',
  `link_type` varchar(20) DEFAULT NULL COMMENT '跳转类型：portfolio/order/custom/null',
  `sort_order` int DEFAULT 0 COMMENT '排序（越大越靠前）',
  `status` tinyint(1) DEFAULT 1 COMMENT '状态：0禁用 1启用',
  `create_by` bigint DEFAULT NULL,
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_by` bigint DEFAULT NULL,
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `del_flag` tinyint(1) DEFAULT 0,
  PRIMARY KEY (`banner_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='小程序首页轮播图';

-- 初始化 Banner 数据
INSERT INTO ds_banner (title, image_url, link_url, link_type, sort_order, status) VALUES
('示例轮播图1', '/uploads/banners/banner1.jpg', NULL, NULL, 1, 1),
('示例轮播图2', '/uploads/banners/banner2.jpg', NULL, NULL, 2, 1);
