/*
 Navicat Premium Data Transfer

 Source Server         : localhost
 Source Server Type    : MySQL
 Source Server Version : 80039 (8.0.39)
 Source Host           : localhost:3306
 Source Schema         : design_studio

 Target Server Type    : MySQL
 Target Server Version : 80039 (8.0.39)
 File Encoding         : 65001

 Date: 09/04/2026 21:15:35
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
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '客户地址表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of ds_address
-- ----------------------------

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
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '对账记录表' ROW_FORMAT = Dynamic;

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
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '订单BOM清单表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of ds_bom_item
-- ----------------------------

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
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'BOM模板表' ROW_FORMAT = Dynamic;

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
) ENGINE = InnoDB AUTO_INCREMENT = 11 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'BOM模板明细表' ROW_FORMAT = Dynamic;

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
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '品类表' ROW_FORMAT = Dynamic;

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
  PRIMARY KEY (`msg_id`) USING BTREE,
  INDEX `idx_sender`(`sender_type` ASC, `sender_id` ASC) USING BTREE,
  INDEX `idx_user`(`user_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '聊天记录表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of ds_chat_message
-- ----------------------------
INSERT INTO `ds_chat_message` VALUES (1, 1, 0, 1, 0, 'hallop', 1, '2026-04-06 15:09:44', 0);
INSERT INTO `ds_chat_message` VALUES (2, 1, 1, 2, 0, 'ciallo~', 1, '2026-04-06 15:11:24', 0);
INSERT INTO `ds_chat_message` VALUES (3, 1, 0, 1, 0, '关注塔菲谢谢喵', 1, '2026-04-09 19:56:14', 0);

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
) ENGINE = InnoDB AUTO_INCREMENT = 12 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '动态字段定义表' ROW_FORMAT = Dynamic;

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
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '设计师-品类关联表' ROW_FORMAT = Dynamic;

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
) ENGINE = InnoDB AUTO_INCREMENT = 11 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '物料表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of ds_material
-- ----------------------------
INSERT INTO `ds_material` VALUES (1, '高级亚麻面料（浅米色）', 'FAB-LINEN-001', '面料', '米', 120.00, 60.00, 10.00, NULL, '优质亚麻，适合春夏服装', 1, NULL, '2026-03-17 15:11:05', 1, '2026-03-17 15:11:05', 0);
INSERT INTO `ds_material` VALUES (2, '真丝面料（香槟色）', 'FAB-SILK-001', '面料', '米', 280.00, 30.00, 5.00, NULL, '100%桑蚕丝', 0, NULL, '2026-03-17 15:11:05', NULL, '2026-03-17 15:11:05', 0);
INSERT INTO `ds_material` VALUES (3, '植鞣革（棕色）', 'FAB-LEATHER-001', '面料', '张', 350.00, 15.00, 3.00, NULL, '意大利进口植鞣革', 0, NULL, '2026-03-17 15:11:05', NULL, '2026-03-17 15:11:05', 0);
INSERT INTO `ds_material` VALUES (4, '鳄鱼皮（黑色）', 'FAB-CROC-001', '面料', '张', 1200.00, 2.00, 2.00, NULL, '稀有鳄鱼皮，需进口', 0, NULL, '2026-03-17 15:11:05', NULL, '2026-03-17 15:11:05', 0);
INSERT INTO `ds_material` VALUES (5, 'YKK拉链（20cm）', 'ACC-ZIP-001', '辅料', '条', 8.50, 200.00, 50.00, NULL, 'YKK金属拉链', 0, NULL, '2026-03-17 15:11:05', NULL, '2026-03-17 15:11:05', 0);
INSERT INTO `ds_material` VALUES (6, '纯棉衬里（白色）', 'FAB-COTTON-001', '面料', '米', 35.00, 100.00, 20.00, NULL, '纯棉里衬', 0, NULL, '2026-03-17 15:11:05', NULL, '2026-03-17 15:11:05', 0);
INSERT INTO `ds_material` VALUES (7, 'D型五金扣', 'HW-DRING-001', '五金件', '个', 5.00, 500.00, 100.00, NULL, '不锈钢D型环', 0, NULL, '2026-03-17 15:11:05', NULL, '2026-03-17 15:11:05', 0);
INSERT INTO `ds_material` VALUES (8, '手缝蜡线（棕色）', 'ACC-WAX-001', '辅料', '卷', 25.00, 80.00, 20.00, NULL, '手工皮具专用', 0, NULL, '2026-03-17 15:11:05', NULL, '2026-03-17 15:11:05', 0);
INSERT INTO `ds_material` VALUES (9, '暗扣', 'HW-SNAP-001', '五金件', '套', 3.00, 300.00, 60.00, NULL, '磁吸暗扣', 0, NULL, '2026-03-17 15:11:05', NULL, '2026-03-17 15:11:05', 0);
INSERT INTO `ds_material` VALUES (10, '包装盒（大号）', 'PKG-BOX-001', '辅料', '个', 15.00, 100.00, 20.00, NULL, '高端定制包装盒', 0, NULL, '2026-03-17 15:11:05', NULL, '2026-03-17 15:11:05', 0);

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
  `version` int NULL DEFAULT 0 COMMENT '版本号(乐观锁)',
  `create_by` bigint NULL DEFAULT NULL,
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `update_by` bigint NULL DEFAULT NULL,
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `finish_time` datetime NULL DEFAULT NULL COMMENT '完成时间',
  `del_flag` tinyint(1) NULL DEFAULT 0,
  PRIMARY KEY (`order_id`) USING BTREE,
  UNIQUE INDEX `uk_order_sn`(`order_sn` ASC) USING BTREE,
  INDEX `idx_user_status`(`user_id` ASC, `status` ASC) USING BTREE,
  INDEX `idx_designer`(`designer_id` ASC) USING BTREE,
  INDEX `idx_create_time`(`create_time` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 6 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '订单主表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of ds_order
-- ----------------------------
INSERT INTO `ds_order` VALUES (1, 'DS202603081601001', 3, 1, 2, 3, 1, '{\"chest\": \"92\", \"waist\": \"72\", \"length\": \"130\", \"shoulder\": \"40\", \"fabric_type\": \"亚麻\"}', 3500.00, 1750.00, 1750.00, '2026-04-10', NULL, '改良汉服，客户要求宽松版型', 0, NULL, 0, NULL, '2026-03-08 16:05:00', NULL, '2026-03-17 15:11:05', NULL, 0);
INSERT INTO `ds_order` VALUES (2, 'DS202603071102001', 2, 3, 3, 14, 1, '{\"usage\": \"公司品牌Logo\", \"art_style\": \"扁平化\", \"resolution\": \"3000×3000\"}', 800.00, 400.00, 400.00, '2026-03-25', NULL, 'Logo设计，需要三个备选方案', 0, NULL, 0, NULL, '2026-03-07 11:05:00', NULL, '2026-04-09 21:07:17', NULL, 0);
INSERT INTO `ds_order` VALUES (3, 'DS202603151400001', 1, 2, 2, 8, 1, '{\"color\": \"黑色\", \"size_spec\": \"长25cm×宽15cm\", \"leather_type\": \"鳄鱼皮\"}', 5800.00, 2900.00, 2900.00, '2026-04-20', NULL, '鳄鱼皮手拿包，高端定制', 1, '鳄鱼皮原料缺货，预计3天到货', 2, NULL, '2026-03-15 14:00:00', 1, '2026-04-09 21:09:47', NULL, 0);
INSERT INTO `ds_order` VALUES (4, 'DS202602201000001', 1, 3, 3, 16, 4, '{\"usage\": \"个人收藏\", \"art_style\": \"水彩风\", \"resolution\": \"1920×1080\"}', 600.00, 300.00, 600.00, '2026-03-05', NULL, '水彩风景画', 0, NULL, 0, NULL, '2026-02-20 10:00:00', NULL, '2026-04-09 21:07:17', '2026-03-03 18:00:00', 0);
INSERT INTO `ds_order` VALUES (5, 'DS202604051756345882', 1, 1, 2, NULL, 1, '{\"chest\": \"1\", \"waist\": \"2\", \"length\": \"4\", \"shoulder\": \"3\"}', 800.00, 300.00, 0.00, '2026-04-29', NULL, '', 0, NULL, 0, 1, '2026-04-05 17:56:34', 1, '2026-04-05 17:56:34', NULL, 0);

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
  `operator_id` bigint NULL DEFAULT NULL COMMENT '操作人ID',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `del_flag` tinyint(1) NULL DEFAULT 0,
  PRIMARY KEY (`progress_id`) USING BTREE,
  INDEX `idx_order`(`order_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 14 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '订单进度表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of ds_order_progress
-- ----------------------------
INSERT INTO `ds_order_progress` VALUES (1, 1, 1, '客户需求已确认，改良汉服宽松版型，亚麻面料', NULL, 2, '2026-03-08 16:10:00', 0);
INSERT INTO `ds_order_progress` VALUES (2, 1, 2, '特选高品质亚麻面料已采购到位，颜色为浅米色', NULL, 2, '2026-03-10 09:00:00', 0);
INSERT INTO `ds_order_progress` VALUES (3, 1, 3, '开始裁剪，按照客户尺寸放样', NULL, 2, '2026-03-12 14:00:00', 0);
INSERT INTO `ds_order_progress` VALUES (4, 2, 12, '需求已确认，客户要求扁平化风格Logo', NULL, 3, '2026-03-07 11:10:00', 0);
INSERT INTO `ds_order_progress` VALUES (5, 2, 13, '草稿完成，已提交3个备选方案给客户', NULL, 3, '2026-03-09 16:00:00', 0);
INSERT INTO `ds_order_progress` VALUES (6, 2, 14, '客户选择方案B，开始线稿细化', NULL, 3, '2026-03-11 10:00:00', 0);
INSERT INTO `ds_order_progress` VALUES (7, 4, 12, '需求确认完毕', NULL, 3, '2026-02-20 10:10:00', 0);
INSERT INTO `ds_order_progress` VALUES (8, 4, 13, '草稿完成', NULL, 3, '2026-02-22 15:00:00', 0);
INSERT INTO `ds_order_progress` VALUES (9, 4, 14, '线稿已定稿', NULL, 3, '2026-02-25 11:00:00', 0);
INSERT INTO `ds_order_progress` VALUES (10, 4, 15, '上色完成，最终稿已出', NULL, 3, '2026-02-28 17:00:00', 0);
INSERT INTO `ds_order_progress` VALUES (11, 4, 16, '客户验收通过，交付完成', NULL, 3, '2026-03-03 18:00:00', 0);
INSERT INTO `ds_order_progress` VALUES (12, 3, 8, '部分', NULL, 1, '2026-03-17 15:16:03', 0);
INSERT INTO `ds_order_progress` VALUES (13, 1, 3, '工作台接口联调记录', NULL, 1, '2026-04-09 21:13:19', 0);

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
) ENGINE = InnoDB AUTO_INCREMENT = 9 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '订单意向表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of ds_order_request
-- ----------------------------
INSERT INTO `ds_order_request` VALUES (1, 1, 1, '想定制一件旗袍，用于参加朋友婚礼', NULL, '{\"chest\": \"88\", \"waist\": \"68\", \"length\": \"120\", \"shoulder\": \"38\", \"fabric_type\": \"丝绸\"}', 0, NULL, NULL, NULL, '2026-03-10 10:00:00', NULL, '2026-03-17 15:11:05', 0);
INSERT INTO `ds_order_request` VALUES (2, 2, 2, '想做一个手工皮革钱包，送给男朋友做生日礼物', NULL, '{\"color\": \"深棕色\", \"size_spec\": \"长20cm×宽10cm\", \"leather_type\": \"植鞣革\"}', 0, NULL, NULL, NULL, '2026-03-11 14:30:00', NULL, '2026-03-17 15:11:05', 0);
INSERT INTO `ds_order_request` VALUES (3, 1, 3, '需要一张日系风格的头像插画', NULL, '{\"usage\": \"社交媒体头像\", \"art_style\": \"日系\", \"resolution\": \"1080×1080\"}', 0, NULL, NULL, NULL, '2026-03-12 09:15:00', NULL, '2026-03-17 15:11:05', 0);
INSERT INTO `ds_order_request` VALUES (4, 3, 1, '需要一套改良汉服', NULL, '{\"chest\": \"92\", \"waist\": \"72\", \"length\": \"130\", \"shoulder\": \"40\", \"fabric_type\": \"亚麻\"}', 1, NULL, 1, NULL, '2026-03-08 16:00:00', NULL, '2026-03-17 15:11:05', 0);
INSERT INTO `ds_order_request` VALUES (5, 2, 3, '设计公司 Logo 扁平化插画', NULL, '{\"usage\": \"公司品牌Logo\", \"art_style\": \"扁平化\", \"resolution\": \"3000×3000\"}', 1, NULL, 2, NULL, '2026-03-07 11:00:00', NULL, '2026-03-17 15:11:05', 0);
INSERT INTO `ds_order_request` VALUES (6, 3, 2, '复古风格手提包', NULL, '{\"color\": \"酒红色\", \"size_spec\": \"长30cm×宽20cm×高15cm\", \"leather_type\": \"牛皮\"}', 2, '客户取消，预算不足', NULL, NULL, '2026-03-05 08:45:00', NULL, '2026-03-17 15:11:05', 0);
INSERT INTO `ds_order_request` VALUES (7, 1, 1, '', '[]', '{\"chest\": \"123\", \"waist\": \"32\", \"length\": \"123\", \"shoulder\": \"45\"}', 0, NULL, NULL, 1, '2026-04-05 17:45:08', 1, '2026-04-05 17:45:08', 0);
INSERT INTO `ds_order_request` VALUES (8, 1, 1, '', '[]', '{\"chest\": \"1\", \"waist\": \"2\", \"length\": \"4\", \"shoulder\": \"3\"}', 1, NULL, 5, 1, '2026-04-05 17:46:11', 1, '2026-04-05 17:46:11', 0);

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
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '支付流水表' ROW_FORMAT = Dynamic;

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
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '作品集表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of ds_portfolio
-- ----------------------------

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
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '退款记录表' ROW_FORMAT = Dynamic;

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
) ENGINE = InnoDB AUTO_INCREMENT = 6 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '小程序用户表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of ds_user
-- ----------------------------
INSERT INTO `ds_user` VALUES (1, 'wx_test_openid_001', NULL, '张小姐', NULL, '13900001001', 1, NULL, NULL, '2026-03-17 15:11:05', '2026-04-09 21:13:51', 0, NULL, 5, '2026-03-24 16:43:20');
INSERT INTO `ds_user` VALUES (2, 'wx_test_openid_002', NULL, '刘先生', NULL, '13900001002', 1, NULL, NULL, '2026-03-17 15:11:05', NULL, 0, NULL, NULL, '2026-03-24 16:43:20');
INSERT INTO `ds_user` VALUES (3, 'wx_test_openid_003', NULL, '陈女士', NULL, '13900001003', 1, NULL, NULL, '2026-03-17 15:11:05', NULL, 0, NULL, NULL, '2026-03-24 16:43:20');
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
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '工作流模板表' ROW_FORMAT = Dynamic;

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
  `create_by` bigint NULL DEFAULT NULL,
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `update_by` bigint NULL DEFAULT NULL,
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `del_flag` tinyint(1) NULL DEFAULT 0,
  PRIMARY KEY (`step_id`) USING BTREE,
  INDEX `idx_workflow`(`workflow_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 17 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '工作流节点表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of ds_workflow_step
-- ----------------------------
INSERT INTO `ds_workflow_step` VALUES (1, 1, '需求确认', 1, 1, 0, '处理节点：需求确认', '[\"save\", \"advance\", \"block\", \"unblock\"]', 0, 1, 1, NULL, '2026-03-04 15:06:58', NULL, '2026-04-09 21:07:17', 0);
INSERT INTO `ds_workflow_step` VALUES (2, 1, '面料采购', 2, 0, 0, '处理节点：面料采购', '[\"save\", \"advance\", \"block\", \"unblock\"]', 0, 1, 2, NULL, '2026-03-04 15:06:58', NULL, '2026-04-09 21:07:17', 0);
INSERT INTO `ds_workflow_step` VALUES (3, 1, '裁剪', 3, 0, 0, '处理节点：裁剪', '[\"save\", \"advance\", \"block\", \"unblock\"]', 1, 1, 3, NULL, '2026-03-04 15:06:58', NULL, '2026-04-09 21:07:17', 0);
INSERT INTO `ds_workflow_step` VALUES (4, 1, '缝制', 4, 0, 0, '处理节点：缝制', '[\"save\", \"advance\", \"block\", \"unblock\"]', 1, 1, 3, NULL, '2026-03-04 15:06:58', NULL, '2026-04-09 21:07:17', 0);
INSERT INTO `ds_workflow_step` VALUES (5, 1, '质检', 5, 0, 0, '处理节点：质检', '[\"save\", \"advance\", \"block\", \"unblock\"]', 1, 1, 1, NULL, '2026-03-04 15:06:58', NULL, '2026-04-09 21:07:17', 0);
INSERT INTO `ds_workflow_step` VALUES (6, 1, '包装发货', 6, 0, 1, '处理节点：包装发货', '[\"save\", \"advance\", \"block\", \"unblock\"]', 0, 1, 1, NULL, '2026-03-04 15:06:58', NULL, '2026-04-09 21:07:17', 0);
INSERT INTO `ds_workflow_step` VALUES (7, 2, '需求确认', 1, 1, 0, '处理节点：需求确认', '[\"save\", \"advance\", \"block\", \"unblock\"]', 0, 1, 1, NULL, '2026-03-04 15:06:58', NULL, '2026-04-09 21:07:17', 0);
INSERT INTO `ds_workflow_step` VALUES (8, 2, '皮料裁切', 2, 0, 0, '处理节点：皮料裁切', '[\"save\", \"advance\", \"block\", \"unblock\"]', 0, 1, 2, NULL, '2026-03-04 15:06:58', NULL, '2026-04-09 21:07:17', 0);
INSERT INTO `ds_workflow_step` VALUES (9, 2, '缝线打磨', 3, 0, 0, '处理节点：缝线打磨', '[\"save\", \"advance\", \"block\", \"unblock\"]', 1, 1, 3, NULL, '2026-03-04 15:06:58', NULL, '2026-04-09 21:07:17', 0);
INSERT INTO `ds_workflow_step` VALUES (10, 2, '上色封边', 4, 0, 0, '处理节点：上色封边', '[\"save\", \"advance\", \"block\", \"unblock\"]', 1, 1, 3, NULL, '2026-03-04 15:06:58', NULL, '2026-04-09 21:07:17', 0);
INSERT INTO `ds_workflow_step` VALUES (11, 2, '质检出货', 5, 0, 1, '处理节点：质检出货', '[\"save\", \"advance\", \"block\", \"unblock\"]', 1, 1, 1, NULL, '2026-03-04 15:06:58', NULL, '2026-04-09 21:07:17', 0);
INSERT INTO `ds_workflow_step` VALUES (12, 3, '需求确认', 1, 1, 0, '处理节点：需求确认', '[\"save\", \"advance\", \"block\", \"unblock\"]', 0, 1, 1, NULL, '2026-03-04 15:06:58', NULL, '2026-04-09 21:07:17', 0);
INSERT INTO `ds_workflow_step` VALUES (13, 3, '草稿构图', 2, 0, 0, '处理节点：草稿构图', '[\"save\", \"advance\", \"block\", \"unblock\"]', 1, 1, 2, NULL, '2026-03-04 15:06:58', NULL, '2026-04-09 21:07:17', 0);
INSERT INTO `ds_workflow_step` VALUES (14, 3, '线稿细化', 3, 0, 0, '处理节点：线稿细化', '[\"save\", \"advance\", \"block\", \"unblock\"]', 1, 1, 3, NULL, '2026-03-04 15:06:58', NULL, '2026-04-09 21:07:17', 0);
INSERT INTO `ds_workflow_step` VALUES (15, 3, '上色完稿', 4, 0, 0, '处理节点：上色完稿', '[\"save\", \"advance\", \"block\", \"unblock\"]', 1, 1, 3, NULL, '2026-03-04 15:06:58', NULL, '2026-04-09 21:07:17', 0);
INSERT INTO `ds_workflow_step` VALUES (16, 3, '客户验收', 5, 0, 1, '处理节点：客户验收', '[\"save\", \"advance\", \"block\", \"unblock\"]', 1, 1, 1, NULL, '2026-03-04 15:06:58', NULL, '2026-04-09 21:07:17', 0);

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
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '后台用户表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_admin
-- ----------------------------
INSERT INTO `sys_admin` VALUES (1, 'admin', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '超级管理员', NULL, NULL, NULL, 1, NULL, '2026-03-04 15:06:58', NULL, '2026-03-04 15:06:58', NULL, 0);
INSERT INTO `sys_admin` VALUES (2, 'designer1', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '李设计师', NULL, '13800001001', NULL, 1, NULL, '2026-03-17 15:11:05', NULL, '2026-03-17 15:11:05', NULL, 0);
INSERT INTO `sys_admin` VALUES (3, 'designer2', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '王设计师', NULL, '13800001002', NULL, 1, NULL, '2026-03-17 15:11:05', 1, '2026-03-17 15:11:05', NULL, 0);

-- ----------------------------
-- Table structure for sys_admin_role
-- ----------------------------
DROP TABLE IF EXISTS `sys_admin_role`;
CREATE TABLE `sys_admin_role`  (
  `admin_id` bigint NOT NULL COMMENT '用户ID',
  `role_id` bigint NOT NULL COMMENT '角色ID',
  PRIMARY KEY (`admin_id`, `role_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户角色关联表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_admin_role
-- ----------------------------
INSERT INTO `sys_admin_role` VALUES (1, 1);
INSERT INTO `sys_admin_role` VALUES (2, 2);
INSERT INTO `sys_admin_role` VALUES (3, 2);

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
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '接口监控指标表' ROW_FORMAT = Dynamic;

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
) ENGINE = InnoDB AUTO_INCREMENT = 15 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '字典数据表' ROW_FORMAT = Dynamic;

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
) ENGINE = InnoDB AUTO_INCREMENT = 8 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '字典类型表' ROW_FORMAT = Dynamic;

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
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '异常日志表' ROW_FORMAT = Dynamic;

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
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '登录日志表' ROW_FORMAT = Dynamic;

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
) ENGINE = InnoDB AUTO_INCREMENT = 27 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '菜单权限表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_menu
-- ----------------------------
INSERT INTO `sys_menu` VALUES (1, 0, '订单管理', 'M', '/order', NULL, NULL, 'ShoppingCart', 1, 1, NULL, '2026-03-04 15:06:58', NULL, '2026-03-04 15:06:58', 0);
INSERT INTO `sys_menu` VALUES (2, 0, '意向管理', 'M', '/request', NULL, NULL, 'Mail', 2, 1, NULL, '2026-03-04 15:06:58', NULL, '2026-03-04 15:06:58', 0);
INSERT INTO `sys_menu` VALUES (3, 0, '配置中心', 'M', '/config', NULL, NULL, 'Settings', 3, 1, NULL, '2026-03-04 15:06:58', NULL, '2026-03-04 15:06:58', 0);
INSERT INTO `sys_menu` VALUES (4, 0, '供应链', 'M', '/supply', NULL, NULL, 'Package', 4, 1, NULL, '2026-03-04 15:06:58', NULL, '2026-03-04 15:06:58', 0);
INSERT INTO `sys_menu` VALUES (5, 0, '作品集', 'M', '/portfolio', NULL, NULL, 'Image', 5, 1, NULL, '2026-03-04 15:06:58', NULL, '2026-03-04 15:06:58', 0);
INSERT INTO `sys_menu` VALUES (6, 0, '数据分析', 'M', '/statistics', NULL, NULL, 'TrendingUp', 6, 1, NULL, '2026-03-04 15:06:58', NULL, '2026-03-04 15:06:58', 0);
INSERT INTO `sys_menu` VALUES (7, 0, '系统管理', 'M', '/system', NULL, NULL, 'Tool', 7, 1, NULL, '2026-03-04 15:06:58', NULL, '2026-03-04 15:06:58', 0);
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
INSERT INTO `sys_menu` VALUES (23, 0, '消息中心', 'M', '/chat', NULL, NULL, 'ChatboxEllipsesOutline', 5, 1, NULL, '2026-03-25 19:24:46', NULL, '2026-03-25 19:24:46', 0);
INSERT INTO `sys_menu` VALUES (24, 23, '在线沟通', 'C', '/chat/index', NULL, 'chat:list', NULL, 1, 1, NULL, '2026-03-25 19:24:46', NULL, '2026-03-25 19:24:46', 0);
INSERT INTO `sys_menu` VALUES (25, 0, '节点工作台', 'M', '/workbench', 'LAYOUT', NULL, 'AppstoreOutlined', 8, 1, NULL, '2026-04-09 20:59:05', NULL, '2026-04-09 21:04:12', 0);
INSERT INTO `sys_menu` VALUES (26, 25, '节点工作台', 'C', 'nodes', '/order/workbench', 'workbench:list', NULL, 1, 1, NULL, '2026-04-09 20:59:05', NULL, '2026-04-09 21:04:12', 0);

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
) ENGINE = InnoDB AUTO_INCREMENT = 26 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '操作日志表' ROW_FORMAT = Dynamic;

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

-- ----------------------------
-- Table structure for sys_role
-- ----------------------------
DROP TABLE IF EXISTS `sys_role`;
CREATE TABLE `sys_role`  (
  `role_id` bigint NOT NULL AUTO_INCREMENT,
  `role_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '角色名称',
  `role_key` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '角色标识(admin/designer)',
  `remark` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `create_by` bigint NULL DEFAULT NULL,
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `update_by` bigint NULL DEFAULT NULL,
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `del_flag` tinyint(1) NULL DEFAULT 0,
  PRIMARY KEY (`role_id`) USING BTREE,
  UNIQUE INDEX `uk_role_key`(`role_key` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '角色表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_role
-- ----------------------------
INSERT INTO `sys_role` VALUES (1, '管理员', 'admin', '拥有全部权限', NULL, '2026-03-04 15:06:58', NULL, '2026-03-04 15:06:58', 0);
INSERT INTO `sys_role` VALUES (2, '设计师', 'designer', '查看和操作被指派的订单', NULL, '2026-03-04 15:06:58', NULL, '2026-03-04 15:06:58', 0);

-- ----------------------------
-- Table structure for sys_role_menu
-- ----------------------------
DROP TABLE IF EXISTS `sys_role_menu`;
CREATE TABLE `sys_role_menu`  (
  `role_id` bigint NOT NULL COMMENT '角色ID',
  `menu_id` bigint NOT NULL COMMENT '菜单ID',
  PRIMARY KEY (`role_id`, `menu_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '角色菜单关联表' ROW_FORMAT = Dynamic;

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
INSERT INTO `sys_role_menu` VALUES (2, 1);
INSERT INTO `sys_role_menu` VALUES (2, 2);
INSERT INTO `sys_role_menu` VALUES (2, 5);
INSERT INTO `sys_role_menu` VALUES (2, 8);
INSERT INTO `sys_role_menu` VALUES (2, 9);
INSERT INTO `sys_role_menu` VALUES (2, 10);
INSERT INTO `sys_role_menu` VALUES (2, 16);
INSERT INTO `sys_role_menu` VALUES (2, 23);
INSERT INTO `sys_role_menu` VALUES (2, 24);
INSERT INTO `sys_role_menu` VALUES (2, 25);
INSERT INTO `sys_role_menu` VALUES (2, 26);

SET FOREIGN_KEY_CHECKS = 1;
