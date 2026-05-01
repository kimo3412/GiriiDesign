/*
 Navicat Premium Dump SQL

 Source Server         : localhost
 Source Server Type    : MySQL
 Source Server Version : 80408 (8.4.8)
 Source Host           : localhost:3306
 Source Schema         : design_studio

 Target Server Type    : MySQL
 Target Server Version : 80408 (8.4.8)
 File Encoding         : 65001

 Date: 01/05/2026 13:40:49
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for ds_address
-- ----------------------------
DROP TABLE IF EXISTS `ds_address`;
CREATE TABLE `ds_address`  (
  `address_id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL COMMENT '所属用户',
  `receiver_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '收货人',
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '联系电话',
  `province` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '省',
  `city` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '市',
  `district` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '区',
  `detail_address` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '详细地址',
  `is_default` tinyint(1) NULL DEFAULT 0 COMMENT '是否默认',
  `create_by` bigint NULL DEFAULT NULL,
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `update_by` bigint NULL DEFAULT NULL,
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `del_flag` tinyint(1) NULL DEFAULT 0,
  PRIMARY KEY (`address_id`) USING BTREE,
  INDEX `idx_user`(`user_id` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '客户地址表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of ds_address
-- ----------------------------

-- ----------------------------
-- Table structure for ds_ai_config
-- ----------------------------
DROP TABLE IF EXISTS `ds_ai_config`;
CREATE TABLE `ds_ai_config`  (
  `config_id` bigint NOT NULL AUTO_INCREMENT COMMENT 'Primary key',
  `provider_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'Provider name',
  `enabled` tinyint(1) NULL DEFAULT 0 COMMENT 'Enabled flag',
  `api_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'OpenAI compatible endpoint',
  `api_key` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'API key',
  `model` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'Model name',
  `system_prompt` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT 'System prompt',
  `create_by` bigint NULL DEFAULT NULL COMMENT 'Created by',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Created time',
  `update_by` bigint NULL DEFAULT NULL COMMENT 'Updated by',
  `update_time` datetime NULL DEFAULT NULL COMMENT 'Updated time',
  `del_flag` tinyint(1) NULL DEFAULT 0 COMMENT 'Logical delete flag',
  PRIMARY KEY (`config_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'AI customer service config' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of ds_ai_config
-- ----------------------------

-- ----------------------------
-- Table structure for ds_banner
-- ----------------------------
DROP TABLE IF EXISTS `ds_banner`;
CREATE TABLE `ds_banner`  (
  `banner_id` bigint NOT NULL AUTO_INCREMENT COMMENT '轮播图ID',
  `title` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '轮播图标题',
  `image_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '图片地址',
  `link_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '跳转链接（可选）',
  `link_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '跳转类型：portfolio/order/custom/null',
  `sort_order` int NULL DEFAULT 0 COMMENT '排序（越大越靠前）',
  `status` tinyint(1) NULL DEFAULT 1 COMMENT '状态：0禁用 1启用',
  `create_by` bigint NULL DEFAULT NULL,
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `update_by` bigint NULL DEFAULT NULL,
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `del_flag` tinyint(1) NULL DEFAULT 0,
  PRIMARY KEY (`banner_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '小程序首页轮播图' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of ds_banner
-- ----------------------------
INSERT INTO `ds_banner` VALUES (1, '示例轮播图1', '/uploads/banners/banner1.jpg', NULL, NULL, 1, 1, NULL, '2026-04-14 22:09:31', NULL, '2026-04-14 22:09:31', 0);
INSERT INTO `ds_banner` VALUES (2, '示例轮播图2', '/uploads/banners/banner2.jpg', NULL, NULL, 2, 1, NULL, '2026-04-14 22:09:31', NULL, '2026-04-14 22:09:31', 0);

-- ----------------------------
-- Table structure for ds_bill_record
-- ----------------------------
DROP TABLE IF EXISTS `ds_bill_record`;
CREATE TABLE `ds_bill_record`  (
  `bill_id` bigint NOT NULL AUTO_INCREMENT,
  `bill_date` date NOT NULL COMMENT '账单日期',
  `wx_transaction_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '微信交易号',
  `local_payment_no` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '本地流水号',
  `wx_amount` decimal(10, 2) NULL DEFAULT NULL COMMENT '微信账单金额',
  `local_amount` decimal(10, 2) NULL DEFAULT NULL COMMENT '本地记录金额',
  `match_status` tinyint(1) NULL DEFAULT NULL COMMENT '0=匹配,1=金额不符,2=本地缺失,3=微信缺失',
  `handle_status` tinyint(1) NULL DEFAULT 0 COMMENT '0=待处理,1=已处理',
  `handle_remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '处理备注',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`bill_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '对账记录表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of ds_bill_record
-- ----------------------------

-- ----------------------------
-- Table structure for ds_bom_item
-- ----------------------------
DROP TABLE IF EXISTS `ds_bom_item`;
CREATE TABLE `ds_bom_item`  (
  `bom_item_id` bigint NOT NULL AUTO_INCREMENT,
  `order_id` bigint NOT NULL COMMENT '所属订单',
  `material_id` bigint NOT NULL COMMENT '物料ID',
  `quantity` decimal(10, 2) NOT NULL COMMENT '实际用量',
  `material_snapshot` json NULL COMMENT '物料快照(名称、单价)',
  `is_allocated` tinyint(1) NULL DEFAULT 0 COMMENT '是否已出库',
  `del_flag` tinyint(1) NULL DEFAULT 0,
  PRIMARY KEY (`bom_item_id`) USING BTREE,
  INDEX `idx_order`(`order_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 11 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '订单BOM清单表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of ds_bom_item
-- ----------------------------
INSERT INTO `ds_bom_item` VALUES (1, 7, 1, 3.50, '{\"sku\": \"FAB-LINEN-001\", \"name\": \"高级亚麻面料（浅米色）\", \"unit\": \"米\", \"unitPrice\": 120.0}', 0, 0);
INSERT INTO `ds_bom_item` VALUES (2, 7, 6, 2.00, '{\"sku\": \"FAB-COTTON-001\", \"name\": \"纯棉衬里（白色）\", \"unit\": \"米\", \"unitPrice\": 35.0}', 0, 0);
INSERT INTO `ds_bom_item` VALUES (3, 7, 5, 1.00, '{\"sku\": \"ACC-ZIP-001\", \"name\": \"YKK拉链（20cm）\", \"unit\": \"条\", \"unitPrice\": 8.5}', 0, 0);
INSERT INTO `ds_bom_item` VALUES (4, 7, 9, 2.00, '{\"sku\": \"HW-SNAP-001\", \"name\": \"暗扣\", \"unit\": \"套\", \"unitPrice\": 3.0}', 0, 0);
INSERT INTO `ds_bom_item` VALUES (5, 7, 10, 1.00, '{\"sku\": \"PKG-BOX-001\", \"name\": \"包装盒（大号）\", \"unit\": \"个\", \"unitPrice\": 15.0}', 0, 0);
INSERT INTO `ds_bom_item` VALUES (6, 8, 1, 3.50, '{\"sku\": \"FAB-LINEN-001\", \"name\": \"高级亚麻面料（浅米色）\", \"unit\": \"米\", \"unitPrice\": 120.0}', 1, 0);
INSERT INTO `ds_bom_item` VALUES (7, 8, 6, 2.00, '{\"sku\": \"FAB-COTTON-001\", \"name\": \"纯棉衬里（白色）\", \"unit\": \"米\", \"unitPrice\": 35.0}', 1, 0);
INSERT INTO `ds_bom_item` VALUES (8, 8, 5, 1.00, '{\"sku\": \"ACC-ZIP-001\", \"name\": \"YKK拉链（20cm）\", \"unit\": \"条\", \"unitPrice\": 8.5}', 1, 0);
INSERT INTO `ds_bom_item` VALUES (9, 8, 9, 2.00, '{\"sku\": \"HW-SNAP-001\", \"name\": \"暗扣\", \"unit\": \"套\", \"unitPrice\": 3.0}', 1, 0);
INSERT INTO `ds_bom_item` VALUES (10, 8, 10, 1.00, '{\"sku\": \"PKG-BOX-001\", \"name\": \"包装盒（大号）\", \"unit\": \"个\", \"unitPrice\": 15.0}', 1, 0);

-- ----------------------------
-- Table structure for ds_bom_template
-- ----------------------------
DROP TABLE IF EXISTS `ds_bom_template`;
CREATE TABLE `ds_bom_template`  (
  `template_id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '模板名称',
  `category_id` bigint NULL DEFAULT NULL COMMENT '关联品类',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `create_by` bigint NULL DEFAULT NULL,
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `update_by` bigint NULL DEFAULT NULL,
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `del_flag` tinyint(1) NULL DEFAULT 0,
  PRIMARY KEY (`template_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'BOM模板表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of ds_bom_template
-- ----------------------------
INSERT INTO `ds_bom_template` VALUES (1, '旗袍标准BOM', 1, '旗袍类服装的标准物料清单', NULL, '2026-03-17 15:11:05', NULL, '2026-03-17 15:11:05', 0);
INSERT INTO `ds_bom_template` VALUES (2, '手工钱包BOM', 2, '小型皮具钱包的标准物料清单', NULL, '2026-03-17 15:11:05', NULL, '2026-03-17 15:11:05', 0);

-- ----------------------------
-- Table structure for ds_bom_template_item
-- ----------------------------
DROP TABLE IF EXISTS `ds_bom_template_item`;
CREATE TABLE `ds_bom_template_item`  (
  `item_id` bigint NOT NULL AUTO_INCREMENT,
  `template_id` bigint NOT NULL COMMENT '所属模板',
  `material_id` bigint NOT NULL COMMENT '物料ID',
  `quantity` decimal(10, 2) NOT NULL COMMENT '所需数量',
  `del_flag` tinyint(1) NULL DEFAULT 0,
  PRIMARY KEY (`item_id`) USING BTREE,
  INDEX `idx_template`(`template_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 11 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'BOM模板明细表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of ds_bom_template_item
-- ----------------------------
INSERT INTO `ds_bom_template_item` VALUES (1, 1, 1, 3.50, 0);
INSERT INTO `ds_bom_template_item` VALUES (2, 1, 6, 2.00, 0);
INSERT INTO `ds_bom_template_item` VALUES (3, 1, 5, 1.00, 0);
INSERT INTO `ds_bom_template_item` VALUES (4, 1, 9, 2.00, 0);
INSERT INTO `ds_bom_template_item` VALUES (5, 1, 10, 1.00, 0);
INSERT INTO `ds_bom_template_item` VALUES (6, 2, 3, 0.50, 0);
INSERT INTO `ds_bom_template_item` VALUES (7, 2, 8, 1.00, 0);
INSERT INTO `ds_bom_template_item` VALUES (8, 2, 7, 4.00, 0);
INSERT INTO `ds_bom_template_item` VALUES (9, 2, 9, 1.00, 0);
INSERT INTO `ds_bom_template_item` VALUES (10, 2, 10, 1.00, 0);

-- ----------------------------
-- Table structure for ds_category
-- ----------------------------
DROP TABLE IF EXISTS `ds_category`;
CREATE TABLE `ds_category`  (
  `category_id` bigint NOT NULL AUTO_INCREMENT COMMENT '品类ID',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '品类名称',
  `icon_url` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '图标URL',
  `is_active` tinyint(1) NULL DEFAULT 1 COMMENT '是否启用',
  `has_bom` tinyint(1) NULL DEFAULT 0 COMMENT '是否需要BOM',
  `is_physical` tinyint(1) NULL DEFAULT 1 COMMENT '是否实体产品',
  `sort_order` int NULL DEFAULT 0 COMMENT '排序',
  `create_by` bigint NULL DEFAULT NULL COMMENT '创建人',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_by` bigint NULL DEFAULT NULL COMMENT '更新人',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `del_flag` tinyint(1) NULL DEFAULT 0 COMMENT '逻辑删除',
  PRIMARY KEY (`category_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '品类表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of ds_category
-- ----------------------------
INSERT INTO `ds_category` VALUES (1, '服装定制', NULL, 1, 1, 1, 1, NULL, '2026-03-04 15:06:58', NULL, '2026-03-04 15:06:58', 0);
INSERT INTO `ds_category` VALUES (2, '手工皮具', NULL, 1, 1, 1, 2, NULL, '2026-03-04 15:06:58', NULL, '2026-03-04 15:06:58', 0);
INSERT INTO `ds_category` VALUES (3, '数字插画', NULL, 1, 0, 0, 3, NULL, '2026-03-04 15:06:58', NULL, '2026-03-04 15:06:58', 0);

-- ----------------------------
-- Table structure for ds_chat_message
-- ----------------------------
DROP TABLE IF EXISTS `ds_chat_message`;
CREATE TABLE `ds_chat_message`  (
  `msg_id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL COMMENT '所属客户',
  `sender_type` tinyint(1) NOT NULL COMMENT '0=客户,1=设计师',
  `sender_id` bigint NOT NULL COMMENT '发送方ID',
  `content_type` tinyint(1) NULL DEFAULT 0 COMMENT '0=文本,1=图片',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '消息内容',
  `is_read` tinyint(1) NULL DEFAULT 0 COMMENT '是否已读',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `del_flag` tinyint(1) NULL DEFAULT 0,
  `order_id` bigint NULL DEFAULT NULL COMMENT '关联订单ID',
  PRIMARY KEY (`msg_id`) USING BTREE,
  INDEX `idx_sender`(`sender_type` ASC, `sender_id` ASC) USING BTREE,
  INDEX `idx_user`(`user_id` ASC) USING BTREE,
  INDEX `idx_order`(`order_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 11 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '聊天记录表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of ds_chat_message
-- ----------------------------
INSERT INTO `ds_chat_message` VALUES (1, 1, 0, 1, 0, 'hallop', 1, '2026-04-06 15:09:44', 0, NULL);
INSERT INTO `ds_chat_message` VALUES (2, 1, 1, 2, 0, '1', 1, '2026-04-06 15:11:24', 0, NULL);
INSERT INTO `ds_chat_message` VALUES (3, 1, 0, 1, 0, '关注', 1, '2026-04-09 19:56:14', 0, NULL);
INSERT INTO `ds_chat_message` VALUES (4, 1, 0, 1, 0, '你好', 1, '2026-04-09 21:36:36', 0, NULL);
INSERT INTO `ds_chat_message` VALUES (5, 1, 1, 1, 0, '好', 1, '2026-04-09 21:36:43', 0, NULL);
INSERT INTO `ds_chat_message` VALUES (6, 1, 0, 1, 0, '订单6的咨询消息', 1, '2026-04-10 23:52:00', 0, 6);
INSERT INTO `ds_chat_message` VALUES (7, 1, 1, 2, 0, '好的，我来处理订单6', 0, '2026-04-10 23:52:00', 0, 6);
INSERT INTO `ds_chat_message` VALUES (8, 1, 0, 1, 0, '订单7有问题想问', 1, '2026-04-10 23:52:00', 0, 7);
INSERT INTO `ds_chat_message` VALUES (9, 1, 1, 1, 0, '订单6的最新进展如何？', 0, '2026-04-10 23:57:14', 0, 6);
INSERT INTO `ds_chat_message` VALUES (10, 1, 0, 1, 0, '123', 1, '2026-04-11 18:00:41', 0, NULL);

-- ----------------------------
-- Table structure for ds_custom_field
-- ----------------------------
DROP TABLE IF EXISTS `ds_custom_field`;
CREATE TABLE `ds_custom_field`  (
  `field_id` bigint NOT NULL AUTO_INCREMENT,
  `category_id` bigint NOT NULL COMMENT '所属品类',
  `label` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '字段显示名',
  `field_key` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '字段键名',
  `field_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '控件类型: text/number/select/date/image',
  `unit` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '单位',
  `options` json NULL COMMENT '选项列表(select用)',
  `placeholder` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '输入提示',
  `is_required` tinyint(1) NULL DEFAULT 0 COMMENT '是否必填',
  `sort_order` int NULL DEFAULT 0 COMMENT '排序',
  `create_by` bigint NULL DEFAULT NULL,
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `update_by` bigint NULL DEFAULT NULL,
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `del_flag` tinyint(1) NULL DEFAULT 0,
  PRIMARY KEY (`field_id`) USING BTREE,
  INDEX `idx_category`(`category_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 12 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '动态字段定义表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of ds_custom_field
-- ----------------------------
INSERT INTO `ds_custom_field` VALUES (1, 1, '胸围', 'chest', 'number', 'cm', NULL, '请输入胸围尺寸', 1, 1, NULL, '2026-03-04 15:06:58', NULL, '2026-03-04 15:06:58', 0);
INSERT INTO `ds_custom_field` VALUES (2, 1, '腰围', 'waist', 'number', 'cm', NULL, '请输入腰围尺寸', 1, 2, NULL, '2026-03-04 15:06:58', NULL, '2026-03-04 15:06:58', 0);
INSERT INTO `ds_custom_field` VALUES (3, 1, '肩宽', 'shoulder', 'number', 'cm', NULL, '请输入肩宽尺寸', 1, 3, NULL, '2026-03-04 15:06:58', NULL, '2026-03-04 15:06:58', 0);
INSERT INTO `ds_custom_field` VALUES (4, 1, '衣长', 'length', 'number', 'cm', NULL, '请输入衣长', 0, 4, NULL, '2026-03-04 15:06:58', NULL, '2026-03-04 15:06:58', 0);
INSERT INTO `ds_custom_field` VALUES (5, 1, '面料偏好', 'fabric_type', 'select', NULL, '[\"纯棉\", \"亚麻\", \"丝绸\", \"羊毛\", \"混纺\"]', '请选择面料', 0, 5, NULL, '2026-03-04 15:06:58', NULL, '2026-03-04 15:06:58', 0);
INSERT INTO `ds_custom_field` VALUES (6, 2, '皮革类型', 'leather_type', 'select', NULL, '[\"牛皮\", \"羊皮\", \"鳄鱼皮\", \"植鞣革\"]', '请选择皮革', 1, 1, NULL, '2026-03-04 15:06:58', NULL, '2026-03-04 15:06:58', 0);
INSERT INTO `ds_custom_field` VALUES (7, 2, '颜色', 'color', 'text', NULL, NULL, '期望的颜色', 1, 2, NULL, '2026-03-04 15:06:58', NULL, '2026-03-04 15:06:58', 0);
INSERT INTO `ds_custom_field` VALUES (8, 2, '尺寸规格', 'size_spec', 'text', NULL, NULL, '如：长20cm×宽15cm', 0, 3, NULL, '2026-03-04 15:06:58', NULL, '2026-03-04 15:06:58', 0);
INSERT INTO `ds_custom_field` VALUES (9, 3, '画风', 'art_style', 'select', NULL, '[\"日系\", \"欧美\", \"水彩风\", \"扁平化\", \"写实\"]', '请选择画风', 1, 1, NULL, '2026-03-04 15:06:58', NULL, '2026-03-04 15:06:58', 0);
INSERT INTO `ds_custom_field` VALUES (10, 3, '分辨率', 'resolution', 'select', NULL, '[\"1080×1080\", \"1920×1080\", \"3000×3000\", \"自定义\"]', '请选择分辨率', 0, 2, NULL, '2026-03-04 15:06:58', NULL, '2026-03-04 15:06:58', 0);
INSERT INTO `ds_custom_field` VALUES (11, 3, '用途', 'usage', 'text', NULL, NULL, '如：头像、海报、插图等', 0, 3, NULL, '2026-03-04 15:06:58', NULL, '2026-03-04 15:06:58', 0);

-- ----------------------------
-- Table structure for ds_designer_category
-- ----------------------------
DROP TABLE IF EXISTS `ds_designer_category`;
CREATE TABLE `ds_designer_category`  (
  `admin_id` bigint NOT NULL COMMENT '设计师ID',
  `category_id` bigint NOT NULL COMMENT '品类ID',
  PRIMARY KEY (`admin_id`, `category_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '设计师-品类关联表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of ds_designer_category
-- ----------------------------
INSERT INTO `ds_designer_category` VALUES (2, 1);
INSERT INTO `ds_designer_category` VALUES (2, 2);
INSERT INTO `ds_designer_category` VALUES (3, 2);
INSERT INTO `ds_designer_category` VALUES (3, 3);

-- ----------------------------
-- Table structure for ds_material
-- ----------------------------
DROP TABLE IF EXISTS `ds_material`;
CREATE TABLE `ds_material`  (
  `material_id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '物料名称',
  `sku` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '物料编码',
  `category` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '物料分类(面料/辅料/五金)',
  `unit` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '单位(米/个/kg)',
  `unit_price` decimal(10, 2) NULL DEFAULT NULL COMMENT '单价',
  `stock` decimal(10, 2) NULL DEFAULT 0.00 COMMENT '当前库存',
  `warning_stock` decimal(10, 2) NULL DEFAULT NULL COMMENT '预警阈值',
  `image_url` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '物料图片',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `version` int NULL DEFAULT 0 COMMENT '版本号(乐观锁)',
  `create_by` bigint NULL DEFAULT NULL,
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `update_by` bigint NULL DEFAULT NULL,
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `del_flag` tinyint(1) NULL DEFAULT 0,
  PRIMARY KEY (`material_id`) USING BTREE,
  UNIQUE INDEX `uk_sku`(`sku` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 11 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '物料表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of ds_material
-- ----------------------------
INSERT INTO `ds_material` VALUES (1, '高级亚麻面料（浅米色）', 'FAB-LINEN-001', '面料', '米', 120.00, 56.50, 10.00, NULL, '优质亚麻，适合春夏服装', 4, NULL, '2026-03-17 15:11:05', 1, '2026-03-17 15:11:05', 0);
INSERT INTO `ds_material` VALUES (2, '真丝面料（香槟色）', 'FAB-SILK-001', '面料', '米', 280.00, 30.00, 5.00, NULL, '100%桑蚕丝', 0, NULL, '2026-03-17 15:11:05', NULL, '2026-03-17 15:11:05', 0);
INSERT INTO `ds_material` VALUES (3, '植鞣革（棕色）', 'FAB-LEATHER-001', '面料', '张', 350.00, 15.00, 3.00, NULL, '意大利进口植鞣革', 0, NULL, '2026-03-17 15:11:05', NULL, '2026-03-17 15:11:05', 0);
INSERT INTO `ds_material` VALUES (4, '鳄鱼皮（黑色）', 'FAB-CROC-001', '面料', '张', 1200.00, 2.00, 2.00, NULL, '稀有鳄鱼皮，需进口', 0, NULL, '2026-03-17 15:11:05', NULL, '2026-03-17 15:11:05', 0);
INSERT INTO `ds_material` VALUES (5, 'YKK拉链（20cm）', 'ACC-ZIP-001', '辅料', '条', 8.50, 199.00, 50.00, NULL, 'YKK金属拉链', 3, NULL, '2026-03-17 15:11:05', 1, '2026-03-17 15:11:05', 0);
INSERT INTO `ds_material` VALUES (6, '纯棉衬里（白色）', 'FAB-COTTON-001', '面料', '米', 35.00, 98.00, 20.00, NULL, '纯棉里衬', 3, NULL, '2026-03-17 15:11:05', 1, '2026-03-17 15:11:05', 0);
INSERT INTO `ds_material` VALUES (7, 'D型五金扣', 'HW-DRING-001', '五金件', '个', 5.00, 500.00, 100.00, NULL, '不锈钢D型环', 0, NULL, '2026-03-17 15:11:05', NULL, '2026-03-17 15:11:05', 0);
INSERT INTO `ds_material` VALUES (8, '手缝蜡线（棕色）', 'ACC-WAX-001', '辅料', '卷', 25.00, 80.00, 20.00, NULL, '手工皮具专用', 0, NULL, '2026-03-17 15:11:05', NULL, '2026-03-17 15:11:05', 0);
INSERT INTO `ds_material` VALUES (9, '暗扣', 'HW-SNAP-001', '五金件', '套', 3.00, 298.00, 60.00, NULL, '磁吸暗扣', 3, NULL, '2026-03-17 15:11:05', 1, '2026-03-17 15:11:05', 0);
INSERT INTO `ds_material` VALUES (10, '包装盒（大号）', 'PKG-BOX-001', '辅料', '个', 15.00, 99.00, 20.00, NULL, '高端定制包装盒', 3, NULL, '2026-03-17 15:11:05', 1, '2026-03-17 15:11:05', 0);

-- ----------------------------
-- Table structure for ds_notification
-- ----------------------------
DROP TABLE IF EXISTS `ds_notification`;
CREATE TABLE `ds_notification`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `user_id` bigint NOT NULL COMMENT '接收用户ID',
  `title` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '通知标题',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '通知内容',
  `type` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '通知类型: order_status/payment/workbench/system',
  `related_id` bigint NULL DEFAULT NULL COMMENT '关联ID，如订单ID',
  `related_type` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '关联类型: order/request',
  `is_read` tinyint(1) NULL DEFAULT 0 COMMENT '是否已读 (0=未读, 1=已读)',
  `create_by` bigint NULL DEFAULT NULL COMMENT '创建人ID',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_by` bigint NULL DEFAULT NULL COMMENT '更新人ID',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `del_flag` tinyint(1) NULL DEFAULT 0 COMMENT '逻辑删除标记',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_notification_user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_notification_user_read`(`user_id` ASC, `is_read` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '站内通知表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of ds_notification
-- ----------------------------
INSERT INTO `ds_notification` VALUES (1, 1, '定金支付成功', '您已成功支付定金 ¥10.00，订单正式进入生产', 'payment', 8, 'order', 0, 1, '2026-04-30 13:15:06', 1, '2026-04-30 13:15:06', 0);

-- ----------------------------
-- Table structure for ds_order
-- ----------------------------
DROP TABLE IF EXISTS `ds_order`;
CREATE TABLE `ds_order`  (
  `order_id` bigint NOT NULL AUTO_INCREMENT,
  `order_sn` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '订单编号',
  `user_id` bigint NOT NULL COMMENT '客户ID',
  `category_id` bigint NOT NULL COMMENT '品类ID',
  `designer_id` bigint NULL DEFAULT NULL COMMENT '指派的设计师ID',
  `current_step_id` bigint NULL DEFAULT NULL COMMENT '当前工作流节点',
  `status` tinyint(1) NULL DEFAULT 0 COMMENT '0=待支付,1=生产中,2=待发货,3=待收货,4=已完成,5=已取消',
  `custom_data_snapshot` json NULL COMMENT '定制参数快照',
  `total_amount` decimal(10, 2) NULL DEFAULT NULL COMMENT '总金额',
  `prepay_amount` decimal(10, 2) NULL DEFAULT NULL COMMENT '预付款',
  `paid_amount` decimal(10, 2) NULL DEFAULT 0.00 COMMENT '已支付金额',
  `expected_date` date NULL DEFAULT NULL COMMENT '预计交付日期',
  `address_snapshot` json NULL COMMENT '收货地址快照',
  `remark` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `is_blocked` tinyint(1) NULL DEFAULT 0 COMMENT '是否阻塞',
  `block_reason` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '阻塞原因',
  `cancel_reason` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '取消原因',
  `delay_reason` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '延期原因',
  `version` int NULL DEFAULT 0 COMMENT '版本号(乐观锁)',
  `create_by` bigint NULL DEFAULT NULL,
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `update_by` bigint NULL DEFAULT NULL,
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `finish_time` datetime NULL DEFAULT NULL COMMENT '完成时间',
  `delivery_time` datetime NULL DEFAULT NULL COMMENT '发货时间',
  `confirm_time` datetime NULL DEFAULT NULL COMMENT '确认完成时间',
  `del_flag` tinyint(1) NULL DEFAULT 0,
  `bom_template_id` bigint NULL DEFAULT NULL COMMENT '关联BOM模板',
  `material_cost` decimal(10, 2) NULL DEFAULT 0.00 COMMENT '物料成本',
  PRIMARY KEY (`order_id`) USING BTREE,
  UNIQUE INDEX `uk_order_sn`(`order_sn` ASC) USING BTREE,
  INDEX `idx_user_status`(`user_id` ASC, `status` ASC) USING BTREE,
  INDEX `idx_designer`(`designer_id` ASC) USING BTREE,
  INDEX `idx_create_time`(`create_time` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 10 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '订单主表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of ds_order
-- ----------------------------
INSERT INTO `ds_order` VALUES (1, 'DS202603081601001', 3, 1, 2, 2, 1, '{\"chest\": \"92\", \"waist\": \"72\", \"length\": \"130\", \"shoulder\": \"40\", \"fabric_type\": \"亚麻\"}', 3500.00, 1750.00, 1750.00, '2026-04-18', NULL, '改良汉服，客户要求宽松版型', 1, '天气原因', NULL, '????????', 11, NULL, '2026-03-08 16:05:00', 1, '2026-04-11 18:05:24', NULL, NULL, NULL, 0, NULL, 0.00);
INSERT INTO `ds_order` VALUES (2, 'DS202603071102001', 2, 3, 3, 12, 1, '{\"usage\": \"公司品牌Logo\", \"art_style\": \"扁平化\", \"resolution\": \"3000×3000\"}', 800.00, 400.00, 400.00, '2026-03-25', NULL, 'Logo设计，需要三个备选方案', 0, NULL, NULL, NULL, 3, NULL, '2026-03-07 11:05:00', 1, '2026-04-10 11:29:04', NULL, NULL, NULL, 0, NULL, 0.00);
INSERT INTO `ds_order` VALUES (3, 'DS202603151400001', 1, 2, 2, 8, 4, '{\"color\": \"黑色\", \"size_spec\": \"长25cm×宽15cm\", \"leather_type\": \"鳄鱼皮\"}', 5800.00, 2900.00, 2900.00, '2026-04-20', NULL, '鳄鱼皮手拿包，高端定制', 1, '鳄鱼皮原料缺货，预计3天到货', NULL, NULL, 4, NULL, '2026-03-15 14:00:00', 1, '2026-04-10 21:06:20', '2026-04-10 21:06:20', '2026-04-10 21:04:19', '2026-04-10 21:06:20', 0, NULL, 0.00);
INSERT INTO `ds_order` VALUES (4, 'DS202602201000001', 1, 3, 3, 16, 4, '{\"usage\": \"个人收藏\", \"art_style\": \"水彩风\", \"resolution\": \"1920×1080\"}', 600.00, 300.00, 600.00, '2026-03-05', NULL, '水彩风景画', 0, NULL, NULL, NULL, 0, NULL, '2026-02-20 10:00:00', NULL, '2026-04-09 21:07:17', '2026-03-03 18:00:00', NULL, NULL, 0, NULL, 0.00);
INSERT INTO `ds_order` VALUES (5, 'DS202604051756345882', 1, 1, 2, NULL, 1, '{\"chest\": \"1\", \"waist\": \"2\", \"length\": \"4\", \"shoulder\": \"3\"}', 800.00, 300.00, 0.00, '2026-04-29', NULL, '', 0, NULL, NULL, NULL, 0, 1, '2026-04-05 17:56:34', 1, '2026-04-05 17:56:34', NULL, NULL, NULL, 0, NULL, 0.00);
INSERT INTO `ds_order` VALUES (6, 'DS202604092137346349', 1, 1, 2, 1, 5, '{\"chest\": \"20\", \"waist\": \"30\", \"shoulder\": \"20\"}', 100.00, 10.00, 0.00, '2026-04-09', NULL, '', 0, '13', '??????????', NULL, 5, 1, '2026-04-09 21:37:35', 1, '2026-04-10 21:03:33', '2026-04-10 21:03:33', NULL, NULL, 0, NULL, 0.00);
INSERT INTO `ds_order` VALUES (7, 'DS202604102239321777', 1, 1, 2, 1, 5, '{\"chest\": \"88\", \"waist\": \"68\", \"length\": \"120\", \"shoulder\": \"38\", \"fabric_type\": \"丝绸\"}', 3500.00, 1500.00, 1500.00, '2026-05-20', NULL, 'BOM测试转单', 0, NULL, '测试取消-归还库存', NULL, 3, 1, '2026-04-10 22:39:33', 1, '2026-04-10 22:57:01', '2026-04-10 22:57:01', NULL, NULL, 0, 1, 519.50);
INSERT INTO `ds_order` VALUES (8, 'DS202604111743293930', 1, 1, 2, 1, 1, '{\"chest\": \"123\", \"waist\": \"32\", \"length\": \"123\", \"shoulder\": \"45\"}', 100.00, 10.00, 10.00, NULL, NULL, '', 0, NULL, NULL, NULL, 2, 1, '2026-04-11 17:43:29', 1, '2026-04-30 13:15:06', NULL, NULL, NULL, 0, 1, 519.50);
INSERT INTO `ds_order` VALUES (9, 'DS202604111801332055', 1, 1, 2, 1, 1, '{\"chest\": \"123\", \"waist\": \"12\", \"length\": \"3\", \"shoulder\": \"12\"}', 1000.00, 10.00, 10.00, '2026-04-25', NULL, '', 0, NULL, NULL, NULL, 1, 1, '2026-04-11 18:01:33', 1, '2026-04-11 18:08:26', NULL, NULL, NULL, 0, NULL, 0.00);

-- ----------------------------
-- Table structure for ds_order_progress
-- ----------------------------
DROP TABLE IF EXISTS `ds_order_progress`;
CREATE TABLE `ds_order_progress`  (
  `progress_id` bigint NOT NULL AUTO_INCREMENT,
  `order_id` bigint NOT NULL COMMENT '所属订单',
  `step_id` bigint NOT NULL COMMENT '对应工作流节点',
  `description` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '进度描述',
  `image_urls` json NULL COMMENT '进度图片',
  `form_data` json NULL COMMENT '节点表单填写数据',
  `operator_id` bigint NULL DEFAULT NULL COMMENT '操作人ID',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `del_flag` tinyint(1) NULL DEFAULT 0,
  PRIMARY KEY (`progress_id`) USING BTREE,
  INDEX `idx_order`(`order_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 47 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '订单进度表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of ds_order_progress
-- ----------------------------
INSERT INTO `ds_order_progress` VALUES (1, 1, 1, '客户需求已确认，改良汉服宽松版型，亚麻面料', NULL, NULL, 2, '2026-03-08 16:10:00', 0);
INSERT INTO `ds_order_progress` VALUES (2, 1, 2, '特选高品质亚麻面料已采购到位，颜色为浅米色', NULL, NULL, 2, '2026-03-10 09:00:00', 0);
INSERT INTO `ds_order_progress` VALUES (3, 1, 3, '开始裁剪，按照客户尺寸放样', NULL, NULL, 2, '2026-03-12 14:00:00', 0);
INSERT INTO `ds_order_progress` VALUES (4, 2, 12, '需求已确认，客户要求扁平化风格Logo', NULL, NULL, 3, '2026-03-07 11:10:00', 0);
INSERT INTO `ds_order_progress` VALUES (5, 2, 13, '草稿完成，已提交3个备选方案给客户', NULL, NULL, 3, '2026-03-09 16:00:00', 0);
INSERT INTO `ds_order_progress` VALUES (6, 2, 14, '客户选择方案B，开始线稿细化', NULL, NULL, 3, '2026-03-11 10:00:00', 0);
INSERT INTO `ds_order_progress` VALUES (7, 4, 12, '需求确认完毕', NULL, NULL, 3, '2026-02-20 10:10:00', 0);
INSERT INTO `ds_order_progress` VALUES (8, 4, 13, '草稿完成', NULL, NULL, 3, '2026-02-22 15:00:00', 0);
INSERT INTO `ds_order_progress` VALUES (9, 4, 14, '线稿已定稿', NULL, NULL, 3, '2026-02-25 11:00:00', 0);
INSERT INTO `ds_order_progress` VALUES (10, 4, 15, '上色完成，最终稿已出', NULL, NULL, 3, '2026-02-28 17:00:00', 0);
INSERT INTO `ds_order_progress` VALUES (11, 4, 16, '客户验收通过，交付完成', NULL, NULL, 3, '2026-03-03 18:00:00', 0);
INSERT INTO `ds_order_progress` VALUES (12, 3, 8, '部分', NULL, NULL, 1, '2026-03-17 15:16:03', 0);
INSERT INTO `ds_order_progress` VALUES (13, 1, 3, '工作台接口联调记录', NULL, NULL, 1, '2026-04-09 21:13:19', 0);
INSERT INTO `ds_order_progress` VALUES (14, 1, 3, 'upload-ok', '\"/uploads/321f10cac04241249a1c608ce6c9b048.png\"', NULL, 1, '2026-04-09 21:33:42', 0);
INSERT INTO `ds_order_progress` VALUES (15, 6, 1, '1', NULL, NULL, 1, '2026-04-09 21:37:59', 0);
INSERT INTO `ds_order_progress` VALUES (16, 6, 1, '订单已阻塞：11', NULL, NULL, 2, '2026-04-09 21:42:51', 0);
INSERT INTO `ds_order_progress` VALUES (17, 6, 1, '订单已解除阻塞', NULL, NULL, 2, '2026-04-09 21:43:14', 0);
INSERT INTO `ds_order_progress` VALUES (18, 6, 1, '订单已阻塞：13', NULL, NULL, 2, '2026-04-09 21:43:17', 0);
INSERT INTO `ds_order_progress` VALUES (19, 6, 1, '订单已解除阻塞', NULL, NULL, 2, '2026-04-09 21:43:22', 0);
INSERT INTO `ds_order_progress` VALUES (20, 1, 2, 'rollback-api-test', NULL, NULL, 1, '2026-04-10 10:36:27', 0);
INSERT INTO `ds_order_progress` VALUES (21, 1, 3, 'rollback-restore', NULL, NULL, 1, '2026-04-10 10:36:28', 0);
INSERT INTO `ds_order_progress` VALUES (22, 1, 2, '退回至节点：面料采购', NULL, NULL, 1, '2026-04-10 10:48:26', 0);
INSERT INTO `ds_order_progress` VALUES (23, 2, 12, '联调：指定退回到需求确认', NULL, NULL, 1, '2026-04-10 11:26:40', 0);
INSERT INTO `ds_order_progress` VALUES (24, 2, 13, '联调：推进到草稿构图', NULL, NULL, 1, '2026-04-10 11:29:04', 0);
INSERT INTO `ds_order_progress` VALUES (25, 2, 12, '联调：退回到需求确认', NULL, NULL, 1, '2026-04-10 11:29:04', 0);
INSERT INTO `ds_order_progress` VALUES (26, 1, 3, '推进至节点：裁剪', NULL, NULL, 1, '2026-04-10 11:34:08', 0);
INSERT INTO `ds_order_progress` VALUES (27, 1, 2, '退回至节点：面料采购', NULL, NULL, 1, '2026-04-10 11:34:13', 0);
INSERT INTO `ds_order_progress` VALUES (28, 1, 1, '退回至节点：需求确认', NULL, NULL, 1, '2026-04-10 11:34:30', 0);
INSERT INTO `ds_order_progress` VALUES (29, 6, 1, '????????', NULL, '{\"chest\": 88, \"waist\": 66}', 1, '2026-04-10 15:43:40', 0);
INSERT INTO `ds_order_progress` VALUES (30, 6, 1, '订单已取消：??????????', NULL, NULL, 1, '2026-04-10 21:03:33', 0);
INSERT INTO `ds_order_progress` VALUES (31, 1, 1, '订单延期至 2026-04-18，原因：????????', NULL, NULL, 1, '2026-04-10 21:03:33', 0);
INSERT INTO `ds_order_progress` VALUES (32, 3, 8, '??????', NULL, NULL, 1, '2026-04-10 21:04:19', 0);
INSERT INTO `ds_order_progress` VALUES (33, 3, 8, '客户已确认收货，订单已完成', NULL, NULL, 1, '2026-04-10 21:06:20', 0);
INSERT INTO `ds_order_progress` VALUES (34, 7, 1, '客户已支付定金：¥1500.00', NULL, NULL, 1, '2026-04-10 22:56:34', 0);
INSERT INTO `ds_order_progress` VALUES (35, 7, 1, '订单已取消：测试取消-归还库存', NULL, NULL, 1, '2026-04-10 22:57:01', 0);
INSERT INTO `ds_order_progress` VALUES (36, 1, 2, '推进至节点：面料采购', NULL, '{\"chest\": \"92\", \"waist\": \"72\"}', 1, '2026-04-11 17:17:35', 0);
INSERT INTO `ds_order_progress` VALUES (37, 1, 1, '退回至节点：需求确认', NULL, NULL, 1, '2026-04-11 18:02:52', 0);
INSERT INTO `ds_order_progress` VALUES (38, 1, 2, '完成需求', NULL, '{\"chest\": \"92\", \"waist\": \"72\"}', 1, '2026-04-11 18:04:27', 0);
INSERT INTO `ds_order_progress` VALUES (39, 1, 2, '订单已阻塞：天气原因', NULL, NULL, 1, '2026-04-11 18:05:24', 0);
INSERT INTO `ds_order_progress` VALUES (40, 9, 1, '客户已支付定金：¥10.00', NULL, NULL, 1, '2026-04-11 18:08:26', 0);
INSERT INTO `ds_order_progress` VALUES (41, 9, 1, NULL, NULL, '{\"chest\": \"123\", \"waist\": \"12\"}', 1, '2026-04-21 00:28:54', 0);
INSERT INTO `ds_order_progress` VALUES (42, 9, 1, NULL, NULL, '{\"chest\": \"123\", \"waist\": \"12\"}', 1, '2026-04-21 00:28:56', 0);
INSERT INTO `ds_order_progress` VALUES (43, 9, 1, NULL, NULL, '{\"chest\": \"123\", \"waist\": \"12\"}', 1, '2026-04-21 00:28:58', 0);
INSERT INTO `ds_order_progress` VALUES (44, 9, 1, NULL, NULL, '{\"chest\": \"123\", \"waist\": \"12\"}', 1, '2026-04-21 00:29:03', 0);
INSERT INTO `ds_order_progress` VALUES (45, 9, 1, NULL, NULL, '{\"chest\": \"123\", \"waist\": \"12\"}', 1, '2026-04-21 00:40:00', 0);
INSERT INTO `ds_order_progress` VALUES (46, 8, 1, '客户已支付定金：¥10.00', NULL, NULL, 1, '2026-04-30 13:15:06', 0);

-- ----------------------------
-- Table structure for ds_order_request
-- ----------------------------
DROP TABLE IF EXISTS `ds_order_request`;
CREATE TABLE `ds_order_request`  (
  `request_id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL COMMENT '提交客户',
  `category_id` bigint NOT NULL COMMENT '定制品类',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '客户文字描述',
  `image_urls` json NULL COMMENT '参考图片(JSON数组)',
  `custom_data` json NULL COMMENT '动态表单数据',
  `status` tinyint(1) NULL DEFAULT 0 COMMENT '0=待处理,1=已转单,2=已关闭',
  `close_reason` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '关闭原因',
  `linked_order_id` bigint NULL DEFAULT NULL COMMENT '转化后的订单ID',
  `create_by` bigint NULL DEFAULT NULL,
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `update_by` bigint NULL DEFAULT NULL,
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `del_flag` tinyint(1) NULL DEFAULT 0,
  PRIMARY KEY (`request_id`) USING BTREE,
  INDEX `idx_user`(`user_id` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 11 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '订单意向表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of ds_order_request
-- ----------------------------
INSERT INTO `ds_order_request` VALUES (1, 1, 1, '想定制一件旗袍，用于参加朋友婚礼', NULL, '{\"chest\": \"88\", \"waist\": \"68\", \"length\": \"120\", \"shoulder\": \"38\", \"fabric_type\": \"丝绸\"}', 1, NULL, 7, NULL, '2026-03-10 10:00:00', 1, '2026-03-17 15:11:05', 0);
INSERT INTO `ds_order_request` VALUES (2, 2, 2, '想做一个手工皮革钱包，送给男朋友做生日礼物', NULL, '{\"color\": \"深棕色\", \"size_spec\": \"长20cm×宽10cm\", \"leather_type\": \"植鞣革\"}', 0, NULL, NULL, NULL, '2026-03-11 14:30:00', NULL, '2026-03-17 15:11:05', 0);
INSERT INTO `ds_order_request` VALUES (3, 1, 3, '需要一张日系风格的头像插画', NULL, '{\"usage\": \"社交媒体头像\", \"art_style\": \"日系\", \"resolution\": \"1080×1080\"}', 0, NULL, NULL, NULL, '2026-03-12 09:15:00', NULL, '2026-03-17 15:11:05', 0);
INSERT INTO `ds_order_request` VALUES (4, 3, 1, '需要一套改良汉服', NULL, '{\"chest\": \"92\", \"waist\": \"72\", \"length\": \"130\", \"shoulder\": \"40\", \"fabric_type\": \"亚麻\"}', 1, NULL, 1, NULL, '2026-03-08 16:00:00', NULL, '2026-03-17 15:11:05', 0);
INSERT INTO `ds_order_request` VALUES (5, 2, 3, '设计公司 Logo 扁平化插画', NULL, '{\"usage\": \"公司品牌Logo\", \"art_style\": \"扁平化\", \"resolution\": \"3000×3000\"}', 1, NULL, 2, NULL, '2026-03-07 11:00:00', NULL, '2026-03-17 15:11:05', 0);
INSERT INTO `ds_order_request` VALUES (6, 3, 2, '复古风格手提包', NULL, '{\"color\": \"酒红色\", \"size_spec\": \"长30cm×宽20cm×高15cm\", \"leather_type\": \"牛皮\"}', 2, '客户取消，预算不足', NULL, NULL, '2026-03-05 08:45:00', NULL, '2026-03-17 15:11:05', 0);
INSERT INTO `ds_order_request` VALUES (7, 1, 1, '', '[]', '{\"chest\": \"123\", \"waist\": \"32\", \"length\": \"123\", \"shoulder\": \"45\"}', 1, NULL, 8, 1, '2026-04-05 17:45:08', 1, '2026-04-05 17:45:08', 0);
INSERT INTO `ds_order_request` VALUES (8, 1, 1, '', '[]', '{\"chest\": \"1\", \"waist\": \"2\", \"length\": \"4\", \"shoulder\": \"3\"}', 1, NULL, 5, 1, '2026-04-05 17:46:11', 1, '2026-04-05 17:46:11', 0);
INSERT INTO `ds_order_request` VALUES (9, 1, 1, '', '[]', '{\"chest\": \"20\", \"waist\": \"30\", \"shoulder\": \"20\"}', 1, NULL, 6, 1, '2026-04-09 21:37:09', 1, '2026-04-09 21:37:09', 0);
INSERT INTO `ds_order_request` VALUES (10, 1, 1, '', '[]', '{\"chest\": \"123\", \"waist\": \"12\", \"length\": \"3\", \"shoulder\": \"12\"}', 1, NULL, 9, 1, '2026-04-11 18:01:09', 1, '2026-04-11 18:01:09', 0);

-- ----------------------------
-- Table structure for ds_payment_record
-- ----------------------------
DROP TABLE IF EXISTS `ds_payment_record`;
CREATE TABLE `ds_payment_record`  (
  `payment_id` bigint NOT NULL AUTO_INCREMENT,
  `payment_no` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '系统支付流水号',
  `order_id` bigint NOT NULL COMMENT '关联订单',
  `user_id` bigint NOT NULL COMMENT '支付用户',
  `payment_type` tinyint(1) NOT NULL COMMENT '1=预付款,2=尾款',
  `amount` decimal(10, 2) NOT NULL COMMENT '支付金额',
  `wx_transaction_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '微信支付交易号',
  `wx_prepay_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '微信预支付ID',
  `status` tinyint(1) NULL DEFAULT 0 COMMENT '0=待支付,1=成功,2=失败,3=已关闭',
  `pay_time` datetime NULL DEFAULT NULL COMMENT '实际支付时间',
  `expire_time` datetime NULL DEFAULT NULL COMMENT '支付过期时间',
  `notify_data` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '微信回调原始数据',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `del_flag` tinyint(1) NULL DEFAULT 0,
  PRIMARY KEY (`payment_id`) USING BTREE,
  UNIQUE INDEX `uk_payment_no`(`payment_no` ASC) USING BTREE,
  INDEX `idx_order`(`order_id` ASC) USING BTREE,
  INDEX `idx_user`(`user_id` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '支付流水表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of ds_payment_record
-- ----------------------------

-- ----------------------------
-- Table structure for ds_portfolio
-- ----------------------------
DROP TABLE IF EXISTS `ds_portfolio`;
CREATE TABLE `ds_portfolio`  (
  `portfolio_id` bigint NOT NULL AUTO_INCREMENT,
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '作品标题',
  `category_id` bigint NULL DEFAULT NULL COMMENT '关联品类',
  `cover_url` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '封面图',
  `image_urls` json NOT NULL COMMENT '图片列表(JSON数组)',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '富文本描述',
  `status` tinyint(1) NULL DEFAULT 0 COMMENT '0=草稿,1=发布',
  `view_count` int NULL DEFAULT 0 COMMENT '浏览次数',
  `sort_order` int NULL DEFAULT 0 COMMENT '排序',
  `create_by` bigint NULL DEFAULT NULL,
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `update_by` bigint NULL DEFAULT NULL,
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `del_flag` tinyint(1) NULL DEFAULT 0,
  PRIMARY KEY (`portfolio_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '作品集表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of ds_portfolio
-- ----------------------------
INSERT INTO `ds_portfolio` VALUES (1, '猫', 1, 'https://i0.hdslb.com/bfs/new_dyn/a4833ebe1038fcd60a196da9b53c0e44270317383.jpg@420w_560h_1e_1c.webp', '[\"https://i0.hdslb.com/bfs/new_dyn/a4833ebe1038fcd60a196da9b53c0e44270317383.jpg@420w_560h_1e_1c.webp\", \"https://i0.hdslb.com/bfs/new_dyn/a42924b84d925cfabf5672f8e7373ee6270317383.jpg@264w_264h_1e_1c.webp\"]', '', 1, 4, 1, 1, '2026-04-10 19:53:02', 1, '2026-04-10 19:53:02', 0);
INSERT INTO `ds_portfolio` VALUES (2, '测试上传作品', 1, '/uploads/8962029f590c4d449c1b3e1afdf2391e.png', '[]', '', 0, 0, 0, 1, '2026-04-10 20:05:54', 1, '2026-04-10 20:05:54', 0);

-- ----------------------------
-- Table structure for ds_refund_record
-- ----------------------------
DROP TABLE IF EXISTS `ds_refund_record`;
CREATE TABLE `ds_refund_record`  (
  `refund_id` bigint NOT NULL AUTO_INCREMENT,
  `refund_no` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '系统退款流水号',
  `order_id` bigint NOT NULL COMMENT '关联订单',
  `payment_id` bigint NULL DEFAULT NULL COMMENT '关联原支付记录',
  `refund_amount` decimal(10, 2) NOT NULL COMMENT '退款金额',
  `refund_reason` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '退款原因',
  `wx_refund_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '微信退款单号',
  `status` tinyint(1) NULL DEFAULT 0 COMMENT '0=处理中,1=退款成功,2=退款失败',
  `refund_time` datetime NULL DEFAULT NULL COMMENT '实际退款时间',
  `operator_id` bigint NULL DEFAULT NULL COMMENT '操作人ID',
  `notify_data` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '微信回调原始数据',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `del_flag` tinyint(1) NULL DEFAULT 0,
  PRIMARY KEY (`refund_id`) USING BTREE,
  UNIQUE INDEX `uk_refund_no`(`refund_no` ASC) USING BTREE,
  INDEX `idx_order`(`order_id` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '退款记录表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of ds_refund_record
-- ----------------------------

-- ----------------------------
-- Table structure for ds_user
-- ----------------------------
DROP TABLE IF EXISTS `ds_user`;
CREATE TABLE `ds_user`  (
  `user_id` bigint NOT NULL AUTO_INCREMENT,
  `openid` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '微信OpenID',
  `unionid` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '微信UnionID',
  `nickname` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '昵称',
  `avatar_url` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '头像URL',
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '手机号',
  `status` tinyint(1) NULL DEFAULT 1 COMMENT '0=禁用,1=正常',
  `gender` tinyint(1) NULL DEFAULT NULL COMMENT '性别',
  `default_address_id` bigint NULL DEFAULT NULL COMMENT '默认地址ID',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '注册时间',
  `last_login_time` datetime NULL DEFAULT NULL COMMENT '最后登录',
  `del_flag` tinyint(1) NULL DEFAULT 0,
  `create_by` bigint NULL DEFAULT NULL,
  `update_by` bigint NULL DEFAULT NULL,
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`user_id`) USING BTREE,
  UNIQUE INDEX `uk_openid`(`openid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 6 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '小程序用户表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of ds_user
-- ----------------------------
INSERT INTO `ds_user` VALUES (1, 'wx_test_openid_001', NULL, '张小姐', NULL, '13900001001', 1, NULL, NULL, '2026-03-17 15:11:05', '2026-04-30 13:04:23', 0, NULL, 5, '2026-03-24 16:43:20');
INSERT INTO `ds_user` VALUES (2, 'wx_test_openid_002', NULL, '刘先生', NULL, '13900001002', 1, NULL, NULL, '2026-03-17 15:11:05', NULL, 0, NULL, NULL, '2026-03-24 16:43:20');
INSERT INTO `ds_user` VALUES (3, 'wx_test_openid_003', NULL, '陈女士', NULL, '13900001003', 1, NULL, NULL, '2026-03-17 15:11:05', '2026-04-11 18:03:48', 0, NULL, NULL, '2026-03-24 16:43:20');
INSERT INTO `ds_user` VALUES (4, 'wx_test_openid_13888888888', NULL, '客户8888', NULL, '13888888888', 1, NULL, NULL, '2026-03-24 16:44:41', '2026-03-25 19:19:38', 0, NULL, 4, '2026-03-24 16:44:41');
INSERT INTO `ds_user` VALUES (5, 'wx_test_openid_default', NULL, 'ZeHana测试客户', NULL, '13888888888', 1, NULL, NULL, '2026-03-25 19:24:46', '2026-04-05 16:57:43', 0, NULL, 1, '2026-03-25 19:24:46');

-- ----------------------------
-- Table structure for ds_workflow
-- ----------------------------
DROP TABLE IF EXISTS `ds_workflow`;
CREATE TABLE `ds_workflow`  (
  `workflow_id` bigint NOT NULL AUTO_INCREMENT,
  `category_id` bigint NOT NULL COMMENT '关联品类(一对一)',
  `workflow_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '工作流名称',
  `create_by` bigint NULL DEFAULT NULL,
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `update_by` bigint NULL DEFAULT NULL,
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `del_flag` tinyint(1) NULL DEFAULT 0,
  PRIMARY KEY (`workflow_id`) USING BTREE,
  UNIQUE INDEX `uk_category`(`category_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '工作流模板表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of ds_workflow
-- ----------------------------
INSERT INTO `ds_workflow` VALUES (1, 1, '服装定制流程', NULL, '2026-03-04 15:06:58', NULL, '2026-03-04 15:06:58', 0);
INSERT INTO `ds_workflow` VALUES (2, 2, '皮具制作流程', NULL, '2026-03-04 15:06:58', NULL, '2026-03-04 15:06:58', 0);
INSERT INTO `ds_workflow` VALUES (3, 3, '数字插画流程', NULL, '2026-03-04 15:06:58', NULL, '2026-03-04 15:06:58', 0);

-- ----------------------------
-- Table structure for ds_workflow_step
-- ----------------------------
DROP TABLE IF EXISTS `ds_workflow_step`;
CREATE TABLE `ds_workflow_step`  (
  `step_id` bigint NOT NULL AUTO_INCREMENT,
  `workflow_id` bigint NOT NULL COMMENT '所属工作流',
  `step_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '节点名称',
  `step_order` int NOT NULL DEFAULT 1 COMMENT '节点顺序',
  `is_start_step` tinyint(1) NULL DEFAULT 0 COMMENT '是否起始节点',
  `is_end_step` tinyint(1) NULL DEFAULT 0 COMMENT '是否结束节点',
  `node_description` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '????',
  `allowed_actions` json NULL COMMENT '????(JSON??)',
  `need_image_upload` tinyint(1) NULL DEFAULT 0 COMMENT '????????',
  `visible_to_client` tinyint(1) NULL DEFAULT 1 COMMENT '???????',
  `expected_duration_days` int NULL DEFAULT NULL COMMENT '??????(?)',
  `node_form_fields` json NULL COMMENT '节点表单字段键列表',
  `create_by` bigint NULL DEFAULT NULL,
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `update_by` bigint NULL DEFAULT NULL,
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `del_flag` tinyint(1) NULL DEFAULT 0,
  PRIMARY KEY (`step_id`) USING BTREE,
  INDEX `idx_workflow`(`workflow_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 17 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '工作流节点表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of ds_workflow_step
-- ----------------------------
INSERT INTO `ds_workflow_step` VALUES (1, 1, '需求确认', 1, 1, 0, '处理节点：需求确认', '[\"save\", \"advance\", \"rollback\", \"block\", \"unblock\"]', 0, 1, 1, '[\"chest\", \"waist\"]', NULL, '2026-03-04 15:06:58', NULL, '2026-04-10 15:43:02', 0);
INSERT INTO `ds_workflow_step` VALUES (2, 1, '面料采购', 2, 0, 0, '处理节点：面料采购', '[\"save\", \"advance\", \"rollback\", \"block\", \"unblock\"]', 0, 1, 2, NULL, NULL, '2026-03-04 15:06:58', NULL, '2026-04-10 10:33:15', 0);
INSERT INTO `ds_workflow_step` VALUES (3, 1, '裁剪', 3, 0, 0, '处理节点：裁剪', '[\"save\", \"advance\", \"rollback\", \"block\", \"unblock\"]', 1, 1, 3, NULL, NULL, '2026-03-04 15:06:58', NULL, '2026-04-10 10:33:15', 0);
INSERT INTO `ds_workflow_step` VALUES (4, 1, '缝制', 4, 0, 0, '处理节点：缝制', '[\"save\", \"advance\", \"rollback\", \"block\", \"unblock\"]', 1, 1, 3, NULL, NULL, '2026-03-04 15:06:58', NULL, '2026-04-10 10:33:15', 0);
INSERT INTO `ds_workflow_step` VALUES (5, 1, '质检', 5, 0, 0, '处理节点：质检', '[\"save\", \"advance\", \"rollback\", \"block\", \"unblock\"]', 1, 1, 1, NULL, NULL, '2026-03-04 15:06:58', NULL, '2026-04-10 10:33:15', 0);
INSERT INTO `ds_workflow_step` VALUES (6, 1, '包装发货', 6, 0, 1, '处理节点：包装发货', '[\"save\", \"advance\", \"rollback\", \"block\", \"unblock\"]', 0, 1, 1, NULL, NULL, '2026-03-04 15:06:58', NULL, '2026-04-10 10:33:15', 0);
INSERT INTO `ds_workflow_step` VALUES (7, 2, '需求确认', 1, 1, 0, '处理节点：需求确认', '[\"save\", \"advance\", \"rollback\", \"block\", \"unblock\"]', 0, 1, 1, NULL, NULL, '2026-03-04 15:06:58', NULL, '2026-04-10 10:33:15', 0);
INSERT INTO `ds_workflow_step` VALUES (8, 2, '皮料裁切', 2, 0, 0, '处理节点：皮料裁切', '[\"save\", \"advance\", \"rollback\", \"block\", \"unblock\"]', 0, 1, 2, NULL, NULL, '2026-03-04 15:06:58', NULL, '2026-04-10 10:33:15', 0);
INSERT INTO `ds_workflow_step` VALUES (9, 2, '缝线打磨', 3, 0, 0, '处理节点：缝线打磨', '[\"save\", \"advance\", \"rollback\", \"block\", \"unblock\"]', 1, 1, 3, NULL, NULL, '2026-03-04 15:06:58', NULL, '2026-04-10 10:33:15', 0);
INSERT INTO `ds_workflow_step` VALUES (10, 2, '上色封边', 4, 0, 0, '处理节点：上色封边', '[\"save\", \"advance\", \"rollback\", \"block\", \"unblock\"]', 1, 1, 3, NULL, NULL, '2026-03-04 15:06:58', NULL, '2026-04-10 10:33:15', 0);
INSERT INTO `ds_workflow_step` VALUES (11, 2, '质检出货', 5, 0, 1, '处理节点：质检出货', '[\"save\", \"advance\", \"rollback\", \"block\", \"unblock\"]', 1, 1, 1, NULL, NULL, '2026-03-04 15:06:58', NULL, '2026-04-10 10:33:15', 0);
INSERT INTO `ds_workflow_step` VALUES (12, 3, '需求确认', 1, 1, 0, '处理节点：需求确认', '[\"save\", \"advance\", \"rollback\", \"block\", \"unblock\"]', 0, 1, 1, NULL, NULL, '2026-03-04 15:06:58', NULL, '2026-04-10 10:33:15', 0);
INSERT INTO `ds_workflow_step` VALUES (13, 3, '草稿构图', 2, 0, 0, '处理节点：草稿构图', '[\"save\", \"advance\", \"rollback\", \"block\", \"unblock\"]', 1, 1, 2, NULL, NULL, '2026-03-04 15:06:58', NULL, '2026-04-10 10:33:15', 0);
INSERT INTO `ds_workflow_step` VALUES (14, 3, '线稿细化', 3, 0, 0, '处理节点：线稿细化', '[\"save\", \"advance\", \"rollback\", \"block\", \"unblock\"]', 1, 1, 3, NULL, NULL, '2026-03-04 15:06:58', NULL, '2026-04-10 10:33:15', 0);
INSERT INTO `ds_workflow_step` VALUES (15, 3, '上色完稿', 4, 0, 0, '处理节点：上色完稿', '[\"save\", \"advance\", \"rollback\", \"block\", \"unblock\"]', 1, 1, 3, NULL, NULL, '2026-03-04 15:06:58', NULL, '2026-04-10 10:33:15', 0);
INSERT INTO `ds_workflow_step` VALUES (16, 3, '客户验收', 5, 0, 1, '处理节点：客户验收', '[\"save\", \"advance\", \"rollback\", \"block\", \"unblock\"]', 1, 1, 1, NULL, NULL, '2026-03-04 15:06:58', NULL, '2026-04-10 10:33:15', 0);

-- ----------------------------
-- Table structure for sys_admin
-- ----------------------------
DROP TABLE IF EXISTS `sys_admin`;
CREATE TABLE `sys_admin`  (
  `admin_id` bigint NOT NULL AUTO_INCREMENT,
  `username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '登录账号',
  `password` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '密码(BCrypt)',
  `nickname` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '昵称',
  `avatar` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '头像',
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '手机号',
  `email` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '邮箱',
  `status` tinyint(1) NULL DEFAULT 1 COMMENT '0=禁用,1=正常',
  `create_by` bigint NULL DEFAULT NULL,
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `update_by` bigint NULL DEFAULT NULL,
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `last_login_time` datetime NULL DEFAULT NULL COMMENT '最后登录',
  `del_flag` tinyint(1) NULL DEFAULT 0,
  PRIMARY KEY (`admin_id`) USING BTREE,
  UNIQUE INDEX `uk_username`(`username` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 8 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '后台用户表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_admin
-- ----------------------------
INSERT INTO `sys_admin` VALUES (1, 'admin', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '超级管理员', NULL, NULL, NULL, 1, NULL, '2026-03-04 15:06:58', NULL, '2026-03-04 15:06:58', NULL, 0);
INSERT INTO `sys_admin` VALUES (2, 'designer1', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '李设计师', NULL, '13800001001', NULL, 1, NULL, '2026-03-17 15:11:05', NULL, '2026-03-17 15:11:05', NULL, 0);
INSERT INTO `sys_admin` VALUES (3, 'designer2', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '王设计师', NULL, '13800001002', NULL, 1, NULL, '2026-03-17 15:11:05', 1, '2026-03-17 15:11:05', NULL, 0);
INSERT INTO `sys_admin` VALUES (4, 'storekeeper', '$2a$10$lquZWWPAEjT1D3Ugbh2NTuZURlkeRF.K3LJcRSDQSTq3ljats0T96', 'storekeeper', NULL, '', NULL, 1, 1, '2026-04-20 00:45:35', 1, '2026-04-20 00:45:35', NULL, 0);
INSERT INTO `sys_admin` VALUES (5, 'purchaser', '$2a$10$MqEyuumZ9MXB/nmwzeV4euzEhnyxbn1Pvw.8b1S1V.g0BtZBrtgP2', 'purchaser', NULL, '', NULL, 1, 1, '2026-04-20 00:45:44', 1, '2026-04-20 00:45:44', NULL, 0);
INSERT INTO `sys_admin` VALUES (6, 'finance', '$2a$10$7ahdyzysipm.sGUK/eC5u.kmXmANkbg6oHz/xJVympU3XDVbg1r.a', 'finance', NULL, '', NULL, 1, 1, '2026-04-20 00:45:54', 1, '2026-04-20 00:45:54', NULL, 0);
INSERT INTO `sys_admin` VALUES (7, 'customer_service', '$2a$10$EI4ij7ybYwOwfck0R9xc7eYthj.vysnH7zYLup406nWkFLxXYqxXO', 'customer_service', NULL, '', NULL, 1, 1, '2026-04-20 00:46:07', 1, '2026-04-20 00:46:07', NULL, 0);

-- ----------------------------
-- Table structure for sys_admin_role
-- ----------------------------
DROP TABLE IF EXISTS `sys_admin_role`;
CREATE TABLE `sys_admin_role`  (
  `admin_id` bigint NOT NULL COMMENT '用户ID',
  `role_id` bigint NOT NULL COMMENT '角色ID',
  PRIMARY KEY (`admin_id`, `role_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户角色关联表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_admin_role
-- ----------------------------
INSERT INTO `sys_admin_role` VALUES (1, 1);
INSERT INTO `sys_admin_role` VALUES (2, 2);
INSERT INTO `sys_admin_role` VALUES (3, 2);
INSERT INTO `sys_admin_role` VALUES (4, 3);
INSERT INTO `sys_admin_role` VALUES (5, 4);
INSERT INTO `sys_admin_role` VALUES (6, 5);
INSERT INTO `sys_admin_role` VALUES (7, 6);

-- ----------------------------
-- Table structure for sys_api_metrics
-- ----------------------------
DROP TABLE IF EXISTS `sys_api_metrics`;
CREATE TABLE `sys_api_metrics`  (
  `metric_id` bigint NOT NULL AUTO_INCREMENT,
  `api_path` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '接口路径',
  `http_method` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'HTTP方法',
  `stat_date` date NOT NULL COMMENT '统计日期',
  `stat_hour` int NULL DEFAULT NULL COMMENT '统计小时(0-23)',
  `call_count` int NULL DEFAULT 0 COMMENT '调用次数',
  `success_count` int NULL DEFAULT 0,
  `fail_count` int NULL DEFAULT 0,
  `avg_cost_ms` int NULL DEFAULT 0 COMMENT '平均耗时(ms)',
  `max_cost_ms` int NULL DEFAULT 0,
  `p99_cost_ms` int NULL DEFAULT 0,
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`metric_id`) USING BTREE,
  UNIQUE INDEX `uk_api_date_hour`(`api_path` ASC, `stat_date` ASC, `stat_hour` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '接口监控指标表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_api_metrics
-- ----------------------------

-- ----------------------------
-- Table structure for sys_dict_data
-- ----------------------------
DROP TABLE IF EXISTS `sys_dict_data`;
CREATE TABLE `sys_dict_data`  (
  `dict_code` bigint NOT NULL AUTO_INCREMENT,
  `dict_type` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '字典类型标识',
  `dict_label` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '字典标签',
  `dict_value` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '字典值',
  `sort_order` int NULL DEFAULT 0 COMMENT '排序',
  `remark` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `del_flag` tinyint(1) NULL DEFAULT 0,
  PRIMARY KEY (`dict_code`) USING BTREE,
  INDEX `idx_dict_type`(`dict_type` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 15 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '字典数据表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_dict_data
-- ----------------------------
INSERT INTO `sys_dict_data` VALUES (1, 'order_status', '待支付', '0', 0, NULL, 0);
INSERT INTO `sys_dict_data` VALUES (2, 'order_status', '生产中', '1', 1, NULL, 0);
INSERT INTO `sys_dict_data` VALUES (3, 'order_status', '待发货', '2', 2, NULL, 0);
INSERT INTO `sys_dict_data` VALUES (4, 'order_status', '待收货', '3', 3, NULL, 0);
INSERT INTO `sys_dict_data` VALUES (5, 'order_status', '已完成', '4', 4, NULL, 0);
INSERT INTO `sys_dict_data` VALUES (6, 'order_status', '已取消', '5', 5, NULL, 0);
INSERT INTO `sys_dict_data` VALUES (7, 'request_status', '待处理', '0', 0, NULL, 0);
INSERT INTO `sys_dict_data` VALUES (8, 'request_status', '已转单', '1', 1, NULL, 0);
INSERT INTO `sys_dict_data` VALUES (9, 'request_status', '已关闭', '2', 2, NULL, 0);
INSERT INTO `sys_dict_data` VALUES (10, 'payment_type', '预付款', '1', 1, NULL, 0);
INSERT INTO `sys_dict_data` VALUES (11, 'payment_type', '尾款', '2', 2, NULL, 0);
INSERT INTO `sys_dict_data` VALUES (12, 'material_category', '面料', 'fabric', 1, NULL, 0);
INSERT INTO `sys_dict_data` VALUES (13, 'material_category', '辅料', 'accessory', 2, NULL, 0);
INSERT INTO `sys_dict_data` VALUES (14, 'material_category', '五金件', 'hardware', 3, NULL, 0);

-- ----------------------------
-- Table structure for sys_dict_type
-- ----------------------------
DROP TABLE IF EXISTS `sys_dict_type`;
CREATE TABLE `sys_dict_type`  (
  `dict_id` bigint NOT NULL AUTO_INCREMENT,
  `dict_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '字典名称',
  `dict_type` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '字典类型标识',
  `remark` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `create_by` bigint NULL DEFAULT NULL,
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `update_by` bigint NULL DEFAULT NULL,
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `del_flag` tinyint(1) NULL DEFAULT 0,
  PRIMARY KEY (`dict_id`) USING BTREE,
  UNIQUE INDEX `uk_dict_type`(`dict_type` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 8 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '字典类型表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_dict_type
-- ----------------------------
INSERT INTO `sys_dict_type` VALUES (1, '订单状态', 'order_status', '订单生命周期状态', NULL, '2026-03-04 15:06:58', NULL, '2026-03-04 15:06:58', 0);
INSERT INTO `sys_dict_type` VALUES (2, '意向状态', 'request_status', '客户意向状态', NULL, '2026-03-04 15:06:58', NULL, '2026-03-04 15:06:58', 0);
INSERT INTO `sys_dict_type` VALUES (3, '支付类型', 'payment_type', '支付类型', NULL, '2026-03-04 15:06:58', NULL, '2026-03-04 15:06:58', 0);
INSERT INTO `sys_dict_type` VALUES (4, '物料分类', 'material_category', '物料分类', NULL, '2026-03-04 15:06:58', NULL, '2026-03-04 15:06:58', 0);
INSERT INTO `sys_dict_type` VALUES (5, '1', '1', '', NULL, '2026-04-05 14:58:11', NULL, '2026-04-05 15:03:50', 1);
INSERT INTO `sys_dict_type` VALUES (7, '2', '2', '', NULL, '2026-04-05 15:00:09', NULL, '2026-04-05 15:03:49', 1);

-- ----------------------------
-- Table structure for sys_exception_log
-- ----------------------------
DROP TABLE IF EXISTS `sys_exception_log`;
CREATE TABLE `sys_exception_log`  (
  `exception_id` bigint NOT NULL AUTO_INCREMENT,
  `exception_type` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '异常类型(类名)',
  `exception_msg` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '异常消息',
  `stack_trace` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '堆栈信息',
  `request_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '请求URL',
  `request_method` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'HTTP方法',
  `request_param` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '请求参数',
  `operator_id` bigint NULL DEFAULT NULL COMMENT '操作人ID',
  `operator_ip` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '操作人IP',
  `is_handled` tinyint(1) NULL DEFAULT 0 COMMENT '是否已处理',
  `handle_remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '处理备注',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '发生时间',
  PRIMARY KEY (`exception_id`) USING BTREE,
  INDEX `idx_create_time`(`create_time` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '异常日志表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_exception_log
-- ----------------------------

-- ----------------------------
-- Table structure for sys_login_log
-- ----------------------------
DROP TABLE IF EXISTS `sys_login_log`;
CREATE TABLE `sys_login_log`  (
  `login_id` bigint NOT NULL AUTO_INCREMENT,
  `admin_id` bigint NULL DEFAULT NULL COMMENT '登录用户ID',
  `username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '登录账号',
  `login_ip` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '登录IP',
  `login_location` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '登录地点',
  `browser` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '浏览器',
  `os` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '操作系统',
  `status` tinyint(1) NULL DEFAULT NULL COMMENT '0=成功,1=失败',
  `msg` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '提示消息',
  `login_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '登录时间',
  PRIMARY KEY (`login_id`) USING BTREE,
  INDEX `idx_admin`(`admin_id` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '登录日志表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_login_log
-- ----------------------------

-- ----------------------------
-- Table structure for sys_menu
-- ----------------------------
DROP TABLE IF EXISTS `sys_menu`;
CREATE TABLE `sys_menu`  (
  `menu_id` bigint NOT NULL AUTO_INCREMENT,
  `parent_id` bigint NULL DEFAULT 0 COMMENT '父菜单ID',
  `menu_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '菜单名称',
  `menu_type` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'M=目录,C=菜单,F=按钮',
  `path` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '路由地址',
  `component` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '组件路径',
  `perms` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '权限标识(如order:list)',
  `icon` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '图标',
  `sort_order` int NULL DEFAULT 0 COMMENT '排序',
  `visible` tinyint(1) NULL DEFAULT 1 COMMENT '是否可见',
  `create_by` bigint NULL DEFAULT NULL,
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `update_by` bigint NULL DEFAULT NULL,
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `del_flag` tinyint(1) NULL DEFAULT 0,
  PRIMARY KEY (`menu_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 34 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '菜单权限表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_menu
-- ----------------------------
INSERT INTO `sys_menu` VALUES (1, 0, '订单管理', 'M', '/order', NULL, NULL, 'ShoppingCart', 3, 1, NULL, '2026-03-04 15:06:58', NULL, '2026-04-11 14:05:26', 0);
INSERT INTO `sys_menu` VALUES (2, 0, '意向管理', 'M', '/request', NULL, NULL, 'Mail', 4, 1, NULL, '2026-03-04 15:06:58', NULL, '2026-04-11 14:05:26', 0);
INSERT INTO `sys_menu` VALUES (3, 0, '配置中心', 'M', '/config', NULL, NULL, 'Settings', 8, 1, NULL, '2026-03-04 15:06:58', NULL, '2026-04-11 14:05:26', 0);
INSERT INTO `sys_menu` VALUES (4, 0, '供应链', 'M', '/supply', NULL, NULL, 'Package', 6, 1, NULL, '2026-03-04 15:06:58', NULL, '2026-04-11 14:05:26', 0);
INSERT INTO `sys_menu` VALUES (5, 0, '作品集', 'M', '/portfolio', NULL, NULL, 'Image', 5, 1, NULL, '2026-03-04 15:06:58', NULL, '2026-03-04 15:06:58', 0);
INSERT INTO `sys_menu` VALUES (6, 0, '数据分析', 'M', '/statistics', NULL, NULL, 'TrendingUp', 7, 1, NULL, '2026-03-04 15:06:58', NULL, '2026-04-11 14:05:26', 0);
INSERT INTO `sys_menu` VALUES (7, 0, '系统管理', 'M', '/system', NULL, NULL, 'Tool', 9, 1, NULL, '2026-03-04 15:06:58', NULL, '2026-04-11 14:05:26', 0);
INSERT INTO `sys_menu` VALUES (8, 1, '订单看板', 'C', '/order/kanban', NULL, 'order:kanban', NULL, 1, 1, NULL, '2026-03-04 15:06:58', NULL, '2026-03-04 15:06:58', 0);
INSERT INTO `sys_menu` VALUES (9, 1, '订单列表', 'C', '/order/list', NULL, 'order:list', NULL, 2, 1, NULL, '2026-03-04 15:06:58', NULL, '2026-03-04 15:06:58', 0);
INSERT INTO `sys_menu` VALUES (10, 2, '意向池', 'C', '/request/list', NULL, 'request:list', NULL, 1, 1, NULL, '2026-03-04 15:06:58', NULL, '2026-03-04 15:06:58', 0);
INSERT INTO `sys_menu` VALUES (11, 3, '品类管理', 'C', '/config/category', NULL, 'category:list', NULL, 1, 1, NULL, '2026-03-04 15:06:58', NULL, '2026-03-04 15:06:58', 0);
INSERT INTO `sys_menu` VALUES (12, 3, '动态字段', 'C', '/config/field', NULL, 'field:list', NULL, 2, 1, NULL, '2026-03-04 15:06:58', NULL, '2026-03-04 15:06:58', 0);
INSERT INTO `sys_menu` VALUES (13, 3, '工作流管理', 'C', '/config/workflow', NULL, 'workflow:list', NULL, 3, 1, NULL, '2026-03-04 15:06:58', NULL, '2026-03-04 15:06:58', 0);
INSERT INTO `sys_menu` VALUES (14, 4, '物料管理', 'C', '/supply/material', NULL, 'material:list', NULL, 1, 1, NULL, '2026-03-04 15:06:58', NULL, '2026-03-04 15:06:58', 0);
INSERT INTO `sys_menu` VALUES (15, 4, 'BOM模板', 'C', '/supply/bom', NULL, 'bom:list', NULL, 2, 1, NULL, '2026-03-04 15:06:58', NULL, '2026-03-04 15:06:58', 0);
INSERT INTO `sys_menu` VALUES (16, 5, '作品管理', 'C', '/portfolio/list', NULL, 'portfolio:list', NULL, 1, 1, NULL, '2026-03-04 15:06:58', NULL, '2026-03-04 15:06:58', 0);
INSERT INTO `sys_menu` VALUES (17, 6, '经营看板', 'C', '/statistics/dashboard', NULL, 'statistics:dashboard', NULL, 1, 1, NULL, '2026-03-04 15:06:58', NULL, '2026-03-04 15:06:58', 0);
INSERT INTO `sys_menu` VALUES (18, 7, '用户管理', 'C', '/system/admin', NULL, 'admin:list', NULL, 1, 1, NULL, '2026-03-04 15:06:58', NULL, '2026-03-04 15:06:58', 0);
INSERT INTO `sys_menu` VALUES (19, 7, '角色管理', 'C', '/system/role', NULL, 'role:list', NULL, 2, 1, NULL, '2026-03-04 15:06:58', NULL, '2026-03-04 15:06:58', 0);
INSERT INTO `sys_menu` VALUES (20, 7, '菜单管理', 'C', '/system/menu', NULL, 'menu:list', NULL, 3, 1, NULL, '2026-03-04 15:06:58', NULL, '2026-03-04 15:06:58', 0);
INSERT INTO `sys_menu` VALUES (21, 7, '字典管理', 'C', '/system/dict', NULL, 'dict:list', NULL, 4, 1, NULL, '2026-03-04 15:06:58', NULL, '2026-03-04 15:06:58', 0);
INSERT INTO `sys_menu` VALUES (22, 7, '操作日志', 'C', '/system/log', NULL, 'log:list', NULL, 5, 1, NULL, '2026-03-04 15:06:58', NULL, '2026-03-04 15:06:58', 0);
INSERT INTO `sys_menu` VALUES (23, 0, '消息中心', 'M', '/chat', NULL, NULL, 'ChatboxEllipsesOutline', 2, 1, NULL, '2026-03-25 19:24:46', NULL, '2026-04-11 14:05:26', 0);
INSERT INTO `sys_menu` VALUES (24, 23, '在线沟通', 'C', '/chat/index', NULL, 'chat:list', NULL, 1, 1, NULL, '2026-03-25 19:24:46', NULL, '2026-03-25 19:24:46', 0);
INSERT INTO `sys_menu` VALUES (25, 0, '节点工作台', 'M', '/workbench', 'LAYOUT', NULL, 'AppstoreOutlined', 1, 1, NULL, '2026-04-09 20:59:05', NULL, '2026-04-11 14:05:26', 0);
INSERT INTO `sys_menu` VALUES (26, 25, '节点工作台', 'C', 'nodes', '/order/workbench', 'workbench:list', NULL, 1, 1, NULL, '2026-04-09 20:59:05', NULL, '2026-04-09 21:04:12', 0);
INSERT INTO `sys_menu` VALUES (27, 4, '库存管理', 'C', '/supply/inventory', NULL, 'inventory:list', 'CubeOutline', 3, 1, NULL, '2026-04-14 22:09:37', NULL, '2026-04-14 22:09:37', 0);
INSERT INTO `sys_menu` VALUES (28, 4, '库存记录', 'C', '/supply/inventory/record', NULL, 'inventory:record', 'ListOutline', 4, 1, NULL, '2026-04-14 22:09:37', NULL, '2026-04-14 22:09:37', 0);
INSERT INTO `sys_menu` VALUES (29, 0, '客户管理', 'M', '/customer', NULL, NULL, 'PeopleOutline', 9, 1, NULL, '2026-04-14 22:09:37', NULL, '2026-04-14 22:09:37', 0);
INSERT INTO `sys_menu` VALUES (30, 29, '客户列表', 'C', '/customer/list', NULL, 'customer:list', NULL, 1, 1, NULL, '2026-04-14 22:09:37', NULL, '2026-04-14 22:09:37', 0);
INSERT INTO `sys_menu` VALUES (31, 29, '地址管理', 'C', '/customer/address', NULL, 'customer:address', NULL, 2, 1, NULL, '2026-04-14 22:09:37', NULL, '2026-04-14 22:09:37', 0);
INSERT INTO `sys_menu` VALUES (32, 3, '轮播图管理', 'C', '/config/banner', NULL, 'banner:list', 'ImagesOutline', 4, 1, NULL, '2026-04-14 22:09:37', NULL, '2026-04-14 22:09:37', 0);
INSERT INTO `sys_menu` VALUES (33, 3, 'AI配置', 'C', '/config/ai', NULL, 'ai:config', 'HardwareChipOutline', 5, 1, NULL, '2026-04-20 01:01:17', NULL, '2026-04-20 01:01:17', 0);

-- ----------------------------
-- Table structure for sys_oper_log
-- ----------------------------
DROP TABLE IF EXISTS `sys_oper_log`;
CREATE TABLE `sys_oper_log`  (
  `log_id` bigint NOT NULL AUTO_INCREMENT,
  `title` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '操作模块',
  `method` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '请求方法',
  `request_method` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'HTTP方法',
  `operator_id` bigint NULL DEFAULT NULL COMMENT '操作人ID',
  `operator_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '操作人账号',
  `oper_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '请求URL',
  `oper_ip` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '请求IP',
  `oper_param` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '请求参数',
  `json_result` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '返回结果',
  `status` tinyint(1) NULL DEFAULT NULL COMMENT '0=成功,1=失败',
  `error_msg` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '错误信息',
  `oper_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '操作时间',
  PRIMARY KEY (`log_id`) USING BTREE,
  INDEX `idx_operator`(`operator_id` ASC) USING BTREE,
  INDEX `idx_oper_time`(`oper_time` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 177 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '操作日志表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_oper_log
-- ----------------------------
INSERT INTO `sys_oper_log` VALUES (1, '新增字典类型', 'com.designstudio.system.controller.DictController.addType', 'POST', 1, 'admin', '/api/v1/admin/dict/types', '0:0:0:0:0:0:0:1', '[{\"dictName\":\"1\",\"dictType\":\"1\",\"remark\":\"\"}]', '{\"code\":200,\"msg\":\"success\"}', 0, NULL, '2026-04-05 14:58:12');
INSERT INTO `sys_oper_log` VALUES (2, '新增字典类型', 'com.designstudio.system.controller.DictController.addType', 'POST', 1, 'admin', '/api/v1/admin/dict/types', '0:0:0:0:0:0:0:1', '[{\"dictName\":\"1\",\"dictType\":\"1\",\"remark\":\"\"}]', NULL, 1, '\r\n### Error updating database.  Cause: java.sql.SQLIntegrityConstraintViolationException: Duplicate entry \'1\' for key \'sys_dict_type.uk_dict_type\'\r\n### The error may exist in com/designstudio/system/mapper/SysDictTypeMapper.java (best guess)\r\n### The error may involve com.designstudio.system.mapper.SysDictTypeMapper.insert-Inline\r\n### The error occurred while setting parameters\r\n### SQL: INSERT INTO sys_dict_type  ( dict_name, dict_type, remark )  VALUES (  ?, ?, ?  )\r\n### Cause: java.sql.SQLIntegrityConstraintViolationException: Duplicate entry \'1\' for key \'sys_dict_type.uk_dict_type\'\n; Duplicate entry \'1\' for key \'sys_dict_type.uk_dict_type\'', '2026-04-05 14:58:49');
INSERT INTO `sys_oper_log` VALUES (3, '新增字典类型', 'com.designstudio.system.controller.DictController.addType', 'POST', 1, 'admin', '/api/v1/admin/dict/types', '0:0:0:0:0:0:0:1', '[{\"dictName\":\"2\",\"dictType\":\"2\",\"remark\":\"\"}]', '{\"code\":200,\"msg\":\"success\"}', 0, NULL, '2026-04-05 15:00:10');
INSERT INTO `sys_oper_log` VALUES (4, '删除字典类型', 'com.designstudio.system.controller.DictController.deleteType', 'DELETE', 1, 'admin', '/api/v1/admin/dict/types/7', '0:0:0:0:0:0:0:1', '[7]', '{\"code\":200,\"msg\":\"success\"}', 0, NULL, '2026-04-05 15:03:49');
INSERT INTO `sys_oper_log` VALUES (5, '删除字典类型', 'com.designstudio.system.controller.DictController.deleteType', 'DELETE', 1, 'admin', '/api/v1/admin/dict/types/5', '0:0:0:0:0:0:0:1', '[5]', '{\"code\":200,\"msg\":\"success\"}', 0, NULL, '2026-04-05 15:03:51');
INSERT INTO `sys_oper_log` VALUES (6, '意向转订单', 'com.designstudio.order.controller.RequestController.convert', 'POST', 1, 'admin', '/api/v1/admin/requests/8/convert', '0:0:0:0:0:0:0:1', '[8,{\"designerId\":2,\"totalAmount\":800,\"prepayAmount\":300,\"expectedDate\":1777392000000,\"remark\":\"\"}]', '{\"code\":200,\"msg\":\"success\",\"data\":{\"orderId\":5,\"orderSn\":\"DS202604051756345882\",\"userId\":1,\"categoryId\":1,\"designerId\":2,\"status\":1,\"customDataSnapshot\":\"{\\\"chest\\\": \\\"1\\\", \\\"waist\\\": \\\"2\\\", \\\"length\\\": \\\"4\\\", \\\"shoulder\\\": \\\"3\\\"}\",\"totalAmount\":800,\"prepayAmount\":300,\"paidAmount\":0,\"expectedDate\":1777392000000,\"remark\":\"\",\"isBlocked\":0,\"createBy\":1,\"createTime\":1775382994117,\"updateBy\":1,\"updateTime\":1775382994117}}', 0, NULL, '2026-04-05 17:56:34');
INSERT INTO `sys_oper_log` VALUES (7, '后台登出', 'com.designstudio.system.controller.AuthController.logout', 'POST', 1, 'admin', '/api/v1/auth/logout', '0:0:0:0:0:0:0:1', '[\"Bearer eyJhbGciOiJIUzUxMiJ9.eyJuaWNrbmFtZSI6Iui2hee6p-euoeeQhuWRmCIsInVzZXJUeXBlIjoiYWRtaW4iLCJ1c2VySWQiOjEsInVzZXJuYW1lIjoiYWRtaW4iLCJzdWIiOiIxIiwiaWF0IjoxNzc1MzY3NjYwLCJleHAiOjE3NzU5NzI0NjB9.xD0w5V2WavGQSG0iQ8e-GptXBPXdSS47YpfDg_6IrlfXPwzwH1A5GeXDAkS-puOcl5Uo2exnjKEfN_XxPyR7eQ\"]', '{\"code\":200,\"msg\":\"success\"}', 0, NULL, '2026-04-06 14:02:28');
INSERT INTO `sys_oper_log` VALUES (8, '后台登录', 'com.designstudio.system.controller.AuthController.login', 'POST', NULL, NULL, '/api/v1/auth/login', '0:0:0:0:0:0:0:1', '[{\"username\":\"designer1\",\"password\":\"admin123\"}]', '{\"code\":200,\"msg\":\"success\",\"data\":{\"token\":\"eyJhbGciOiJIUzUxMiJ9.eyJuaWNrbmFtZSI6IuadjuiuvuiuoeW4iCIsInVzZXJUeXBlIjoiYWRtaW4iLCJ1c2VySWQiOjIsInVzZXJuYW1lIjoiZGVzaWduZXIxIiwic3ViIjoiMiIsImlhdCI6MTc3NTQ1NTM2NiwiZXhwIjoxNzc2MDYwMTY2fQ.O7hst5s6eidB-C7Ezti2Jo5PNdhP23yz_2_Cw2GolgSm2NWe4izW9EAxTz_e55wiIPkorOBTfAylgkneAJyT3w\",\"adminId\":2,\"username\":\"designer1\",\"nickname\":\"李设计师\"}}', 0, NULL, '2026-04-06 14:02:46');
INSERT INTO `sys_oper_log` VALUES (9, '后台登出', 'com.designstudio.system.controller.AuthController.logout', 'POST', 2, 'designer1', '/api/v1/auth/logout', '0:0:0:0:0:0:0:1', '[\"Bearer eyJhbGciOiJIUzUxMiJ9.eyJuaWNrbmFtZSI6IuadjuiuvuiuoeW4iCIsInVzZXJUeXBlIjoiYWRtaW4iLCJ1c2VySWQiOjIsInVzZXJuYW1lIjoiZGVzaWduZXIxIiwic3ViIjoiMiIsImlhdCI6MTc3NTQ1NTM2NiwiZXhwIjoxNzc2MDYwMTY2fQ.O7hst5s6eidB-C7Ezti2Jo5PNdhP23yz_2_Cw2GolgSm2NWe4izW9EAxTz_e55wiIPkorOBTfAylgkneAJyT3w\"]', '{\"code\":200,\"msg\":\"success\"}', 0, NULL, '2026-04-08 13:09:34');
INSERT INTO `sys_oper_log` VALUES (10, '后台登录', 'com.designstudio.system.controller.AuthController.login', 'POST', NULL, NULL, '/api/v1/auth/login', '0:0:0:0:0:0:0:1', '[{\"username\":\"admin\",\"password\":\"admin123\"}]', '{\"code\":200,\"msg\":\"success\",\"data\":{\"token\":\"eyJhbGciOiJIUzUxMiJ9.eyJuaWNrbmFtZSI6Iui2hee6p-euoeeQhuWRmCIsInVzZXJUeXBlIjoiYWRtaW4iLCJ1c2VySWQiOjEsInVzZXJuYW1lIjoiYWRtaW4iLCJzdWIiOiIxIiwiaWF0IjoxNzc1NjI0OTc2LCJleHAiOjE3NzYyMjk3NzZ9.ow98OIBRP7JaIF5SLJqo2hlUn1YQ9STuZCimnK4E07JhogjBxoX0OLXZlBPXQYdjSUNpn1anS9eM1SRidh26EQ\",\"adminId\":1,\"username\":\"admin\",\"nickname\":\"超级管理员\"}}', 0, NULL, '2026-04-08 13:09:37');
INSERT INTO `sys_oper_log` VALUES (11, '后台登录', 'com.designstudio.system.controller.AuthController.login', 'POST', NULL, NULL, '/api/v1/auth/login', '0:0:0:0:0:0:0:1', '[{\"username\":\"admin\",\"password\":\"admin123\"}]', '{\"code\":200,\"msg\":\"success\",\"data\":{\"token\":\"eyJhbGciOiJIUzUxMiJ9.eyJuaWNrbmFtZSI6Iui2hee6p-euoeeQhuWRmCIsInVzZXJUeXBlIjoiYWRtaW4iLCJ1c2VySWQiOjEsInVzZXJuYW1lIjoiYWRtaW4iLCJzdWIiOiIxIiwiaWF0IjoxNzc1NjMwNDg5LCJleHAiOjE3NzYyMzUyODl9.Ulw1Fn9jAx9raAPkieMqaQdNwvL8OJwGfrSYhkeUVNPHsMZSqFTjDmkTQzINI3uQx7YSMwfHipawshgsD12A1A\",\"adminId\":1,\"username\":\"admin\",\"nickname\":\"超级管理员\"}}', 0, NULL, '2026-04-08 14:41:29');
INSERT INTO `sys_oper_log` VALUES (12, '物料入库', 'com.designstudio.supply.controller.MaterialController.stockIn', 'POST', 1, 'admin', '/api/v1/admin/materials/1/stock-in', '0:0:0:0:0:0:0:1', '[1,{\"quantity\":10}]', '{\"code\":200,\"msg\":\"success\"}', 0, NULL, '2026-04-08 14:49:05');
INSERT INTO `sys_oper_log` VALUES (13, '后台登录', 'com.designstudio.system.controller.AuthController.login', 'POST', NULL, NULL, '/api/v1/auth/login', '0:0:0:0:0:0:0:1', '[{\"username\":\"admin\",\"password\":\"admin123\"}]', '{\"code\":200,\"msg\":\"success\",\"data\":{\"token\":\"eyJhbGciOiJIUzUxMiJ9.eyJuaWNrbmFtZSI6Iui2hee6p-euoeeQhuWRmCIsInVzZXJUeXBlIjoiYWRtaW4iLCJ1c2VySWQiOjEsInVzZXJuYW1lIjoiYWRtaW4iLCJzdWIiOiIxIiwiaWF0IjoxNzc1NjM2NDEzLCJleHAiOjE3NzYyNDEyMTN9.Pn3vQmwErKw8ZvW5pUt8Blbkzzu2QHm_SqTe_hy3TQ5_trkOtSjcCo5XhipHJ83Un6xMaJQDjR_MkM-N-2XL2Q\",\"adminId\":1,\"username\":\"admin\",\"nickname\":\"超级管理员\"}}', 0, NULL, '2026-04-08 16:20:13');
INSERT INTO `sys_oper_log` VALUES (14, '编辑后台用户', 'com.designstudio.system.controller.SysAdminController.update', 'PUT', 1, 'admin', '/api/v1/admin/users/3', '0:0:0:0:0:0:0:1', '[3,{\"username\":\"designer2\",\"password\":\"\",\"nickname\":\"王设计师\",\"phone\":\"13800001002\",\"status\":1,\"roleIds\":[2]}]', '{\"code\":200,\"msg\":\"success\"}', 0, NULL, '2026-04-09 19:08:28');
INSERT INTO `sys_oper_log` VALUES (15, '设置设计师品类', 'com.designstudio.system.controller.SysAdminController.updateCategories', 'PUT', 1, 'admin', '/api/v1/admin/users/3/categories', '0:0:0:0:0:0:0:1', '[3,[3,2]]', '{\"code\":200,\"msg\":\"success\"}', 0, NULL, '2026-04-09 19:08:28');
INSERT INTO `sys_oper_log` VALUES (16, '后台登录', 'com.designstudio.system.controller.AuthController.login', 'POST', NULL, NULL, '/api/v1/auth/login', '0:0:0:0:0:0:0:1', '[{\"username\":\"admin\",\"password\":\"admin123\"}]', '{\"code\":200,\"msg\":\"success\",\"data\":{\"token\":\"eyJhbGciOiJIUzUxMiJ9.eyJuaWNrbmFtZSI6Iui2hee6p-euoeeQhuWRmCIsInVzZXJUeXBlIjoiYWRtaW4iLCJ1c2VySWQiOjEsInVzZXJuYW1lIjoiYWRtaW4iLCJzdWIiOiIxIiwiaWF0IjoxNzc1NzM5OTQ5LCJleHAiOjE3NzYzNDQ3NDl9.xyE9LWy6GPLU4M1FJC388Q0Nf20nmEOPrLOZbPhrgIeESmOKt2MFsGMNDxsEbFaylOcxYqUXvoX-ImynWLhJOw\",\"adminId\":1,\"username\":\"admin\",\"nickname\":\"超级管理员\"}}', 0, NULL, '2026-04-09 21:05:48');
INSERT INTO `sys_oper_log` VALUES (17, '后台登录', 'com.designstudio.system.controller.AuthController.login', 'POST', NULL, NULL, '/api/v1/auth/login', '0:0:0:0:0:0:0:1', '[{\"username\":\"admin\",\"password\":\"admin123\"}]', '{\"code\":200,\"msg\":\"success\",\"data\":{\"token\":\"eyJhbGciOiJIUzUxMiJ9.eyJuaWNrbmFtZSI6Iui2hee6p-euoeeQhuWRmCIsInVzZXJUeXBlIjoiYWRtaW4iLCJ1c2VySWQiOjEsInVzZXJuYW1lIjoiYWRtaW4iLCJzdWIiOiIxIiwiaWF0IjoxNzc1NzM5OTYyLCJleHAiOjE3NzYzNDQ3NjJ9.qCjC6k94_T31d7uJIRrgb85pkAMD2zaBmDfWdin0E4ymRieHlgdz80rNTryZYOFBODzFIXsWXpEcmF8MMgKS7A\",\"adminId\":1,\"username\":\"admin\",\"nickname\":\"超级管理员\"}}', 0, NULL, '2026-04-09 21:06:02');
INSERT INTO `sys_oper_log` VALUES (18, '后台登录', 'com.designstudio.system.controller.AuthController.login', 'POST', NULL, NULL, '/api/v1/auth/login', '0:0:0:0:0:0:0:1', '[{\"username\":\"admin\",\"password\":\"admin123\"}]', '{\"code\":200,\"msg\":\"success\",\"data\":{\"token\":\"eyJhbGciOiJIUzUxMiJ9.eyJuaWNrbmFtZSI6Iui2hee6p-euoeeQhuWRmCIsInVzZXJUeXBlIjoiYWRtaW4iLCJ1c2VySWQiOjEsInVzZXJuYW1lIjoiYWRtaW4iLCJzdWIiOiIxIiwiaWF0IjoxNzc1NzM5OTYyLCJleHAiOjE3NzYzNDQ3NjJ9.qCjC6k94_T31d7uJIRrgb85pkAMD2zaBmDfWdin0E4ymRieHlgdz80rNTryZYOFBODzFIXsWXpEcmF8MMgKS7A\",\"adminId\":1,\"username\":\"admin\",\"nickname\":\"超级管理员\"}}', 0, NULL, '2026-04-09 21:06:03');
INSERT INTO `sys_oper_log` VALUES (19, '后台登录', 'com.designstudio.system.controller.AuthController.login', 'POST', NULL, NULL, '/api/v1/auth/login', '0:0:0:0:0:0:0:1', '[{\"username\":\"admin\",\"password\":\"admin123\"}]', '{\"code\":200,\"msg\":\"success\",\"data\":{\"token\":\"eyJhbGciOiJIUzUxMiJ9.eyJuaWNrbmFtZSI6Iui2hee6p-euoeeQhuWRmCIsInVzZXJUeXBlIjoiYWRtaW4iLCJ1c2VySWQiOjEsInVzZXJuYW1lIjoiYWRtaW4iLCJzdWIiOiIxIiwiaWF0IjoxNzc1NzQwMTU5LCJleHAiOjE3NzYzNDQ5NTl9.3_Wh1nNmCJ2tuYk8qQvpCjq2Siojc7sHPpZpzzj4YI95Clk3Gq-NTeyZJz6VrrAeZcffGqAngFOW6JcTDC_toA\",\"adminId\":1,\"username\":\"admin\",\"nickname\":\"超级管理员\"}}', 0, NULL, '2026-04-09 21:09:18');
INSERT INTO `sys_oper_log` VALUES (20, '后台登录', 'com.designstudio.system.controller.AuthController.login', 'POST', NULL, NULL, '/api/v1/auth/login', '0:0:0:0:0:0:0:1', '[{\"username\":\"admin\",\"password\":\"admin123\"}]', '{\"code\":200,\"msg\":\"success\",\"data\":{\"token\":\"eyJhbGciOiJIUzUxMiJ9.eyJuaWNrbmFtZSI6Iui2hee6p-euoeeQhuWRmCIsInVzZXJUeXBlIjoiYWRtaW4iLCJ1c2VySWQiOjEsInVzZXJuYW1lIjoiYWRtaW4iLCJzdWIiOiIxIiwiaWF0IjoxNzc1NzQwMTU5LCJleHAiOjE3NzYzNDQ5NTl9.3_Wh1nNmCJ2tuYk8qQvpCjq2Siojc7sHPpZpzzj4YI95Clk3Gq-NTeyZJz6VrrAeZcffGqAngFOW6JcTDC_toA\",\"adminId\":1,\"username\":\"admin\",\"nickname\":\"超级管理员\"}}', 0, NULL, '2026-04-09 21:09:18');
INSERT INTO `sys_oper_log` VALUES (21, '后台登录', 'com.designstudio.system.controller.AuthController.login', 'POST', NULL, NULL, '/api/v1/auth/login', '0:0:0:0:0:0:0:1', '[{\"username\":\"admin\",\"password\":\"admin123\"}]', '{\"code\":200,\"msg\":\"success\",\"data\":{\"token\":\"eyJhbGciOiJIUzUxMiJ9.eyJuaWNrbmFtZSI6Iui2hee6p-euoeeQhuWRmCIsInVzZXJUeXBlIjoiYWRtaW4iLCJ1c2VySWQiOjEsInVzZXJuYW1lIjoiYWRtaW4iLCJzdWIiOiIxIiwiaWF0IjoxNzc1NzQwMTg3LCJleHAiOjE3NzYzNDQ5ODd9.aTz8pn9T05i3x_w0264D4jw022N7EoRhPiNhs-HJufMA54O9sqmtjzjquAFN_bwKNk5vMC5v23bAdXnoJBw0Rg\",\"adminId\":1,\"username\":\"admin\",\"nickname\":\"超级管理员\"}}', 0, NULL, '2026-04-09 21:09:48');
INSERT INTO `sys_oper_log` VALUES (22, '后台登录', 'com.designstudio.system.controller.AuthController.login', 'POST', NULL, NULL, '/api/v1/auth/login', '0:0:0:0:0:0:0:1', '[{\"username\":\"admin\",\"password\":\"admin123\"}]', '{\"code\":200,\"msg\":\"success\",\"data\":{\"token\":\"eyJhbGciOiJIUzUxMiJ9.eyJuaWNrbmFtZSI6Iui2hee6p-euoeeQhuWRmCIsInVzZXJUeXBlIjoiYWRtaW4iLCJ1c2VySWQiOjEsInVzZXJuYW1lIjoiYWRtaW4iLCJzdWIiOiIxIiwiaWF0IjoxNzc1NzQwMTg3LCJleHAiOjE3NzYzNDQ5ODd9.aTz8pn9T05i3x_w0264D4jw022N7EoRhPiNhs-HJufMA54O9sqmtjzjquAFN_bwKNk5vMC5v23bAdXnoJBw0Rg\",\"adminId\":1,\"username\":\"admin\",\"nickname\":\"超级管理员\"}}', 0, NULL, '2026-04-09 21:09:48');
INSERT INTO `sys_oper_log` VALUES (23, '执行节点工作台动作', 'com.designstudio.order.controller.WorkbenchController.action', 'POST', 1, 'admin', '/api/v1/admin/workbench/orders/1/action', '0:0:0:0:0:0:0:1', '[1,{\"action\":\"save\",\"description\":\"?????????\",\"imageUrls\":\"\",\"blockReason\":\"\"}]', '{\"code\":500,\"msg\":\"\\r\\n### Error updating database.  Cause: com.mysql.cj.jdbc.exceptions.MysqlDataTruncation: Data truncation: Invalid JSON text: \\\"The document is empty.\\\" at position 0 in value for column \'ds_order_progress.image_urls\'.\\r\\n### The error may exist in com/designstudio/order/mapper/DsOrderProgressMapper.java (best guess)\\r\\n### The error may involve com.designstudio.order.mapper.DsOrderProgressMapper.insert-Inline\\r\\n### The error occurred while setting parameters\\r\\n### SQL: INSERT INTO ds_order_progress  ( order_id, step_id, description, image_urls, operator_id, create_time, del_flag )  VALUES (  ?, ?, ?, ?, ?, ?, ?  )\\r\\n### Cause: com.mysql.cj.jdbc.exceptions.MysqlDataTruncation: Data truncation: Invalid JSON text: \\\"The document is empty.\\\" at position 0 in value for column \'ds_order_progress.image_urls\'.\\n; Data truncation: Invalid JSON text: \\\"The document is empty.\\\" at position 0 in value for column \'ds_order_progress.image_urls\'.\"}', 0, NULL, '2026-04-09 21:09:48');
INSERT INTO `sys_oper_log` VALUES (24, '后台登录', 'com.designstudio.system.controller.AuthController.login', 'POST', NULL, NULL, '/api/v1/auth/login', '0:0:0:0:0:0:0:1', '[{\"username\":\"admin\",\"password\":\"admin123\"}]', '{\"code\":200,\"msg\":\"success\",\"data\":{\"token\":\"eyJhbGciOiJIUzUxMiJ9.eyJuaWNrbmFtZSI6Iui2hee6p-euoeeQhuWRmCIsInVzZXJUeXBlIjoiYWRtaW4iLCJ1c2VySWQiOjEsInVzZXJuYW1lIjoiYWRtaW4iLCJzdWIiOiIxIiwiaWF0IjoxNzc1NzQwMzk3LCJleHAiOjE3NzYzNDUxOTd9.KpYbUbwI_NSR8--FUFwJdtPyHNqIgOYIq1woEMYhSinoKT9M_9c2JHtl1J7nUAcqsT-STsC9ZSVUJZW0q0IAhA\",\"adminId\":1,\"username\":\"admin\",\"nickname\":\"超级管理员\"}}', 0, NULL, '2026-04-09 21:13:16');
INSERT INTO `sys_oper_log` VALUES (25, '执行节点工作台动作', 'com.designstudio.order.controller.WorkbenchController.action', 'POST', 1, 'admin', '/api/v1/admin/workbench/orders/1/action', '0:0:0:0:0:0:0:1', '[1,{\"action\":\"save\",\"description\":\"?????????\",\"imageUrls\":\"\",\"blockReason\":\"\"}]', '{\"code\":200,\"msg\":\"success\"}', 0, NULL, '2026-04-09 21:13:19');
INSERT INTO `sys_oper_log` VALUES (26, '后台登录', 'com.designstudio.system.controller.AuthController.login', 'POST', NULL, NULL, '/api/v1/auth/login', '0:0:0:0:0:0:0:1', '[{\"username\":\"admin\",\"password\":\"admin123\"}]', '{\"code\":200,\"msg\":\"success\",\"data\":{\"token\":\"eyJhbGciOiJIUzUxMiJ9.eyJuaWNrbmFtZSI6Iui2hee6p-euoeeQhuWRmCIsInVzZXJUeXBlIjoiYWRtaW4iLCJ1c2VySWQiOjEsInVzZXJuYW1lIjoiYWRtaW4iLCJzdWIiOiIxIiwiaWF0IjoxNzc1NzQxNTY1LCJleHAiOjE3NzYzNDYzNjV9.WvvxUhGjsDmvcYVN3SKiXibImknU8NDiLky0hr8D510vS6QHuH4e-sjNuteDjh4PSFvERdVymhNrEdFCPkutlg\",\"adminId\":1,\"username\":\"admin\",\"nickname\":\"超级管理员\"}}', 0, NULL, '2026-04-09 21:32:45');
INSERT INTO `sys_oper_log` VALUES (27, '后台登录', 'com.designstudio.system.controller.AuthController.login', 'POST', NULL, NULL, '/api/v1/auth/login', '0:0:0:0:0:0:0:1', '[{\"username\":\"admin\",\"password\":\"admin123\"}]', '{\"code\":200,\"msg\":\"success\",\"data\":{\"token\":\"eyJhbGciOiJIUzUxMiJ9.eyJuaWNrbmFtZSI6Iui2hee6p-euoeeQhuWRmCIsInVzZXJUeXBlIjoiYWRtaW4iLCJ1c2VySWQiOjEsInVzZXJuYW1lIjoiYWRtaW4iLCJzdWIiOiIxIiwiaWF0IjoxNzc1NzQxNTgyLCJleHAiOjE3NzYzNDYzODJ9.N5lgBiGewEWHxITV4sQsZj6YLFzDk_najMXqtMLRjWsyNgUc1ISPp2wBwOgpnqxxzSZGP-gJ4Z4Pu693ITWyPA\",\"adminId\":1,\"username\":\"admin\",\"nickname\":\"超级管理员\"}}', 0, NULL, '2026-04-09 21:33:02');
INSERT INTO `sys_oper_log` VALUES (28, '执行节点工作台动作', 'com.designstudio.order.controller.WorkbenchController.action', 'POST', 1, 'admin', '/api/v1/admin/workbench/orders/1/action', '0:0:0:0:0:0:0:1', '[1,{\"action\":\"save\",\"description\":\"no-image-check\"}]', '{\"code\":500,\"msg\":\"当前节点要求上传图片\"}', 0, NULL, '2026-04-09 21:33:02');
INSERT INTO `sys_oper_log` VALUES (29, '后台登录', 'com.designstudio.system.controller.AuthController.login', 'POST', NULL, NULL, '/api/v1/auth/login', '0:0:0:0:0:0:0:1', '[{\"username\":\"admin\",\"password\":\"admin123\"}]', '{\"code\":200,\"msg\":\"success\",\"data\":{\"token\":\"eyJhbGciOiJIUzUxMiJ9.eyJuaWNrbmFtZSI6Iui2hee6p-euoeeQhuWRmCIsInVzZXJUeXBlIjoiYWRtaW4iLCJ1c2VySWQiOjEsInVzZXJuYW1lIjoiYWRtaW4iLCJzdWIiOiIxIiwiaWF0IjoxNzc1NzQxNjAzLCJleHAiOjE3NzYzNDY0MDN9.UHP_EtmrFxs3SyD48OYEON1IgJ1ufC_W3Y0na8MXLfDvG1nZCoj9Ta4ogwPBR-rfXwBgP2v6fio3aV-cczwq6w\",\"adminId\":1,\"username\":\"admin\",\"nickname\":\"超级管理员\"}}', 0, NULL, '2026-04-09 21:33:23');
INSERT INTO `sys_oper_log` VALUES (30, '后台登录', 'com.designstudio.system.controller.AuthController.login', 'POST', NULL, NULL, '/api/v1/auth/login', '0:0:0:0:0:0:0:1', '[{\"username\":\"admin\",\"password\":\"admin123\"}]', '{\"code\":200,\"msg\":\"success\",\"data\":{\"token\":\"eyJhbGciOiJIUzUxMiJ9.eyJuaWNrbmFtZSI6Iui2hee6p-euoeeQhuWRmCIsInVzZXJUeXBlIjoiYWRtaW4iLCJ1c2VySWQiOjEsInVzZXJuYW1lIjoiYWRtaW4iLCJzdWIiOiIxIiwiaWF0IjoxNzc1NzQxNjIwLCJleHAiOjE3NzYzNDY0MjB9.-TxfGCn_DiKNccma1fxlFJqcXEc6xyacd0egO7m-xv5uURIuLKhyEe_ZaLN3zwAIPuqtF8rMkkrxqIRZtSYTJg\",\"adminId\":1,\"username\":\"admin\",\"nickname\":\"超级管理员\"}}', 0, NULL, '2026-04-09 21:33:41');
INSERT INTO `sys_oper_log` VALUES (31, '执行节点工作台动作', 'com.designstudio.order.controller.WorkbenchController.action', 'POST', 1, 'admin', '/api/v1/admin/workbench/orders/1/action', '0:0:0:0:0:0:0:1', '[1,{\"action\":\"save\",\"description\":\"no-image-check\"}]', '{\"code\":500,\"msg\":\"当前节点要求上传图片\"}', 0, NULL, '2026-04-09 21:33:41');
INSERT INTO `sys_oper_log` VALUES (32, '执行节点工作台动作', 'com.designstudio.order.controller.WorkbenchController.action', 'POST', 1, 'admin', '/api/v1/admin/workbench/orders/1/action', '0:0:0:0:0:0:0:1', '[1,{\"action\":\"save\",\"description\":\"upload-ok\",\"imageUrls\":\"\\\"/uploads/321f10cac04241249a1c608ce6c9b048.png\\\"\"}]', '{\"code\":200,\"msg\":\"success\"}', 0, NULL, '2026-04-09 21:33:42');
INSERT INTO `sys_oper_log` VALUES (33, '后台登出', 'com.designstudio.system.controller.AuthController.logout', 'POST', 1, 'admin', '/api/v1/auth/logout', '0:0:0:0:0:0:0:1', '[\"Bearer eyJhbGciOiJIUzUxMiJ9.eyJuaWNrbmFtZSI6Iui2hee6p-euoeeQhuWRmCIsInVzZXJUeXBlIjoiYWRtaW4iLCJ1c2VySWQiOjEsInVzZXJuYW1lIjoiYWRtaW4iLCJzdWIiOiIxIiwiaWF0IjoxNzc1NjM2NDEzLCJleHAiOjE3NzYyNDEyMTN9.Pn3vQmwErKw8ZvW5pUt8Blbkzzu2QHm_SqTe_hy3TQ5_trkOtSjcCo5XhipHJ83Un6xMaJQDjR_MkM-N-2XL2Q\"]', '{\"code\":200,\"msg\":\"success\"}', 0, NULL, '2026-04-09 21:36:01');
INSERT INTO `sys_oper_log` VALUES (34, '后台登录', 'com.designstudio.system.controller.AuthController.login', 'POST', NULL, NULL, '/api/v1/auth/login', '0:0:0:0:0:0:0:1', '[{\"username\":\"admin\",\"password\":\"admin123\"}]', '{\"code\":200,\"msg\":\"success\",\"data\":{\"token\":\"eyJhbGciOiJIUzUxMiJ9.eyJuaWNrbmFtZSI6Iui2hee6p-euoeeQhuWRmCIsInVzZXJUeXBlIjoiYWRtaW4iLCJ1c2VySWQiOjEsInVzZXJuYW1lIjoiYWRtaW4iLCJzdWIiOiIxIiwiaWF0IjoxNzc1NzQxNzY2LCJleHAiOjE3NzYzNDY1NjZ9.4i4jizppUdqkp_4GjOBdD-NQvkOZSAEaexXWlO1y7i9vOZCrjQuHa1aA02XxGMfzt-Fya80h-Zuk-mUHj-fQpQ\",\"adminId\":1,\"username\":\"admin\",\"nickname\":\"超级管理员\"}}', 0, NULL, '2026-04-09 21:36:06');
INSERT INTO `sys_oper_log` VALUES (35, '意向转订单', 'com.designstudio.order.controller.RequestController.convert', 'POST', 1, 'admin', '/api/v1/admin/requests/9/convert', '0:0:0:0:0:0:0:1', '[9,{\"designerId\":2,\"totalAmount\":100,\"prepayAmount\":10,\"expectedDate\":1775664000000,\"remark\":\"\"}]', '{\"code\":200,\"msg\":\"success\",\"data\":{\"orderId\":6,\"orderSn\":\"DS202604092137346349\",\"userId\":1,\"categoryId\":1,\"designerId\":2,\"currentStepId\":1,\"status\":0,\"customDataSnapshot\":\"{\\\"chest\\\": \\\"20\\\", \\\"waist\\\": \\\"30\\\", \\\"shoulder\\\": \\\"20\\\"}\",\"totalAmount\":100,\"prepayAmount\":10,\"paidAmount\":0,\"expectedDate\":1775664000000,\"remark\":\"\",\"isBlocked\":0,\"createBy\":1,\"createTime\":1775741854582,\"updateBy\":1,\"updateTime\":1775741854582}}', 0, NULL, '2026-04-09 21:37:35');
INSERT INTO `sys_oper_log` VALUES (36, '添加订单进度', 'com.designstudio.order.controller.OrderController.addProgress', 'POST', 1, 'admin', '/api/v1/admin/orders/6/progress', '0:0:0:0:0:0:0:1', '[6,{\"description\":\"1\"}]', '{\"code\":200,\"msg\":\"success\"}', 0, NULL, '2026-04-09 21:37:59');
INSERT INTO `sys_oper_log` VALUES (37, '后台登出', 'com.designstudio.system.controller.AuthController.logout', 'POST', 1, 'admin', '/api/v1/auth/logout', '0:0:0:0:0:0:0:1', '[\"Bearer eyJhbGciOiJIUzUxMiJ9.eyJuaWNrbmFtZSI6Iui2hee6p-euoeeQhuWRmCIsInVzZXJUeXBlIjoiYWRtaW4iLCJ1c2VySWQiOjEsInVzZXJuYW1lIjoiYWRtaW4iLCJzdWIiOiIxIiwiaWF0IjoxNzc1NzQxNzY2LCJleHAiOjE3NzYzNDY1NjZ9.4i4jizppUdqkp_4GjOBdD-NQvkOZSAEaexXWlO1y7i9vOZCrjQuHa1aA02XxGMfzt-Fya80h-Zuk-mUHj-fQpQ\"]', '{\"code\":200,\"msg\":\"success\"}', 0, NULL, '2026-04-09 21:41:36');
INSERT INTO `sys_oper_log` VALUES (38, '后台登录', 'com.designstudio.system.controller.AuthController.login', 'POST', NULL, NULL, '/api/v1/auth/login', '0:0:0:0:0:0:0:1', '[{\"username\":\"desgner1\",\"password\":\"admin123\"}]', NULL, 1, '用户名或密码错误', '2026-04-09 21:41:43');
INSERT INTO `sys_oper_log` VALUES (39, '后台登录', 'com.designstudio.system.controller.AuthController.login', 'POST', NULL, NULL, '/api/v1/auth/login', '0:0:0:0:0:0:0:1', '[{\"username\":\"desgner1\",\"password\":\"123456\"}]', NULL, 1, '用户名或密码错误', '2026-04-09 21:41:55');
INSERT INTO `sys_oper_log` VALUES (40, '后台登录', 'com.designstudio.system.controller.AuthController.login', 'POST', NULL, NULL, '/api/v1/auth/login', '0:0:0:0:0:0:0:1', '[{\"username\":\"designer1\",\"password\":\"123456\"}]', NULL, 1, '用户名或密码错误', '2026-04-09 21:41:59');
INSERT INTO `sys_oper_log` VALUES (41, '后台登录', 'com.designstudio.system.controller.AuthController.login', 'POST', NULL, NULL, '/api/v1/auth/login', '0:0:0:0:0:0:0:1', '[{\"username\":\"designer1\",\"password\":\"admin123\"}]', '{\"code\":200,\"msg\":\"success\",\"data\":{\"token\":\"eyJhbGciOiJIUzUxMiJ9.eyJuaWNrbmFtZSI6IuadjuiuvuiuoeW4iCIsInVzZXJUeXBlIjoiYWRtaW4iLCJ1c2VySWQiOjIsInVzZXJuYW1lIjoiZGVzaWduZXIxIiwic3ViIjoiMiIsImlhdCI6MTc3NTc0MjEyNCwiZXhwIjoxNzc2MzQ2OTI0fQ.miry4jcJs-O166Y5ErHq8CYUph0fAJ2Obz682ejbl1eHdtB1Knly2mgZnrUMnTOjI-UnU4xOJ6Odo6fdjuHguA\",\"adminId\":2,\"username\":\"designer1\",\"nickname\":\"李设计师\"}}', 0, NULL, '2026-04-09 21:42:04');
INSERT INTO `sys_oper_log` VALUES (42, '执行节点工作台动作', 'com.designstudio.order.controller.WorkbenchController.action', 'POST', 2, 'designer1', '/api/v1/admin/workbench/orders/6/action', '0:0:0:0:0:0:0:1', '[6,{\"action\":\"block\",\"blockReason\":\"11\"}]', '{\"code\":200,\"msg\":\"success\"}', 0, NULL, '2026-04-09 21:42:51');
INSERT INTO `sys_oper_log` VALUES (43, '执行节点工作台动作', 'com.designstudio.order.controller.WorkbenchController.action', 'POST', 2, 'designer1', '/api/v1/admin/workbench/orders/6/action', '0:0:0:0:0:0:0:1', '[6,{\"action\":\"unblock\"}]', '{\"code\":200,\"msg\":\"success\"}', 0, NULL, '2026-04-09 21:43:14');
INSERT INTO `sys_oper_log` VALUES (44, '执行节点工作台动作', 'com.designstudio.order.controller.WorkbenchController.action', 'POST', 2, 'designer1', '/api/v1/admin/workbench/orders/6/action', '0:0:0:0:0:0:0:1', '[6,{\"action\":\"block\",\"blockReason\":\"13\"}]', '{\"code\":200,\"msg\":\"success\"}', 0, NULL, '2026-04-09 21:43:17');
INSERT INTO `sys_oper_log` VALUES (45, '执行节点工作台动作', 'com.designstudio.order.controller.WorkbenchController.action', 'POST', 2, 'designer1', '/api/v1/admin/workbench/orders/6/action', '0:0:0:0:0:0:0:1', '[6,{\"action\":\"unblock\"}]', '{\"code\":200,\"msg\":\"success\"}', 0, NULL, '2026-04-09 21:43:22');
INSERT INTO `sys_oper_log` VALUES (46, '后台登出', 'com.designstudio.system.controller.AuthController.logout', 'POST', 2, 'designer1', '/api/v1/auth/logout', '0:0:0:0:0:0:0:1', '[\"Bearer eyJhbGciOiJIUzUxMiJ9.eyJuaWNrbmFtZSI6IuadjuiuvuiuoeW4iCIsInVzZXJUeXBlIjoiYWRtaW4iLCJ1c2VySWQiOjIsInVzZXJuYW1lIjoiZGVzaWduZXIxIiwic3ViIjoiMiIsImlhdCI6MTc3NTc0MjEyNCwiZXhwIjoxNzc2MzQ2OTI0fQ.miry4jcJs-O166Y5ErHq8CYUph0fAJ2Obz682ejbl1eHdtB1Knly2mgZnrUMnTOjI-UnU4xOJ6Odo6fdjuHguA\"]', '{\"code\":200,\"msg\":\"success\"}', 0, NULL, '2026-04-09 21:48:11');
INSERT INTO `sys_oper_log` VALUES (47, '后台登录', 'com.designstudio.system.controller.AuthController.login', 'POST', NULL, NULL, '/api/v1/auth/login', '0:0:0:0:0:0:0:1', '[{\"username\":\"admin\",\"password\":\"admin123\"}]', '{\"code\":200,\"msg\":\"success\",\"data\":{\"token\":\"eyJhbGciOiJIUzUxMiJ9.eyJuaWNrbmFtZSI6Iui2hee6p-euoeeQhuWRmCIsInVzZXJUeXBlIjoiYWRtaW4iLCJ1c2VySWQiOjEsInVzZXJuYW1lIjoiYWRtaW4iLCJzdWIiOiIxIiwiaWF0IjoxNzc1NzQyNDkyLCJleHAiOjE3NzYzNDcyOTJ9.WxezeHqI19aA5zCUmTxqMTpSVJKtE7sOTlalE36ZFKuyhRdxhupmTk5WPvjQFgNPYhVXJdNY-NKXyk6F6zj2Rg\",\"adminId\":1,\"username\":\"admin\",\"nickname\":\"超级管理员\"}}', 0, NULL, '2026-04-09 21:48:13');
INSERT INTO `sys_oper_log` VALUES (48, '后台登录', 'com.designstudio.system.controller.AuthController.login', 'POST', NULL, NULL, '/api/v1/auth/login', '0:0:0:0:0:0:0:1', '[{\"username\":\"admin\",\"password\":\"admin123\"}]', '{\"code\":200,\"msg\":\"success\",\"data\":{\"token\":\"eyJhbGciOiJIUzUxMiJ9.eyJuaWNrbmFtZSI6Iui2hee6p-euoeeQhuWRmCIsInVzZXJUeXBlIjoiYWRtaW4iLCJ1c2VySWQiOjEsInVzZXJuYW1lIjoiYWRtaW4iLCJzdWIiOiIxIiwiaWF0IjoxNzc1NzQyNzQyLCJleHAiOjE3NzYzNDc1NDJ9.e-NMGP95iT9AKDx4MXMcnm9x0bu2jfIpUVKarHSNu92HGHZsL13-PhIBC-iCTXfCk4y4JRqbh_Ie9jMGwdWHTw\",\"adminId\":1,\"username\":\"admin\",\"nickname\":\"超级管理员\"}}', 0, NULL, '2026-04-09 21:52:22');
INSERT INTO `sys_oper_log` VALUES (49, '后台登录', 'com.designstudio.system.controller.AuthController.login', 'POST', NULL, NULL, '/api/v1/auth/login', '0:0:0:0:0:0:0:1', '[{\"username\":\"admin\",\"password\":\"admin123\"}]', '{\"code\":200,\"msg\":\"success\",\"data\":{\"token\":\"eyJhbGciOiJIUzUxMiJ9.eyJuaWNrbmFtZSI6Iui2hee6p-euoeeQhuWRmCIsInVzZXJUeXBlIjoiYWRtaW4iLCJ1c2VySWQiOjEsInVzZXJuYW1lIjoiYWRtaW4iLCJzdWIiOiIxIiwiaWF0IjoxNzc1Nzg4NDQyLCJleHAiOjE3NzYzOTMyNDJ9.VJ2GTCqr_Qz8RWz2AXeFObQi3r-b5SjgBLHTvb4EXXomOEIbVsLSTJO9zN_rDOYJnUwTyr9M2a4Lw15ZmY_Mtw\",\"adminId\":1,\"username\":\"admin\",\"nickname\":\"超级管理员\"}}', 0, NULL, '2026-04-10 10:34:02');
INSERT INTO `sys_oper_log` VALUES (50, '后台登录', 'com.designstudio.system.controller.AuthController.login', 'POST', NULL, NULL, '/api/v1/auth/login', '0:0:0:0:0:0:0:1', '[{\"username\":\"admin\",\"password\":\"admin123\"}]', '{\"code\":200,\"msg\":\"success\",\"data\":{\"token\":\"eyJhbGciOiJIUzUxMiJ9.eyJuaWNrbmFtZSI6Iui2hee6p-euoeeQhuWRmCIsInVzZXJUeXBlIjoiYWRtaW4iLCJ1c2VySWQiOjEsInVzZXJuYW1lIjoiYWRtaW4iLCJzdWIiOiIxIiwiaWF0IjoxNzc1Nzg4NDUxLCJleHAiOjE3NzYzOTMyNTF9.X7KyYIG6JTIPLB-Q21XNXBJTGH2nvxFdlJzOm2IQzeQnpaYTUl4WoLEEGogSseS0_qzz_Md_AjZvCPX47Ix9PQ\",\"adminId\":1,\"username\":\"admin\",\"nickname\":\"超级管理员\"}}', 0, NULL, '2026-04-10 10:34:12');
INSERT INTO `sys_oper_log` VALUES (51, '后台登录', 'com.designstudio.system.controller.AuthController.login', 'POST', NULL, NULL, '/api/v1/auth/login', '0:0:0:0:0:0:0:1', '[{\"username\":\"admin\",\"password\":\"admin123\"}]', '{\"code\":200,\"msg\":\"success\",\"data\":{\"token\":\"eyJhbGciOiJIUzUxMiJ9.eyJuaWNrbmFtZSI6Iui2hee6p-euoeeQhuWRmCIsInVzZXJUeXBlIjoiYWRtaW4iLCJ1c2VySWQiOjEsInVzZXJuYW1lIjoiYWRtaW4iLCJzdWIiOiIxIiwiaWF0IjoxNzc1Nzg4NDYxLCJleHAiOjE3NzYzOTMyNjF9.cc5VHXDqglC887KQG9cYF7FshOPY5dgUwMpf53kKspJAMj5PYeoVLaov_JMstKNMaQX2L_I0stFVqjST18AH4A\",\"adminId\":1,\"username\":\"admin\",\"nickname\":\"超级管理员\"}}', 0, NULL, '2026-04-10 10:34:21');
INSERT INTO `sys_oper_log` VALUES (52, '后台登录', 'com.designstudio.system.controller.AuthController.login', 'POST', NULL, NULL, '/api/v1/auth/login', '0:0:0:0:0:0:0:1', '[{\"username\":\"admin\",\"password\":\"admin123\"}]', '{\"code\":200,\"msg\":\"success\",\"data\":{\"token\":\"eyJhbGciOiJIUzUxMiJ9.eyJuaWNrbmFtZSI6Iui2hee6p-euoeeQhuWRmCIsInVzZXJUeXBlIjoiYWRtaW4iLCJ1c2VySWQiOjEsInVzZXJuYW1lIjoiYWRtaW4iLCJzdWIiOiIxIiwiaWF0IjoxNzc1Nzg4NDY4LCJleHAiOjE3NzYzOTMyNjh9.Ya7tN-PFdam-QETlKLcN04EQqrdn1ZuR26k-ruTtmNJBhwWB_jyBlVv6oR73yFOemwcY0DYXc-1-FNJnnDYOTw\",\"adminId\":1,\"username\":\"admin\",\"nickname\":\"超级管理员\"}}', 0, NULL, '2026-04-10 10:34:28');
INSERT INTO `sys_oper_log` VALUES (53, '后台登录', 'com.designstudio.system.controller.AuthController.login', 'POST', NULL, NULL, '/api/v1/auth/login', '0:0:0:0:0:0:0:1', '[{\"username\":\"admin\",\"password\":\"admin123\"}]', '{\"code\":200,\"msg\":\"success\",\"data\":{\"token\":\"eyJhbGciOiJIUzUxMiJ9.eyJuaWNrbmFtZSI6Iui2hee6p-euoeeQhuWRmCIsInVzZXJUeXBlIjoiYWRtaW4iLCJ1c2VySWQiOjEsInVzZXJuYW1lIjoiYWRtaW4iLCJzdWIiOiIxIiwiaWF0IjoxNzc1Nzg4NTcyLCJleHAiOjE3NzYzOTMzNzJ9.nm9oHs1fOFGGMerJtW_DyZKtNqHUzd4IxFQsAPyvrIxLGQF7fXGonrDghXVBki-NjQd7VDuD3MnO02rx0xHwbw\",\"adminId\":1,\"username\":\"admin\",\"nickname\":\"超级管理员\"}}', 0, NULL, '2026-04-10 10:36:12');
INSERT INTO `sys_oper_log` VALUES (54, '后台登录', 'com.designstudio.system.controller.AuthController.login', 'POST', NULL, NULL, '/api/v1/auth/login', '0:0:0:0:0:0:0:1', '[{\"username\":\"admin\",\"password\":\"admin123\"}]', '{\"code\":200,\"msg\":\"success\",\"data\":{\"token\":\"eyJhbGciOiJIUzUxMiJ9.eyJuaWNrbmFtZSI6Iui2hee6p-euoeeQhuWRmCIsInVzZXJUeXBlIjoiYWRtaW4iLCJ1c2VySWQiOjEsInVzZXJuYW1lIjoiYWRtaW4iLCJzdWIiOiIxIiwiaWF0IjoxNzc1Nzg4NTg3LCJleHAiOjE3NzYzOTMzODd9.hnNZWvYNUip_BMbEh1m2SBjfL0rOOdXzRbpUGGSVsdcoXOovU8aYYn_nGPYrvNFYfTqnZ2wuKsIGKujeP3sdng\",\"adminId\":1,\"username\":\"admin\",\"nickname\":\"超级管理员\"}}', 0, NULL, '2026-04-10 10:36:27');
INSERT INTO `sys_oper_log` VALUES (55, '执行节点工作台动作', 'com.designstudio.order.controller.WorkbenchController.action', 'POST', 1, 'admin', '/api/v1/admin/workbench/orders/1/action', '0:0:0:0:0:0:0:1', '[1,{\"action\":\"rollback\",\"description\":\"rollback-api-test\"}]', '{\"code\":200,\"msg\":\"success\"}', 0, NULL, '2026-04-10 10:36:27');
INSERT INTO `sys_oper_log` VALUES (56, '执行节点工作台动作', 'com.designstudio.order.controller.WorkbenchController.action', 'POST', 1, 'admin', '/api/v1/admin/workbench/orders/1/action', '0:0:0:0:0:0:0:1', '[1,{\"action\":\"advance\",\"description\":\"rollback-restore\"}]', '{\"code\":200,\"msg\":\"success\"}', 0, NULL, '2026-04-10 10:36:28');
INSERT INTO `sys_oper_log` VALUES (57, '执行节点工作台动作', 'com.designstudio.order.controller.WorkbenchController.action', 'POST', 1, 'admin', '/api/v1/admin/workbench/orders/1/action', '0:0:0:0:0:0:0:1', '[1,{\"action\":\"rollback\"}]', '{\"code\":200,\"msg\":\"success\"}', 0, NULL, '2026-04-10 10:48:26');
INSERT INTO `sys_oper_log` VALUES (58, '后台登录', 'com.designstudio.system.controller.AuthController.login', 'POST', NULL, NULL, '/api/v1/auth/login', '0:0:0:0:0:0:0:1', '[{\"username\":\"admin\",\"password\":\"admin123\"}]', '{\"code\":200,\"msg\":\"success\",\"data\":{\"token\":\"eyJhbGciOiJIUzUxMiJ9.eyJuaWNrbmFtZSI6Iui2hee6p-euoeeQhuWRmCIsInVzZXJUeXBlIjoiYWRtaW4iLCJ1c2VySWQiOjEsInVzZXJuYW1lIjoiYWRtaW4iLCJzdWIiOiIxIiwiaWF0IjoxNzc1Nzg5NTcyLCJleHAiOjE3NzYzOTQzNzJ9.QjxO0pg3TAZg_2h3-aBoaBVcSzk0zaAOBm24UUp1vCPgl0tW_OOeskIyknQ_dYnXpO25QxFihLgBFvT8-9NpzA\",\"adminId\":1,\"username\":\"admin\",\"nickname\":\"超级管理员\"}}', 0, NULL, '2026-04-10 10:52:51');
INSERT INTO `sys_oper_log` VALUES (59, '后台登录', 'com.designstudio.system.controller.AuthController.login', 'POST', NULL, NULL, '/api/v1/auth/login', '0:0:0:0:0:0:0:1', '[{\"username\":\"admin\",\"password\":\"admin123\"}]', '{\"code\":200,\"msg\":\"success\",\"data\":{\"token\":\"eyJhbGciOiJIUzUxMiJ9.eyJuaWNrbmFtZSI6Iui2hee6p-euoeeQhuWRmCIsInVzZXJUeXBlIjoiYWRtaW4iLCJ1c2VySWQiOjEsInVzZXJuYW1lIjoiYWRtaW4iLCJzdWIiOiIxIiwiaWF0IjoxNzc1Nzg5NTg0LCJleHAiOjE3NzYzOTQzODR9.WLEC_wTgnvYi0d7HD6Slnv_IIOscUb4BaDC2_Ig4dRru0TBz2Wnr2PBa0EpGIjE0TS8D6g3_KOmMs3zMSXNnMA\",\"adminId\":1,\"username\":\"admin\",\"nickname\":\"超级管理员\"}}', 0, NULL, '2026-04-10 10:53:05');
INSERT INTO `sys_oper_log` VALUES (60, '后台登录', 'com.designstudio.system.controller.AuthController.login', 'POST', NULL, NULL, '/api/v1/auth/login', '0:0:0:0:0:0:0:1', '[{\"username\":\"admin\",\"password\":\"admin123\"}]', '{\"code\":200,\"msg\":\"success\",\"data\":{\"token\":\"eyJhbGciOiJIUzUxMiJ9.eyJuaWNrbmFtZSI6Iui2hee6p-euoeeQhuWRmCIsInVzZXJUeXBlIjoiYWRtaW4iLCJ1c2VySWQiOjEsInVzZXJuYW1lIjoiYWRtaW4iLCJzdWIiOiIxIiwiaWF0IjoxNzc1NzkxNTQzLCJleHAiOjE3NzYzOTYzNDN9.E3XHc_tjMke3oDqk1qNCKR7AucVFZj-PcYq1_0TP8jDWYB1nF0ZEKpMWISTcuNBhHDh48LbHzejHpFikaW2ERA\",\"adminId\":1,\"username\":\"admin\",\"nickname\":\"超级管理员\"}}', 0, NULL, '2026-04-10 11:25:43');
INSERT INTO `sys_oper_log` VALUES (61, '后台登录', 'com.designstudio.system.controller.AuthController.login', 'POST', NULL, NULL, '/api/v1/auth/login', '0:0:0:0:0:0:0:1', '[{\"username\":\"admin\",\"password\":\"admin123\"}]', '{\"code\":200,\"msg\":\"success\",\"data\":{\"token\":\"eyJhbGciOiJIUzUxMiJ9.eyJuaWNrbmFtZSI6Iui2hee6p-euoeeQhuWRmCIsInVzZXJUeXBlIjoiYWRtaW4iLCJ1c2VySWQiOjEsInVzZXJuYW1lIjoiYWRtaW4iLCJzdWIiOiIxIiwiaWF0IjoxNzc1NzkxNTUzLCJleHAiOjE3NzYzOTYzNTN9.A4z6oVfa383_xcHxBmYmVeWNqF7cmiKpOFPZ3rIQeaFKuOl5IuKdrZFUKDaUuH6hYiC_HHzD97X4PqWCjqdswg\",\"adminId\":1,\"username\":\"admin\",\"nickname\":\"超级管理员\"}}', 0, NULL, '2026-04-10 11:25:53');
INSERT INTO `sys_oper_log` VALUES (62, '后台登录', 'com.designstudio.system.controller.AuthController.login', 'POST', NULL, NULL, '/api/v1/auth/login', '0:0:0:0:0:0:0:1', '[{\"username\":\"admin\",\"password\":\"admin123\"}]', '{\"code\":200,\"msg\":\"success\",\"data\":{\"token\":\"eyJhbGciOiJIUzUxMiJ9.eyJuaWNrbmFtZSI6Iui2hee6p-euoeeQhuWRmCIsInVzZXJUeXBlIjoiYWRtaW4iLCJ1c2VySWQiOjEsInVzZXJuYW1lIjoiYWRtaW4iLCJzdWIiOiIxIiwiaWF0IjoxNzc1NzkxNTcxLCJleHAiOjE3NzYzOTYzNzF9.LzDWjZugJaatsLlub-_xxVXUXS4OPNH6Ual_NV6MSVqDd8cpUJn2_MGI-pXJipMyPKZbnS2EJvo_3FYMNxx3VQ\",\"adminId\":1,\"username\":\"admin\",\"nickname\":\"超级管理员\"}}', 0, NULL, '2026-04-10 11:26:11');
INSERT INTO `sys_oper_log` VALUES (63, '后台登录', 'com.designstudio.system.controller.AuthController.login', 'POST', NULL, NULL, '/api/v1/auth/login', '0:0:0:0:0:0:0:1', '[{\"username\":\"admin\",\"password\":\"admin123\"}]', '{\"code\":200,\"msg\":\"success\",\"data\":{\"token\":\"eyJhbGciOiJIUzUxMiJ9.eyJuaWNrbmFtZSI6Iui2hee6p-euoeeQhuWRmCIsInVzZXJUeXBlIjoiYWRtaW4iLCJ1c2VySWQiOjEsInVzZXJuYW1lIjoiYWRtaW4iLCJzdWIiOiIxIiwiaWF0IjoxNzc1NzkxNTgxLCJleHAiOjE3NzYzOTYzODF9.SdM4nqDOUzblF1p48LYSg_yVrBk8rHu6G8tkqoTeir-JsgdCEQhm6SUuXm04Hj-PwstaOU3CMYAUGzDz1vrXeA\",\"adminId\":1,\"username\":\"admin\",\"nickname\":\"超级管理员\"}}', 0, NULL, '2026-04-10 11:26:21');
INSERT INTO `sys_oper_log` VALUES (64, '后台登录', 'com.designstudio.system.controller.AuthController.login', 'POST', NULL, NULL, '/api/v1/auth/login', '0:0:0:0:0:0:0:1', '[{\"username\":\"admin\",\"password\":\"admin123\"}]', '{\"code\":200,\"msg\":\"success\",\"data\":{\"token\":\"eyJhbGciOiJIUzUxMiJ9.eyJuaWNrbmFtZSI6Iui2hee6p-euoeeQhuWRmCIsInVzZXJUeXBlIjoiYWRtaW4iLCJ1c2VySWQiOjEsInVzZXJuYW1lIjoiYWRtaW4iLCJzdWIiOiIxIiwiaWF0IjoxNzc1NzkxNTk5LCJleHAiOjE3NzYzOTYzOTl9.dRHs4Wy2tDwGI6PKAqY2Q8CAbDvYyyq2NLpAvycsC6zFZZcQSV6WENTltf_F7cNTCKAJ3GRRbUETnp5NmzlxbA\",\"adminId\":1,\"username\":\"admin\",\"nickname\":\"超级管理员\"}}', 0, NULL, '2026-04-10 11:26:39');
INSERT INTO `sys_oper_log` VALUES (65, '执行节点工作台动作', 'com.designstudio.order.controller.WorkbenchController.action', 'POST', 1, 'admin', '/api/v1/admin/workbench/orders/2/action', '0:0:0:0:0:0:0:1', '[2,{\"action\":\"rollback\",\"description\":\"??:?????????\",\"rollbackTargetStepId\":12}]', '{\"code\":200,\"msg\":\"success\"}', 0, NULL, '2026-04-10 11:26:39');
INSERT INTO `sys_oper_log` VALUES (66, '后台登录', 'com.designstudio.system.controller.AuthController.login', 'POST', NULL, NULL, '/api/v1/auth/login', '0:0:0:0:0:0:0:1', '[{\"username\":\"admin\",\"password\":\"admin123\"}]', '{\"code\":200,\"msg\":\"success\",\"data\":{\"token\":\"eyJhbGciOiJIUzUxMiJ9.eyJuaWNrbmFtZSI6Iui2hee6p-euoeeQhuWRmCIsInVzZXJUeXBlIjoiYWRtaW4iLCJ1c2VySWQiOjEsInVzZXJuYW1lIjoiYWRtaW4iLCJzdWIiOiIxIiwiaWF0IjoxNzc1NzkxNzQzLCJleHAiOjE3NzYzOTY1NDN9.Zzokx1VgeoT2walWRuyq6QonNG3v-l0Di7wSKmamU4W1y18h7LONT9Rr3z9z7IE7HbiKKOCh-FQoo85yd0RUHg\",\"adminId\":1,\"username\":\"admin\",\"nickname\":\"超级管理员\"}}', 0, NULL, '2026-04-10 11:29:03');
INSERT INTO `sys_oper_log` VALUES (67, '执行节点工作台动作', 'com.designstudio.order.controller.WorkbenchController.action', 'POST', 1, 'admin', '/api/v1/admin/workbench/orders/2/action', '0:0:0:0:0:0:0:1', '[2,{\"action\":\"advance\",\"description\":\"??:???????\"}]', '{\"code\":200,\"msg\":\"success\"}', 0, NULL, '2026-04-10 11:29:04');
INSERT INTO `sys_oper_log` VALUES (68, '执行节点工作台动作', 'com.designstudio.order.controller.WorkbenchController.action', 'POST', 1, 'admin', '/api/v1/admin/workbench/orders/2/action', '0:0:0:0:0:0:0:1', '[2,{\"action\":\"rollback\",\"description\":\"??:???????\",\"rollbackTargetStepId\":12}]', '{\"code\":200,\"msg\":\"success\"}', 0, NULL, '2026-04-10 11:29:04');
INSERT INTO `sys_oper_log` VALUES (69, '执行节点工作台动作', 'com.designstudio.order.controller.WorkbenchController.action', 'POST', 1, 'admin', '/api/v1/admin/workbench/orders/1/action', '0:0:0:0:0:0:0:1', '[1,{\"action\":\"advance\"}]', '{\"code\":200,\"msg\":\"success\"}', 0, NULL, '2026-04-10 11:34:07');
INSERT INTO `sys_oper_log` VALUES (70, '执行节点工作台动作', 'com.designstudio.order.controller.WorkbenchController.action', 'POST', 1, 'admin', '/api/v1/admin/workbench/orders/1/action', '0:0:0:0:0:0:0:1', '[1,{\"action\":\"rollback\",\"rollbackTargetStepId\":2}]', '{\"code\":200,\"msg\":\"success\"}', 0, NULL, '2026-04-10 11:34:13');
INSERT INTO `sys_oper_log` VALUES (71, '执行节点工作台动作', 'com.designstudio.order.controller.WorkbenchController.action', 'POST', 1, 'admin', '/api/v1/admin/workbench/orders/1/action', '0:0:0:0:0:0:0:1', '[1,{\"action\":\"rollback\",\"rollbackTargetStepId\":1}]', '{\"code\":200,\"msg\":\"success\"}', 0, NULL, '2026-04-10 11:34:30');
INSERT INTO `sys_oper_log` VALUES (72, '后台登录', 'com.designstudio.system.controller.AuthController.login', 'POST', NULL, NULL, '/api/v1/auth/login', '0:0:0:0:0:0:0:1', '[{\"username\":\"admin\",\"password\":\"admin123\"}]', '{\"code\":200,\"msg\":\"success\",\"data\":{\"token\":\"eyJhbGciOiJIUzUxMiJ9.eyJuaWNrbmFtZSI6Iui2hee6p-euoeeQhuWRmCIsInVzZXJUeXBlIjoiYWRtaW4iLCJ1c2VySWQiOjEsInVzZXJuYW1lIjoiYWRtaW4iLCJzdWIiOiIxIiwiaWF0IjoxNzc1NzkyNzU3LCJleHAiOjE3NzYzOTc1NTd9.7JyQP_51vXDgnFAb5edcfXXms4aS-khCA7m-_XlqDRzn6bjllHrWlbMaHWs0bvpsY_Fi6-u0o6YgfYBgJg04aA\",\"adminId\":1,\"username\":\"admin\",\"nickname\":\"超级管理员\"}}', 0, NULL, '2026-04-10 11:45:56');
INSERT INTO `sys_oper_log` VALUES (73, '后台登录', 'com.designstudio.system.controller.AuthController.login', 'POST', NULL, NULL, '/api/v1/auth/login', '0:0:0:0:0:0:0:1', '[{\"username\":\"admin\",\"password\":\"admin123\"}]', '{\"code\":200,\"msg\":\"success\",\"data\":{\"token\":\"eyJhbGciOiJIUzUxMiJ9.eyJuaWNrbmFtZSI6Iui2hee6p-euoeeQhuWRmCIsInVzZXJUeXBlIjoiYWRtaW4iLCJ1c2VySWQiOjEsInVzZXJuYW1lIjoiYWRtaW4iLCJzdWIiOiIxIiwiaWF0IjoxNzc1NzkyNzU3LCJleHAiOjE3NzYzOTc1NTd9.7JyQP_51vXDgnFAb5edcfXXms4aS-khCA7m-_XlqDRzn6bjllHrWlbMaHWs0bvpsY_Fi6-u0o6YgfYBgJg04aA\",\"adminId\":1,\"username\":\"admin\",\"nickname\":\"超级管理员\"}}', 0, NULL, '2026-04-10 11:45:56');
INSERT INTO `sys_oper_log` VALUES (74, '后台登录', 'com.designstudio.system.controller.AuthController.login', 'POST', NULL, NULL, '/api/v1/auth/login', '0:0:0:0:0:0:0:1', '[{\"username\":\"admin\",\"password\":\"admin123\"}]', '{\"code\":200,\"msg\":\"success\",\"data\":{\"token\":\"eyJhbGciOiJIUzUxMiJ9.eyJuaWNrbmFtZSI6Iui2hee6p-euoeeQhuWRmCIsInVzZXJUeXBlIjoiYWRtaW4iLCJ1c2VySWQiOjEsInVzZXJuYW1lIjoiYWRtaW4iLCJzdWIiOiIxIiwiaWF0IjoxNzc1ODA2OTU1LCJleHAiOjE3NzY0MTE3NTV9.-traSvkg25Gm9IfkLqGp4DWLgJncdKVWMseSUQWTwK7C7-9GrHn1pSVDP8j7qhqFeTLeYWR_pSPjlaPmRzzBzw\",\"adminId\":1,\"username\":\"admin\",\"nickname\":\"超级管理员\"}}', 0, NULL, '2026-04-10 15:42:35');
INSERT INTO `sys_oper_log` VALUES (75, '后台登录', 'com.designstudio.system.controller.AuthController.login', 'POST', NULL, NULL, '/api/v1/auth/login', '0:0:0:0:0:0:0:1', '[{\"username\":\"admin\",\"password\":\"admin123\"}]', '{\"code\":200,\"msg\":\"success\",\"data\":{\"token\":\"eyJhbGciOiJIUzUxMiJ9.eyJuaWNrbmFtZSI6Iui2hee6p-euoeeQhuWRmCIsInVzZXJUeXBlIjoiYWRtaW4iLCJ1c2VySWQiOjEsInVzZXJuYW1lIjoiYWRtaW4iLCJzdWIiOiIxIiwiaWF0IjoxNzc1ODA2OTY4LCJleHAiOjE3NzY0MTE3Njh9.Nqvdu6N9q1hpm3BRTEzvPfN0FVCkGby9GMONBbxx8dtWBP8DXnQtxBQmLxIAGUvflTGeg6iR2BvTDTyxr8jfxQ\",\"adminId\":1,\"username\":\"admin\",\"nickname\":\"超级管理员\"}}', 0, NULL, '2026-04-10 15:42:49');
INSERT INTO `sys_oper_log` VALUES (76, '后台登录', 'com.designstudio.system.controller.AuthController.login', 'POST', NULL, NULL, '/api/v1/auth/login', '0:0:0:0:0:0:0:1', '[{\"username\":\"admin\",\"password\":\"admin123\"}]', '{\"code\":200,\"msg\":\"success\",\"data\":{\"token\":\"eyJhbGciOiJIUzUxMiJ9.eyJuaWNrbmFtZSI6Iui2hee6p-euoeeQhuWRmCIsInVzZXJUeXBlIjoiYWRtaW4iLCJ1c2VySWQiOjEsInVzZXJuYW1lIjoiYWRtaW4iLCJzdWIiOiIxIiwiaWF0IjoxNzc1ODA2OTk1LCJleHAiOjE3NzY0MTE3OTV9.nEdhShZjg9AsgXqcccyOsMfkq144N3WVrRxwFqlQAz-pOuX26_6pngm4zaXgDoRcNlUt2F7kAhVXfocfCz1IqA\",\"adminId\":1,\"username\":\"admin\",\"nickname\":\"超级管理员\"}}', 0, NULL, '2026-04-10 15:43:15');
INSERT INTO `sys_oper_log` VALUES (77, '后台登录', 'com.designstudio.system.controller.AuthController.login', 'POST', NULL, NULL, '/api/v1/auth/login', '0:0:0:0:0:0:0:1', '[{\"username\":\"admin\",\"password\":\"admin123\"}]', '{\"code\":200,\"msg\":\"success\",\"data\":{\"token\":\"eyJhbGciOiJIUzUxMiJ9.eyJuaWNrbmFtZSI6Iui2hee6p-euoeeQhuWRmCIsInVzZXJUeXBlIjoiYWRtaW4iLCJ1c2VySWQiOjEsInVzZXJuYW1lIjoiYWRtaW4iLCJzdWIiOiIxIiwiaWF0IjoxNzc1ODA2OTk1LCJleHAiOjE3NzY0MTE3OTV9.nEdhShZjg9AsgXqcccyOsMfkq144N3WVrRxwFqlQAz-pOuX26_6pngm4zaXgDoRcNlUt2F7kAhVXfocfCz1IqA\",\"adminId\":1,\"username\":\"admin\",\"nickname\":\"超级管理员\"}}', 0, NULL, '2026-04-10 15:43:15');
INSERT INTO `sys_oper_log` VALUES (78, '后台登录', 'com.designstudio.system.controller.AuthController.login', 'POST', NULL, NULL, '/api/v1/auth/login', '0:0:0:0:0:0:0:1', '[{\"username\":\"admin\",\"password\":\"admin123\"}]', '{\"code\":200,\"msg\":\"success\",\"data\":{\"token\":\"eyJhbGciOiJIUzUxMiJ9.eyJuaWNrbmFtZSI6Iui2hee6p-euoeeQhuWRmCIsInVzZXJUeXBlIjoiYWRtaW4iLCJ1c2VySWQiOjEsInVzZXJuYW1lIjoiYWRtaW4iLCJzdWIiOiIxIiwiaWF0IjoxNzc1ODA3MDE5LCJleHAiOjE3NzY0MTE4MTl9.N93_wOMypXAE0KAntC9oBtNLZDHjcb01gpilKjTSYvYamG-UfmA_Sr_pxyqkfEVXxSrTkCm_NQ79UUFs7oTfZQ\",\"adminId\":1,\"username\":\"admin\",\"nickname\":\"超级管理员\"}}', 0, NULL, '2026-04-10 15:43:39');
INSERT INTO `sys_oper_log` VALUES (79, '后台登录', 'com.designstudio.system.controller.AuthController.login', 'POST', NULL, NULL, '/api/v1/auth/login', '0:0:0:0:0:0:0:1', '[{\"username\":\"admin\",\"password\":\"admin123\"}]', '{\"code\":200,\"msg\":\"success\",\"data\":{\"token\":\"eyJhbGciOiJIUzUxMiJ9.eyJuaWNrbmFtZSI6Iui2hee6p-euoeeQhuWRmCIsInVzZXJUeXBlIjoiYWRtaW4iLCJ1c2VySWQiOjEsInVzZXJuYW1lIjoiYWRtaW4iLCJzdWIiOiIxIiwiaWF0IjoxNzc1ODA3MDE5LCJleHAiOjE3NzY0MTE4MTl9.N93_wOMypXAE0KAntC9oBtNLZDHjcb01gpilKjTSYvYamG-UfmA_Sr_pxyqkfEVXxSrTkCm_NQ79UUFs7oTfZQ\",\"adminId\":1,\"username\":\"admin\",\"nickname\":\"超级管理员\"}}', 0, NULL, '2026-04-10 15:43:39');
INSERT INTO `sys_oper_log` VALUES (80, '执行节点工作台动作', 'com.designstudio.order.controller.WorkbenchController.action', 'POST', 1, 'admin', '/api/v1/admin/workbench/orders/6/action', '0:0:0:0:0:0:0:1', '[6,{\"action\":\"save\",\"description\":\"????????\",\"formData\":\"{}\"}]', '{\"code\":500,\"msg\":\"请填写当前节点的必填字段\"}', 0, NULL, '2026-04-10 15:43:40');
INSERT INTO `sys_oper_log` VALUES (81, '执行节点工作台动作', 'com.designstudio.order.controller.WorkbenchController.action', 'POST', 1, 'admin', '/api/v1/admin/workbench/orders/6/action', '0:0:0:0:0:0:0:1', '[6,{\"action\":\"save\",\"description\":\"????????\",\"formData\":\"{\\\"chest\\\":88,\\\"waist\\\":66}\"}]', '{\"code\":200,\"msg\":\"success\"}', 0, NULL, '2026-04-10 15:43:40');
INSERT INTO `sys_oper_log` VALUES (82, '后台登录', 'com.designstudio.system.controller.AuthController.login', 'POST', NULL, NULL, '/api/v1/auth/login', '0:0:0:0:0:0:0:1', '[{\"username\":\"adminadmin\",\"password\":\"admin123admin123\"}]', NULL, 1, '用户名或密码错误', '2026-04-10 15:53:50');
INSERT INTO `sys_oper_log` VALUES (83, '后台登录', 'com.designstudio.system.controller.AuthController.login', 'POST', NULL, NULL, '/api/v1/auth/login', '0:0:0:0:0:0:0:1', '[{\"username\":\"admin\",\"password\":\"admin123\"}]', '{\"code\":200,\"msg\":\"success\",\"data\":{\"token\":\"eyJhbGciOiJIUzUxMiJ9.eyJuaWNrbmFtZSI6Iui2hee6p-euoeeQhuWRmCIsInVzZXJUeXBlIjoiYWRtaW4iLCJ1c2VySWQiOjEsInVzZXJuYW1lIjoiYWRtaW4iLCJzdWIiOiIxIiwiaWF0IjoxNzc1ODA3NjQ1LCJleHAiOjE3NzY0MTI0NDV9.LgTLshwNDNY9PDRWlOTJA9xC3amklFlt_BRKkKRtDsNqgXFlRyXh9ebKSVVa1zQJH1EnZRQ4ldpv12fJvw8MBA\",\"adminId\":1,\"username\":\"admin\",\"nickname\":\"超级管理员\"}}', 0, NULL, '2026-04-10 15:54:06');
INSERT INTO `sys_oper_log` VALUES (84, '后台登录', 'com.designstudio.system.controller.AuthController.login', 'POST', NULL, NULL, '/api/v1/auth/login', '0:0:0:0:0:0:0:1', '[{\"username\":\"admin\",\"password\":\"admin123\"}]', '{\"code\":200,\"msg\":\"success\",\"data\":{\"token\":\"eyJhbGciOiJIUzUxMiJ9.eyJuaWNrbmFtZSI6Iui2hee6p-euoeeQhuWRmCIsInVzZXJUeXBlIjoiYWRtaW4iLCJ1c2VySWQiOjEsInVzZXJuYW1lIjoiYWRtaW4iLCJzdWIiOiIxIiwiaWF0IjoxNzc1ODA3NjUzLCJleHAiOjE3NzY0MTI0NTN9.644qLEu05SfuavGjwk4LPnPuq_PqbEGQKXGy8wdiux_JBabpQxieDF8ksBMj6PNDtkt17_wQ-oMrk_DXTJ2-tw\",\"adminId\":1,\"username\":\"admin\",\"nickname\":\"超级管理员\"}}', 0, NULL, '2026-04-10 15:54:14');
INSERT INTO `sys_oper_log` VALUES (85, '后台登录', 'com.designstudio.system.controller.AuthController.login', 'POST', NULL, NULL, '/api/v1/auth/login', '0:0:0:0:0:0:0:1', '[{\"username\":\"admin\",\"password\":\"admin123\"}]', '{\"code\":200,\"msg\":\"success\",\"data\":{\"token\":\"eyJhbGciOiJIUzUxMiJ9.eyJuaWNrbmFtZSI6Iui2hee6p-euoeeQhuWRmCIsInVzZXJUeXBlIjoiYWRtaW4iLCJ1c2VySWQiOjEsInVzZXJuYW1lIjoiYWRtaW4iLCJzdWIiOiIxIiwiaWF0IjoxNzc1ODA5NzE1LCJleHAiOjE3NzY0MTQ1MTV9.3Ts1RwKORykUNt9djRgIXnj86817qwIYaYR5oD4tZeIdg3Fav7LfgngXlMSyqd6MknPhfuvl7DWqm1jEQxJvxQ\",\"adminId\":1,\"username\":\"admin\",\"nickname\":\"超级管理员\"}}', 0, NULL, '2026-04-10 16:28:35');
INSERT INTO `sys_oper_log` VALUES (86, '后台登录', 'com.designstudio.system.controller.AuthController.login', 'POST', NULL, NULL, '/api/v1/auth/login', '0:0:0:0:0:0:0:1', '[{\"username\":\"admin\",\"password\":\"admin123\"}]', '{\"code\":200,\"msg\":\"success\",\"data\":{\"token\":\"eyJhbGciOiJIUzUxMiJ9.eyJuaWNrbmFtZSI6Iui2hee6p-euoeeQhuWRmCIsInVzZXJUeXBlIjoiYWRtaW4iLCJ1c2VySWQiOjEsInVzZXJuYW1lIjoiYWRtaW4iLCJzdWIiOiIxIiwiaWF0IjoxNzc1ODA5NzQyLCJleHAiOjE3NzY0MTQ1NDJ9.AdgR7a2vZEuH8ZVn7aJ2znVUhc7BLX6wYODwXRiOe5jervQNIKpYR_vgvuIHcHRZBLi8UQlZSML76dGrdhAF9A\",\"adminId\":1,\"username\":\"admin\",\"nickname\":\"超级管理员\"}}', 0, NULL, '2026-04-10 16:29:02');
INSERT INTO `sys_oper_log` VALUES (87, '后台登录', 'com.designstudio.system.controller.AuthController.login', 'POST', NULL, NULL, '/api/v1/auth/login', '0:0:0:0:0:0:0:1', '[{\"username\":\"admin\",\"password\":\"admin123\"}]', '{\"code\":200,\"msg\":\"success\",\"data\":{\"token\":\"eyJhbGciOiJIUzUxMiJ9.eyJuaWNrbmFtZSI6Iui2hee6p-euoeeQhuWRmCIsInVzZXJUeXBlIjoiYWRtaW4iLCJ1c2VySWQiOjEsInVzZXJuYW1lIjoiYWRtaW4iLCJzdWIiOiIxIiwiaWF0IjoxNzc1ODE4NzY3LCJleHAiOjE3NzY0MjM1Njd9.x3-Gtg4RvMyo0-kpwox5WoYqBOW2EZNO972_-vluKGDcfchsPZnJRbV6B_E7m_zOPkVLFyGlXj-g6_D3XKlc1Q\",\"adminId\":1,\"username\":\"admin\",\"nickname\":\"超级管理员\"}}', 0, NULL, '2026-04-10 18:59:27');
INSERT INTO `sys_oper_log` VALUES (88, '后台登录', 'com.designstudio.system.controller.AuthController.login', 'POST', NULL, NULL, '/api/v1/auth/login', '0:0:0:0:0:0:0:1', '[{\"username\":\"admin\",\"password\":\"admin123\"}]', '{\"code\":200,\"msg\":\"success\",\"data\":{\"token\":\"eyJhbGciOiJIUzUxMiJ9.eyJuaWNrbmFtZSI6Iui2hee6p-euoeeQhuWRmCIsInVzZXJUeXBlIjoiYWRtaW4iLCJ1c2VySWQiOjEsInVzZXJuYW1lIjoiYWRtaW4iLCJzdWIiOiIxIiwiaWF0IjoxNzc1ODE4Nzg1LCJleHAiOjE3NzY0MjM1ODV9.RIqNb1USvI6_Bs4f2iW4789OlwGvl_csYQ2UIBAO9WNFcbw8BMuz2U58N6dNCG94FBHz-nxeZXhy4d_3fE3XGA\",\"adminId\":1,\"username\":\"admin\",\"nickname\":\"超级管理员\"}}', 0, NULL, '2026-04-10 18:59:46');
INSERT INTO `sys_oper_log` VALUES (89, '后台登录', 'com.designstudio.system.controller.AuthController.login', 'POST', NULL, NULL, '/api/v1/auth/login', '0:0:0:0:0:0:0:1', '[{\"username\":\"admin\",\"password\":\"admin123\"}]', '{\"code\":200,\"msg\":\"success\",\"data\":{\"token\":\"eyJhbGciOiJIUzUxMiJ9.eyJuaWNrbmFtZSI6Iui2hee6p-euoeeQhuWRmCIsInVzZXJUeXBlIjoiYWRtaW4iLCJ1c2VySWQiOjEsInVzZXJuYW1lIjoiYWRtaW4iLCJzdWIiOiIxIiwiaWF0IjoxNzc1ODE4ODU2LCJleHAiOjE3NzY0MjM2NTZ9.277DxiDyp0Zcs52NyP6b-8gKCM98UO2oXgtWciRBf-p1pECVdv5DFb75RXy2Ug9phZUHVb87I_QSuqDrdr84sg\",\"adminId\":1,\"username\":\"admin\",\"nickname\":\"超级管理员\"}}', 0, NULL, '2026-04-10 19:00:56');
INSERT INTO `sys_oper_log` VALUES (90, '后台登录', 'com.designstudio.system.controller.AuthController.login', 'POST', NULL, NULL, '/api/v1/auth/login', '0:0:0:0:0:0:0:1', '[{\"username\":\"admin\",\"password\":\"admin123\"}]', '{\"code\":200,\"msg\":\"success\",\"data\":{\"token\":\"eyJhbGciOiJIUzUxMiJ9.eyJuaWNrbmFtZSI6Iui2hee6p-euoeeQhuWRmCIsInVzZXJUeXBlIjoiYWRtaW4iLCJ1c2VySWQiOjEsInVzZXJuYW1lIjoiYWRtaW4iLCJzdWIiOiIxIiwiaWF0IjoxNzc1ODE5MTE1LCJleHAiOjE3NzY0MjM5MTV9.Z_nJ3SMbXNYiKxI-kzWmAMPUL3mrEP2zCAQ_EWVQHPLKztuaDjq5dxJ3TiXZNkMeVDo9avIdmanrXgNsJqpjoQ\",\"adminId\":1,\"username\":\"admin\",\"nickname\":\"超级管理员\"}}', 0, NULL, '2026-04-10 19:05:16');
INSERT INTO `sys_oper_log` VALUES (91, '后台登录', 'com.designstudio.system.controller.AuthController.login', 'POST', NULL, NULL, '/api/v1/auth/login', '0:0:0:0:0:0:0:1', '[{\"username\":\"admin\",\"password\":\"admin123\"}]', '{\"code\":200,\"msg\":\"success\",\"data\":{\"token\":\"eyJhbGciOiJIUzUxMiJ9.eyJuaWNrbmFtZSI6Iui2hee6p-euoeeQhuWRmCIsInVzZXJUeXBlIjoiYWRtaW4iLCJ1c2VySWQiOjEsInVzZXJuYW1lIjoiYWRtaW4iLCJzdWIiOiIxIiwiaWF0IjoxNzc1ODE5MTQyLCJleHAiOjE3NzY0MjM5NDJ9.RB9kXJuE_IoKiBtZ6XWKYehXWsRbIGGziZo7QRLMDm7kZ_Txg6ZPh7GYJ7eywsd6IlwpHqwb8hIbOKGwXGmnyw\",\"adminId\":1,\"username\":\"admin\",\"nickname\":\"超级管理员\"}}', 0, NULL, '2026-04-10 19:05:43');
INSERT INTO `sys_oper_log` VALUES (92, '后台登录', 'com.designstudio.system.controller.AuthController.login', 'POST', NULL, NULL, '/api/v1/auth/login', '0:0:0:0:0:0:0:1', '[{\"username\":\"admin\",\"password\":\"admin123\"}]', '{\"code\":200,\"msg\":\"success\",\"data\":{\"token\":\"eyJhbGciOiJIUzUxMiJ9.eyJuaWNrbmFtZSI6Iui2hee6p-euoeeQhuWRmCIsInVzZXJUeXBlIjoiYWRtaW4iLCJ1c2VySWQiOjEsInVzZXJuYW1lIjoiYWRtaW4iLCJzdWIiOiIxIiwiaWF0IjoxNzc1ODE5MTY0LCJleHAiOjE3NzY0MjM5NjR9.H8_cgRLRrjBILK1pJswc5KYFXqpNyeiha1Kyh6Tg8PMEjD6SL0etQHBQbLhALMCFhgxv-0n0sdQqlPMTZIZ3RA\",\"adminId\":1,\"username\":\"admin\",\"nickname\":\"超级管理员\"}}', 0, NULL, '2026-04-10 19:06:05');
INSERT INTO `sys_oper_log` VALUES (93, '后台登录', 'com.designstudio.system.controller.AuthController.login', 'POST', NULL, NULL, '/api/v1/auth/login', '0:0:0:0:0:0:0:1', '[{\"username\":\"admin\",\"password\":\"admin123\"}]', '{\"code\":200,\"msg\":\"success\",\"data\":{\"token\":\"eyJhbGciOiJIUzUxMiJ9.eyJuaWNrbmFtZSI6Iui2hee6p-euoeeQhuWRmCIsInVzZXJUeXBlIjoiYWRtaW4iLCJ1c2VySWQiOjEsInVzZXJuYW1lIjoiYWRtaW4iLCJzdWIiOiIxIiwiaWF0IjoxNzc1ODE5MjY0LCJleHAiOjE3NzY0MjQwNjR9.SIWDXdjz_t6ptFe4QZkbvG3gkbw9iH7RiGEIBw03--qnAXxI4HOznB5uoSpXh2ImITBrBW-w8malzRC1MoTcyw\",\"adminId\":1,\"username\":\"admin\",\"nickname\":\"超级管理员\"}}', 0, NULL, '2026-04-10 19:07:44');
INSERT INTO `sys_oper_log` VALUES (94, '新增作品集', 'com.designstudio.portfolio.controller.PortfolioController.add', 'POST', 1, 'admin', '/api/v1/admin/portfolios', '0:0:0:0:0:0:0:1', '[{\"title\":\"猫\",\"categoryId\":1,\"coverUrl\":\"https://i0.hdslb.com/bfs/new_dyn/a4833ebe1038fcd60a196da9b53c0e44270317383.jpg@420w_560h_1e_1c.webp\",\"imageUrls\":[\"https://i0.hdslb.com/bfs/new_dyn/a4833ebe1038fcd60a196da9b53c0e44270317383.jpg@420w_560h_1e_1c.webp\",\"https://i0.hdslb.com/bfs/new_dyn/a42924b84d925cfabf5672f8e7373ee6270317383.jpg@264w_264h_1e_1c.webp\"],\"description\":\"\",\"status\":1,\"sortOrder\":1}]', '{\"code\":200,\"msg\":\"success\"}', 0, NULL, '2026-04-10 19:53:02');
INSERT INTO `sys_oper_log` VALUES (95, '新增作品集', 'com.designstudio.portfolio.controller.PortfolioController.add', 'POST', 1, 'admin', '/api/v1/admin/portfolios', '0:0:0:0:0:0:0:1', '[{\"title\":\"测试上传作品\",\"categoryId\":1,\"coverUrl\":\"/uploads/8962029f590c4d449c1b3e1afdf2391e.png\",\"imageUrls\":[],\"description\":\"\",\"status\":0,\"sortOrder\":0}]', '{\"code\":200,\"msg\":\"success\"}', 0, NULL, '2026-04-10 20:05:54');
INSERT INTO `sys_oper_log` VALUES (96, '后台登录', 'com.designstudio.system.controller.AuthController.login', 'POST', NULL, NULL, '/api/v1/auth/login', '0:0:0:0:0:0:0:1', '[{\"username\":\"admin\",\"password\":\"admin123\"}]', '{\"code\":200,\"msg\":\"success\",\"data\":{\"token\":\"eyJhbGciOiJIUzUxMiJ9.eyJuaWNrbmFtZSI6Iui2hee6p-euoeeQhuWRmCIsInVzZXJUeXBlIjoiYWRtaW4iLCJ1c2VySWQiOjEsInVzZXJuYW1lIjoiYWRtaW4iLCJzdWIiOiIxIiwiaWF0IjoxNzc1ODI2MTgxLCJleHAiOjE3NzY0MzA5ODF9.fcd8-5q4HfDVeJDsZ4QZ_8YABfI2Cse85jF3AQY5Z7DMT1oa01N7VuTeZOBvsdvOLveaeTxXGpLe18FhYIos-Q\",\"adminId\":1,\"username\":\"admin\",\"nickname\":\"超级管理员\"}}', 0, NULL, '2026-04-10 21:03:01');
INSERT INTO `sys_oper_log` VALUES (97, '取消订单', 'com.designstudio.order.controller.OrderController.cancel', 'POST', 1, 'admin', '/api/v1/admin/orders/6/cancel', '0:0:0:0:0:0:0:1', '[6,{\"cancelReason\":\"??????????\"}]', '{\"code\":200,\"msg\":\"success\"}', 0, NULL, '2026-04-10 21:03:33');
INSERT INTO `sys_oper_log` VALUES (98, '订单延期', 'com.designstudio.order.controller.OrderController.delay', 'POST', 1, 'admin', '/api/v1/admin/orders/1/delay', '0:0:0:0:0:0:0:1', '[1,{\"delayReason\":\"????????\",\"expectedDate\":1776441600000}]', '{\"code\":200,\"msg\":\"success\"}', 0, NULL, '2026-04-10 21:03:33');
INSERT INTO `sys_oper_log` VALUES (99, '订单发货', 'com.designstudio.order.controller.OrderController.ship', 'POST', 1, 'admin', '/api/v1/admin/orders/3/ship', '0:0:0:0:0:0:0:1', '[3,{\"description\":\"??????\"}]', '{\"code\":200,\"msg\":\"success\"}', 0, NULL, '2026-04-10 21:04:19');
INSERT INTO `sys_oper_log` VALUES (100, '后台登录', 'com.designstudio.system.controller.AuthController.login', 'POST', NULL, NULL, '/api/v1/auth/login', '0:0:0:0:0:0:0:1', '[{\"username\":\"admin\",\"password\":\"admin123\"}]', '{\"code\":200,\"msg\":\"success\",\"data\":{\"token\":\"eyJhbGciOiJIUzUxMiJ9.eyJuaWNrbmFtZSI6Iui2hee6p-euoeeQhuWRmCIsInVzZXJUeXBlIjoiYWRtaW4iLCJ1c2VySWQiOjEsInVzZXJuYW1lIjoiYWRtaW4iLCJzdWIiOiIxIiwiaWF0IjoxNzc1ODI3OTEyLCJleHAiOjE3NzY0MzI3MTJ9.lAArOhBc9Wt2v21BcdrST7qiE42rKbkoGjTY1PxViS3qRcWNmlwLGaRrS7B_yGjnE8A1hmNS6LVnuGabn42edA\",\"adminId\":1,\"username\":\"admin\",\"nickname\":\"超级管理员\"}}', 0, NULL, '2026-04-10 21:31:52');
INSERT INTO `sys_oper_log` VALUES (101, '后台登录', 'com.designstudio.system.controller.AuthController.login', 'POST', NULL, NULL, '/api/v1/auth/login', '0:0:0:0:0:0:0:1', '[{\"username\":\"admin\",\"password\":\"admin123\"}]', '{\"code\":200,\"msg\":\"success\",\"data\":{\"token\":\"eyJhbGciOiJIUzUxMiJ9.eyJuaWNrbmFtZSI6Iui2hee6p-euoeeQhuWRmCIsInVzZXJUeXBlIjoiYWRtaW4iLCJ1c2VySWQiOjEsInVzZXJuYW1lIjoiYWRtaW4iLCJzdWIiOiIxIiwiaWF0IjoxNzc1ODI3OTEyLCJleHAiOjE3NzY0MzI3MTJ9.lAArOhBc9Wt2v21BcdrST7qiE42rKbkoGjTY1PxViS3qRcWNmlwLGaRrS7B_yGjnE8A1hmNS6LVnuGabn42edA\",\"adminId\":1,\"username\":\"admin\",\"nickname\":\"超级管理员\"}}', 0, NULL, '2026-04-10 21:31:52');
INSERT INTO `sys_oper_log` VALUES (102, '后台登录', 'com.designstudio.system.controller.AuthController.login', 'POST', NULL, NULL, '/api/v1/auth/login', '0:0:0:0:0:0:0:1', '[{\"username\":\"admin\",\"password\":\"admin123\"}]', '{\"code\":200,\"msg\":\"success\",\"data\":{\"token\":\"eyJhbGciOiJIUzUxMiJ9.eyJuaWNrbmFtZSI6Iui2hee6p-euoeeQhuWRmCIsInVzZXJUeXBlIjoiYWRtaW4iLCJ1c2VySWQiOjEsInVzZXJuYW1lIjoiYWRtaW4iLCJzdWIiOiIxIiwiaWF0IjoxNzc1ODI3OTk5LCJleHAiOjE3NzY0MzI3OTl9.jWePAJYskiV2QPMhjACmVm98rsipfK0TKLbrxgLi_g3XrZRjVy8vyG3_JTFvBu73PVWoG_doNVqknw_97BnrWQ\",\"adminId\":1,\"username\":\"admin\",\"nickname\":\"超级管理员\"}}', 0, NULL, '2026-04-10 21:33:19');
INSERT INTO `sys_oper_log` VALUES (103, '后台登录', 'com.designstudio.system.controller.AuthController.login', 'POST', NULL, NULL, '/api/v1/auth/login', '0:0:0:0:0:0:0:1', '[{\"username\":\"admin\",\"password\":\"admin123\"}]', '{\"code\":200,\"msg\":\"success\",\"data\":{\"token\":\"eyJhbGciOiJIUzUxMiJ9.eyJuaWNrbmFtZSI6Iui2hee6p-euoeeQhuWRmCIsInVzZXJUeXBlIjoiYWRtaW4iLCJ1c2VySWQiOjEsInVzZXJuYW1lIjoiYWRtaW4iLCJzdWIiOiIxIiwiaWF0IjoxNzc1ODI3OTk5LCJleHAiOjE3NzY0MzI3OTl9.jWePAJYskiV2QPMhjACmVm98rsipfK0TKLbrxgLi_g3XrZRjVy8vyG3_JTFvBu73PVWoG_doNVqknw_97BnrWQ\",\"adminId\":1,\"username\":\"admin\",\"nickname\":\"超级管理员\"}}', 0, NULL, '2026-04-10 21:33:19');
INSERT INTO `sys_oper_log` VALUES (104, '后台登录', 'com.designstudio.system.controller.AuthController.login', 'POST', NULL, NULL, '/api/v1/auth/login', '0:0:0:0:0:0:0:1', '[{\"username\":\"adminadmin\",\"password\":\"admin123admin123\"}]', NULL, 1, '用户名或密码错误', '2026-04-10 21:34:15');
INSERT INTO `sys_oper_log` VALUES (105, '后台登录', 'com.designstudio.system.controller.AuthController.login', 'POST', NULL, NULL, '/api/v1/auth/login', '0:0:0:0:0:0:0:1', '[{\"username\":\"adminadmin\",\"password\":\"admin123admin123\"}]', NULL, 1, '用户名或密码错误', '2026-04-10 21:34:32');
INSERT INTO `sys_oper_log` VALUES (106, '后台登录', 'com.designstudio.system.controller.AuthController.login', 'POST', NULL, NULL, '/api/v1/auth/login', '0:0:0:0:0:0:0:1', '[{\"username\":\"admin\",\"password\":\"admin123\"}]', '{\"code\":200,\"msg\":\"success\",\"data\":{\"token\":\"eyJhbGciOiJIUzUxMiJ9.eyJuaWNrbmFtZSI6Iui2hee6p-euoeeQhuWRmCIsInVzZXJUeXBlIjoiYWRtaW4iLCJ1c2VySWQiOjEsInVzZXJuYW1lIjoiYWRtaW4iLCJzdWIiOiIxIiwiaWF0IjoxNzc1ODI4MTU1LCJleHAiOjE3NzY0MzI5NTV9.17vIkgK4clDDuvgeyLlwPX3Ns50MU3l_SwBRJo7BJnQUQUjxrCD1mU6FKxGV37M_bJeRIuwfbMj26wWSihRXNg\",\"adminId\":1,\"username\":\"admin\",\"nickname\":\"超级管理员\"}}', 0, NULL, '2026-04-10 21:35:55');
INSERT INTO `sys_oper_log` VALUES (107, '意向转订单', 'com.designstudio.order.controller.RequestController.convert', 'POST', 1, 'admin', '/api/v1/admin/requests/1/convert', '0:0:0:0:0:0:0:1', '[1,{\"designerId\":2,\"totalAmount\":3500,\"prepayAmount\":1500,\"expectedDate\":1779206400000,\"remark\":\"BOM测试转单\",\"bomTemplateId\":1}]', '{\"code\":200,\"msg\":\"success\",\"data\":{\"orderId\":7,\"orderSn\":\"DS202604102239321777\",\"userId\":1,\"categoryId\":1,\"designerId\":2,\"currentStepId\":1,\"status\":0,\"customDataSnapshot\":\"{\\\"chest\\\": \\\"88\\\", \\\"waist\\\": \\\"68\\\", \\\"length\\\": \\\"120\\\", \\\"shoulder\\\": \\\"38\\\", \\\"fabric_type\\\": \\\"丝绸\\\"}\",\"totalAmount\":3500,\"prepayAmount\":1500,\"paidAmount\":0,\"bomTemplateId\":1,\"expectedDate\":1779206400000,\"remark\":\"BOM测试转单\",\"isBlocked\":0,\"createBy\":1,\"createTime\":1775831972555,\"updateBy\":1,\"updateTime\":1775831972557}}', 0, NULL, '2026-04-10 22:39:32');
INSERT INTO `sys_oper_log` VALUES (108, '取消订单', 'com.designstudio.order.controller.OrderController.cancel', 'POST', 1, 'admin', '/api/v1/admin/orders/7/cancel', '0:0:0:0:0:0:0:1', '[7,{\"cancelReason\":\"测试取消-归还库存\"}]', '{\"code\":200,\"msg\":\"success\"}', 0, NULL, '2026-04-10 22:57:01');
INSERT INTO `sys_oper_log` VALUES (109, '后台登录', 'com.designstudio.system.controller.AuthController.login', 'POST', NULL, NULL, '/api/v1/auth/login', '0:0:0:0:0:0:0:1', '[{\"username\":\"admin\",\"password\":\"admin123\"}]', '{\"code\":200,\"msg\":\"success\",\"data\":{\"token\":\"eyJhbGciOiJIUzUxMiJ9.eyJuaWNrbmFtZSI6Iui2hee6p-euoeeQhuWRmCIsInVzZXJUeXBlIjoiYWRtaW4iLCJ1c2VySWQiOjEsInVzZXJuYW1lIjoiYWRtaW4iLCJzdWIiOiIxIiwiaWF0IjoxNzc1ODM2MzI5LCJleHAiOjE3NzY0NDExMjl9._k25kKU70Z2OWduBHIHKzQzecyLJHo4f4cZeHvhE5GxNo9NxlFgtVSuxXmO2tEPZAmufF2U4-shnTtgIiqHBXA\",\"adminId\":1,\"username\":\"admin\",\"nickname\":\"超级管理员\"}}', 0, NULL, '2026-04-10 23:52:09');
INSERT INTO `sys_oper_log` VALUES (110, '后台登录', 'com.designstudio.system.controller.AuthController.login', 'POST', NULL, NULL, '/api/v1/auth/login', '0:0:0:0:0:0:0:1', '[{\"username\":\"admin\",\"password\":\"admin123\"}]', '{\"code\":200,\"msg\":\"success\",\"data\":{\"token\":\"eyJhbGciOiJIUzUxMiJ9.eyJuaWNrbmFtZSI6Iui2hee6p-euoeeQhuWRmCIsInVzZXJUeXBlIjoiYWRtaW4iLCJ1c2VySWQiOjEsInVzZXJuYW1lIjoiYWRtaW4iLCJzdWIiOiIxIiwiaWF0IjoxNzc1ODgzOTM1LCJleHAiOjE3NzY0ODg3MzV9.PX_TRRLEqBn53yp9o5rMfAYXXn7SVwNF9j01xahwIlFOm1UOI8wJao7VtgKhSvT8L1ejZnD1xsfbzx0LdBA89w\",\"adminId\":1,\"username\":\"admin\",\"nickname\":\"超级管理员\"}}', 0, NULL, '2026-04-11 13:05:34');
INSERT INTO `sys_oper_log` VALUES (111, '后台登录', 'com.designstudio.system.controller.AuthController.login', 'POST', NULL, NULL, '/api/v1/auth/login', '0:0:0:0:0:0:0:1', '[{\"username\":\"admin\",\"password\":\"admin123\"}]', '{\"code\":200,\"msg\":\"success\",\"data\":{\"token\":\"eyJhbGciOiJIUzUxMiJ9.eyJuaWNrbmFtZSI6Iui2hee6p-euoeeQhuWRmCIsInVzZXJUeXBlIjoiYWRtaW4iLCJ1c2VySWQiOjEsInVzZXJuYW1lIjoiYWRtaW4iLCJzdWIiOiIxIiwiaWF0IjoxNzc1ODgzOTM1LCJleHAiOjE3NzY0ODg3MzV9.PX_TRRLEqBn53yp9o5rMfAYXXn7SVwNF9j01xahwIlFOm1UOI8wJao7VtgKhSvT8L1ejZnD1xsfbzx0LdBA89w\",\"adminId\":1,\"username\":\"admin\",\"nickname\":\"超级管理员\"}}', 0, NULL, '2026-04-11 13:05:34');
INSERT INTO `sys_oper_log` VALUES (112, '后台登录', 'com.designstudio.system.controller.AuthController.login', 'POST', NULL, NULL, '/api/v1/auth/login', '0:0:0:0:0:0:0:1', '[{\"username\":\"admin\",\"password\":\"admin123\"}]', '{\"code\":200,\"msg\":\"success\",\"data\":{\"token\":\"eyJhbGciOiJIUzUxMiJ9.eyJuaWNrbmFtZSI6Iui2hee6p-euoeeQhuWRmCIsInVzZXJUeXBlIjoiYWRtaW4iLCJ1c2VySWQiOjEsInVzZXJuYW1lIjoiYWRtaW4iLCJzdWIiOiIxIiwiaWF0IjoxNzc1ODgzOTkzLCJleHAiOjE3NzY0ODg3OTN9.IPTNb-Wyi8psr7b9RBRbRsjTsYnLDPG-Ipr9OeT_Iath5wo5t1gCxysmhB5Nk4I0CCq2YNSY9-BaAhWh0Jokqw\",\"adminId\":1,\"username\":\"admin\",\"nickname\":\"超级管理员\"}}', 0, NULL, '2026-04-11 13:06:33');
INSERT INTO `sys_oper_log` VALUES (113, '后台登录', 'com.designstudio.system.controller.AuthController.login', 'POST', NULL, NULL, '/api/v1/auth/login', '0:0:0:0:0:0:0:1', '[{\"username\":\"admin\",\"password\":\"admin123\"}]', '{\"code\":200,\"msg\":\"success\",\"data\":{\"token\":\"eyJhbGciOiJIUzUxMiJ9.eyJuaWNrbmFtZSI6Iui2hee6p-euoeeQhuWRmCIsInVzZXJUeXBlIjoiYWRtaW4iLCJ1c2VySWQiOjEsInVzZXJuYW1lIjoiYWRtaW4iLCJzdWIiOiIxIiwiaWF0IjoxNzc1ODgzOTkzLCJleHAiOjE3NzY0ODg3OTN9.IPTNb-Wyi8psr7b9RBRbRsjTsYnLDPG-Ipr9OeT_Iath5wo5t1gCxysmhB5Nk4I0CCq2YNSY9-BaAhWh0Jokqw\",\"adminId\":1,\"username\":\"admin\",\"nickname\":\"超级管理员\"}}', 0, NULL, '2026-04-11 13:06:33');
INSERT INTO `sys_oper_log` VALUES (114, '后台登录', 'com.designstudio.system.controller.AuthController.login', 'POST', NULL, NULL, '/api/v1/auth/login', '0:0:0:0:0:0:0:1', '[{\"username\":\"admin\",\"password\":\"admin123\"}]', '{\"code\":200,\"msg\":\"success\",\"data\":{\"token\":\"eyJhbGciOiJIUzUxMiJ9.eyJuaWNrbmFtZSI6Iui2hee6p-euoeeQhuWRmCIsInVzZXJUeXBlIjoiYWRtaW4iLCJ1c2VySWQiOjEsInVzZXJuYW1lIjoiYWRtaW4iLCJzdWIiOiIxIiwiaWF0IjoxNzc1ODg0MDA1LCJleHAiOjE3NzY0ODg4MDV9.7TUbkDwuTZA-rt4GBx6k3r03SslcCG_nU11baEwWkpR8BPV26Z1uKJJ3xMRMgWHb-CDct_S50UqvUWVF5bsS7w\",\"adminId\":1,\"username\":\"admin\",\"nickname\":\"超级管理员\"}}', 0, NULL, '2026-04-11 13:06:46');
INSERT INTO `sys_oper_log` VALUES (115, '后台登录', 'com.designstudio.system.controller.AuthController.login', 'POST', NULL, NULL, '/api/v1/auth/login', '0:0:0:0:0:0:0:1', '[{\"username\":\"admin\",\"password\":\"admin123\"}]', '{\"code\":200,\"msg\":\"success\",\"data\":{\"token\":\"eyJhbGciOiJIUzUxMiJ9.eyJuaWNrbmFtZSI6Iui2hee6p-euoeeQhuWRmCIsInVzZXJUeXBlIjoiYWRtaW4iLCJ1c2VySWQiOjEsInVzZXJuYW1lIjoiYWRtaW4iLCJzdWIiOiIxIiwiaWF0IjoxNzc1ODg0MDE1LCJleHAiOjE3NzY0ODg4MTV9.aGT_h5Dp1yyZvvAjZZIJkD7LWt0S-ISHU9bm4xpAHwdGJ0o9xyNKUqTHb_PxUmUYLPB7nqCSQeetXoTiQ4g9sg\",\"adminId\":1,\"username\":\"admin\",\"nickname\":\"超级管理员\"}}', 0, NULL, '2026-04-11 13:06:55');
INSERT INTO `sys_oper_log` VALUES (116, '后台登录', 'com.designstudio.system.controller.AuthController.login', 'POST', NULL, NULL, '/api/v1/auth/login', '0:0:0:0:0:0:0:1', '[{\"username\":\"admin\",\"password\":\"admin123\"}]', '{\"code\":200,\"msg\":\"success\",\"data\":{\"token\":\"eyJhbGciOiJIUzUxMiJ9.eyJuaWNrbmFtZSI6Iui2hee6p-euoeeQhuWRmCIsInVzZXJUeXBlIjoiYWRtaW4iLCJ1c2VySWQiOjEsInVzZXJuYW1lIjoiYWRtaW4iLCJzdWIiOiIxIiwiaWF0IjoxNzc1ODg0MDM4LCJleHAiOjE3NzY0ODg4Mzh9.AjlDI2_qxuPWXqY4IbYHFB0qtMWyhr5tNmWoswuztclsKHdEElSrOMG35ySDip8N5iI4OtNRsuFnJMs6_Yw6mg\",\"adminId\":1,\"username\":\"admin\",\"nickname\":\"超级管理员\"}}', 0, NULL, '2026-04-11 13:07:18');
INSERT INTO `sys_oper_log` VALUES (117, '执行节点工作台动作', 'com.designstudio.order.controller.WorkbenchController.action', 'POST', 1, 'admin', '/api/v1/admin/workbench/orders/1/action', '0:0:0:0:0:0:0:1', '[1,{\"action\":\"advance\",\"formData\":\"{\\\"chest\\\":\\\"92\\\",\\\"waist\\\":\\\"72\\\"}\"}]', '{\"code\":200,\"msg\":\"success\"}', 0, NULL, '2026-04-11 17:17:35');
INSERT INTO `sys_oper_log` VALUES (118, '意向转订单', 'com.designstudio.order.controller.RequestController.convert', 'POST', 1, 'admin', '/api/v1/admin/requests/7/convert', '0:0:0:0:0:0:0:1', '[7,{\"designerId\":2,\"totalAmount\":100,\"prepayAmount\":10,\"remark\":\"\",\"bomTemplateId\":1}]', '{\"code\":200,\"msg\":\"success\",\"data\":{\"orderId\":8,\"orderSn\":\"DS202604111743293930\",\"userId\":1,\"categoryId\":1,\"designerId\":2,\"currentStepId\":1,\"status\":0,\"customDataSnapshot\":\"{\\\"chest\\\": \\\"123\\\", \\\"waist\\\": \\\"32\\\", \\\"length\\\": \\\"123\\\", \\\"shoulder\\\": \\\"45\\\"}\",\"totalAmount\":100,\"prepayAmount\":10,\"paidAmount\":0,\"bomTemplateId\":1,\"remark\":\"\",\"isBlocked\":0,\"createBy\":1,\"createTime\":1775900609225,\"updateBy\":1,\"updateTime\":1775900609230}}', 0, NULL, '2026-04-11 17:43:29');
INSERT INTO `sys_oper_log` VALUES (119, '后台登出', 'com.designstudio.system.controller.AuthController.logout', 'POST', 1, 'admin', '/api/v1/auth/logout', '0:0:0:0:0:0:0:1', '[\"Bearer eyJhbGciOiJIUzUxMiJ9.eyJuaWNrbmFtZSI6Iui2hee6p-euoeeQhuWRmCIsInVzZXJUeXBlIjoiYWRtaW4iLCJ1c2VySWQiOjEsInVzZXJuYW1lIjoiYWRtaW4iLCJzdWIiOiIxIiwiaWF0IjoxNzc1NzQyNzQyLCJleHAiOjE3NzYzNDc1NDJ9.e-NMGP95iT9AKDx4MXMcnm9x0bu2jfIpUVKarHSNu92HGHZsL13-PhIBC-iCTXfCk4y4JRqbh_Ie9jMGwdWHTw\"]', '{\"code\":200,\"msg\":\"success\"}', 0, NULL, '2026-04-11 17:43:59');
INSERT INTO `sys_oper_log` VALUES (120, '后台登录', 'com.designstudio.system.controller.AuthController.login', 'POST', NULL, NULL, '/api/v1/auth/login', '0:0:0:0:0:0:0:1', '[{\"username\":\"designer1\",\"password\":\"admin123\"}]', '{\"code\":200,\"msg\":\"success\",\"data\":{\"token\":\"eyJhbGciOiJIUzUxMiJ9.eyJuaWNrbmFtZSI6IuadjuiuvuiuoeW4iCIsInVzZXJUeXBlIjoiYWRtaW4iLCJ1c2VySWQiOjIsInVzZXJuYW1lIjoiZGVzaWduZXIxIiwic3ViIjoiMiIsImlhdCI6MTc3NTkwMDY0NywiZXhwIjoxNzc2NTA1NDQ3fQ.OVxmd4Rb8-qpW9u7uO1Sq80W-itSymWd1Df7EREgqIbz0f-tmI8NiJktU7CqnHARtF07keO1UPP2jOlghgk33g\",\"adminId\":2,\"username\":\"designer1\",\"nickname\":\"李设计师\"}}', 0, NULL, '2026-04-11 17:44:07');
INSERT INTO `sys_oper_log` VALUES (121, '后台登出', 'com.designstudio.system.controller.AuthController.logout', 'POST', 2, 'designer1', '/api/v1/auth/logout', '0:0:0:0:0:0:0:1', '[\"Bearer eyJhbGciOiJIUzUxMiJ9.eyJuaWNrbmFtZSI6IuadjuiuvuiuoeW4iCIsInVzZXJUeXBlIjoiYWRtaW4iLCJ1c2VySWQiOjIsInVzZXJuYW1lIjoiZGVzaWduZXIxIiwic3ViIjoiMiIsImlhdCI6MTc3NTkwMDY0NywiZXhwIjoxNzc2NTA1NDQ3fQ.OVxmd4Rb8-qpW9u7uO1Sq80W-itSymWd1Df7EREgqIbz0f-tmI8NiJktU7CqnHARtF07keO1UPP2jOlghgk33g\"]', '{\"code\":200,\"msg\":\"success\"}', 0, NULL, '2026-04-11 17:44:23');
INSERT INTO `sys_oper_log` VALUES (122, '后台登录', 'com.designstudio.system.controller.AuthController.login', 'POST', NULL, NULL, '/api/v1/auth/login', '0:0:0:0:0:0:0:1', '[{\"username\":\"admin\",\"password\":\"admin123\"}]', '{\"code\":200,\"msg\":\"success\",\"data\":{\"token\":\"eyJhbGciOiJIUzUxMiJ9.eyJuaWNrbmFtZSI6Iui2hee6p-euoeeQhuWRmCIsInVzZXJUeXBlIjoiYWRtaW4iLCJ1c2VySWQiOjEsInVzZXJuYW1lIjoiYWRtaW4iLCJzdWIiOiIxIiwiaWF0IjoxNzc1OTAwNjY0LCJleHAiOjE3NzY1MDU0NjR9.b84kHO7L6x43LekjxwnHJF2f71_eUqUSZO24amYy3IOmdm5QOnZZ_TXqntCO_bxcztSFS94a7X4cxI_tWR5Kag\",\"adminId\":1,\"username\":\"admin\",\"nickname\":\"超级管理员\"}}', 0, NULL, '2026-04-11 17:44:24');
INSERT INTO `sys_oper_log` VALUES (123, '意向转订单', 'com.designstudio.order.controller.RequestController.convert', 'POST', 1, 'admin', '/api/v1/admin/requests/10/convert', '0:0:0:0:0:0:0:1', '[10,{\"designerId\":2,\"totalAmount\":1000,\"prepayAmount\":10,\"expectedDate\":1777046400000,\"remark\":\"\"}]', '{\"code\":200,\"msg\":\"success\",\"data\":{\"orderId\":9,\"orderSn\":\"DS202604111801332055\",\"userId\":1,\"categoryId\":1,\"designerId\":2,\"currentStepId\":1,\"status\":0,\"customDataSnapshot\":\"{\\\"chest\\\": \\\"123\\\", \\\"waist\\\": \\\"12\\\", \\\"length\\\": \\\"3\\\", \\\"shoulder\\\": \\\"12\\\"}\",\"totalAmount\":1000,\"prepayAmount\":10,\"paidAmount\":0,\"expectedDate\":1777046400000,\"remark\":\"\",\"isBlocked\":0,\"createBy\":1,\"createTime\":1775901693230,\"updateBy\":1,\"updateTime\":1775901693231}}', 0, NULL, '2026-04-11 18:01:33');
INSERT INTO `sys_oper_log` VALUES (124, '执行节点工作台动作', 'com.designstudio.order.controller.WorkbenchController.action', 'POST', 1, 'admin', '/api/v1/admin/workbench/orders/1/action', '0:0:0:0:0:0:0:1', '[1,{\"action\":\"rollback\",\"rollbackTargetStepId\":1}]', '{\"code\":200,\"msg\":\"success\"}', 0, NULL, '2026-04-11 18:02:52');
INSERT INTO `sys_oper_log` VALUES (125, '执行节点工作台动作', 'com.designstudio.order.controller.WorkbenchController.action', 'POST', 1, 'admin', '/api/v1/admin/workbench/orders/9/action', '0:0:0:0:0:0:0:1', '[9,{\"action\":\"advance\",\"formData\":\"{\\\"chest\\\":\\\"123\\\",\\\"waist\\\":\\\"12\\\"}\"}]', '{\"code\":500,\"msg\":\"只有生产中的订单才能推进\"}', 0, NULL, '2026-04-11 18:03:14');
INSERT INTO `sys_oper_log` VALUES (126, '执行节点工作台动作', 'com.designstudio.order.controller.WorkbenchController.action', 'POST', 1, 'admin', '/api/v1/admin/workbench/orders/8/action', '0:0:0:0:0:0:0:1', '[8,{\"action\":\"advance\",\"formData\":\"{\\\"chest\\\":\\\"123\\\",\\\"waist\\\":\\\"32\\\"}\"}]', '{\"code\":500,\"msg\":\"只有生产中的订单才能推进\"}', 0, NULL, '2026-04-11 18:03:19');
INSERT INTO `sys_oper_log` VALUES (127, '执行节点工作台动作', 'com.designstudio.order.controller.WorkbenchController.action', 'POST', 1, 'admin', '/api/v1/admin/workbench/orders/1/action', '0:0:0:0:0:0:0:1', '[1,{\"action\":\"advance\",\"description\":\"完成需求\",\"formData\":\"{\\\"chest\\\":\\\"92\\\",\\\"waist\\\":\\\"72\\\"}\"}]', '{\"code\":200,\"msg\":\"success\"}', 0, NULL, '2026-04-11 18:04:27');
INSERT INTO `sys_oper_log` VALUES (128, '执行节点工作台动作', 'com.designstudio.order.controller.WorkbenchController.action', 'POST', 1, 'admin', '/api/v1/admin/workbench/orders/1/action', '0:0:0:0:0:0:0:1', '[1,{\"action\":\"block\",\"blockReason\":\"天气原因\"}]', '{\"code\":200,\"msg\":\"success\"}', 0, NULL, '2026-04-11 18:05:24');
INSERT INTO `sys_oper_log` VALUES (129, '后台登出', 'com.designstudio.system.controller.AuthController.logout', 'POST', 1, 'admin', '/api/v1/auth/logout', '0:0:0:0:0:0:0:1', '[\"Bearer eyJhbGciOiJIUzUxMiJ9.eyJuaWNrbmFtZSI6Iui2hee6p-euoeeQhuWRmCIsInVzZXJUeXBlIjoiYWRtaW4iLCJ1c2VySWQiOjEsInVzZXJuYW1lIjoiYWRtaW4iLCJzdWIiOiIxIiwiaWF0IjoxNzc1OTAwNjY0LCJleHAiOjE3NzY1MDU0NjR9.b84kHO7L6x43LekjxwnHJF2f71_eUqUSZO24amYy3IOmdm5QOnZZ_TXqntCO_bxcztSFS94a7X4cxI_tWR5Kag\"]', '{\"code\":200,\"msg\":\"success\"}', 0, NULL, '2026-04-11 18:14:11');
INSERT INTO `sys_oper_log` VALUES (130, '后台登录', 'com.designstudio.system.controller.AuthController.login', 'POST', NULL, NULL, '/api/v1/auth/login', '0:0:0:0:0:0:0:1', '[{\"username\":\"designer\",\"password\":\"admin123\"}]', NULL, 1, '用户名或密码错误', '2026-04-11 18:14:17');
INSERT INTO `sys_oper_log` VALUES (131, '后台登录', 'com.designstudio.system.controller.AuthController.login', 'POST', NULL, NULL, '/api/v1/auth/login', '0:0:0:0:0:0:0:1', '[{\"username\":\"designer1\",\"password\":\"admin123\"}]', '{\"code\":200,\"msg\":\"success\",\"data\":{\"token\":\"eyJhbGciOiJIUzUxMiJ9.eyJuaWNrbmFtZSI6IuadjuiuvuiuoeW4iCIsInVzZXJUeXBlIjoiYWRtaW4iLCJ1c2VySWQiOjIsInVzZXJuYW1lIjoiZGVzaWduZXIxIiwic3ViIjoiMiIsImlhdCI6MTc3NTkwMjQ1OSwiZXhwIjoxNzc2NTA3MjU5fQ.ZmjF6CZel3VDPROPPhlDyRZAG9i9m8P9kuajf_QVFs3Kxi2usXLnKfWZZj7TCbTqLQDQKfAJyn07s8J5teb0hQ\",\"adminId\":2,\"username\":\"designer1\",\"nickname\":\"李设计师\"}}', 0, NULL, '2026-04-11 18:14:20');
INSERT INTO `sys_oper_log` VALUES (132, '后台登出', 'com.designstudio.system.controller.AuthController.logout', 'POST', 2, 'designer1', '/api/v1/auth/logout', '0:0:0:0:0:0:0:1', '[\"Bearer eyJhbGciOiJIUzUxMiJ9.eyJuaWNrbmFtZSI6IuadjuiuvuiuoeW4iCIsInVzZXJUeXBlIjoiYWRtaW4iLCJ1c2VySWQiOjIsInVzZXJuYW1lIjoiZGVzaWduZXIxIiwic3ViIjoiMiIsImlhdCI6MTc3NTkwMjQ1OSwiZXhwIjoxNzc2NTA3MjU5fQ.ZmjF6CZel3VDPROPPhlDyRZAG9i9m8P9kuajf_QVFs3Kxi2usXLnKfWZZj7TCbTqLQDQKfAJyn07s8J5teb0hQ\"]', '{\"code\":200,\"msg\":\"success\"}', 0, NULL, '2026-04-11 18:19:07');
INSERT INTO `sys_oper_log` VALUES (133, '后台登录', 'com.designstudio.system.controller.AuthController.login', 'POST', NULL, NULL, '/api/v1/auth/login', '0:0:0:0:0:0:0:1', '[{\"username\":\"admin\",\"password\":\"admin123\"}]', '{\"code\":200,\"msg\":\"success\",\"data\":{\"token\":\"eyJhbGciOiJIUzUxMiJ9.eyJuaWNrbmFtZSI6Iui2hee6p-euoeeQhuWRmCIsInVzZXJUeXBlIjoiYWRtaW4iLCJ1c2VySWQiOjEsInVzZXJuYW1lIjoiYWRtaW4iLCJzdWIiOiIxIiwiaWF0IjoxNzc1OTAyNzQ5LCJleHAiOjE3NzY1MDc1NDl9.8FQd-h8M5zOumyqX62Bt7wyDWBytNZuzXkqk2Ube8wWsrrvIMhS7015s-SDreGWcWvPoa81X8t5x5IGVFCN13g\",\"adminId\":1,\"username\":\"admin\",\"nickname\":\"超级管理员\"}}', 0, NULL, '2026-04-11 18:19:09');
INSERT INTO `sys_oper_log` VALUES (134, '后台登录', 'com.designstudio.system.controller.AuthController.login', 'POST', NULL, NULL, '/api/v1/auth/login', '0:0:0:0:0:0:0:1', '[{\"username\":\"admin\",\"password\":\"admin123\"}]', '{\"code\":200,\"msg\":\"success\",\"data\":{\"token\":\"eyJhbGciOiJIUzUxMiJ9.eyJuaWNrbmFtZSI6Iui2hee6p-euoeeQhuWRmCIsInVzZXJUeXBlIjoiYWRtaW4iLCJ1c2VySWQiOjEsInVzZXJuYW1lIjoiYWRtaW4iLCJzdWIiOiIxIiwiaWF0IjoxNzc2MDYwNDQ5LCJleHAiOjE3NzY2NjUyNDl9.HWi3dIAY75iUTZZk7dpgtq5Ua0jILREbrDHjHOkmf35y-fM2MAIFXHgafHSfqpB26izFk8z9K-JDtYr5uYAdVg\",\"adminId\":1,\"username\":\"admin\",\"nickname\":\"超级管理员\"}}', 0, NULL, '2026-04-13 14:07:29');
INSERT INTO `sys_oper_log` VALUES (135, '后台登录', 'com.designstudio.system.controller.AuthController.login', 'POST', NULL, NULL, '/api/v1/auth/login', '0:0:0:0:0:0:0:1', '[{\"username\":\"admin\",\"password\":\"admin123admin123\"}]', NULL, 1, '用户名或密码错误', '2026-04-14 21:50:49');
INSERT INTO `sys_oper_log` VALUES (136, '后台登录', 'com.designstudio.system.controller.AuthController.login', 'POST', NULL, NULL, '/api/v1/auth/login', '0:0:0:0:0:0:0:1', '[{\"username\":\"admin\",\"password\":\"admin123\"}]', '{\"code\":200,\"msg\":\"success\",\"data\":{\"token\":\"eyJhbGciOiJIUzUxMiJ9.eyJuaWNrbmFtZSI6Iui2hee6p-euoeeQhuWRmCIsInVzZXJUeXBlIjoiYWRtaW4iLCJ1c2VySWQiOjEsInVzZXJuYW1lIjoiYWRtaW4iLCJzdWIiOiIxIiwiaWF0IjoxNzc2MTc0ODE3LCJleHAiOjE3NzY3Nzk2MTd9.aOLNnviFrJe3UHTcqSQoD6xS7QyHT440ean9aWKaLxGfd57GmWf8KsJydbLMT4ot8K061JfWdJmz02cErWSofg\",\"adminId\":1,\"username\":\"admin\",\"nickname\":\"超级管理员\"}}', 0, NULL, '2026-04-14 21:53:37');
INSERT INTO `sys_oper_log` VALUES (137, '后台登录', 'com.designstudio.system.controller.AuthController.login', 'POST', NULL, NULL, '/api/v1/auth/login', '0:0:0:0:0:0:0:1', '[{\"username\":\"admin\",\"password\":\"admin123\"}]', '{\"code\":200,\"msg\":\"success\",\"data\":{\"token\":\"eyJhbGciOiJIUzUxMiJ9.eyJuaWNrbmFtZSI6Iui2hee6p-euoeeQhuWRmCIsInVzZXJUeXBlIjoiYWRtaW4iLCJ1c2VySWQiOjEsInVzZXJuYW1lIjoiYWRtaW4iLCJzdWIiOiIxIiwiaWF0IjoxNzc2MTc1MTQzLCJleHAiOjE3NzY3Nzk5NDN9.XZYiL2mIW7fj7r3bJQtA6yojwhfr90gV70Lee0vgwFrcPscVZY6cToFn8fk-fetqgyHNOxF9Km7zsoZHeY54Ng\",\"adminId\":1,\"username\":\"admin\",\"nickname\":\"超级管理员\"}}', 0, NULL, '2026-04-14 21:59:03');
INSERT INTO `sys_oper_log` VALUES (138, '后台登录', 'com.designstudio.system.controller.AuthController.login', 'POST', NULL, NULL, '/api/v1/auth/login', '0:0:0:0:0:0:0:1', '[{\"username\":\"admin\",\"password\":\"admin123\"}]', '{\"code\":200,\"msg\":\"success\",\"data\":{\"token\":\"eyJhbGciOiJIUzUxMiJ9.eyJuaWNrbmFtZSI6Iui2hee6p-euoeeQhuWRmCIsInVzZXJUeXBlIjoiYWRtaW4iLCJ1c2VySWQiOjEsInVzZXJuYW1lIjoiYWRtaW4iLCJzdWIiOiIxIiwiaWF0IjoxNzc2MTc1ODM1LCJleHAiOjE3NzY3ODA2MzV9.UiccuGcXJULX967BbsIjDh-5M8JoP-u44frKOsAOVPcRAHQoSbBxckr5Xr6G1dhst9JKtkVTWqFNikFti72RXw\",\"adminId\":1,\"username\":\"admin\",\"nickname\":\"超级管理员\"}}', 0, NULL, '2026-04-14 22:10:36');
INSERT INTO `sys_oper_log` VALUES (139, '后台登录', 'com.designstudio.system.controller.AuthController.login', 'POST', NULL, NULL, '/api/v1/auth/login', '0:0:0:0:0:0:0:1', '[{\"username\":\"admin\",\"password\":\"admin123\"}]', '{\"code\":200,\"msg\":\"success\",\"data\":{\"token\":\"eyJhbGciOiJIUzUxMiJ9.eyJuaWNrbmFtZSI6Iui2hee6p-euoeeQhuWRmCIsInVzZXJUeXBlIjoiYWRtaW4iLCJ1c2VySWQiOjEsInVzZXJuYW1lIjoiYWRtaW4iLCJzdWIiOiIxIiwiaWF0IjoxNzc2MTc1ODk5LCJleHAiOjE3NzY3ODA2OTl9.ZtQkOsltghq4Y3UKMqU6D_wKx671r5k5l_iuXnLJH0roGAwjnt85ig6pe57U0b5SRicFU0D0xW-JokgKha_ksQ\",\"adminId\":1,\"username\":\"admin\",\"nickname\":\"超级管理员\"}}', 0, NULL, '2026-04-14 22:11:39');
INSERT INTO `sys_oper_log` VALUES (140, '后台登录', 'com.designstudio.system.controller.AuthController.login', 'POST', NULL, NULL, '/api/v1/auth/login', '0:0:0:0:0:0:0:1', '[{\"username\":\"admin\",\"password\":\"admin123\"}]', '{\"code\":200,\"msg\":\"success\",\"data\":{\"token\":\"eyJhbGciOiJIUzUxMiJ9.eyJuaWNrbmFtZSI6Iui2hee6p-euoeeQhuWRmCIsInVzZXJUeXBlIjoiYWRtaW4iLCJ1c2VySWQiOjEsInVzZXJuYW1lIjoiYWRtaW4iLCJzdWIiOiIxIiwiaWF0IjoxNzc2MTc1OTI0LCJleHAiOjE3NzY3ODA3MjR9.fmSBy8obn7umLGCOEzsAMl8HAvf3G4LvCvLO8vsTkoYpHiZGdDkVtmFQhuiRWH_lH048R3RZ44dqo9duKmbdaA\",\"adminId\":1,\"username\":\"admin\",\"nickname\":\"超级管理员\"}}', 0, NULL, '2026-04-14 22:12:04');
INSERT INTO `sys_oper_log` VALUES (141, '后台登录', 'com.designstudio.system.controller.AuthController.login', 'POST', NULL, NULL, '/api/v1/auth/login', '0:0:0:0:0:0:0:1', '[{\"username\":\"admin\",\"password\":\"admin123\"}]', '{\"code\":200,\"msg\":\"success\",\"data\":{\"token\":\"eyJhbGciOiJIUzUxMiJ9.eyJuaWNrbmFtZSI6Iui2hee6p-euoeeQhuWRmCIsInVzZXJUeXBlIjoiYWRtaW4iLCJ1c2VySWQiOjEsInVzZXJuYW1lIjoiYWRtaW4iLCJzdWIiOiIxIiwiaWF0IjoxNzc2MjQ1NjM0LCJleHAiOjE3NzY4NTA0MzR9.NeudHAdPDHBpCLcRCwMzvdud940xvbp4BBoVyOt_Q_zxJyFIQGfl1cEaQCSkHHgVc_CrcNjdUmt-qXn-inNd7Q\",\"adminId\":1,\"username\":\"admin\",\"nickname\":\"超级管理员\"}}', 0, NULL, '2026-04-15 17:33:54');
INSERT INTO `sys_oper_log` VALUES (142, '后台登录', 'com.designstudio.system.controller.AuthController.login', 'POST', NULL, NULL, '/api/v1/auth/login', '0:0:0:0:0:0:0:1', '[{\"username\":\"admin\",\"password\":\"admin123admin123\"}]', NULL, 1, '用户名或密码错误', '2026-04-15 17:34:11');
INSERT INTO `sys_oper_log` VALUES (143, '后台登录', 'com.designstudio.system.controller.AuthController.login', 'POST', NULL, NULL, '/api/v1/auth/login', '0:0:0:0:0:0:0:1', '[{\"username\":\"admin\",\"password\":\"admin123admin123\"}]', NULL, 1, '用户名或密码错误', '2026-04-15 17:35:38');
INSERT INTO `sys_oper_log` VALUES (144, '后台登录', 'com.designstudio.system.controller.AuthController.login', 'POST', NULL, NULL, '/api/v1/auth/login', '0:0:0:0:0:0:0:1', '[{\"username\":\"admin\",\"password\":\"admin123\"}]', '{\"code\":200,\"msg\":\"success\",\"data\":{\"token\":\"eyJhbGciOiJIUzUxMiJ9.eyJuaWNrbmFtZSI6Iui2hee6p-euoeeQhuWRmCIsInVzZXJUeXBlIjoiYWRtaW4iLCJ1c2VySWQiOjEsInVzZXJuYW1lIjoiYWRtaW4iLCJzdWIiOiIxIiwiaWF0IjoxNzc2MjQ1NzQzLCJleHAiOjE3NzY4NTA1NDN9.eexSdczI6CIhCawWWYvPkdiQg5Nc_WqChAGeE8PE3wtPJXH3WUEyqD-DNSI7cKbFszkIfKfmR2QY3TB4DqJ88g\",\"adminId\":1,\"username\":\"admin\",\"nickname\":\"超级管理员\"}}', 0, NULL, '2026-04-15 17:35:43');
INSERT INTO `sys_oper_log` VALUES (145, '后台登录', 'com.designstudio.system.controller.AuthController.login', 'POST', NULL, NULL, '/api/v1/auth/login', '0:0:0:0:0:0:0:1', '[{\"username\":\"admin\",\"password\":\"admin123\"}]', '{\"code\":200,\"msg\":\"success\",\"data\":{\"token\":\"eyJhbGciOiJIUzUxMiJ9.eyJuaWNrbmFtZSI6Iui2hee6p-euoeeQhuWRmCIsInVzZXJUeXBlIjoiYWRtaW4iLCJ1c2VySWQiOjEsInVzZXJuYW1lIjoiYWRtaW4iLCJzdWIiOiIxIiwiaWF0IjoxNzc2MjQ2MTYyLCJleHAiOjE3NzY4NTA5NjJ9.BaRRXiZBa7Hpf-EMpwwYTwTRO0qkMgYwqGhFYX-iLzFFaBanTgCnFO2c_0mt6Umo06Gtl1cSF17Dl2ITnaoqIA\",\"adminId\":1,\"username\":\"admin\",\"nickname\":\"超级管理员\"}}', 0, NULL, '2026-04-15 17:42:43');
INSERT INTO `sys_oper_log` VALUES (146, '后台登录', 'com.designstudio.system.controller.AuthController.login', 'POST', NULL, NULL, '/api/v1/auth/login', '0:0:0:0:0:0:0:1', '[{\"username\":\"admin\",\"password\":\"admin123\"}]', '{\"code\":200,\"msg\":\"success\",\"data\":{\"token\":\"eyJhbGciOiJIUzUxMiJ9.eyJuaWNrbmFtZSI6Iui2hee6p-euoeeQhuWRmCIsInVzZXJUeXBlIjoiYWRtaW4iLCJ1c2VySWQiOjEsInVzZXJuYW1lIjoiYWRtaW4iLCJzdWIiOiIxIiwiaWF0IjoxNzc2MjQ2MTcwLCJleHAiOjE3NzY4NTA5NzB9.gPYu0y9-9Ex1WoTNEegmpjy6Usp8nFdlW6dp3czsBMTKA16soLm8fmkeSrTPEA46EVPg1-4MyWbLnRmAeTZBWQ\",\"adminId\":1,\"username\":\"admin\",\"nickname\":\"超级管理员\"}}', 0, NULL, '2026-04-15 17:42:51');
INSERT INTO `sys_oper_log` VALUES (147, '后台登录', 'com.designstudio.system.controller.AuthController.login', 'POST', NULL, NULL, '/api/v1/auth/login', '0:0:0:0:0:0:0:1', '[{\"username\":\"admin\",\"password\":\"admin123\"}]', '{\"code\":200,\"msg\":\"success\",\"data\":{\"token\":\"eyJhbGciOiJIUzUxMiJ9.eyJuaWNrbmFtZSI6Iui2hee6p-euoeeQhuWRmCIsInVzZXJUeXBlIjoiYWRtaW4iLCJ1c2VySWQiOjEsInVzZXJuYW1lIjoiYWRtaW4iLCJzdWIiOiIxIiwiaWF0IjoxNzc2MjQ2ODEyLCJleHAiOjE3NzY4NTE2MTJ9.S5GBGH5ATXs02l-d7KHFIbvYNlUvTYIscFkVIg3-1eMMHSAiwRAObhsLC5xcCu9ZJz4eC8B27sicLyeebF62yw\",\"adminId\":1,\"username\":\"admin\",\"nickname\":\"超级管理员\"}}', 0, NULL, '2026-04-15 17:53:33');
INSERT INTO `sys_oper_log` VALUES (148, '新增后台用户', 'com.designstudio.system.controller.SysAdminController.add', 'POST', 1, 'admin', '/api/v1/admin/users', '0:0:0:0:0:0:0:1', '[{\"username\":\"storekeeper\",\"password\":\"\",\"nickname\":\"storekeeper\",\"phone\":\"\",\"status\":1,\"roleIds\":[3]}]', '{\"code\":200,\"msg\":\"success\"}', 0, NULL, '2026-04-20 00:45:35');
INSERT INTO `sys_oper_log` VALUES (149, '新增后台用户', 'com.designstudio.system.controller.SysAdminController.add', 'POST', 1, 'admin', '/api/v1/admin/users', '0:0:0:0:0:0:0:1', '[{\"username\":\"purchaser\",\"password\":\"\",\"nickname\":\"purchaser\",\"phone\":\"\",\"status\":1,\"roleIds\":[4]}]', '{\"code\":200,\"msg\":\"success\"}', 0, NULL, '2026-04-20 00:45:44');
INSERT INTO `sys_oper_log` VALUES (150, '新增后台用户', 'com.designstudio.system.controller.SysAdminController.add', 'POST', 1, 'admin', '/api/v1/admin/users', '0:0:0:0:0:0:0:1', '[{\"username\":\"finance\",\"password\":\"\",\"nickname\":\"finance\",\"phone\":\"\",\"status\":1,\"roleIds\":[5]}]', '{\"code\":200,\"msg\":\"success\"}', 0, NULL, '2026-04-20 00:45:54');
INSERT INTO `sys_oper_log` VALUES (151, '新增后台用户', 'com.designstudio.system.controller.SysAdminController.add', 'POST', 1, 'admin', '/api/v1/admin/users', '0:0:0:0:0:0:0:1', '[{\"username\":\"customer_service\",\"password\":\"\",\"nickname\":\"customer_service\",\"phone\":\"\",\"status\":1,\"roleIds\":[6]}]', '{\"code\":200,\"msg\":\"success\"}', 0, NULL, '2026-04-20 00:46:07');
INSERT INTO `sys_oper_log` VALUES (152, '后台登出', 'com.designstudio.system.controller.AuthController.logout', 'POST', 1, 'admin', '/api/v1/auth/logout', '0:0:0:0:0:0:0:1', '[\"Bearer eyJhbGciOiJIUzUxMiJ9.eyJuaWNrbmFtZSI6Iui2hee6p-euoeeQhuWRmCIsInVzZXJUeXBlIjoiYWRtaW4iLCJ1c2VySWQiOjEsInVzZXJuYW1lIjoiYWRtaW4iLCJzdWIiOiIxIiwiaWF0IjoxNzc2MDYwNDQ5LCJleHAiOjE3NzY2NjUyNDl9.HWi3dIAY75iUTZZk7dpgtq5Ua0jILREbrDHjHOkmf35y-fM2MAIFXHgafHSfqpB26izFk8z9K-JDtYr5uYAdVg\"]', '{\"code\":200,\"msg\":\"success\"}', 0, NULL, '2026-04-20 00:46:17');
INSERT INTO `sys_oper_log` VALUES (153, '后台登录', 'com.designstudio.system.controller.AuthController.login', 'POST', NULL, NULL, '/api/v1/auth/login', '0:0:0:0:0:0:0:1', '[{\"username\":\"storekeeper\",\"password\":\"123456\"}]', '{\"code\":200,\"msg\":\"success\",\"data\":{\"token\":\"eyJhbGciOiJIUzUxMiJ9.eyJyb2xlcyI6WyJzdG9yZWtlZXBlciJdLCJuaWNrbmFtZSI6InN0b3Jla2VlcGVyIiwidXNlclR5cGUiOiJhZG1pbiIsInVzZXJJZCI6NCwidXNlcm5hbWUiOiJzdG9yZWtlZXBlciIsInN1YiI6IjQiLCJpYXQiOjE3NzY2MTcxOTMsImV4cCI6MTc3NzIyMTk5M30.Qn5kLCSGri45SwHpyViBqHtAnM-Mcnp8XmuYRQ9UhwBz5BL8jX9wWt6nkk48EoOiK9yYiFaWEmpl7t8KEVNluw\",\"adminId\":4,\"username\":\"storekeeper\",\"nickname\":\"storekeeper\"}}', 0, NULL, '2026-04-20 00:46:34');
INSERT INTO `sys_oper_log` VALUES (154, '后台登出', 'com.designstudio.system.controller.AuthController.logout', 'POST', 4, 'storekeeper', '/api/v1/auth/logout', '0:0:0:0:0:0:0:1', '[\"Bearer eyJhbGciOiJIUzUxMiJ9.eyJyb2xlcyI6WyJzdG9yZWtlZXBlciJdLCJuaWNrbmFtZSI6InN0b3Jla2VlcGVyIiwidXNlclR5cGUiOiJhZG1pbiIsInVzZXJJZCI6NCwidXNlcm5hbWUiOiJzdG9yZWtlZXBlciIsInN1YiI6IjQiLCJpYXQiOjE3NzY2MTcxOTMsImV4cCI6MTc3NzIyMTk5M30.Qn5kLCSGri45SwHpyViBqHtAnM-Mcnp8XmuYRQ9UhwBz5BL8jX9wWt6nkk48EoOiK9yYiFaWEmpl7t8KEVNluw\"]', '{\"code\":200,\"msg\":\"success\"}', 0, NULL, '2026-04-20 00:47:03');
INSERT INTO `sys_oper_log` VALUES (155, '后台登录', 'com.designstudio.system.controller.AuthController.login', 'POST', NULL, NULL, '/api/v1/auth/login', '0:0:0:0:0:0:0:1', '[{\"username\":\"purchaser\",\"password\":\"123456\"}]', '{\"code\":200,\"msg\":\"success\",\"data\":{\"token\":\"eyJhbGciOiJIUzUxMiJ9.eyJyb2xlcyI6WyJwdXJjaGFzZXIiXSwibmlja25hbWUiOiJwdXJjaGFzZXIiLCJ1c2VyVHlwZSI6ImFkbWluIiwidXNlcklkIjo1LCJ1c2VybmFtZSI6InB1cmNoYXNlciIsInN1YiI6IjUiLCJpYXQiOjE3NzY2MTcyMjYsImV4cCI6MTc3NzIyMjAyNn0.-qnfwur4dIrCQ1MqNT3-4lXoeTZLRMvgBnbmOxhkudEstiGE85jftozq5Ko5q10OvupI1bTkE3Ak67kY-cGTCQ\",\"adminId\":5,\"username\":\"purchaser\",\"nickname\":\"purchaser\"}}', 0, NULL, '2026-04-20 00:47:06');
INSERT INTO `sys_oper_log` VALUES (156, '后台登出', 'com.designstudio.system.controller.AuthController.logout', 'POST', 5, 'purchaser', '/api/v1/auth/logout', '0:0:0:0:0:0:0:1', '[\"Bearer eyJhbGciOiJIUzUxMiJ9.eyJyb2xlcyI6WyJwdXJjaGFzZXIiXSwibmlja25hbWUiOiJwdXJjaGFzZXIiLCJ1c2VyVHlwZSI6ImFkbWluIiwidXNlcklkIjo1LCJ1c2VybmFtZSI6InB1cmNoYXNlciIsInN1YiI6IjUiLCJpYXQiOjE3NzY2MTcyMjYsImV4cCI6MTc3NzIyMjAyNn0.-qnfwur4dIrCQ1MqNT3-4lXoeTZLRMvgBnbmOxhkudEstiGE85jftozq5Ko5q10OvupI1bTkE3Ak67kY-cGTCQ\"]', '{\"code\":200,\"msg\":\"success\"}', 0, NULL, '2026-04-20 00:47:32');
INSERT INTO `sys_oper_log` VALUES (157, '后台登录', 'com.designstudio.system.controller.AuthController.login', 'POST', NULL, NULL, '/api/v1/auth/login', '0:0:0:0:0:0:0:1', '[{\"username\":\"finance\",\"password\":\"12346\"}]', NULL, 1, '用户名或密码错误', '2026-04-20 00:47:42');
INSERT INTO `sys_oper_log` VALUES (158, '后台登录', 'com.designstudio.system.controller.AuthController.login', 'POST', NULL, NULL, '/api/v1/auth/login', '0:0:0:0:0:0:0:1', '[{\"username\":\"finance\",\"password\":\"123456\"}]', '{\"code\":200,\"msg\":\"success\",\"data\":{\"token\":\"eyJhbGciOiJIUzUxMiJ9.eyJyb2xlcyI6WyJmaW5hbmNlIl0sIm5pY2tuYW1lIjoiZmluYW5jZSIsInVzZXJUeXBlIjoiYWRtaW4iLCJ1c2VySWQiOjYsInVzZXJuYW1lIjoiZmluYW5jZSIsInN1YiI6IjYiLCJpYXQiOjE3NzY2MTcyNjUsImV4cCI6MTc3NzIyMjA2NX0.OeFEJD7qo-GDrg4qb7KzQyJMMO0YsPNYLx3EBZIrKsUs6cnDALONKF3kLT7On8oolF8QNMWLpeHDvRhbq5p5EQ\",\"adminId\":6,\"username\":\"finance\",\"nickname\":\"finance\"}}', 0, NULL, '2026-04-20 00:47:46');
INSERT INTO `sys_oper_log` VALUES (159, '后台登出', 'com.designstudio.system.controller.AuthController.logout', 'POST', 6, 'finance', '/api/v1/auth/logout', '0:0:0:0:0:0:0:1', '[\"Bearer eyJhbGciOiJIUzUxMiJ9.eyJyb2xlcyI6WyJmaW5hbmNlIl0sIm5pY2tuYW1lIjoiZmluYW5jZSIsInVzZXJUeXBlIjoiYWRtaW4iLCJ1c2VySWQiOjYsInVzZXJuYW1lIjoiZmluYW5jZSIsInN1YiI6IjYiLCJpYXQiOjE3NzY2MTcyNjUsImV4cCI6MTc3NzIyMjA2NX0.OeFEJD7qo-GDrg4qb7KzQyJMMO0YsPNYLx3EBZIrKsUs6cnDALONKF3kLT7On8oolF8QNMWLpeHDvRhbq5p5EQ\"]', '{\"code\":200,\"msg\":\"success\"}', 0, NULL, '2026-04-20 00:47:54');
INSERT INTO `sys_oper_log` VALUES (160, '后台登录', 'com.designstudio.system.controller.AuthController.login', 'POST', NULL, NULL, '/api/v1/auth/login', '0:0:0:0:0:0:0:1', '[{\"username\":\"customer_service\",\"password\":\"123456\"}]', '{\"code\":200,\"msg\":\"success\",\"data\":{\"token\":\"eyJhbGciOiJIUzUxMiJ9.eyJyb2xlcyI6WyJjdXN0b21lcl9zZXJ2aWNlIl0sIm5pY2tuYW1lIjoiY3VzdG9tZXJfc2VydmljZSIsInVzZXJUeXBlIjoiYWRtaW4iLCJ1c2VySWQiOjcsInVzZXJuYW1lIjoiY3VzdG9tZXJfc2VydmljZSIsInN1YiI6IjciLCJpYXQiOjE3NzY2MTcyODUsImV4cCI6MTc3NzIyMjA4NX0.ifSyKjSJUiTwDle1BxaYRf_q70-gvwXvab8LKGtKhzSsrxc1PsDLpdxyF2iTNSc6Oah-2wqg-4ud452TS3Pl-g\",\"adminId\":7,\"username\":\"customer_service\",\"nickname\":\"customer_service\"}}', 0, NULL, '2026-04-20 00:48:05');
INSERT INTO `sys_oper_log` VALUES (161, '后台登出', 'com.designstudio.system.controller.AuthController.logout', 'POST', 7, 'customer_service', '/api/v1/auth/logout', '0:0:0:0:0:0:0:1', '[\"Bearer eyJhbGciOiJIUzUxMiJ9.eyJyb2xlcyI6WyJjdXN0b21lcl9zZXJ2aWNlIl0sIm5pY2tuYW1lIjoiY3VzdG9tZXJfc2VydmljZSIsInVzZXJUeXBlIjoiYWRtaW4iLCJ1c2VySWQiOjcsInVzZXJuYW1lIjoiY3VzdG9tZXJfc2VydmljZSIsInN1YiI6IjciLCJpYXQiOjE3NzY2MTcyODUsImV4cCI6MTc3NzIyMjA4NX0.ifSyKjSJUiTwDle1BxaYRf_q70-gvwXvab8LKGtKhzSsrxc1PsDLpdxyF2iTNSc6Oah-2wqg-4ud452TS3Pl-g\"]', '{\"code\":200,\"msg\":\"success\"}', 0, NULL, '2026-04-20 23:33:35');
INSERT INTO `sys_oper_log` VALUES (162, '后台登录', 'com.designstudio.system.controller.AuthController.login', 'POST', NULL, NULL, '/api/v1/auth/login', '0:0:0:0:0:0:0:1', '[{\"username\":\"admin\",\"password\":\"admin123\"}]', '{\"code\":200,\"msg\":\"success\",\"data\":{\"token\":\"eyJhbGciOiJIUzUxMiJ9.eyJyb2xlcyI6WyJhZG1pbiJdLCJuaWNrbmFtZSI6Iui2hee6p-euoeeQhuWRmCIsInVzZXJUeXBlIjoiYWRtaW4iLCJ1c2VySWQiOjEsInVzZXJuYW1lIjoiYWRtaW4iLCJzdWIiOiIxIiwiaWF0IjoxNzc2Njk5MjE1LCJleHAiOjE3NzczMDQwMTV9.kQaACO1texG8Y4bqUzW_msMUcxUcegeypTmJCwyUlTvLWSFuHtOvj3-fH8bm02BybkBMYcH2JDdHgtx0nXdVkQ\",\"adminId\":1,\"username\":\"admin\",\"nickname\":\"超级管理员\"}}', 0, NULL, '2026-04-20 23:33:36');
INSERT INTO `sys_oper_log` VALUES (163, '执行节点工作台动作', 'com.designstudio.order.controller.WorkbenchController.action', 'POST', 1, 'admin', '/api/v1/admin/workbench/orders/9/action', '0:0:0:0:0:0:0:1', '[9,{\"action\":\"save\",\"formData\":\"{\\\"chest\\\":\\\"123\\\",\\\"waist\\\":\\\"12\\\"}\"}]', '{\"code\":200,\"msg\":\"success\"}', 0, NULL, '2026-04-21 00:28:54');
INSERT INTO `sys_oper_log` VALUES (164, '执行节点工作台动作', 'com.designstudio.order.controller.WorkbenchController.action', 'POST', 1, 'admin', '/api/v1/admin/workbench/orders/9/action', '0:0:0:0:0:0:0:1', '[9,{\"action\":\"save\",\"formData\":\"{\\\"chest\\\":\\\"123\\\",\\\"waist\\\":\\\"12\\\"}\"}]', '{\"code\":200,\"msg\":\"success\"}', 0, NULL, '2026-04-21 00:28:56');
INSERT INTO `sys_oper_log` VALUES (165, '执行节点工作台动作', 'com.designstudio.order.controller.WorkbenchController.action', 'POST', 1, 'admin', '/api/v1/admin/workbench/orders/9/action', '0:0:0:0:0:0:0:1', '[9,{\"action\":\"save\",\"formData\":\"{\\\"chest\\\":\\\"123\\\",\\\"waist\\\":\\\"12\\\"}\"}]', '{\"code\":200,\"msg\":\"success\"}', 0, NULL, '2026-04-21 00:28:58');
INSERT INTO `sys_oper_log` VALUES (166, '执行节点工作台动作', 'com.designstudio.order.controller.WorkbenchController.action', 'POST', 1, 'admin', '/api/v1/admin/workbench/orders/9/action', '0:0:0:0:0:0:0:1', '[9,{\"action\":\"save\",\"formData\":\"{\\\"chest\\\":\\\"123\\\",\\\"waist\\\":\\\"12\\\"}\"}]', '{\"code\":200,\"msg\":\"success\"}', 0, NULL, '2026-04-21 00:29:03');
INSERT INTO `sys_oper_log` VALUES (167, '执行节点工作台动作', 'com.designstudio.order.controller.WorkbenchController.action', 'POST', 1, 'admin', '/api/v1/admin/workbench/orders/9/action', '0:0:0:0:0:0:0:1', '[9,{\"action\":\"save\",\"formData\":\"{\\\"chest\\\":\\\"123\\\",\\\"waist\\\":\\\"12\\\"}\"}]', '{\"code\":200,\"msg\":\"success\"}', 0, NULL, '2026-04-21 00:40:00');
INSERT INTO `sys_oper_log` VALUES (168, '后台登录', 'com.designstudio.system.controller.AuthController.login', 'POST', NULL, NULL, '/api/v1/auth/login', '0:0:0:0:0:0:0:1', '[{\"username\":\"admin\",\"password\":\"admin123\"}]', '{\"code\":200,\"msg\":\"success\",\"data\":{\"token\":\"eyJhbGciOiJIUzUxMiJ9.eyJyb2xlcyI6WyJhZG1pbiJdLCJuaWNrbmFtZSI6Iui2hee6p-euoeeQhuWRmCIsInVzZXJUeXBlIjoiYWRtaW4iLCJ1c2VySWQiOjEsInVzZXJuYW1lIjoiYWRtaW4iLCJzdWIiOiIxIiwiaWF0IjoxNzc3MzA3Mjc4LCJleHAiOjE3Nzc5MTIwNzh9._Z8vfKZ6TMRez39v-2M0Rn7UtDMKENNHDQsjER0M1mg0_hZ84r1N7OzfjkPy-H5mJeZMna1EWmR0UAKm7l0QGQ\",\"adminId\":1,\"username\":\"admin\",\"nickname\":\"超级管理员\"}}', 0, NULL, '2026-04-28 00:27:58');
INSERT INTO `sys_oper_log` VALUES (169, '后台登录', 'com.designstudio.system.controller.AuthController.login', 'POST', NULL, NULL, '/api/v1/auth/login', '0:0:0:0:0:0:0:1', '[{\"username\":\"admin\",\"password\":\"admin123\"}]', '{\"code\":200,\"msg\":\"success\",\"data\":{\"token\":\"eyJhbGciOiJIUzUxMiJ9.eyJyb2xlcyI6WyJhZG1pbiJdLCJuaWNrbmFtZSI6Iui2hee6p-euoeeQhuWRmCIsInVzZXJUeXBlIjoiYWRtaW4iLCJ1c2VySWQiOjEsInVzZXJuYW1lIjoiYWRtaW4iLCJzdWIiOiIxIiwiaWF0IjoxNzc3NDY4NDY2LCJleHAiOjE3NzgwNzMyNjZ9.jOydZCnQc7XZx7fCz4XPzthQWU1anLvb5QzmAbe0oKxbBuTrKyATGwSNXXnJkN0q5ae4nN80jJUf5-e5prrqYA\",\"adminId\":1,\"username\":\"admin\",\"nickname\":\"超级管理员\"}}', 0, NULL, '2026-04-29 21:14:26');
INSERT INTO `sys_oper_log` VALUES (170, '后台登录', 'com.designstudio.system.controller.AuthController.login', 'POST', NULL, NULL, '/api/v1/auth/login', '0:0:0:0:0:0:0:1', '[{\"username\":\"designer1\",\"password\":\"admin123\"}]', '{\"code\":200,\"msg\":\"success\",\"data\":{\"token\":\"eyJhbGciOiJIUzUxMiJ9.eyJyb2xlcyI6WyJkZXNpZ25lciJdLCJuaWNrbmFtZSI6IuadjuiuvuiuoeW4iCIsInVzZXJUeXBlIjoiYWRtaW4iLCJ1c2VySWQiOjIsInVzZXJuYW1lIjoiZGVzaWduZXIxIiwic3ViIjoiMiIsImlhdCI6MTc3NzQ2ODQ4NCwiZXhwIjoxNzc4MDczMjg0fQ.AUoAt-dXDIIj7cGe3wlbH0U_U0eShLWZTbCyIPUFZTYBzCK_nlLZ_r0zJ0zDCz_1B61EeEijHu2fEX08YY-urw\",\"adminId\":2,\"username\":\"designer1\",\"nickname\":\"李设计师\"}}', 0, NULL, '2026-04-29 21:14:45');
INSERT INTO `sys_oper_log` VALUES (171, '后台登录', 'com.designstudio.system.controller.AuthController.login', 'POST', NULL, NULL, '/api/v1/auth/login', '0:0:0:0:0:0:0:1', '[{\"username\":\"designer2\",\"password\":\"admin123\"}]', '{\"code\":200,\"msg\":\"success\",\"data\":{\"token\":\"eyJhbGciOiJIUzUxMiJ9.eyJyb2xlcyI6WyJkZXNpZ25lciJdLCJuaWNrbmFtZSI6IueOi-iuvuiuoeW4iCIsInVzZXJUeXBlIjoiYWRtaW4iLCJ1c2VySWQiOjMsInVzZXJuYW1lIjoiZGVzaWduZXIyIiwic3ViIjoiMyIsImlhdCI6MTc3NzQ2ODQ4NCwiZXhwIjoxNzc4MDczMjg0fQ.RZOQoOT1NcoeN1pj9VUuHIy5WHt-eFP9AUF_WUI4mU3QDRdwPdBaumZbOyCNTzMFQ6x8LtcEZPCq7Et9RzLWCw\",\"adminId\":3,\"username\":\"designer2\",\"nickname\":\"王设计师\"}}', 0, NULL, '2026-04-29 21:14:45');
INSERT INTO `sys_oper_log` VALUES (172, '后台登录', 'com.designstudio.system.controller.AuthController.login', 'POST', NULL, NULL, '/api/v1/auth/login', '0:0:0:0:0:0:0:1', '[{\"username\":\"finance\",\"password\":\"admin123\"}]', NULL, 1, '用户名或密码错误', '2026-04-29 21:14:45');
INSERT INTO `sys_oper_log` VALUES (173, '后台登录', 'com.designstudio.system.controller.AuthController.login', 'POST', NULL, NULL, '/api/v1/auth/login', '0:0:0:0:0:0:0:1', '[{\"username\":\"purchaser\",\"password\":\"admin123\"}]', NULL, 1, '用户名或密码错误', '2026-04-29 21:14:45');
INSERT INTO `sys_oper_log` VALUES (174, '后台登录', 'com.designstudio.system.controller.AuthController.login', 'POST', NULL, NULL, '/api/v1/auth/login', '0:0:0:0:0:0:0:1', '[{\"username\":\"storekeeper\",\"password\":\"admin123\"}]', NULL, 1, '用户名或密码错误', '2026-04-29 21:14:45');
INSERT INTO `sys_oper_log` VALUES (175, '后台登录', 'com.designstudio.system.controller.AuthController.login', 'POST', NULL, NULL, '/api/v1/auth/login', '0:0:0:0:0:0:0:1', '[{\"username\":\"customer_service\",\"password\":\"admin123\"}]', NULL, 1, '用户名或密码错误', '2026-04-29 21:14:45');
INSERT INTO `sys_oper_log` VALUES (176, '后台登录', 'com.designstudio.system.controller.AuthController.login', 'POST', NULL, NULL, '/api/v1/auth/login', '0:0:0:0:0:0:0:1', '[{\"username\":\"admin\",\"password\":\"admin123\"}]', '{\"code\":200,\"msg\":\"success\",\"data\":{\"token\":\"eyJhbGciOiJIUzUxMiJ9.eyJyb2xlcyI6WyJhZG1pbiJdLCJuaWNrbmFtZSI6Iui2hee6p-euoeeQhuWRmCIsInVzZXJUeXBlIjoiYWRtaW4iLCJ1c2VySWQiOjEsInVzZXJuYW1lIjoiYWRtaW4iLCJzdWIiOiIxIiwiaWF0IjoxNzc3NDY4OTUzLCJleHAiOjE3NzgwNzM3NTN9.GeqUh-n7cmp9K344J5ZjqBjBTKYdeVOm92Jt59E-9ucL_qgEnY2BNsAbzqmHMTOhMU1zDCe-hc3s0bueK9YlJQ\",\"adminId\":1,\"username\":\"admin\",\"nickname\":\"超级管理员\"}}', 0, NULL, '2026-04-29 21:22:34');

-- ----------------------------
-- Table structure for sys_role
-- ----------------------------
DROP TABLE IF EXISTS `sys_role`;
CREATE TABLE `sys_role`  (
  `role_id` bigint NOT NULL AUTO_INCREMENT,
  `role_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '角色名称',
  `role_key` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '角色标识(admin/designer)',
  `role_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '角色类型: admin/designer/storekeeper/purchaser/finance/customer_service',
  `remark` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `create_by` bigint NULL DEFAULT NULL,
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `update_by` bigint NULL DEFAULT NULL,
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `del_flag` tinyint(1) NULL DEFAULT 0,
  PRIMARY KEY (`role_id`) USING BTREE,
  UNIQUE INDEX `uk_role_key`(`role_key` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '角色表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_role
-- ----------------------------
INSERT INTO `sys_role` VALUES (1, '管理员', 'admin', 'admin', 'Full backend access', NULL, '2026-03-04 15:06:58', NULL, '2026-04-14 22:09:37', 0);
INSERT INTO `sys_role` VALUES (2, '设计师', 'designer', 'designer', 'Order execution, request handling, portfolio and chat access', NULL, '2026-03-04 15:06:58', NULL, '2026-04-14 22:09:37', 0);
INSERT INTO `sys_role` VALUES (3, '库管', 'storekeeper', 'storekeeper', '负责物料管理和库存查看', NULL, '2026-04-14 22:09:37', NULL, '2026-04-14 22:09:37', 0);
INSERT INTO `sys_role` VALUES (4, '采购', 'purchaser', 'purchaser', '负责物料采购和库存管理', NULL, '2026-04-14 22:09:37', NULL, '2026-04-14 22:09:37', 0);
INSERT INTO `sys_role` VALUES (5, '财务', 'finance', 'finance', '负责订单收款和财务报表', NULL, '2026-04-14 22:09:37', NULL, '2026-04-14 22:09:37', 0);
INSERT INTO `sys_role` VALUES (6, '客服', 'customer_service', 'customer_service', '负责客户沟通和在线答疑', NULL, '2026-04-14 22:09:37', NULL, '2026-04-14 22:09:37', 0);

-- ----------------------------
-- Table structure for sys_role_menu
-- ----------------------------
DROP TABLE IF EXISTS `sys_role_menu`;
CREATE TABLE `sys_role_menu`  (
  `role_id` bigint NOT NULL COMMENT '角色ID',
  `menu_id` bigint NOT NULL COMMENT '菜单ID',
  PRIMARY KEY (`role_id`, `menu_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '角色菜单关联表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_role_menu
-- ----------------------------
INSERT INTO `sys_role_menu` VALUES (1, 1);
INSERT INTO `sys_role_menu` VALUES (1, 2);
INSERT INTO `sys_role_menu` VALUES (1, 3);
INSERT INTO `sys_role_menu` VALUES (1, 4);
INSERT INTO `sys_role_menu` VALUES (1, 5);
INSERT INTO `sys_role_menu` VALUES (1, 6);
INSERT INTO `sys_role_menu` VALUES (1, 7);
INSERT INTO `sys_role_menu` VALUES (1, 8);
INSERT INTO `sys_role_menu` VALUES (1, 9);
INSERT INTO `sys_role_menu` VALUES (1, 10);
INSERT INTO `sys_role_menu` VALUES (1, 11);
INSERT INTO `sys_role_menu` VALUES (1, 12);
INSERT INTO `sys_role_menu` VALUES (1, 13);
INSERT INTO `sys_role_menu` VALUES (1, 14);
INSERT INTO `sys_role_menu` VALUES (1, 15);
INSERT INTO `sys_role_menu` VALUES (1, 16);
INSERT INTO `sys_role_menu` VALUES (1, 17);
INSERT INTO `sys_role_menu` VALUES (1, 18);
INSERT INTO `sys_role_menu` VALUES (1, 19);
INSERT INTO `sys_role_menu` VALUES (1, 20);
INSERT INTO `sys_role_menu` VALUES (1, 21);
INSERT INTO `sys_role_menu` VALUES (1, 22);
INSERT INTO `sys_role_menu` VALUES (1, 23);
INSERT INTO `sys_role_menu` VALUES (1, 24);
INSERT INTO `sys_role_menu` VALUES (1, 25);
INSERT INTO `sys_role_menu` VALUES (1, 26);
INSERT INTO `sys_role_menu` VALUES (1, 27);
INSERT INTO `sys_role_menu` VALUES (1, 28);
INSERT INTO `sys_role_menu` VALUES (1, 29);
INSERT INTO `sys_role_menu` VALUES (1, 30);
INSERT INTO `sys_role_menu` VALUES (1, 31);
INSERT INTO `sys_role_menu` VALUES (1, 32);
INSERT INTO `sys_role_menu` VALUES (1, 33);
INSERT INTO `sys_role_menu` VALUES (2, 1);
INSERT INTO `sys_role_menu` VALUES (2, 2);
INSERT INTO `sys_role_menu` VALUES (2, 5);
INSERT INTO `sys_role_menu` VALUES (2, 6);
INSERT INTO `sys_role_menu` VALUES (2, 8);
INSERT INTO `sys_role_menu` VALUES (2, 9);
INSERT INTO `sys_role_menu` VALUES (2, 10);
INSERT INTO `sys_role_menu` VALUES (2, 16);
INSERT INTO `sys_role_menu` VALUES (2, 17);
INSERT INTO `sys_role_menu` VALUES (2, 23);
INSERT INTO `sys_role_menu` VALUES (2, 24);
INSERT INTO `sys_role_menu` VALUES (2, 25);
INSERT INTO `sys_role_menu` VALUES (2, 26);
INSERT INTO `sys_role_menu` VALUES (3, 4);
INSERT INTO `sys_role_menu` VALUES (3, 14);
INSERT INTO `sys_role_menu` VALUES (3, 27);
INSERT INTO `sys_role_menu` VALUES (3, 28);
INSERT INTO `sys_role_menu` VALUES (4, 4);
INSERT INTO `sys_role_menu` VALUES (4, 14);
INSERT INTO `sys_role_menu` VALUES (4, 27);
INSERT INTO `sys_role_menu` VALUES (4, 28);
INSERT INTO `sys_role_menu` VALUES (5, 1);
INSERT INTO `sys_role_menu` VALUES (5, 6);
INSERT INTO `sys_role_menu` VALUES (5, 9);
INSERT INTO `sys_role_menu` VALUES (5, 17);
INSERT INTO `sys_role_menu` VALUES (6, 23);
INSERT INTO `sys_role_menu` VALUES (6, 24);
INSERT INTO `sys_role_menu` VALUES (6, 29);
INSERT INTO `sys_role_menu` VALUES (6, 30);
INSERT INTO `sys_role_menu` VALUES (6, 31);

SET FOREIGN_KEY_CHECKS = 1;
