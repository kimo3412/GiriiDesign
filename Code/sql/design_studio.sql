-- MySQL dump 10.13  Distrib 8.4.8, for Win64 (x86_64)
--
-- Host: localhost    Database: design_studio
-- ------------------------------------------------------
-- Server version	8.4.8

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `ds_address`
--

DROP TABLE IF EXISTS `ds_address`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ds_address` (
  `address_id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL COMMENT '所属用户',
  `receiver_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '收货人',
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '联系电话',
  `province` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '省',
  `city` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '市',
  `district` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '区',
  `detail_address` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '详细地址',
  `is_default` tinyint(1) DEFAULT '0' COMMENT '是否默认',
  `create_by` bigint DEFAULT NULL,
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_by` bigint DEFAULT NULL,
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `del_flag` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`address_id`) USING BTREE,
  KEY `idx_user` (`user_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='客户地址表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ds_address`
--

LOCK TABLES `ds_address` WRITE;
/*!40000 ALTER TABLE `ds_address` DISABLE KEYS */;
/*!40000 ALTER TABLE `ds_address` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ds_banner`
--

DROP TABLE IF EXISTS `ds_banner`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ds_banner` (
  `banner_id` bigint NOT NULL AUTO_INCREMENT COMMENT '轮播图ID',
  `title` varchar(100) NOT NULL COMMENT '轮播图标题',
  `image_url` varchar(500) NOT NULL COMMENT '图片地址',
  `link_url` varchar(500) DEFAULT NULL COMMENT '跳转链接（可选）',
  `link_type` varchar(20) DEFAULT NULL COMMENT '跳转类型：portfolio/order/custom/null',
  `sort_order` int DEFAULT '0' COMMENT '排序（越大越靠前）',
  `status` tinyint(1) DEFAULT '1' COMMENT '状态：0禁用 1启用',
  `create_by` bigint DEFAULT NULL,
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_by` bigint DEFAULT NULL,
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `del_flag` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`banner_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='小程序首页轮播图';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ds_banner`
--

LOCK TABLES `ds_banner` WRITE;
/*!40000 ALTER TABLE `ds_banner` DISABLE KEYS */;
INSERT INTO `ds_banner` VALUES (1,'示例轮播图1','/uploads/banners/banner1.jpg',NULL,NULL,1,1,NULL,'2026-04-14 22:09:31',NULL,'2026-04-14 22:09:31',0),(2,'示例轮播图2','/uploads/banners/banner2.jpg',NULL,NULL,2,1,NULL,'2026-04-14 22:09:31',NULL,'2026-04-14 22:09:31',0);
/*!40000 ALTER TABLE `ds_banner` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ds_bill_record`
--

DROP TABLE IF EXISTS `ds_bill_record`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ds_bill_record` (
  `bill_id` bigint NOT NULL AUTO_INCREMENT,
  `bill_date` date NOT NULL COMMENT '账单日期',
  `wx_transaction_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '微信交易号',
  `local_payment_no` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '本地流水号',
  `wx_amount` decimal(10,2) DEFAULT NULL COMMENT '微信账单金额',
  `local_amount` decimal(10,2) DEFAULT NULL COMMENT '本地记录金额',
  `match_status` tinyint(1) DEFAULT NULL COMMENT '0=匹配,1=金额不符,2=本地缺失,3=微信缺失',
  `handle_status` tinyint(1) DEFAULT '0' COMMENT '0=待处理,1=已处理',
  `handle_remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '处理备注',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`bill_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='对账记录表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ds_bill_record`
--

LOCK TABLES `ds_bill_record` WRITE;
/*!40000 ALTER TABLE `ds_bill_record` DISABLE KEYS */;
/*!40000 ALTER TABLE `ds_bill_record` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ds_bom_item`
--

DROP TABLE IF EXISTS `ds_bom_item`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ds_bom_item` (
  `bom_item_id` bigint NOT NULL AUTO_INCREMENT,
  `order_id` bigint NOT NULL COMMENT '所属订单',
  `material_id` bigint NOT NULL COMMENT '物料ID',
  `quantity` decimal(10,2) NOT NULL COMMENT '实际用量',
  `material_snapshot` json DEFAULT NULL COMMENT '物料快照(名称、单价)',
  `is_allocated` tinyint(1) DEFAULT '0' COMMENT '是否已出库',
  `del_flag` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`bom_item_id`) USING BTREE,
  KEY `idx_order` (`order_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='订单BOM清单表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ds_bom_item`
--

LOCK TABLES `ds_bom_item` WRITE;
/*!40000 ALTER TABLE `ds_bom_item` DISABLE KEYS */;
INSERT INTO `ds_bom_item` VALUES (1,7,1,3.50,'{\"sku\": \"FAB-LINEN-001\", \"name\": \"高级亚麻面料（浅米色）\", \"unit\": \"米\", \"unitPrice\": 120.0}',0,0),(2,7,6,2.00,'{\"sku\": \"FAB-COTTON-001\", \"name\": \"纯棉衬里（白色）\", \"unit\": \"米\", \"unitPrice\": 35.0}',0,0),(3,7,5,1.00,'{\"sku\": \"ACC-ZIP-001\", \"name\": \"YKK拉链（20cm）\", \"unit\": \"条\", \"unitPrice\": 8.5}',0,0),(4,7,9,2.00,'{\"sku\": \"HW-SNAP-001\", \"name\": \"暗扣\", \"unit\": \"套\", \"unitPrice\": 3.0}',0,0),(5,7,10,1.00,'{\"sku\": \"PKG-BOX-001\", \"name\": \"包装盒（大号）\", \"unit\": \"个\", \"unitPrice\": 15.0}',0,0),(6,8,1,3.50,'{\"sku\": \"FAB-LINEN-001\", \"name\": \"高级亚麻面料（浅米色）\", \"unit\": \"米\", \"unitPrice\": 120.0}',1,0),(7,8,6,2.00,'{\"sku\": \"FAB-COTTON-001\", \"name\": \"纯棉衬里（白色）\", \"unit\": \"米\", \"unitPrice\": 35.0}',1,0),(8,8,5,1.00,'{\"sku\": \"ACC-ZIP-001\", \"name\": \"YKK拉链（20cm）\", \"unit\": \"条\", \"unitPrice\": 8.5}',1,0),(9,8,9,2.00,'{\"sku\": \"HW-SNAP-001\", \"name\": \"暗扣\", \"unit\": \"套\", \"unitPrice\": 3.0}',1,0),(10,8,10,1.00,'{\"sku\": \"PKG-BOX-001\", \"name\": \"包装盒（大号）\", \"unit\": \"个\", \"unitPrice\": 15.0}',1,0);
/*!40000 ALTER TABLE `ds_bom_item` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ds_bom_template`
--

DROP TABLE IF EXISTS `ds_bom_template`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ds_bom_template` (
  `template_id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '模板名称',
  `category_id` bigint DEFAULT NULL COMMENT '关联品类',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '备注',
  `create_by` bigint DEFAULT NULL,
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_by` bigint DEFAULT NULL,
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `del_flag` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`template_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='BOM模板表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ds_bom_template`
--

LOCK TABLES `ds_bom_template` WRITE;
/*!40000 ALTER TABLE `ds_bom_template` DISABLE KEYS */;
INSERT INTO `ds_bom_template` VALUES (1,'旗袍标准BOM',1,'旗袍类服装的标准物料清单',NULL,'2026-03-17 15:11:05',NULL,'2026-03-17 15:11:05',0),(2,'手工钱包BOM',2,'小型皮具钱包的标准物料清单',NULL,'2026-03-17 15:11:05',NULL,'2026-03-17 15:11:05',0);
/*!40000 ALTER TABLE `ds_bom_template` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ds_bom_template_item`
--

DROP TABLE IF EXISTS `ds_bom_template_item`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ds_bom_template_item` (
  `item_id` bigint NOT NULL AUTO_INCREMENT,
  `template_id` bigint NOT NULL COMMENT '所属模板',
  `material_id` bigint NOT NULL COMMENT '物料ID',
  `quantity` decimal(10,2) NOT NULL COMMENT '所需数量',
  `del_flag` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`item_id`) USING BTREE,
  KEY `idx_template` (`template_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='BOM模板明细表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ds_bom_template_item`
--

LOCK TABLES `ds_bom_template_item` WRITE;
/*!40000 ALTER TABLE `ds_bom_template_item` DISABLE KEYS */;
INSERT INTO `ds_bom_template_item` VALUES (1,1,1,3.50,0),(2,1,6,2.00,0),(3,1,5,1.00,0),(4,1,9,2.00,0),(5,1,10,1.00,0),(6,2,3,0.50,0),(7,2,8,1.00,0),(8,2,7,4.00,0),(9,2,9,1.00,0),(10,2,10,1.00,0);
/*!40000 ALTER TABLE `ds_bom_template_item` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ds_category`
--

DROP TABLE IF EXISTS `ds_category`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ds_category` (
  `category_id` bigint NOT NULL AUTO_INCREMENT COMMENT '品类ID',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '品类名称',
  `icon_url` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '图标URL',
  `is_active` tinyint(1) DEFAULT '1' COMMENT '是否启用',
  `has_bom` tinyint(1) DEFAULT '0' COMMENT '是否需要BOM',
  `is_physical` tinyint(1) DEFAULT '1' COMMENT '是否实体产品',
  `sort_order` int DEFAULT '0' COMMENT '排序',
  `create_by` bigint DEFAULT NULL COMMENT '创建人',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_by` bigint DEFAULT NULL COMMENT '更新人',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `del_flag` tinyint(1) DEFAULT '0' COMMENT '逻辑删除',
  PRIMARY KEY (`category_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='品类表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ds_category`
--

LOCK TABLES `ds_category` WRITE;
/*!40000 ALTER TABLE `ds_category` DISABLE KEYS */;
INSERT INTO `ds_category` VALUES (1,'服装定制',NULL,1,1,1,1,NULL,'2026-03-04 15:06:58',NULL,'2026-03-04 15:06:58',0),(2,'手工皮具',NULL,1,1,1,2,NULL,'2026-03-04 15:06:58',NULL,'2026-03-04 15:06:58',0),(3,'数字插画',NULL,1,0,0,3,NULL,'2026-03-04 15:06:58',NULL,'2026-03-04 15:06:58',0);
/*!40000 ALTER TABLE `ds_category` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ds_chat_message`
--

DROP TABLE IF EXISTS `ds_chat_message`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ds_chat_message` (
  `msg_id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL COMMENT '所属客户',
  `sender_type` tinyint(1) NOT NULL COMMENT '0=客户,1=设计师',
  `sender_id` bigint NOT NULL COMMENT '发送方ID',
  `content_type` tinyint(1) DEFAULT '0' COMMENT '0=文本,1=图片',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '消息内容',
  `is_read` tinyint(1) DEFAULT '0' COMMENT '是否已读',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `del_flag` tinyint(1) DEFAULT '0',
  `order_id` bigint DEFAULT NULL COMMENT '关联订单ID',
  PRIMARY KEY (`msg_id`) USING BTREE,
  KEY `idx_sender` (`sender_type`,`sender_id`) USING BTREE,
  KEY `idx_user` (`user_id`) USING BTREE,
  KEY `idx_order` (`order_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='聊天记录表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ds_chat_message`
--

LOCK TABLES `ds_chat_message` WRITE;
/*!40000 ALTER TABLE `ds_chat_message` DISABLE KEYS */;
INSERT INTO `ds_chat_message` VALUES (1,1,0,1,0,'hallop',1,'2026-04-06 15:09:44',0,NULL),(2,1,1,2,0,'1',1,'2026-04-06 15:11:24',0,NULL),(3,1,0,1,0,'关注',1,'2026-04-09 19:56:14',0,NULL),(4,1,0,1,0,'你好',1,'2026-04-09 21:36:36',0,NULL),(5,1,1,1,0,'好',1,'2026-04-09 21:36:43',0,NULL),(6,1,0,1,0,'订单6的咨询消息',1,'2026-04-10 23:52:00',0,6),(7,1,1,2,0,'好的，我来处理订单6',0,'2026-04-10 23:52:00',0,6),(8,1,0,1,0,'订单7有问题想问',1,'2026-04-10 23:52:00',0,7),(9,1,1,1,0,'订单6的最新进展如何？',0,'2026-04-10 23:57:14',0,6),(10,1,0,1,0,'123',1,'2026-04-11 18:00:41',0,NULL);
/*!40000 ALTER TABLE `ds_chat_message` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ds_custom_field`
--

DROP TABLE IF EXISTS `ds_custom_field`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ds_custom_field` (
  `field_id` bigint NOT NULL AUTO_INCREMENT,
  `category_id` bigint NOT NULL COMMENT '所属品类',
  `label` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '字段显示名',
  `field_key` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '字段键名',
  `field_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '控件类型: text/number/select/date/image',
  `unit` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '单位',
  `options` json DEFAULT NULL COMMENT '选项列表(select用)',
  `placeholder` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '输入提示',
  `is_required` tinyint(1) DEFAULT '0' COMMENT '是否必填',
  `sort_order` int DEFAULT '0' COMMENT '排序',
  `create_by` bigint DEFAULT NULL,
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_by` bigint DEFAULT NULL,
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `del_flag` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`field_id`) USING BTREE,
  KEY `idx_category` (`category_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='动态字段定义表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ds_custom_field`
--

LOCK TABLES `ds_custom_field` WRITE;
/*!40000 ALTER TABLE `ds_custom_field` DISABLE KEYS */;
INSERT INTO `ds_custom_field` VALUES (1,1,'胸围','chest','number','cm',NULL,'请输入胸围尺寸',1,1,NULL,'2026-03-04 15:06:58',NULL,'2026-03-04 15:06:58',0),(2,1,'腰围','waist','number','cm',NULL,'请输入腰围尺寸',1,2,NULL,'2026-03-04 15:06:58',NULL,'2026-03-04 15:06:58',0),(3,1,'肩宽','shoulder','number','cm',NULL,'请输入肩宽尺寸',1,3,NULL,'2026-03-04 15:06:58',NULL,'2026-03-04 15:06:58',0),(4,1,'衣长','length','number','cm',NULL,'请输入衣长',0,4,NULL,'2026-03-04 15:06:58',NULL,'2026-03-04 15:06:58',0),(5,1,'面料偏好','fabric_type','select',NULL,'[\"纯棉\", \"亚麻\", \"丝绸\", \"羊毛\", \"混纺\"]','请选择面料',0,5,NULL,'2026-03-04 15:06:58',NULL,'2026-03-04 15:06:58',0),(6,2,'皮革类型','leather_type','select',NULL,'[\"牛皮\", \"羊皮\", \"鳄鱼皮\", \"植鞣革\"]','请选择皮革',1,1,NULL,'2026-03-04 15:06:58',NULL,'2026-03-04 15:06:58',0),(7,2,'颜色','color','text',NULL,NULL,'期望的颜色',1,2,NULL,'2026-03-04 15:06:58',NULL,'2026-03-04 15:06:58',0),(8,2,'尺寸规格','size_spec','text',NULL,NULL,'如：长20cm×宽15cm',0,3,NULL,'2026-03-04 15:06:58',NULL,'2026-03-04 15:06:58',0),(9,3,'画风','art_style','select',NULL,'[\"日系\", \"欧美\", \"水彩风\", \"扁平化\", \"写实\"]','请选择画风',1,1,NULL,'2026-03-04 15:06:58',NULL,'2026-03-04 15:06:58',0),(10,3,'分辨率','resolution','select',NULL,'[\"1080×1080\", \"1920×1080\", \"3000×3000\", \"自定义\"]','请选择分辨率',0,2,NULL,'2026-03-04 15:06:58',NULL,'2026-03-04 15:06:58',0),(11,3,'用途','usage','text',NULL,NULL,'如：头像、海报、插图等',0,3,NULL,'2026-03-04 15:06:58',NULL,'2026-03-04 15:06:58',0);
/*!40000 ALTER TABLE `ds_custom_field` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ds_designer_category`
--

DROP TABLE IF EXISTS `ds_designer_category`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ds_designer_category` (
  `admin_id` bigint NOT NULL COMMENT '设计师ID',
  `category_id` bigint NOT NULL COMMENT '品类ID',
  PRIMARY KEY (`admin_id`,`category_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='设计师-品类关联表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ds_designer_category`
--

LOCK TABLES `ds_designer_category` WRITE;
/*!40000 ALTER TABLE `ds_designer_category` DISABLE KEYS */;
INSERT INTO `ds_designer_category` VALUES (2,1),(2,2),(3,2),(3,3);
/*!40000 ALTER TABLE `ds_designer_category` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ds_material`
--

DROP TABLE IF EXISTS `ds_material`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ds_material` (
  `material_id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '物料名称',
  `sku` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '物料编码',
  `category` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '物料分类(面料/辅料/五金)',
  `unit` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '单位(米/个/kg)',
  `unit_price` decimal(10,2) DEFAULT NULL COMMENT '单价',
  `stock` decimal(10,2) DEFAULT '0.00' COMMENT '当前库存',
  `warning_stock` decimal(10,2) DEFAULT NULL COMMENT '预警阈值',
  `image_url` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '物料图片',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '备注',
  `version` int DEFAULT '0' COMMENT '版本号(乐观锁)',
  `create_by` bigint DEFAULT NULL,
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_by` bigint DEFAULT NULL,
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `del_flag` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`material_id`) USING BTREE,
  UNIQUE KEY `uk_sku` (`sku`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='物料表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ds_material`
--

LOCK TABLES `ds_material` WRITE;
/*!40000 ALTER TABLE `ds_material` DISABLE KEYS */;
INSERT INTO `ds_material` VALUES (1,'高级亚麻面料（浅米色）','FAB-LINEN-001','面料','米',120.00,56.50,10.00,NULL,'优质亚麻，适合春夏服装',4,NULL,'2026-03-17 15:11:05',1,'2026-03-17 15:11:05',0),(2,'真丝面料（香槟色）','FAB-SILK-001','面料','米',280.00,30.00,5.00,NULL,'100%桑蚕丝',0,NULL,'2026-03-17 15:11:05',NULL,'2026-03-17 15:11:05',0),(3,'植鞣革（棕色）','FAB-LEATHER-001','面料','张',350.00,15.00,3.00,NULL,'意大利进口植鞣革',0,NULL,'2026-03-17 15:11:05',NULL,'2026-03-17 15:11:05',0),(4,'鳄鱼皮（黑色）','FAB-CROC-001','面料','张',1200.00,2.00,2.00,NULL,'稀有鳄鱼皮，需进口',0,NULL,'2026-03-17 15:11:05',NULL,'2026-03-17 15:11:05',0),(5,'YKK拉链（20cm）','ACC-ZIP-001','辅料','条',8.50,199.00,50.00,NULL,'YKK金属拉链',3,NULL,'2026-03-17 15:11:05',1,'2026-03-17 15:11:05',0),(6,'纯棉衬里（白色）','FAB-COTTON-001','面料','米',35.00,98.00,20.00,NULL,'纯棉里衬',3,NULL,'2026-03-17 15:11:05',1,'2026-03-17 15:11:05',0),(7,'D型五金扣','HW-DRING-001','五金件','个',5.00,500.00,100.00,NULL,'不锈钢D型环',0,NULL,'2026-03-17 15:11:05',NULL,'2026-03-17 15:11:05',0),(8,'手缝蜡线（棕色）','ACC-WAX-001','辅料','卷',25.00,80.00,20.00,NULL,'手工皮具专用',0,NULL,'2026-03-17 15:11:05',NULL,'2026-03-17 15:11:05',0),(9,'暗扣','HW-SNAP-001','五金件','套',3.00,298.00,60.00,NULL,'磁吸暗扣',3,NULL,'2026-03-17 15:11:05',1,'2026-03-17 15:11:05',0),(10,'包装盒（大号）','PKG-BOX-001','辅料','个',15.00,99.00,20.00,NULL,'高端定制包装盒',3,NULL,'2026-03-17 15:11:05',1,'2026-03-17 15:11:05',0);
/*!40000 ALTER TABLE `ds_material` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ds_notification`
--

DROP TABLE IF EXISTS `ds_notification`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ds_notification` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `user_id` bigint NOT NULL COMMENT '接收用户ID',
  `title` varchar(100) NOT NULL COMMENT '通知标题',
  `content` text COMMENT '通知内容',
  `type` varchar(30) DEFAULT NULL COMMENT '通知类型: order_status/payment/workbench/system',
  `related_id` bigint DEFAULT NULL COMMENT '关联ID，如订单ID',
  `related_type` varchar(30) DEFAULT NULL COMMENT '关联类型: order/request',
  `is_read` tinyint(1) DEFAULT '0' COMMENT '是否已读 (0=未读, 1=已读)',
  `create_by` bigint DEFAULT NULL COMMENT '创建人ID',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_by` bigint DEFAULT NULL COMMENT '更新人ID',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `del_flag` tinyint(1) DEFAULT '0' COMMENT '逻辑删除标记',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_notification_user_id` (`user_id`) USING BTREE,
  KEY `idx_notification_user_read` (`user_id`,`is_read`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='站内通知表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ds_notification`
--

LOCK TABLES `ds_notification` WRITE;
/*!40000 ALTER TABLE `ds_notification` DISABLE KEYS */;
INSERT INTO `ds_notification` VALUES (1,1,'定金支付成功','您已成功支付定金 ¥10.00，订单正式进入生产','payment',8,'order',0,1,'2026-04-30 13:15:06',1,'2026-04-30 13:15:06',0),(2,1,'订单进度更新','您的订单已推进至新节点：面料采购','workbench',9,'order',0,1,'2026-05-01 14:33:15',1,'2026-05-01 14:33:15',0);
/*!40000 ALTER TABLE `ds_notification` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ds_order`
--

DROP TABLE IF EXISTS `ds_order`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ds_order` (
  `order_id` bigint NOT NULL AUTO_INCREMENT,
  `order_sn` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '订单编号',
  `user_id` bigint NOT NULL COMMENT '客户ID',
  `category_id` bigint NOT NULL COMMENT '品类ID',
  `designer_id` bigint DEFAULT NULL COMMENT '指派的设计师ID',
  `current_step_id` bigint DEFAULT NULL COMMENT '当前工作流节点',
  `status` tinyint(1) DEFAULT '0' COMMENT '0=待支付,1=生产中,2=待发货,3=待收货,4=已完成,5=已取消',
  `custom_data_snapshot` json DEFAULT NULL COMMENT '定制参数快照',
  `total_amount` decimal(10,2) DEFAULT NULL COMMENT '总金额',
  `prepay_amount` decimal(10,2) DEFAULT NULL COMMENT '预付款',
  `paid_amount` decimal(10,2) DEFAULT '0.00' COMMENT '已支付金额',
  `expected_date` date DEFAULT NULL COMMENT '预计交付日期',
  `address_snapshot` json DEFAULT NULL COMMENT '收货地址快照',
  `remark` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '备注',
  `is_blocked` tinyint(1) DEFAULT '0' COMMENT '是否阻塞',
  `block_reason` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '阻塞原因',
  `cancel_reason` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '取消原因',
  `delay_reason` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '延期原因',
  `version` int DEFAULT '0' COMMENT '版本号(乐观锁)',
  `create_by` bigint DEFAULT NULL,
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_by` bigint DEFAULT NULL,
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `finish_time` datetime DEFAULT NULL COMMENT '完成时间',
  `delivery_time` datetime DEFAULT NULL COMMENT '发货时间',
  `confirm_time` datetime DEFAULT NULL COMMENT '确认完成时间',
  `del_flag` tinyint(1) DEFAULT '0',
  `bom_template_id` bigint DEFAULT NULL COMMENT '关联BOM模板',
  `material_cost` decimal(10,2) DEFAULT '0.00' COMMENT '物料成本',
  PRIMARY KEY (`order_id`) USING BTREE,
  UNIQUE KEY `uk_order_sn` (`order_sn`) USING BTREE,
  KEY `idx_user_status` (`user_id`,`status`) USING BTREE,
  KEY `idx_designer` (`designer_id`) USING BTREE,
  KEY `idx_create_time` (`create_time`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='订单主表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ds_order`
--

LOCK TABLES `ds_order` WRITE;
/*!40000 ALTER TABLE `ds_order` DISABLE KEYS */;
INSERT INTO `ds_order` VALUES (1,'DS202603081601001',3,1,2,2,1,'{\"chest\": \"92\", \"waist\": \"72\", \"length\": \"130\", \"shoulder\": \"40\", \"fabric_type\": \"亚麻\"}',3500.00,1750.00,1750.00,'2026-04-18',NULL,'改良汉服，客户要求宽松版型',1,'天气原因',NULL,'????????',11,NULL,'2026-03-08 16:05:00',1,'2026-04-11 18:05:24',NULL,NULL,NULL,0,NULL,0.00),(2,'DS202603071102001',2,3,3,12,1,'{\"usage\": \"公司品牌Logo\", \"art_style\": \"扁平化\", \"resolution\": \"3000×3000\"}',800.00,400.00,400.00,'2026-03-25',NULL,'Logo设计，需要三个备选方案',0,NULL,NULL,NULL,3,NULL,'2026-03-07 11:05:00',1,'2026-04-10 11:29:04',NULL,NULL,NULL,0,NULL,0.00),(3,'DS202603151400001',1,2,2,8,4,'{\"color\": \"黑色\", \"size_spec\": \"长25cm×宽15cm\", \"leather_type\": \"鳄鱼皮\"}',5800.00,2900.00,2900.00,'2026-04-20',NULL,'鳄鱼皮手拿包，高端定制',1,'鳄鱼皮原料缺货，预计3天到货',NULL,NULL,4,NULL,'2026-03-15 14:00:00',1,'2026-04-10 21:06:20','2026-04-10 21:06:20','2026-04-10 21:04:19','2026-04-10 21:06:20',0,NULL,0.00),(4,'DS202602201000001',1,3,3,16,4,'{\"usage\": \"个人收藏\", \"art_style\": \"水彩风\", \"resolution\": \"1920×1080\"}',600.00,300.00,600.00,'2026-03-05',NULL,'水彩风景画',0,NULL,NULL,NULL,0,NULL,'2026-02-20 10:00:00',NULL,'2026-04-09 21:07:17','2026-03-03 18:00:00',NULL,NULL,0,NULL,0.00),(5,'DS202604051756345882',1,1,2,NULL,1,'{\"chest\": \"1\", \"waist\": \"2\", \"length\": \"4\", \"shoulder\": \"3\"}',800.00,300.00,0.00,'2026-04-29',NULL,'',0,NULL,NULL,NULL,0,1,'2026-04-05 17:56:34',1,'2026-04-05 17:56:34',NULL,NULL,NULL,0,NULL,0.00),(6,'DS202604092137346349',1,1,2,1,5,'{\"chest\": \"20\", \"waist\": \"30\", \"shoulder\": \"20\"}',100.00,10.00,0.00,'2026-04-09',NULL,'',0,'13','??????????',NULL,5,1,'2026-04-09 21:37:35',1,'2026-04-10 21:03:33','2026-04-10 21:03:33',NULL,NULL,0,NULL,0.00),(7,'DS202604102239321777',1,1,2,1,5,'{\"chest\": \"88\", \"waist\": \"68\", \"length\": \"120\", \"shoulder\": \"38\", \"fabric_type\": \"丝绸\"}',3500.00,1500.00,1500.00,'2026-05-20',NULL,'BOM测试转单',0,NULL,'测试取消-归还库存',NULL,3,1,'2026-04-10 22:39:33',1,'2026-04-10 22:57:01','2026-04-10 22:57:01',NULL,NULL,0,1,519.50),(8,'DS202604111743293930',1,1,2,1,1,'{\"chest\": \"123\", \"waist\": \"32\", \"length\": \"123\", \"shoulder\": \"45\"}',100.00,10.00,10.00,NULL,NULL,'',0,NULL,NULL,NULL,2,1,'2026-04-11 17:43:29',1,'2026-04-30 13:15:06',NULL,NULL,NULL,0,1,519.50),(9,'DS202604111801332055',1,1,2,2,1,'{\"chest\": \"123\", \"waist\": \"12\", \"length\": \"3\", \"shoulder\": \"12\"}',1000.00,10.00,10.00,'2026-04-25',NULL,'',0,NULL,NULL,NULL,2,1,'2026-04-11 18:01:33',1,'2026-05-01 14:33:15',NULL,NULL,NULL,0,NULL,0.00);
/*!40000 ALTER TABLE `ds_order` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ds_order_progress`
--

DROP TABLE IF EXISTS `ds_order_progress`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ds_order_progress` (
  `progress_id` bigint NOT NULL AUTO_INCREMENT,
  `order_id` bigint NOT NULL COMMENT '所属订单',
  `step_id` bigint NOT NULL COMMENT '对应工作流节点',
  `description` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '进度描述',
  `image_urls` json DEFAULT NULL COMMENT '进度图片',
  `form_data` json DEFAULT NULL COMMENT '节点表单填写数据',
  `operator_id` bigint DEFAULT NULL COMMENT '操作人ID',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `del_flag` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`progress_id`) USING BTREE,
  KEY `idx_order` (`order_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=49 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='订单进度表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ds_order_progress`
--

LOCK TABLES `ds_order_progress` WRITE;
/*!40000 ALTER TABLE `ds_order_progress` DISABLE KEYS */;
INSERT INTO `ds_order_progress` VALUES (1,1,1,'客户需求已确认，改良汉服宽松版型，亚麻面料',NULL,NULL,2,'2026-03-08 16:10:00',0),(2,1,2,'特选高品质亚麻面料已采购到位，颜色为浅米色',NULL,NULL,2,'2026-03-10 09:00:00',0),(3,1,3,'开始裁剪，按照客户尺寸放样',NULL,NULL,2,'2026-03-12 14:00:00',0),(4,2,12,'需求已确认，客户要求扁平化风格Logo',NULL,NULL,3,'2026-03-07 11:10:00',0),(5,2,13,'草稿完成，已提交3个备选方案给客户',NULL,NULL,3,'2026-03-09 16:00:00',0),(6,2,14,'客户选择方案B，开始线稿细化',NULL,NULL,3,'2026-03-11 10:00:00',0),(7,4,12,'需求确认完毕',NULL,NULL,3,'2026-02-20 10:10:00',0),(8,4,13,'草稿完成',NULL,NULL,3,'2026-02-22 15:00:00',0),(9,4,14,'线稿已定稿',NULL,NULL,3,'2026-02-25 11:00:00',0),(10,4,15,'上色完成，最终稿已出',NULL,NULL,3,'2026-02-28 17:00:00',0),(11,4,16,'客户验收通过，交付完成',NULL,NULL,3,'2026-03-03 18:00:00',0),(12,3,8,'部分',NULL,NULL,1,'2026-03-17 15:16:03',0),(13,1,3,'工作台接口联调记录',NULL,NULL,1,'2026-04-09 21:13:19',0),(14,1,3,'upload-ok','\"/uploads/321f10cac04241249a1c608ce6c9b048.png\"',NULL,1,'2026-04-09 21:33:42',0),(15,6,1,'1',NULL,NULL,1,'2026-04-09 21:37:59',0),(16,6,1,'订单已阻塞：11',NULL,NULL,2,'2026-04-09 21:42:51',0),(17,6,1,'订单已解除阻塞',NULL,NULL,2,'2026-04-09 21:43:14',0),(18,6,1,'订单已阻塞：13',NULL,NULL,2,'2026-04-09 21:43:17',0),(19,6,1,'订单已解除阻塞',NULL,NULL,2,'2026-04-09 21:43:22',0),(20,1,2,'rollback-api-test',NULL,NULL,1,'2026-04-10 10:36:27',0),(21,1,3,'rollback-restore',NULL,NULL,1,'2026-04-10 10:36:28',0),(22,1,2,'退回至节点：面料采购',NULL,NULL,1,'2026-04-10 10:48:26',0),(23,2,12,'联调：指定退回到需求确认',NULL,NULL,1,'2026-04-10 11:26:40',0),(24,2,13,'联调：推进到草稿构图',NULL,NULL,1,'2026-04-10 11:29:04',0),(25,2,12,'联调：退回到需求确认',NULL,NULL,1,'2026-04-10 11:29:04',0),(26,1,3,'推进至节点：裁剪',NULL,NULL,1,'2026-04-10 11:34:08',0),(27,1,2,'退回至节点：面料采购',NULL,NULL,1,'2026-04-10 11:34:13',0),(28,1,1,'退回至节点：需求确认',NULL,NULL,1,'2026-04-10 11:34:30',0),(29,6,1,'????????',NULL,'{\"chest\": 88, \"waist\": 66}',1,'2026-04-10 15:43:40',0),(30,6,1,'订单已取消：??????????',NULL,NULL,1,'2026-04-10 21:03:33',0),(31,1,1,'订单延期至 2026-04-18，原因：????????',NULL,NULL,1,'2026-04-10 21:03:33',0),(32,3,8,'??????',NULL,NULL,1,'2026-04-10 21:04:19',0),(33,3,8,'客户已确认收货，订单已完成',NULL,NULL,1,'2026-04-10 21:06:20',0),(34,7,1,'客户已支付定金：¥1500.00',NULL,NULL,1,'2026-04-10 22:56:34',0),(35,7,1,'订单已取消：测试取消-归还库存',NULL,NULL,1,'2026-04-10 22:57:01',0),(36,1,2,'推进至节点：面料采购',NULL,'{\"chest\": \"92\", \"waist\": \"72\"}',1,'2026-04-11 17:17:35',0),(37,1,1,'退回至节点：需求确认',NULL,NULL,1,'2026-04-11 18:02:52',0),(38,1,2,'完成需求',NULL,'{\"chest\": \"92\", \"waist\": \"72\"}',1,'2026-04-11 18:04:27',0),(39,1,2,'订单已阻塞：天气原因',NULL,NULL,1,'2026-04-11 18:05:24',0),(40,9,1,'客户已支付定金：¥10.00',NULL,NULL,1,'2026-04-11 18:08:26',0),(41,9,1,NULL,NULL,'{\"chest\": \"123\", \"waist\": \"12\"}',1,'2026-04-21 00:28:54',0),(42,9,1,NULL,NULL,'{\"chest\": \"123\", \"waist\": \"12\"}',1,'2026-04-21 00:28:56',0),(43,9,1,NULL,NULL,'{\"chest\": \"123\", \"waist\": \"12\"}',1,'2026-04-21 00:28:58',0),(44,9,1,NULL,NULL,'{\"chest\": \"123\", \"waist\": \"12\"}',1,'2026-04-21 00:29:03',0),(45,9,1,NULL,NULL,'{\"chest\": \"123\", \"waist\": \"12\"}',1,'2026-04-21 00:40:00',0),(46,8,1,'客户已支付定金：¥10.00',NULL,NULL,1,'2026-04-30 13:15:06',0),(47,9,1,'尺寸已确认：胸围90cm，腰围75cm，准备进入下一阶段。',NULL,'{\"chest\": 90, \"waist\": 75}',1,'2026-05-01 14:32:49',0),(48,9,2,'推进至节点：面料采购',NULL,'{\"chest\": 90, \"waist\": 75}',1,'2026-05-01 14:33:15',0);
/*!40000 ALTER TABLE `ds_order_progress` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ds_order_request`
--

DROP TABLE IF EXISTS `ds_order_request`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ds_order_request` (
  `request_id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL COMMENT '提交客户',
  `category_id` bigint NOT NULL COMMENT '定制品类',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci COMMENT '客户文字描述',
  `image_urls` json DEFAULT NULL COMMENT '参考图片(JSON数组)',
  `custom_data` json DEFAULT NULL COMMENT '动态表单数据',
  `status` tinyint(1) DEFAULT '0' COMMENT '0=待处理,1=已转单,2=已关闭',
  `close_reason` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '关闭原因',
  `linked_order_id` bigint DEFAULT NULL COMMENT '转化后的订单ID',
  `create_by` bigint DEFAULT NULL,
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_by` bigint DEFAULT NULL,
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `del_flag` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`request_id`) USING BTREE,
  KEY `idx_user` (`user_id`) USING BTREE,
  KEY `idx_status` (`status`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='订单意向表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ds_order_request`
--

LOCK TABLES `ds_order_request` WRITE;
/*!40000 ALTER TABLE `ds_order_request` DISABLE KEYS */;
INSERT INTO `ds_order_request` VALUES (1,1,1,'想定制一件旗袍，用于参加朋友婚礼',NULL,'{\"chest\": \"88\", \"waist\": \"68\", \"length\": \"120\", \"shoulder\": \"38\", \"fabric_type\": \"丝绸\"}',1,NULL,7,NULL,'2026-03-10 10:00:00',1,'2026-03-17 15:11:05',0),(2,2,2,'想做一个手工皮革钱包，送给男朋友做生日礼物',NULL,'{\"color\": \"深棕色\", \"size_spec\": \"长20cm×宽10cm\", \"leather_type\": \"植鞣革\"}',0,NULL,NULL,NULL,'2026-03-11 14:30:00',NULL,'2026-03-17 15:11:05',0),(3,1,3,'需要一张日系风格的头像插画',NULL,'{\"usage\": \"社交媒体头像\", \"art_style\": \"日系\", \"resolution\": \"1080×1080\"}',0,NULL,NULL,NULL,'2026-03-12 09:15:00',NULL,'2026-03-17 15:11:05',0),(4,3,1,'需要一套改良汉服',NULL,'{\"chest\": \"92\", \"waist\": \"72\", \"length\": \"130\", \"shoulder\": \"40\", \"fabric_type\": \"亚麻\"}',1,NULL,1,NULL,'2026-03-08 16:00:00',NULL,'2026-03-17 15:11:05',0),(5,2,3,'设计公司 Logo 扁平化插画',NULL,'{\"usage\": \"公司品牌Logo\", \"art_style\": \"扁平化\", \"resolution\": \"3000×3000\"}',1,NULL,2,NULL,'2026-03-07 11:00:00',NULL,'2026-03-17 15:11:05',0),(6,3,2,'复古风格手提包',NULL,'{\"color\": \"酒红色\", \"size_spec\": \"长30cm×宽20cm×高15cm\", \"leather_type\": \"牛皮\"}',2,'客户取消，预算不足',NULL,NULL,'2026-03-05 08:45:00',NULL,'2026-03-17 15:11:05',0),(7,1,1,'','[]','{\"chest\": \"123\", \"waist\": \"32\", \"length\": \"123\", \"shoulder\": \"45\"}',1,NULL,8,1,'2026-04-05 17:45:08',1,'2026-04-05 17:45:08',0),(8,1,1,'','[]','{\"chest\": \"1\", \"waist\": \"2\", \"length\": \"4\", \"shoulder\": \"3\"}',1,NULL,5,1,'2026-04-05 17:46:11',1,'2026-04-05 17:46:11',0),(9,1,1,'','[]','{\"chest\": \"20\", \"waist\": \"30\", \"shoulder\": \"20\"}',1,NULL,6,1,'2026-04-09 21:37:09',1,'2026-04-09 21:37:09',0),(10,1,1,'','[]','{\"chest\": \"123\", \"waist\": \"12\", \"length\": \"3\", \"shoulder\": \"12\"}',1,NULL,9,1,'2026-04-11 18:01:09',1,'2026-04-11 18:01:09',0);
/*!40000 ALTER TABLE `ds_order_request` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ds_payment_record`
--

DROP TABLE IF EXISTS `ds_payment_record`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ds_payment_record` (
  `payment_id` bigint NOT NULL AUTO_INCREMENT,
  `payment_no` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '系统支付流水号',
  `order_id` bigint NOT NULL COMMENT '关联订单',
  `user_id` bigint NOT NULL COMMENT '支付用户',
  `payment_type` tinyint(1) NOT NULL COMMENT '1=预付款,2=尾款',
  `amount` decimal(10,2) NOT NULL COMMENT '支付金额',
  `wx_transaction_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '微信支付交易号',
  `wx_prepay_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '微信预支付ID',
  `status` tinyint(1) DEFAULT '0' COMMENT '0=待支付,1=成功,2=失败,3=已关闭',
  `pay_time` datetime DEFAULT NULL COMMENT '实际支付时间',
  `expire_time` datetime DEFAULT NULL COMMENT '支付过期时间',
  `notify_data` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci COMMENT '微信回调原始数据',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `del_flag` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`payment_id`) USING BTREE,
  UNIQUE KEY `uk_payment_no` (`payment_no`) USING BTREE,
  KEY `idx_order` (`order_id`) USING BTREE,
  KEY `idx_user` (`user_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='支付流水表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ds_payment_record`
--

LOCK TABLES `ds_payment_record` WRITE;
/*!40000 ALTER TABLE `ds_payment_record` DISABLE KEYS */;
/*!40000 ALTER TABLE `ds_payment_record` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ds_portfolio`
--

DROP TABLE IF EXISTS `ds_portfolio`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ds_portfolio` (
  `portfolio_id` bigint NOT NULL AUTO_INCREMENT,
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '作品标题',
  `category_id` bigint DEFAULT NULL COMMENT '关联品类',
  `cover_url` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '封面图',
  `image_urls` json NOT NULL COMMENT '图片列表(JSON数组)',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci COMMENT '富文本描述',
  `status` tinyint(1) DEFAULT '0' COMMENT '0=草稿,1=发布',
  `view_count` int DEFAULT '0' COMMENT '浏览次数',
  `sort_order` int DEFAULT '0' COMMENT '排序',
  `create_by` bigint DEFAULT NULL,
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_by` bigint DEFAULT NULL,
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `del_flag` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`portfolio_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='作品集表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ds_portfolio`
--

LOCK TABLES `ds_portfolio` WRITE;
/*!40000 ALTER TABLE `ds_portfolio` DISABLE KEYS */;
INSERT INTO `ds_portfolio` VALUES (1,'猫',1,'https://i0.hdslb.com/bfs/new_dyn/a4833ebe1038fcd60a196da9b53c0e44270317383.jpg@420w_560h_1e_1c.webp','[\"https://i0.hdslb.com/bfs/new_dyn/a4833ebe1038fcd60a196da9b53c0e44270317383.jpg@420w_560h_1e_1c.webp\", \"https://i0.hdslb.com/bfs/new_dyn/a42924b84d925cfabf5672f8e7373ee6270317383.jpg@264w_264h_1e_1c.webp\"]','',1,4,1,1,'2026-04-10 19:53:02',1,'2026-04-10 19:53:02',0),(2,'测试上传作品',1,'http://localhost:8081/uploads/fc1a62f7bca648898b01d8239d4fb54b.png','[]','',0,0,0,1,'2026-04-10 20:05:54',1,'2026-04-10 20:05:54',0);
/*!40000 ALTER TABLE `ds_portfolio` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ds_refund_record`
--

DROP TABLE IF EXISTS `ds_refund_record`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ds_refund_record` (
  `refund_id` bigint NOT NULL AUTO_INCREMENT,
  `refund_no` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '系统退款流水号',
  `order_id` bigint NOT NULL COMMENT '关联订单',
  `payment_id` bigint DEFAULT NULL COMMENT '关联原支付记录',
  `refund_amount` decimal(10,2) NOT NULL COMMENT '退款金额',
  `refund_reason` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '退款原因',
  `wx_refund_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '微信退款单号',
  `status` tinyint(1) DEFAULT '0' COMMENT '0=处理中,1=退款成功,2=退款失败',
  `refund_time` datetime DEFAULT NULL COMMENT '实际退款时间',
  `operator_id` bigint DEFAULT NULL COMMENT '操作人ID',
  `notify_data` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci COMMENT '微信回调原始数据',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `del_flag` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`refund_id`) USING BTREE,
  UNIQUE KEY `uk_refund_no` (`refund_no`) USING BTREE,
  KEY `idx_order` (`order_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='退款记录表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ds_refund_record`
--

LOCK TABLES `ds_refund_record` WRITE;
/*!40000 ALTER TABLE `ds_refund_record` DISABLE KEYS */;
/*!40000 ALTER TABLE `ds_refund_record` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ds_user`
--

DROP TABLE IF EXISTS `ds_user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ds_user` (
  `user_id` bigint NOT NULL AUTO_INCREMENT,
  `openid` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '微信OpenID',
  `unionid` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '微信UnionID',
  `nickname` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '昵称',
  `avatar_url` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '头像URL',
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '手机号',
  `status` tinyint(1) DEFAULT '1' COMMENT '0=禁用,1=正常',
  `gender` tinyint(1) DEFAULT NULL COMMENT '性别',
  `default_address_id` bigint DEFAULT NULL COMMENT '默认地址ID',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '注册时间',
  `last_login_time` datetime DEFAULT NULL COMMENT '最后登录',
  `del_flag` tinyint(1) DEFAULT '0',
  `create_by` bigint DEFAULT NULL,
  `update_by` bigint DEFAULT NULL,
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`user_id`) USING BTREE,
  UNIQUE KEY `uk_openid` (`openid`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='小程序用户表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ds_user`
--

LOCK TABLES `ds_user` WRITE;
/*!40000 ALTER TABLE `ds_user` DISABLE KEYS */;
INSERT INTO `ds_user` VALUES (1,'wx_test_openid_001',NULL,'张小姐',NULL,'13900001001',1,NULL,NULL,'2026-03-17 15:11:05','2026-04-30 13:04:23',0,NULL,5,'2026-03-24 16:43:20'),(2,'wx_test_openid_002',NULL,'刘先生',NULL,'13900001002',1,NULL,NULL,'2026-03-17 15:11:05',NULL,0,NULL,NULL,'2026-03-24 16:43:20'),(3,'wx_test_openid_003',NULL,'陈女士',NULL,'13900001003',1,NULL,NULL,'2026-03-17 15:11:05','2026-04-11 18:03:48',0,NULL,NULL,'2026-03-24 16:43:20'),(4,'wx_test_openid_13888888888',NULL,'客户8888',NULL,'13888888888',1,NULL,NULL,'2026-03-24 16:44:41','2026-03-25 19:19:38',0,NULL,4,'2026-03-24 16:44:41'),(5,'wx_test_openid_default',NULL,'ZeHana测试客户',NULL,'13888888888',1,NULL,NULL,'2026-03-25 19:24:46','2026-04-05 16:57:43',0,NULL,1,'2026-03-25 19:24:46');
/*!40000 ALTER TABLE `ds_user` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ds_workflow`
--

DROP TABLE IF EXISTS `ds_workflow`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ds_workflow` (
  `workflow_id` bigint NOT NULL AUTO_INCREMENT,
  `category_id` bigint NOT NULL COMMENT '关联品类(一对一)',
  `workflow_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '工作流名称',
  `create_by` bigint DEFAULT NULL,
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_by` bigint DEFAULT NULL,
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `del_flag` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`workflow_id`) USING BTREE,
  UNIQUE KEY `uk_category` (`category_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='工作流模板表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ds_workflow`
--

LOCK TABLES `ds_workflow` WRITE;
/*!40000 ALTER TABLE `ds_workflow` DISABLE KEYS */;
INSERT INTO `ds_workflow` VALUES (1,1,'服装定制流程',NULL,'2026-03-04 15:06:58',NULL,'2026-03-04 15:06:58',0),(2,2,'皮具制作流程',NULL,'2026-03-04 15:06:58',NULL,'2026-03-04 15:06:58',0),(3,3,'数字插画流程',NULL,'2026-03-04 15:06:58',NULL,'2026-03-04 15:06:58',0);
/*!40000 ALTER TABLE `ds_workflow` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ds_workflow_step`
--

DROP TABLE IF EXISTS `ds_workflow_step`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ds_workflow_step` (
  `step_id` bigint NOT NULL AUTO_INCREMENT,
  `workflow_id` bigint NOT NULL COMMENT '所属工作流',
  `step_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '节点名称',
  `step_order` int NOT NULL DEFAULT '1' COMMENT '节点顺序',
  `is_start_step` tinyint(1) DEFAULT '0' COMMENT '是否起始节点',
  `is_end_step` tinyint(1) DEFAULT '0' COMMENT '是否结束节点',
  `node_description` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '????',
  `allowed_actions` json DEFAULT NULL COMMENT '????(JSON??)',
  `need_image_upload` tinyint(1) DEFAULT '0' COMMENT '????????',
  `visible_to_client` tinyint(1) DEFAULT '1' COMMENT '???????',
  `expected_duration_days` int DEFAULT NULL COMMENT '??????(?)',
  `node_form_fields` json DEFAULT NULL COMMENT '节点表单字段键列表',
  `create_by` bigint DEFAULT NULL,
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_by` bigint DEFAULT NULL,
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `del_flag` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`step_id`) USING BTREE,
  KEY `idx_workflow` (`workflow_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='工作流节点表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ds_workflow_step`
--

LOCK TABLES `ds_workflow_step` WRITE;
/*!40000 ALTER TABLE `ds_workflow_step` DISABLE KEYS */;
INSERT INTO `ds_workflow_step` VALUES (1,1,'需求确认',1,1,0,'处理节点：需求确认','[\"save\", \"advance\", \"rollback\", \"block\", \"unblock\"]',0,1,1,'[\"chest\", \"waist\"]',NULL,'2026-03-04 15:06:58',NULL,'2026-04-10 15:43:02',0),(2,1,'面料采购',2,0,0,'处理节点：面料采购','[\"save\", \"advance\", \"rollback\", \"block\", \"unblock\"]',0,1,2,NULL,NULL,'2026-03-04 15:06:58',NULL,'2026-04-10 10:33:15',0),(3,1,'裁剪',3,0,0,'处理节点：裁剪','[\"save\", \"advance\", \"rollback\", \"block\", \"unblock\"]',1,1,3,NULL,NULL,'2026-03-04 15:06:58',NULL,'2026-04-10 10:33:15',0),(4,1,'缝制',4,0,0,'处理节点：缝制','[\"save\", \"advance\", \"rollback\", \"block\", \"unblock\"]',1,1,3,NULL,NULL,'2026-03-04 15:06:58',NULL,'2026-04-10 10:33:15',0),(5,1,'质检',5,0,0,'处理节点：质检','[\"save\", \"advance\", \"rollback\", \"block\", \"unblock\"]',1,1,1,NULL,NULL,'2026-03-04 15:06:58',NULL,'2026-04-10 10:33:15',0),(6,1,'包装发货',6,0,1,'处理节点：包装发货','[\"save\", \"advance\", \"rollback\", \"block\", \"unblock\"]',0,1,1,NULL,NULL,'2026-03-04 15:06:58',NULL,'2026-04-10 10:33:15',0),(7,2,'需求确认',1,1,0,'处理节点：需求确认','[\"save\", \"advance\", \"rollback\", \"block\", \"unblock\"]',0,1,1,NULL,NULL,'2026-03-04 15:06:58',NULL,'2026-04-10 10:33:15',0),(8,2,'皮料裁切',2,0,0,'处理节点：皮料裁切','[\"save\", \"advance\", \"rollback\", \"block\", \"unblock\"]',0,1,2,NULL,NULL,'2026-03-04 15:06:58',NULL,'2026-04-10 10:33:15',0),(9,2,'缝线打磨',3,0,0,'处理节点：缝线打磨','[\"save\", \"advance\", \"rollback\", \"block\", \"unblock\"]',1,1,3,NULL,NULL,'2026-03-04 15:06:58',NULL,'2026-04-10 10:33:15',0),(10,2,'上色封边',4,0,0,'处理节点：上色封边','[\"save\", \"advance\", \"rollback\", \"block\", \"unblock\"]',1,1,3,NULL,NULL,'2026-03-04 15:06:58',NULL,'2026-04-10 10:33:15',0),(11,2,'质检出货',5,0,1,'处理节点：质检出货','[\"save\", \"advance\", \"rollback\", \"block\", \"unblock\"]',1,1,1,NULL,NULL,'2026-03-04 15:06:58',NULL,'2026-04-10 10:33:15',0),(12,3,'需求确认',1,1,0,'处理节点：需求确认','[\"save\", \"advance\", \"rollback\", \"block\", \"unblock\"]',0,1,1,NULL,NULL,'2026-03-04 15:06:58',NULL,'2026-04-10 10:33:15',0),(13,3,'草稿构图',2,0,0,'处理节点：草稿构图','[\"save\", \"advance\", \"rollback\", \"block\", \"unblock\"]',1,1,2,NULL,NULL,'2026-03-04 15:06:58',NULL,'2026-04-10 10:33:15',0),(14,3,'线稿细化',3,0,0,'处理节点：线稿细化','[\"save\", \"advance\", \"rollback\", \"block\", \"unblock\"]',1,1,3,NULL,NULL,'2026-03-04 15:06:58',NULL,'2026-04-10 10:33:15',0),(15,3,'上色完稿',4,0,0,'处理节点：上色完稿','[\"save\", \"advance\", \"rollback\", \"block\", \"unblock\"]',1,1,3,NULL,NULL,'2026-03-04 15:06:58',NULL,'2026-04-10 10:33:15',0),(16,3,'客户验收',5,0,1,'处理节点：客户验收','[\"save\", \"advance\", \"rollback\", \"block\", \"unblock\"]',1,1,1,NULL,NULL,'2026-03-04 15:06:58',NULL,'2026-04-10 10:33:15',0);
/*!40000 ALTER TABLE `ds_workflow_step` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_admin`
--

DROP TABLE IF EXISTS `sys_admin`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_admin` (
  `admin_id` bigint NOT NULL AUTO_INCREMENT,
  `username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '登录账号',
  `password` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '密码(BCrypt)',
  `nickname` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '昵称',
  `avatar` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '头像',
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '手机号',
  `email` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '邮箱',
  `status` tinyint(1) DEFAULT '1' COMMENT '0=禁用,1=正常',
  `create_by` bigint DEFAULT NULL,
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_by` bigint DEFAULT NULL,
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `last_login_time` datetime DEFAULT NULL COMMENT '最后登录',
  `del_flag` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`admin_id`) USING BTREE,
  UNIQUE KEY `uk_username` (`username`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='后台用户表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_admin`
--

LOCK TABLES `sys_admin` WRITE;
/*!40000 ALTER TABLE `sys_admin` DISABLE KEYS */;
INSERT INTO `sys_admin` VALUES (1,'admin','$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2','超级管理员',NULL,NULL,NULL,1,NULL,'2026-03-04 15:06:58',NULL,'2026-03-04 15:06:58',NULL,0),(2,'designer1','$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2','李设计师',NULL,'13800001001',NULL,1,NULL,'2026-03-17 15:11:05',NULL,'2026-03-17 15:11:05',NULL,0),(3,'designer2','$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2','王设计师',NULL,'13800001002',NULL,1,NULL,'2026-03-17 15:11:05',1,'2026-03-17 15:11:05',NULL,0),(4,'storekeeper','$2a$10$lquZWWPAEjT1D3Ugbh2NTuZURlkeRF.K3LJcRSDQSTq3ljats0T96','storekeeper',NULL,'',NULL,1,1,'2026-04-20 00:45:35',1,'2026-04-20 00:45:35',NULL,0),(5,'purchaser','$2a$10$MqEyuumZ9MXB/nmwzeV4euzEhnyxbn1Pvw.8b1S1V.g0BtZBrtgP2','purchaser',NULL,'',NULL,1,1,'2026-04-20 00:45:44',1,'2026-04-20 00:45:44',NULL,0),(6,'finance','$2a$10$7ahdyzysipm.sGUK/eC5u.kmXmANkbg6oHz/xJVympU3XDVbg1r.a','finance',NULL,'',NULL,1,1,'2026-04-20 00:45:54',1,'2026-04-20 00:45:54',NULL,0),(7,'customer_service','$2a$10$EI4ij7ybYwOwfck0R9xc7eYthj.vysnH7zYLup406nWkFLxXYqxXO','customer_service',NULL,'',NULL,1,1,'2026-04-20 00:46:07',1,'2026-04-20 00:46:07',NULL,0);
/*!40000 ALTER TABLE `sys_admin` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_admin_role`
--

DROP TABLE IF EXISTS `sys_admin_role`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_admin_role` (
  `admin_id` bigint NOT NULL COMMENT '用户ID',
  `role_id` bigint NOT NULL COMMENT '角色ID',
  PRIMARY KEY (`admin_id`,`role_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='用户角色关联表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_admin_role`
--

LOCK TABLES `sys_admin_role` WRITE;
/*!40000 ALTER TABLE `sys_admin_role` DISABLE KEYS */;
INSERT INTO `sys_admin_role` VALUES (1,1),(2,2),(3,2),(4,3),(5,4),(6,5),(7,6);
/*!40000 ALTER TABLE `sys_admin_role` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_api_metrics`
--

DROP TABLE IF EXISTS `sys_api_metrics`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_api_metrics` (
  `metric_id` bigint NOT NULL AUTO_INCREMENT,
  `api_path` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '接口路径',
  `http_method` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'HTTP方法',
  `stat_date` date NOT NULL COMMENT '统计日期',
  `stat_hour` int DEFAULT NULL COMMENT '统计小时(0-23)',
  `call_count` int DEFAULT '0' COMMENT '调用次数',
  `success_count` int DEFAULT '0',
  `fail_count` int DEFAULT '0',
  `avg_cost_ms` int DEFAULT '0' COMMENT '平均耗时(ms)',
  `max_cost_ms` int DEFAULT '0',
  `p99_cost_ms` int DEFAULT '0',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`metric_id`) USING BTREE,
  UNIQUE KEY `uk_api_date_hour` (`api_path`,`stat_date`,`stat_hour`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='接口监控指标表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_api_metrics`
--

LOCK TABLES `sys_api_metrics` WRITE;
/*!40000 ALTER TABLE `sys_api_metrics` DISABLE KEYS */;
/*!40000 ALTER TABLE `sys_api_metrics` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_dict_data`
--

DROP TABLE IF EXISTS `sys_dict_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_dict_data` (
  `dict_code` bigint NOT NULL AUTO_INCREMENT,
  `dict_type` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '字典类型标识',
  `dict_label` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '字典标签',
  `dict_value` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '字典值',
  `sort_order` int DEFAULT '0' COMMENT '排序',
  `remark` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '备注',
  `del_flag` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`dict_code`) USING BTREE,
  KEY `idx_dict_type` (`dict_type`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='字典数据表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_dict_data`
--

LOCK TABLES `sys_dict_data` WRITE;
/*!40000 ALTER TABLE `sys_dict_data` DISABLE KEYS */;
INSERT INTO `sys_dict_data` VALUES (1,'order_status','待支付','0',0,NULL,0),(2,'order_status','生产中','1',1,NULL,0),(3,'order_status','待发货','2',2,NULL,0),(4,'order_status','待收货','3',3,NULL,0),(5,'order_status','已完成','4',4,NULL,0),(6,'order_status','已取消','5',5,NULL,0),(7,'request_status','待处理','0',0,NULL,0),(8,'request_status','已转单','1',1,NULL,0),(9,'request_status','已关闭','2',2,NULL,0),(10,'payment_type','预付款','1',1,NULL,0),(11,'payment_type','尾款','2',2,NULL,0),(12,'material_category','面料','fabric',1,NULL,0),(13,'material_category','辅料','accessory',2,NULL,0),(14,'material_category','五金件','hardware',3,NULL,0);
/*!40000 ALTER TABLE `sys_dict_data` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_dict_type`
--

DROP TABLE IF EXISTS `sys_dict_type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_dict_type` (
  `dict_id` bigint NOT NULL AUTO_INCREMENT,
  `dict_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '字典名称',
  `dict_type` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '字典类型标识',
  `remark` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '备注',
  `create_by` bigint DEFAULT NULL,
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_by` bigint DEFAULT NULL,
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `del_flag` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`dict_id`) USING BTREE,
  UNIQUE KEY `uk_dict_type` (`dict_type`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='字典类型表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_dict_type`
--

LOCK TABLES `sys_dict_type` WRITE;
/*!40000 ALTER TABLE `sys_dict_type` DISABLE KEYS */;
INSERT INTO `sys_dict_type` VALUES (1,'订单状态','order_status','订单生命周期状态',NULL,'2026-03-04 15:06:58',NULL,'2026-03-04 15:06:58',0),(2,'意向状态','request_status','客户意向状态',NULL,'2026-03-04 15:06:58',NULL,'2026-03-04 15:06:58',0),(3,'支付类型','payment_type','支付类型',NULL,'2026-03-04 15:06:58',NULL,'2026-03-04 15:06:58',0),(4,'物料分类','material_category','物料分类',NULL,'2026-03-04 15:06:58',NULL,'2026-03-04 15:06:58',0),(5,'1','1','',NULL,'2026-04-05 14:58:11',NULL,'2026-04-05 15:03:50',1),(7,'2','2','',NULL,'2026-04-05 15:00:09',NULL,'2026-04-05 15:03:49',1);
/*!40000 ALTER TABLE `sys_dict_type` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_exception_log`
--

DROP TABLE IF EXISTS `sys_exception_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_exception_log` (
  `exception_id` bigint NOT NULL AUTO_INCREMENT,
  `exception_type` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '异常类型(类名)',
  `exception_msg` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci COMMENT '异常消息',
  `stack_trace` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci COMMENT '堆栈信息',
  `request_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '请求URL',
  `request_method` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'HTTP方法',
  `request_param` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci COMMENT '请求参数',
  `operator_id` bigint DEFAULT NULL COMMENT '操作人ID',
  `operator_ip` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '操作人IP',
  `is_handled` tinyint(1) DEFAULT '0' COMMENT '是否已处理',
  `handle_remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '处理备注',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '发生时间',
  PRIMARY KEY (`exception_id`) USING BTREE,
  KEY `idx_create_time` (`create_time`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='异常日志表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_exception_log`
--

LOCK TABLES `sys_exception_log` WRITE;
/*!40000 ALTER TABLE `sys_exception_log` DISABLE KEYS */;
/*!40000 ALTER TABLE `sys_exception_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_login_log`
--

DROP TABLE IF EXISTS `sys_login_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_login_log` (
  `login_id` bigint NOT NULL AUTO_INCREMENT,
  `admin_id` bigint DEFAULT NULL COMMENT '登录用户ID',
  `username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '登录账号',
  `login_ip` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '登录IP',
  `login_location` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '登录地点',
  `browser` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '浏览器',
  `os` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '操作系统',
  `status` tinyint(1) DEFAULT NULL COMMENT '0=成功,1=失败',
  `msg` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '提示消息',
  `login_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '登录时间',
  PRIMARY KEY (`login_id`) USING BTREE,
  KEY `idx_admin` (`admin_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='登录日志表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_login_log`
--

LOCK TABLES `sys_login_log` WRITE;
/*!40000 ALTER TABLE `sys_login_log` DISABLE KEYS */;
/*!40000 ALTER TABLE `sys_login_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_menu`
--

DROP TABLE IF EXISTS `sys_menu`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_menu` (
  `menu_id` bigint NOT NULL AUTO_INCREMENT,
  `parent_id` bigint DEFAULT '0' COMMENT '父菜单ID',
  `menu_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '菜单名称',
  `menu_type` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'M=目录,C=菜单,F=按钮',
  `path` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '路由地址',
  `component` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '组件路径',
  `perms` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '权限标识(如order:list)',
  `icon` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '图标',
  `sort_order` int DEFAULT '0' COMMENT '排序',
  `visible` tinyint(1) DEFAULT '1' COMMENT '是否可见',
  `create_by` bigint DEFAULT NULL,
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_by` bigint DEFAULT NULL,
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `del_flag` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`menu_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=34 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='菜单权限表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_menu`
--

LOCK TABLES `sys_menu` WRITE;
/*!40000 ALTER TABLE `sys_menu` DISABLE KEYS */;
INSERT INTO `sys_menu` VALUES (1,0,'订单管理','M','/order',NULL,NULL,'ShoppingCart',3,1,NULL,'2026-03-04 15:06:58',NULL,'2026-04-11 14:05:26',0),(2,0,'意向管理','M','/request',NULL,NULL,'Mail',4,1,NULL,'2026-03-04 15:06:58',NULL,'2026-04-11 14:05:26',0),(3,0,'配置中心','M','/config',NULL,NULL,'Settings',8,1,NULL,'2026-03-04 15:06:58',NULL,'2026-04-11 14:05:26',0),(4,0,'供应链','M','/supply',NULL,NULL,'Package',6,1,NULL,'2026-03-04 15:06:58',NULL,'2026-04-11 14:05:26',0),(5,0,'作品集','M','/portfolio',NULL,NULL,'Image',5,1,NULL,'2026-03-04 15:06:58',NULL,'2026-03-04 15:06:58',0),(6,0,'数据分析','M','/statistics',NULL,NULL,'TrendingUp',7,1,NULL,'2026-03-04 15:06:58',NULL,'2026-04-11 14:05:26',0),(7,0,'系统管理','M','/system',NULL,NULL,'Tool',9,1,NULL,'2026-03-04 15:06:58',NULL,'2026-04-11 14:05:26',0),(8,1,'订单看板','C','/order/kanban',NULL,'order:kanban',NULL,1,1,NULL,'2026-03-04 15:06:58',NULL,'2026-03-04 15:06:58',0),(9,1,'订单列表','C','/order/list',NULL,'order:list',NULL,2,1,NULL,'2026-03-04 15:06:58',NULL,'2026-03-04 15:06:58',0),(10,2,'意向池','C','/request/list',NULL,'request:list',NULL,1,1,NULL,'2026-03-04 15:06:58',NULL,'2026-03-04 15:06:58',0),(11,3,'品类管理','C','/config/category',NULL,'category:list',NULL,1,1,NULL,'2026-03-04 15:06:58',NULL,'2026-03-04 15:06:58',0),(12,3,'动态字段','C','/config/field',NULL,'field:list',NULL,2,1,NULL,'2026-03-04 15:06:58',NULL,'2026-03-04 15:06:58',0),(13,3,'工作流管理','C','/config/workflow',NULL,'workflow:list',NULL,3,1,NULL,'2026-03-04 15:06:58',NULL,'2026-03-04 15:06:58',0),(14,4,'物料管理','C','/supply/material',NULL,'material:list',NULL,1,1,NULL,'2026-03-04 15:06:58',NULL,'2026-03-04 15:06:58',0),(15,4,'BOM模板','C','/supply/bom',NULL,'bom:list',NULL,2,1,NULL,'2026-03-04 15:06:58',NULL,'2026-03-04 15:06:58',0),(16,5,'作品管理','C','/portfolio/list',NULL,'portfolio:list',NULL,1,1,NULL,'2026-03-04 15:06:58',NULL,'2026-03-04 15:06:58',0),(17,6,'经营看板','C','/statistics/dashboard',NULL,'statistics:dashboard',NULL,1,1,NULL,'2026-03-04 15:06:58',NULL,'2026-03-04 15:06:58',0),(18,7,'用户管理','C','/system/admin',NULL,'admin:list',NULL,1,1,NULL,'2026-03-04 15:06:58',NULL,'2026-03-04 15:06:58',0),(19,7,'角色管理','C','/system/role',NULL,'role:list',NULL,2,1,NULL,'2026-03-04 15:06:58',NULL,'2026-03-04 15:06:58',0),(20,7,'菜单管理','C','/system/menu',NULL,'menu:list',NULL,3,1,NULL,'2026-03-04 15:06:58',NULL,'2026-03-04 15:06:58',0),(21,7,'字典管理','C','/system/dict',NULL,'dict:list',NULL,4,1,NULL,'2026-03-04 15:06:58',NULL,'2026-03-04 15:06:58',0),(22,7,'操作日志','C','/system/log',NULL,'log:list',NULL,5,1,NULL,'2026-03-04 15:06:58',NULL,'2026-03-04 15:06:58',0),(23,0,'消息中心','M','/chat',NULL,NULL,'ChatboxEllipsesOutline',2,1,NULL,'2026-03-25 19:24:46',NULL,'2026-04-11 14:05:26',0),(24,23,'在线沟通','C','/chat/index',NULL,'chat:list',NULL,1,1,NULL,'2026-03-25 19:24:46',NULL,'2026-03-25 19:24:46',0),(25,0,'节点工作台','M','/workbench','LAYOUT',NULL,'AppstoreOutlined',1,1,NULL,'2026-04-09 20:59:05',NULL,'2026-04-11 14:05:26',0),(26,25,'节点工作台','C','nodes','/order/workbench','workbench:list',NULL,1,1,NULL,'2026-04-09 20:59:05',NULL,'2026-04-09 21:04:12',0),(27,4,'库存管理','C','/supply/inventory',NULL,'inventory:list','CubeOutline',3,1,NULL,'2026-04-14 22:09:37',NULL,'2026-04-14 22:09:37',0),(28,4,'库存记录','C','/supply/inventory/record',NULL,'inventory:record','ListOutline',4,1,NULL,'2026-04-14 22:09:37',NULL,'2026-04-14 22:09:37',0),(29,0,'客户管理','M','/customer',NULL,NULL,'PeopleOutline',9,1,NULL,'2026-04-14 22:09:37',NULL,'2026-04-14 22:09:37',0),(30,29,'客户列表','C','/customer/list',NULL,'customer:list',NULL,1,1,NULL,'2026-04-14 22:09:37',NULL,'2026-04-14 22:09:37',0),(31,29,'地址管理','C','/customer/address',NULL,'customer:address',NULL,2,1,NULL,'2026-04-14 22:09:37',NULL,'2026-04-14 22:09:37',0),(32,3,'轮播图管理','C','/config/banner',NULL,'banner:list','ImagesOutline',4,1,NULL,'2026-04-14 22:09:37',NULL,'2026-04-14 22:09:37',0),(33,3,'AI配置','C','/config/ai',NULL,'ai:config','HardwareChipOutline',5,1,NULL,'2026-04-20 01:01:17',NULL,'2026-04-20 01:01:17',0);
/*!40000 ALTER TABLE `sys_menu` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_role`
--

DROP TABLE IF EXISTS `sys_role`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_role` (
  `role_id` bigint NOT NULL AUTO_INCREMENT,
  `role_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '角色名称',
  `role_key` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '角色标识(admin/designer)',
  `role_type` varchar(50) DEFAULT NULL COMMENT '角色类型: admin/designer/storekeeper/purchaser/finance/customer_service',
  `remark` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '备注',
  `create_by` bigint DEFAULT NULL,
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_by` bigint DEFAULT NULL,
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `del_flag` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`role_id`) USING BTREE,
  UNIQUE KEY `uk_role_key` (`role_key`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='角色表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_role`
--

LOCK TABLES `sys_role` WRITE;
/*!40000 ALTER TABLE `sys_role` DISABLE KEYS */;
INSERT INTO `sys_role` VALUES (1,'管理员','admin','admin','Full backend access',NULL,'2026-03-04 15:06:58',NULL,'2026-04-14 22:09:37',0),(2,'设计师','designer','designer','Order execution, request handling, portfolio and chat access',NULL,'2026-03-04 15:06:58',NULL,'2026-04-14 22:09:37',0),(3,'库管','storekeeper','storekeeper','负责物料管理和库存查看',NULL,'2026-04-14 22:09:37',NULL,'2026-04-14 22:09:37',0),(4,'采购','purchaser','purchaser','负责物料采购和库存管理',NULL,'2026-04-14 22:09:37',NULL,'2026-04-14 22:09:37',0),(5,'财务','finance','finance','负责订单收款和财务报表',NULL,'2026-04-14 22:09:37',NULL,'2026-04-14 22:09:37',0),(6,'客服','customer_service','customer_service','负责客户沟通和在线答疑',NULL,'2026-04-14 22:09:37',NULL,'2026-04-14 22:09:37',0);
/*!40000 ALTER TABLE `sys_role` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_role_menu`
--

DROP TABLE IF EXISTS `sys_role_menu`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_role_menu` (
  `role_id` bigint NOT NULL COMMENT '角色ID',
  `menu_id` bigint NOT NULL COMMENT '菜单ID',
  PRIMARY KEY (`role_id`,`menu_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='角色菜单关联表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_role_menu`
--

LOCK TABLES `sys_role_menu` WRITE;
/*!40000 ALTER TABLE `sys_role_menu` DISABLE KEYS */;
INSERT INTO `sys_role_menu` VALUES (1,1),(1,2),(1,3),(1,4),(1,5),(1,6),(1,7),(1,8),(1,9),(1,10),(1,11),(1,12),(1,13),(1,14),(1,15),(1,16),(1,17),(1,18),(1,19),(1,20),(1,21),(1,22),(1,23),(1,24),(1,25),(1,26),(1,27),(1,28),(1,29),(1,30),(1,31),(1,32),(1,33),(2,1),(2,2),(2,5),(2,6),(2,8),(2,9),(2,10),(2,16),(2,17),(2,23),(2,24),(2,25),(2,26),(3,4),(3,14),(3,27),(3,28),(4,4),(4,14),(4,27),(4,28),(5,1),(5,6),(5,9),(5,17),(6,23),(6,24),(6,29),(6,30),(6,31);
/*!40000 ALTER TABLE `sys_role_menu` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping routines for database 'design_studio'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed

-- MySQL dump 10.13  Distrib 8.4.8, for Win64 (x86_64)
--
-- Host: localhost    Database: design_studio
-- ------------------------------------------------------
-- Server version	8.4.8

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `ds_ai_config`
--

DROP TABLE IF EXISTS `ds_ai_config`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ds_ai_config` (
  `config_id` bigint NOT NULL AUTO_INCREMENT COMMENT 'Primary key',
  `provider_name` varchar(100) DEFAULT NULL COMMENT 'Provider name',
  `enabled` tinyint(1) DEFAULT '0' COMMENT 'Enabled flag',
  `api_url` varchar(500) DEFAULT NULL COMMENT 'OpenAI compatible endpoint',
  `api_key` varchar(500) DEFAULT NULL COMMENT 'API key',
  `model` varchar(100) DEFAULT NULL COMMENT 'Model name',
  `system_prompt` text COMMENT 'System prompt',
  `create_by` bigint DEFAULT NULL COMMENT 'Created by',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT 'Created time',
  `update_by` bigint DEFAULT NULL COMMENT 'Updated by',
  `update_time` datetime DEFAULT NULL COMMENT 'Updated time',
  `del_flag` tinyint(1) DEFAULT '0' COMMENT 'Logical delete flag',
  PRIMARY KEY (`config_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='AI customer service config';
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed

-- Sanitized seed data for ds_ai_config
INSERT INTO `ds_ai_config` VALUES (1, 'OpenAI Compatible', 1, 'https://api.example.com/v1/chat/completions', 'your-api-key', 'your-model-name', '你是ZeHana独立设计师工作室的智能客服，名为小Z。熟悉定制家具、软装设计、生产流程等问题。请用专业、友好的语气回复客户，长度适中。如遇到无法回答的问题，请引导客户联系人工客服。', 1, '2026-05-01 14:32:05', 1, '2026-05-01 14:32:05', 0);

-- MySQL dump 10.13  Distrib 8.4.8, for Win64 (x86_64)
--
-- Host: localhost    Database: design_studio
-- ------------------------------------------------------
-- Server version	8.4.8

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `sys_oper_log`
--

DROP TABLE IF EXISTS `sys_oper_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_oper_log` (
  `log_id` bigint NOT NULL AUTO_INCREMENT,
  `title` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '操作模块',
  `method` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '请求方法',
  `request_method` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'HTTP方法',
  `operator_id` bigint DEFAULT NULL COMMENT '操作人ID',
  `operator_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '操作人账号',
  `oper_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '请求URL',
  `oper_ip` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '请求IP',
  `oper_param` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci COMMENT '请求参数',
  `json_result` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci COMMENT '返回结果',
  `status` tinyint(1) DEFAULT NULL COMMENT '0=成功,1=失败',
  `error_msg` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci COMMENT '错误信息',
  `oper_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '操作时间',
  PRIMARY KEY (`log_id`) USING BTREE,
  KEY `idx_operator` (`operator_id`) USING BTREE,
  KEY `idx_oper_time` (`oper_time`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=219 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='操作日志表';
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed
