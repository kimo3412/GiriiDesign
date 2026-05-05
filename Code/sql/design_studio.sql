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
  `user_id` bigint NOT NULL COMMENT '鎵€灞炵敤鎴?,
  `receiver_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '鏀惰揣浜?,
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '鑱旂郴鐢佃瘽',
  `province` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '鐪?,
  `city` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '甯?,
  `district` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '鍖?,
  `detail_address` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '璇︾粏鍦板潃',
  `is_default` tinyint(1) DEFAULT '0' COMMENT '鏄惁榛樿',
  `create_by` bigint DEFAULT NULL,
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_by` bigint DEFAULT NULL,
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `del_flag` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`address_id`) USING BTREE,
  KEY `idx_user` (`user_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='瀹㈡埛鍦板潃琛?;
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
  `banner_id` bigint NOT NULL AUTO_INCREMENT COMMENT '杞挱鍥綢D',
  `title` varchar(100) NOT NULL COMMENT '杞挱鍥炬爣棰?,
  `image_url` varchar(500) NOT NULL COMMENT '鍥剧墖鍦板潃',
  `link_url` varchar(500) DEFAULT NULL COMMENT '璺宠浆閾炬帴锛堝彲閫夛級',
  `link_type` varchar(20) DEFAULT NULL COMMENT '璺宠浆绫诲瀷锛歱ortfolio/order/custom/null',
  `sort_order` int DEFAULT '0' COMMENT '鎺掑簭锛堣秺澶ц秺闈犲墠锛?,
  `status` tinyint(1) DEFAULT '1' COMMENT '鐘舵€侊細0绂佺敤 1鍚敤',
  `create_by` bigint DEFAULT NULL,
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_by` bigint DEFAULT NULL,
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `del_flag` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`banner_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='灏忕▼搴忛椤佃疆鎾浘';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ds_banner`
--

LOCK TABLES `ds_banner` WRITE;
/*!40000 ALTER TABLE `ds_banner` DISABLE KEYS */;
INSERT INTO `ds_banner` VALUES (1,'绀轰緥杞挱鍥?','/static/images/home-banner-couture.png',NULL,NULL,1,1,NULL,'2026-04-14 22:09:31',NULL,'2026-04-14 22:09:31',0),(2,'绀轰緥杞挱鍥?','/static/images/home-banner-leather.png',NULL,NULL,2,1,NULL,'2026-04-14 22:09:31',NULL,'2026-04-14 22:09:31',0);
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
  `bill_date` date NOT NULL COMMENT '璐﹀崟鏃ユ湡',
  `wx_transaction_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '寰俊浜ゆ槗鍙?,
  `local_payment_no` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '鏈湴娴佹按鍙?,
  `wx_amount` decimal(10,2) DEFAULT NULL COMMENT '寰俊璐﹀崟閲戦',
  `local_amount` decimal(10,2) DEFAULT NULL COMMENT '鏈湴璁板綍閲戦',
  `match_status` tinyint(1) DEFAULT NULL COMMENT '0=鍖归厤,1=閲戦涓嶇,2=鏈湴缂哄け,3=寰俊缂哄け',
  `handle_status` tinyint(1) DEFAULT '0' COMMENT '0=寰呭鐞?1=宸插鐞?,
  `handle_remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '澶勭悊澶囨敞',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`bill_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='瀵硅处璁板綍琛?;
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
  `order_id` bigint NOT NULL COMMENT '鎵€灞炶鍗?,
  `material_id` bigint NOT NULL COMMENT '鐗╂枡ID',
  `quantity` decimal(10,2) NOT NULL COMMENT '瀹為檯鐢ㄩ噺',
  `material_snapshot` json DEFAULT NULL COMMENT '鐗╂枡蹇収(鍚嶇О銆佸崟浠?',
  `is_allocated` tinyint(1) DEFAULT '0' COMMENT '鏄惁宸插嚭搴?,
  `del_flag` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`bom_item_id`) USING BTREE,
  KEY `idx_order` (`order_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='璁㈠崟BOM娓呭崟琛?;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ds_bom_item`
--

LOCK TABLES `ds_bom_item` WRITE;
/*!40000 ALTER TABLE `ds_bom_item` DISABLE KEYS */;
INSERT INTO `ds_bom_item` VALUES (1,7,1,3.50,'{\"sku\": \"FAB-LINEN-001\", \"name\": \"楂樼骇浜氶夯闈㈡枡锛堟祬绫宠壊锛塡", \"unit\": \"绫砛", \"unitPrice\": 120.0}',0,0),(2,7,6,2.00,'{\"sku\": \"FAB-COTTON-001\", \"name\": \"绾琛噷锛堢櫧鑹诧級\", \"unit\": \"绫砛", \"unitPrice\": 35.0}',0,0),(3,7,5,1.00,'{\"sku\": \"ACC-ZIP-001\", \"name\": \"YKK鎷夐摼锛?0cm锛塡", \"unit\": \"鏉", \"unitPrice\": 8.5}',0,0),(4,7,9,2.00,'{\"sku\": \"HW-SNAP-001\", \"name\": \"鏆楁墸\", \"unit\": \"濂梊", \"unitPrice\": 3.0}',0,0),(5,7,10,1.00,'{\"sku\": \"PKG-BOX-001\", \"name\": \"鍖呰鐩掞紙澶у彿锛塡", \"unit\": \"涓猏", \"unitPrice\": 15.0}',0,0),(6,8,1,3.50,'{\"sku\": \"FAB-LINEN-001\", \"name\": \"楂樼骇浜氶夯闈㈡枡锛堟祬绫宠壊锛塡", \"unit\": \"绫砛", \"unitPrice\": 120.0}',1,0),(7,8,6,2.00,'{\"sku\": \"FAB-COTTON-001\", \"name\": \"绾琛噷锛堢櫧鑹诧級\", \"unit\": \"绫砛", \"unitPrice\": 35.0}',1,0),(8,8,5,1.00,'{\"sku\": \"ACC-ZIP-001\", \"name\": \"YKK鎷夐摼锛?0cm锛塡", \"unit\": \"鏉", \"unitPrice\": 8.5}',1,0),(9,8,9,2.00,'{\"sku\": \"HW-SNAP-001\", \"name\": \"鏆楁墸\", \"unit\": \"濂梊", \"unitPrice\": 3.0}',1,0),(10,8,10,1.00,'{\"sku\": \"PKG-BOX-001\", \"name\": \"鍖呰鐩掞紙澶у彿锛塡", \"unit\": \"涓猏", \"unitPrice\": 15.0}',1,0);
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
  `name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '妯℃澘鍚嶇О',
  `category_id` bigint DEFAULT NULL COMMENT '鍏宠仈鍝佺被',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '澶囨敞',
  `create_by` bigint DEFAULT NULL,
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_by` bigint DEFAULT NULL,
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `del_flag` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`template_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='BOM妯℃澘琛?;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ds_bom_template`
--

LOCK TABLES `ds_bom_template` WRITE;
/*!40000 ALTER TABLE `ds_bom_template` DISABLE KEYS */;
INSERT INTO `ds_bom_template` VALUES (1,'鏃楄鏍囧噯BOM',1,'鏃楄绫绘湇瑁呯殑鏍囧噯鐗╂枡娓呭崟',NULL,'2026-03-17 15:11:05',NULL,'2026-03-17 15:11:05',0),(2,'鎵嬪伐閽卞寘BOM',2,'灏忓瀷鐨叿閽卞寘鐨勬爣鍑嗙墿鏂欐竻鍗?,NULL,'2026-03-17 15:11:05',NULL,'2026-03-17 15:11:05',0);
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
  `template_id` bigint NOT NULL COMMENT '鎵€灞炴ā鏉?,
  `material_id` bigint NOT NULL COMMENT '鐗╂枡ID',
  `quantity` decimal(10,2) NOT NULL COMMENT '鎵€闇€鏁伴噺',
  `del_flag` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`item_id`) USING BTREE,
  KEY `idx_template` (`template_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='BOM妯℃澘鏄庣粏琛?;
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
  `category_id` bigint NOT NULL AUTO_INCREMENT COMMENT '鍝佺被ID',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '鍝佺被鍚嶇О',
  `icon_url` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '鍥炬爣URL',
  `is_active` tinyint(1) DEFAULT '1' COMMENT '鏄惁鍚敤',
  `has_bom` tinyint(1) DEFAULT '0' COMMENT '鏄惁闇€瑕丅OM',
  `is_physical` tinyint(1) DEFAULT '1' COMMENT '鏄惁瀹炰綋浜у搧',
  `sort_order` int DEFAULT '0' COMMENT '鎺掑簭',
  `create_by` bigint DEFAULT NULL COMMENT '鍒涘缓浜?,
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  `update_by` bigint DEFAULT NULL COMMENT '鏇存柊浜?,
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '鏇存柊鏃堕棿',
  `del_flag` tinyint(1) DEFAULT '0' COMMENT '閫昏緫鍒犻櫎',
  PRIMARY KEY (`category_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='鍝佺被琛?;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ds_category`
--

LOCK TABLES `ds_category` WRITE;
/*!40000 ALTER TABLE `ds_category` DISABLE KEYS */;
INSERT INTO `ds_category` VALUES (1,'鏈嶈瀹氬埗',NULL,1,1,1,1,NULL,'2026-03-04 15:06:58',NULL,'2026-03-04 15:06:58',0),(2,'鎵嬪伐鐨叿',NULL,1,1,1,2,NULL,'2026-03-04 15:06:58',NULL,'2026-03-04 15:06:58',0),(3,'鏁板瓧鎻掔敾',NULL,1,0,0,3,NULL,'2026-03-04 15:06:58',NULL,'2026-03-04 15:06:58',0);
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
  `user_id` bigint NOT NULL COMMENT '鎵€灞炲鎴?,
  `sender_type` tinyint(1) NOT NULL COMMENT '0=瀹㈡埛,1=璁捐甯?,
  `sender_id` bigint NOT NULL COMMENT '鍙戦€佹柟ID',
  `content_type` tinyint(1) DEFAULT '0' COMMENT '0=鏂囨湰,1=鍥剧墖',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '娑堟伅鍐呭',
  `is_read` tinyint(1) DEFAULT '0' COMMENT '鏄惁宸茶',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `del_flag` tinyint(1) DEFAULT '0',
  `order_id` bigint DEFAULT NULL COMMENT '鍏宠仈璁㈠崟ID',
  PRIMARY KEY (`msg_id`) USING BTREE,
  KEY `idx_sender` (`sender_type`,`sender_id`) USING BTREE,
  KEY `idx_user` (`user_id`) USING BTREE,
  KEY `idx_order` (`order_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='鑱婂ぉ璁板綍琛?;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ds_chat_message`
--

LOCK TABLES `ds_chat_message` WRITE;
/*!40000 ALTER TABLE `ds_chat_message` DISABLE KEYS */;
INSERT INTO `ds_chat_message` VALUES (1,1,0,1,0,'hallop',1,'2026-04-06 15:09:44',0,NULL),(2,1,1,2,0,'1',1,'2026-04-06 15:11:24',0,NULL),(3,1,0,1,0,'鍏虫敞',1,'2026-04-09 19:56:14',0,NULL),(4,1,0,1,0,'浣犲ソ',1,'2026-04-09 21:36:36',0,NULL),(5,1,1,1,0,'濂?,1,'2026-04-09 21:36:43',0,NULL),(6,1,0,1,0,'璁㈠崟6鐨勫挩璇㈡秷鎭?,1,'2026-04-10 23:52:00',0,6),(7,1,1,2,0,'濂界殑锛屾垜鏉ュ鐞嗚鍗?',0,'2026-04-10 23:52:00',0,6),(8,1,0,1,0,'璁㈠崟7鏈夐棶棰樻兂闂?,1,'2026-04-10 23:52:00',0,7),(9,1,1,1,0,'璁㈠崟6鐨勬渶鏂拌繘灞曞浣曪紵',0,'2026-04-10 23:57:14',0,6),(10,1,0,1,0,'123',1,'2026-04-11 18:00:41',0,NULL);
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
  `category_id` bigint NOT NULL COMMENT '鎵€灞炲搧绫?,
  `label` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '瀛楁鏄剧ず鍚?,
  `field_key` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '瀛楁閿悕',
  `field_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '鎺т欢绫诲瀷: text/number/select/date/image',
  `unit` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '鍗曚綅',
  `options` json DEFAULT NULL COMMENT '閫夐」鍒楄〃(select鐢?',
  `placeholder` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '杈撳叆鎻愮ず',
  `is_required` tinyint(1) DEFAULT '0' COMMENT '鏄惁蹇呭～',
  `sort_order` int DEFAULT '0' COMMENT '鎺掑簭',
  `create_by` bigint DEFAULT NULL,
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_by` bigint DEFAULT NULL,
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `del_flag` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`field_id`) USING BTREE,
  KEY `idx_category` (`category_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='鍔ㄦ€佸瓧娈靛畾涔夎〃';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ds_custom_field`
--

LOCK TABLES `ds_custom_field` WRITE;
/*!40000 ALTER TABLE `ds_custom_field` DISABLE KEYS */;
INSERT INTO `ds_custom_field` VALUES (1,1,'鑳稿洿','chest','number','cm',NULL,'璇疯緭鍏ヨ兏鍥村昂瀵?,1,1,NULL,'2026-03-04 15:06:58',NULL,'2026-03-04 15:06:58',0),(2,1,'鑵板洿','waist','number','cm',NULL,'璇疯緭鍏ヨ叞鍥村昂瀵?,1,2,NULL,'2026-03-04 15:06:58',NULL,'2026-03-04 15:06:58',0),(3,1,'鑲╁','shoulder','number','cm',NULL,'璇疯緭鍏ヨ偐瀹藉昂瀵?,1,3,NULL,'2026-03-04 15:06:58',NULL,'2026-03-04 15:06:58',0),(4,1,'琛ｉ暱','length','number','cm',NULL,'璇疯緭鍏ヨ。闀?,0,4,NULL,'2026-03-04 15:06:58',NULL,'2026-03-04 15:06:58',0),(5,1,'闈㈡枡鍋忓ソ','fabric_type','select',NULL,'[\"绾\", \"浜氶夯\", \"涓濈桓\", \"缇婃瘺\", \"娣风汉\"]','璇烽€夋嫨闈㈡枡',0,5,NULL,'2026-03-04 15:06:58',NULL,'2026-03-04 15:06:58',0),(6,2,'鐨潻绫诲瀷','leather_type','select',NULL,'[\"鐗涚毊\", \"缇婄毊\", \"槌勯奔鐨甛", \"妞嶉灒闈‐"]','璇烽€夋嫨鐨潻',1,1,NULL,'2026-03-04 15:06:58',NULL,'2026-03-04 15:06:58',0),(7,2,'棰滆壊','color','text',NULL,NULL,'鏈熸湜鐨勯鑹?,1,2,NULL,'2026-03-04 15:06:58',NULL,'2026-03-04 15:06:58',0),(8,2,'灏哄瑙勬牸','size_spec','text',NULL,NULL,'濡傦細闀?0cm脳瀹?5cm',0,3,NULL,'2026-03-04 15:06:58',NULL,'2026-03-04 15:06:58',0),(9,3,'鐢婚','art_style','select',NULL,'[\"鏃ョ郴\", \"娆х編\", \"姘村僵椋嶾", \"鎵佸钩鍖朶", \"鍐欏疄\"]','璇烽€夋嫨鐢婚',1,1,NULL,'2026-03-04 15:06:58',NULL,'2026-03-04 15:06:58',0),(10,3,'鍒嗚鲸鐜?,'resolution','select',NULL,'[\"1080脳1080\", \"1920脳1080\", \"3000脳3000\", \"鑷畾涔塡"]','璇烽€夋嫨鍒嗚鲸鐜?,0,2,NULL,'2026-03-04 15:06:58',NULL,'2026-03-04 15:06:58',0),(11,3,'鐢ㄩ€?,'usage','text',NULL,NULL,'濡傦細澶村儚銆佹捣鎶ャ€佹彃鍥剧瓑',0,3,NULL,'2026-03-04 15:06:58',NULL,'2026-03-04 15:06:58',0);
/*!40000 ALTER TABLE `ds_custom_field` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ds_designer_category`
--

DROP TABLE IF EXISTS `ds_designer_category`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ds_designer_category` (
  `admin_id` bigint NOT NULL COMMENT '璁捐甯圛D',
  `category_id` bigint NOT NULL COMMENT '鍝佺被ID',
  PRIMARY KEY (`admin_id`,`category_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='璁捐甯?鍝佺被鍏宠仈琛?;
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
  `name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '鐗╂枡鍚嶇О',
  `sku` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '鐗╂枡缂栫爜',
  `category` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '鐗╂枡鍒嗙被(闈㈡枡/杈呮枡/浜旈噾)',
  `unit` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '鍗曚綅(绫?涓?kg)',
  `unit_price` decimal(10,2) DEFAULT NULL COMMENT '鍗曚环',
  `stock` decimal(10,2) DEFAULT '0.00' COMMENT '褰撳墠搴撳瓨',
  `warning_stock` decimal(10,2) DEFAULT NULL COMMENT '棰勮闃堝€?,
  `image_url` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '鐗╂枡鍥剧墖',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '澶囨敞',
  `version` int DEFAULT '0' COMMENT '鐗堟湰鍙?涔愯閿?',
  `create_by` bigint DEFAULT NULL,
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_by` bigint DEFAULT NULL,
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `del_flag` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`material_id`) USING BTREE,
  UNIQUE KEY `uk_sku` (`sku`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='鐗╂枡琛?;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ds_material`
--

LOCK TABLES `ds_material` WRITE;
/*!40000 ALTER TABLE `ds_material` DISABLE KEYS */;
INSERT INTO `ds_material` VALUES (1,'楂樼骇浜氶夯闈㈡枡锛堟祬绫宠壊锛?,'FAB-LINEN-001','闈㈡枡','绫?,120.00,56.50,10.00,NULL,'浼樿川浜氶夯锛岄€傚悎鏄ュ鏈嶈',4,NULL,'2026-03-17 15:11:05',1,'2026-03-17 15:11:05',0),(2,'鐪熶笣闈㈡枡锛堥妲熻壊锛?,'FAB-SILK-001','闈㈡枡','绫?,280.00,30.00,5.00,NULL,'100%妗戣殨涓?,0,NULL,'2026-03-17 15:11:05',NULL,'2026-03-17 15:11:05',0),(3,'妞嶉灒闈╋紙妫曡壊锛?,'FAB-LEATHER-001','闈㈡枡','寮?,350.00,15.00,3.00,NULL,'鎰忓ぇ鍒╄繘鍙ｆ闉ｉ潻',0,NULL,'2026-03-17 15:11:05',NULL,'2026-03-17 15:11:05',0),(4,'槌勯奔鐨紙榛戣壊锛?,'FAB-CROC-001','闈㈡枡','寮?,1200.00,2.00,2.00,NULL,'绋€鏈夐硠楸肩毊锛岄渶杩涘彛',0,NULL,'2026-03-17 15:11:05',NULL,'2026-03-17 15:11:05',0),(5,'YKK鎷夐摼锛?0cm锛?,'ACC-ZIP-001','杈呮枡','鏉?,8.50,199.00,50.00,NULL,'YKK閲戝睘鎷夐摼',3,NULL,'2026-03-17 15:11:05',1,'2026-03-17 15:11:05',0),(6,'绾琛噷锛堢櫧鑹诧級','FAB-COTTON-001','闈㈡枡','绫?,35.00,98.00,20.00,NULL,'绾閲岃‖',3,NULL,'2026-03-17 15:11:05',1,'2026-03-17 15:11:05',0),(7,'D鍨嬩簲閲戞墸','HW-DRING-001','浜旈噾浠?,'涓?,5.00,500.00,100.00,NULL,'涓嶉攬閽鍨嬬幆',0,NULL,'2026-03-17 15:11:05',NULL,'2026-03-17 15:11:05',0),(8,'鎵嬬紳铚＄嚎锛堟鑹诧級','ACC-WAX-001','杈呮枡','鍗?,25.00,80.00,20.00,NULL,'鎵嬪伐鐨叿涓撶敤',0,NULL,'2026-03-17 15:11:05',NULL,'2026-03-17 15:11:05',0),(9,'鏆楁墸','HW-SNAP-001','浜旈噾浠?,'濂?,3.00,298.00,60.00,NULL,'纾佸惛鏆楁墸',3,NULL,'2026-03-17 15:11:05',1,'2026-03-17 15:11:05',0),(10,'鍖呰鐩掞紙澶у彿锛?,'PKG-BOX-001','杈呮枡','涓?,15.00,99.00,20.00,NULL,'楂樼瀹氬埗鍖呰鐩?,3,NULL,'2026-03-17 15:11:05',1,'2026-03-17 15:11:05',0);
/*!40000 ALTER TABLE `ds_material` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ds_notification`
--

DROP TABLE IF EXISTS `ds_notification`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ds_notification` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '涓婚敭',
  `user_id` bigint NOT NULL COMMENT '鎺ユ敹鐢ㄦ埛ID',
  `title` varchar(100) NOT NULL COMMENT '閫氱煡鏍囬',
  `content` text COMMENT '閫氱煡鍐呭',
  `type` varchar(30) DEFAULT NULL COMMENT '閫氱煡绫诲瀷: order_status/payment/workbench/system',
  `related_id` bigint DEFAULT NULL COMMENT '鍏宠仈ID锛屽璁㈠崟ID',
  `related_type` varchar(30) DEFAULT NULL COMMENT '鍏宠仈绫诲瀷: order/request',
  `is_read` tinyint(1) DEFAULT '0' COMMENT '鏄惁宸茶 (0=鏈, 1=宸茶)',
  `create_by` bigint DEFAULT NULL COMMENT '鍒涘缓浜篒D',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  `update_by` bigint DEFAULT NULL COMMENT '鏇存柊浜篒D',
  `update_time` datetime DEFAULT NULL COMMENT '鏇存柊鏃堕棿',
  `del_flag` tinyint(1) DEFAULT '0' COMMENT '閫昏緫鍒犻櫎鏍囪',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_notification_user_id` (`user_id`) USING BTREE,
  KEY `idx_notification_user_read` (`user_id`,`is_read`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='绔欏唴閫氱煡琛?;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ds_notification`
--

LOCK TABLES `ds_notification` WRITE;
/*!40000 ALTER TABLE `ds_notification` DISABLE KEYS */;
INSERT INTO `ds_notification` VALUES (1,1,'瀹氶噾鏀粯鎴愬姛','鎮ㄥ凡鎴愬姛鏀粯瀹氶噾 楼10.00锛岃鍗曟寮忚繘鍏ョ敓浜?,'payment',8,'order',0,1,'2026-04-30 13:15:06',1,'2026-04-30 13:15:06',0),(2,1,'璁㈠崟杩涘害鏇存柊','鎮ㄧ殑璁㈠崟宸叉帹杩涜嚦鏂拌妭鐐癸細闈㈡枡閲囪喘','workbench',9,'order',0,1,'2026-05-01 14:33:15',1,'2026-05-01 14:33:15',0);
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
  `order_sn` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '璁㈠崟缂栧彿',
  `user_id` bigint NOT NULL COMMENT '瀹㈡埛ID',
  `category_id` bigint NOT NULL COMMENT '鍝佺被ID',
  `designer_id` bigint DEFAULT NULL COMMENT '鎸囨淳鐨勮璁″笀ID',
  `current_step_id` bigint DEFAULT NULL COMMENT '褰撳墠宸ヤ綔娴佽妭鐐?,
  `status` tinyint(1) DEFAULT '0' COMMENT '0=寰呮敮浠?1=鐢熶骇涓?2=寰呭彂璐?3=寰呮敹璐?4=宸插畬鎴?5=宸插彇娑?,
  `custom_data_snapshot` json DEFAULT NULL COMMENT '瀹氬埗鍙傛暟蹇収',
  `total_amount` decimal(10,2) DEFAULT NULL COMMENT '鎬婚噾棰?,
  `prepay_amount` decimal(10,2) DEFAULT NULL COMMENT '棰勪粯娆?,
  `paid_amount` decimal(10,2) DEFAULT '0.00' COMMENT '宸叉敮浠橀噾棰?,
  `expected_date` date DEFAULT NULL COMMENT '棰勮浜や粯鏃ユ湡',
  `address_snapshot` json DEFAULT NULL COMMENT '鏀惰揣鍦板潃蹇収',
  `remark` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '澶囨敞',
  `is_blocked` tinyint(1) DEFAULT '0' COMMENT '鏄惁闃诲',
  `block_reason` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '闃诲鍘熷洜',
  `cancel_reason` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '鍙栨秷鍘熷洜',
  `delay_reason` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '寤舵湡鍘熷洜',
  `version` int DEFAULT '0' COMMENT '鐗堟湰鍙?涔愯閿?',
  `create_by` bigint DEFAULT NULL,
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_by` bigint DEFAULT NULL,
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `finish_time` datetime DEFAULT NULL COMMENT '瀹屾垚鏃堕棿',
  `delivery_time` datetime DEFAULT NULL COMMENT '鍙戣揣鏃堕棿',
  `confirm_time` datetime DEFAULT NULL COMMENT '纭瀹屾垚鏃堕棿',
  `del_flag` tinyint(1) DEFAULT '0',
  `bom_template_id` bigint DEFAULT NULL COMMENT '鍏宠仈BOM妯℃澘',
  `material_cost` decimal(10,2) DEFAULT '0.00' COMMENT '鐗╂枡鎴愭湰',
  PRIMARY KEY (`order_id`) USING BTREE,
  UNIQUE KEY `uk_order_sn` (`order_sn`) USING BTREE,
  KEY `idx_user_status` (`user_id`,`status`) USING BTREE,
  KEY `idx_designer` (`designer_id`) USING BTREE,
  KEY `idx_create_time` (`create_time`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='璁㈠崟涓昏〃';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ds_order`
--

LOCK TABLES `ds_order` WRITE;
/*!40000 ALTER TABLE `ds_order` DISABLE KEYS */;
INSERT INTO `ds_order` VALUES (1,'DS202603081601001',3,1,2,2,1,'{\"chest\": \"92\", \"waist\": \"72\", \"length\": \"130\", \"shoulder\": \"40\", \"fabric_type\": \"浜氶夯\"}',3500.00,1750.00,1750.00,'2026-04-18',NULL,'鏀硅壇姹夋湇锛屽鎴疯姹傚鏉剧増鍨?,1,'澶╂皵鍘熷洜',NULL,'????????',11,NULL,'2026-03-08 16:05:00',1,'2026-04-11 18:05:24',NULL,NULL,NULL,0,NULL,0.00),(2,'DS202603071102001',2,3,3,12,1,'{\"usage\": \"鍏徃鍝佺墝Logo\", \"art_style\": \"鎵佸钩鍖朶", \"resolution\": \"3000脳3000\"}',800.00,400.00,400.00,'2026-03-25',NULL,'Logo璁捐锛岄渶瑕佷笁涓閫夋柟妗?,0,NULL,NULL,NULL,3,NULL,'2026-03-07 11:05:00',1,'2026-04-10 11:29:04',NULL,NULL,NULL,0,NULL,0.00),(3,'DS202603151400001',1,2,2,8,4,'{\"color\": \"榛戣壊\", \"size_spec\": \"闀?5cm脳瀹?5cm\", \"leather_type\": \"槌勯奔鐨甛"}',5800.00,2900.00,2900.00,'2026-04-20',NULL,'槌勯奔鐨墜鎷垮寘锛岄珮绔畾鍒?,1,'槌勯奔鐨師鏂欑己璐э紝棰勮3澶╁埌璐?,NULL,NULL,4,NULL,'2026-03-15 14:00:00',1,'2026-04-10 21:06:20','2026-04-10 21:06:20','2026-04-10 21:04:19','2026-04-10 21:06:20',0,NULL,0.00),(4,'DS202602201000001',1,3,3,16,4,'{\"usage\": \"涓汉鏀惰棌\", \"art_style\": \"姘村僵椋嶾", \"resolution\": \"1920脳1080\"}',600.00,300.00,600.00,'2026-03-05',NULL,'姘村僵椋庢櫙鐢?,0,NULL,NULL,NULL,0,NULL,'2026-02-20 10:00:00',NULL,'2026-04-09 21:07:17','2026-03-03 18:00:00',NULL,NULL,0,NULL,0.00),(5,'DS202604051756345882',1,1,2,NULL,1,'{\"chest\": \"1\", \"waist\": \"2\", \"length\": \"4\", \"shoulder\": \"3\"}',800.00,300.00,0.00,'2026-04-29',NULL,'',0,NULL,NULL,NULL,0,1,'2026-04-05 17:56:34',1,'2026-04-05 17:56:34',NULL,NULL,NULL,0,NULL,0.00),(6,'DS202604092137346349',1,1,2,1,5,'{\"chest\": \"20\", \"waist\": \"30\", \"shoulder\": \"20\"}',100.00,10.00,0.00,'2026-04-09',NULL,'',0,'13','??????????',NULL,5,1,'2026-04-09 21:37:35',1,'2026-04-10 21:03:33','2026-04-10 21:03:33',NULL,NULL,0,NULL,0.00),(7,'DS202604102239321777',1,1,2,1,5,'{\"chest\": \"88\", \"waist\": \"68\", \"length\": \"120\", \"shoulder\": \"38\", \"fabric_type\": \"涓濈桓\"}',3500.00,1500.00,1500.00,'2026-05-20',NULL,'BOM娴嬭瘯杞崟',0,NULL,'娴嬭瘯鍙栨秷-褰掕繕搴撳瓨',NULL,3,1,'2026-04-10 22:39:33',1,'2026-04-10 22:57:01','2026-04-10 22:57:01',NULL,NULL,0,1,519.50),(8,'DS202604111743293930',1,1,2,1,1,'{\"chest\": \"123\", \"waist\": \"32\", \"length\": \"123\", \"shoulder\": \"45\"}',100.00,10.00,10.00,NULL,NULL,'',0,NULL,NULL,NULL,2,1,'2026-04-11 17:43:29',1,'2026-04-30 13:15:06',NULL,NULL,NULL,0,1,519.50),(9,'DS202604111801332055',1,1,2,2,1,'{\"chest\": \"123\", \"waist\": \"12\", \"length\": \"3\", \"shoulder\": \"12\"}',1000.00,10.00,10.00,'2026-04-25',NULL,'',0,NULL,NULL,NULL,2,1,'2026-04-11 18:01:33',1,'2026-05-01 14:33:15',NULL,NULL,NULL,0,NULL,0.00);
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
  `order_id` bigint NOT NULL COMMENT '鎵€灞炶鍗?,
  `step_id` bigint NOT NULL COMMENT '瀵瑰簲宸ヤ綔娴佽妭鐐?,
  `description` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '杩涘害鎻忚堪',
  `image_urls` json DEFAULT NULL COMMENT '杩涘害鍥剧墖',
  `form_data` json DEFAULT NULL COMMENT '鑺傜偣琛ㄥ崟濉啓鏁版嵁',
  `operator_id` bigint DEFAULT NULL COMMENT '鎿嶄綔浜篒D',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `del_flag` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`progress_id`) USING BTREE,
  KEY `idx_order` (`order_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=49 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='璁㈠崟杩涘害琛?;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ds_order_progress`
--

LOCK TABLES `ds_order_progress` WRITE;
/*!40000 ALTER TABLE `ds_order_progress` DISABLE KEYS */;
INSERT INTO `ds_order_progress` VALUES (1,1,1,'瀹㈡埛闇€姹傚凡纭锛屾敼鑹眽鏈嶅鏉剧増鍨嬶紝浜氶夯闈㈡枡',NULL,NULL,2,'2026-03-08 16:10:00',0),(2,1,2,'鐗归€夐珮鍝佽川浜氶夯闈㈡枡宸查噰璐埌浣嶏紝棰滆壊涓烘祬绫宠壊',NULL,NULL,2,'2026-03-10 09:00:00',0),(3,1,3,'寮€濮嬭鍓紝鎸夌収瀹㈡埛灏哄鏀炬牱',NULL,NULL,2,'2026-03-12 14:00:00',0),(4,2,12,'闇€姹傚凡纭锛屽鎴疯姹傛墎骞冲寲椋庢牸Logo',NULL,NULL,3,'2026-03-07 11:10:00',0),(5,2,13,'鑽夌瀹屾垚锛屽凡鎻愪氦3涓閫夋柟妗堢粰瀹㈡埛',NULL,NULL,3,'2026-03-09 16:00:00',0),(6,2,14,'瀹㈡埛閫夋嫨鏂规B锛屽紑濮嬬嚎绋跨粏鍖?,NULL,NULL,3,'2026-03-11 10:00:00',0),(7,4,12,'闇€姹傜‘璁ゅ畬姣?,NULL,NULL,3,'2026-02-20 10:10:00',0),(8,4,13,'鑽夌瀹屾垚',NULL,NULL,3,'2026-02-22 15:00:00',0),(9,4,14,'绾跨宸插畾绋?,NULL,NULL,3,'2026-02-25 11:00:00',0),(10,4,15,'涓婅壊瀹屾垚锛屾渶缁堢宸插嚭',NULL,NULL,3,'2026-02-28 17:00:00',0),(11,4,16,'瀹㈡埛楠屾敹閫氳繃锛屼氦浠樺畬鎴?,NULL,NULL,3,'2026-03-03 18:00:00',0),(12,3,8,'閮ㄥ垎',NULL,NULL,1,'2026-03-17 15:16:03',0),(13,1,3,'宸ヤ綔鍙版帴鍙ｈ仈璋冭褰?,NULL,NULL,1,'2026-04-09 21:13:19',0),(14,1,3,'upload-ok','\"/uploads/321f10cac04241249a1c608ce6c9b048.png\"',NULL,1,'2026-04-09 21:33:42',0),(15,6,1,'1',NULL,NULL,1,'2026-04-09 21:37:59',0),(16,6,1,'璁㈠崟宸查樆濉烇細11',NULL,NULL,2,'2026-04-09 21:42:51',0),(17,6,1,'璁㈠崟宸茶В闄ら樆濉?,NULL,NULL,2,'2026-04-09 21:43:14',0),(18,6,1,'璁㈠崟宸查樆濉烇細13',NULL,NULL,2,'2026-04-09 21:43:17',0),(19,6,1,'璁㈠崟宸茶В闄ら樆濉?,NULL,NULL,2,'2026-04-09 21:43:22',0),(20,1,2,'rollback-api-test',NULL,NULL,1,'2026-04-10 10:36:27',0),(21,1,3,'rollback-restore',NULL,NULL,1,'2026-04-10 10:36:28',0),(22,1,2,'閫€鍥炶嚦鑺傜偣锛氶潰鏂欓噰璐?,NULL,NULL,1,'2026-04-10 10:48:26',0),(23,2,12,'鑱旇皟锛氭寚瀹氶€€鍥炲埌闇€姹傜‘璁?,NULL,NULL,1,'2026-04-10 11:26:40',0),(24,2,13,'鑱旇皟锛氭帹杩涘埌鑽夌鏋勫浘',NULL,NULL,1,'2026-04-10 11:29:04',0),(25,2,12,'鑱旇皟锛氶€€鍥炲埌闇€姹傜‘璁?,NULL,NULL,1,'2026-04-10 11:29:04',0),(26,1,3,'鎺ㄨ繘鑷宠妭鐐癸細瑁佸壀',NULL,NULL,1,'2026-04-10 11:34:08',0),(27,1,2,'閫€鍥炶嚦鑺傜偣锛氶潰鏂欓噰璐?,NULL,NULL,1,'2026-04-10 11:34:13',0),(28,1,1,'閫€鍥炶嚦鑺傜偣锛氶渶姹傜‘璁?,NULL,NULL,1,'2026-04-10 11:34:30',0),(29,6,1,'????????',NULL,'{\"chest\": 88, \"waist\": 66}',1,'2026-04-10 15:43:40',0),(30,6,1,'璁㈠崟宸插彇娑堬細??????????',NULL,NULL,1,'2026-04-10 21:03:33',0),(31,1,1,'璁㈠崟寤舵湡鑷?2026-04-18锛屽師鍥狅細????????',NULL,NULL,1,'2026-04-10 21:03:33',0),(32,3,8,'??????',NULL,NULL,1,'2026-04-10 21:04:19',0),(33,3,8,'瀹㈡埛宸茬‘璁ゆ敹璐э紝璁㈠崟宸插畬鎴?,NULL,NULL,1,'2026-04-10 21:06:20',0),(34,7,1,'瀹㈡埛宸叉敮浠樺畾閲戯細楼1500.00',NULL,NULL,1,'2026-04-10 22:56:34',0),(35,7,1,'璁㈠崟宸插彇娑堬細娴嬭瘯鍙栨秷-褰掕繕搴撳瓨',NULL,NULL,1,'2026-04-10 22:57:01',0),(36,1,2,'鎺ㄨ繘鑷宠妭鐐癸細闈㈡枡閲囪喘',NULL,'{\"chest\": \"92\", \"waist\": \"72\"}',1,'2026-04-11 17:17:35',0),(37,1,1,'閫€鍥炶嚦鑺傜偣锛氶渶姹傜‘璁?,NULL,NULL,1,'2026-04-11 18:02:52',0),(38,1,2,'瀹屾垚闇€姹?,NULL,'{\"chest\": \"92\", \"waist\": \"72\"}',1,'2026-04-11 18:04:27',0),(39,1,2,'璁㈠崟宸查樆濉烇細澶╂皵鍘熷洜',NULL,NULL,1,'2026-04-11 18:05:24',0),(40,9,1,'瀹㈡埛宸叉敮浠樺畾閲戯細楼10.00',NULL,NULL,1,'2026-04-11 18:08:26',0),(41,9,1,NULL,NULL,'{\"chest\": \"123\", \"waist\": \"12\"}',1,'2026-04-21 00:28:54',0),(42,9,1,NULL,NULL,'{\"chest\": \"123\", \"waist\": \"12\"}',1,'2026-04-21 00:28:56',0),(43,9,1,NULL,NULL,'{\"chest\": \"123\", \"waist\": \"12\"}',1,'2026-04-21 00:28:58',0),(44,9,1,NULL,NULL,'{\"chest\": \"123\", \"waist\": \"12\"}',1,'2026-04-21 00:29:03',0),(45,9,1,NULL,NULL,'{\"chest\": \"123\", \"waist\": \"12\"}',1,'2026-04-21 00:40:00',0),(46,8,1,'瀹㈡埛宸叉敮浠樺畾閲戯細楼10.00',NULL,NULL,1,'2026-04-30 13:15:06',0),(47,9,1,'灏哄宸茬‘璁わ細鑳稿洿90cm锛岃叞鍥?5cm锛屽噯澶囪繘鍏ヤ笅涓€闃舵銆?,NULL,'{\"chest\": 90, \"waist\": 75}',1,'2026-05-01 14:32:49',0),(48,9,2,'鎺ㄨ繘鑷宠妭鐐癸細闈㈡枡閲囪喘',NULL,'{\"chest\": 90, \"waist\": 75}',1,'2026-05-01 14:33:15',0);
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
  `user_id` bigint NOT NULL COMMENT '鎻愪氦瀹㈡埛',
  `category_id` bigint NOT NULL COMMENT '瀹氬埗鍝佺被',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci COMMENT '瀹㈡埛鏂囧瓧鎻忚堪',
  `image_urls` json DEFAULT NULL COMMENT '鍙傝€冨浘鐗?JSON鏁扮粍)',
  `custom_data` json DEFAULT NULL COMMENT '鍔ㄦ€佽〃鍗曟暟鎹?,
  `status` tinyint(1) DEFAULT '0' COMMENT '0=寰呭鐞?1=宸茶浆鍗?2=宸插叧闂?,
  `close_reason` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '鍏抽棴鍘熷洜',
  `linked_order_id` bigint DEFAULT NULL COMMENT '杞寲鍚庣殑璁㈠崟ID',
  `create_by` bigint DEFAULT NULL,
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_by` bigint DEFAULT NULL,
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `del_flag` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`request_id`) USING BTREE,
  KEY `idx_user` (`user_id`) USING BTREE,
  KEY `idx_status` (`status`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='璁㈠崟鎰忓悜琛?;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ds_order_request`
--

LOCK TABLES `ds_order_request` WRITE;
/*!40000 ALTER TABLE `ds_order_request` DISABLE KEYS */;
INSERT INTO `ds_order_request` VALUES (1,1,1,'鎯冲畾鍒朵竴浠舵棗琚嶏紝鐢ㄤ簬鍙傚姞鏈嬪弸濠氱ぜ',NULL,'{\"chest\": \"88\", \"waist\": \"68\", \"length\": \"120\", \"shoulder\": \"38\", \"fabric_type\": \"涓濈桓\"}',1,NULL,7,NULL,'2026-03-10 10:00:00',1,'2026-03-17 15:11:05',0),(2,2,2,'鎯冲仛涓€涓墜宸ョ毊闈╅挶鍖咃紝閫佺粰鐢锋湅鍙嬪仛鐢熸棩绀肩墿',NULL,'{\"color\": \"娣辨鑹瞈", \"size_spec\": \"闀?0cm脳瀹?0cm\", \"leather_type\": \"妞嶉灒闈‐"}',0,NULL,NULL,NULL,'2026-03-11 14:30:00',NULL,'2026-03-17 15:11:05',0),(3,1,3,'闇€瑕佷竴寮犳棩绯婚鏍肩殑澶村儚鎻掔敾',NULL,'{\"usage\": \"绀句氦濯掍綋澶村儚\", \"art_style\": \"鏃ョ郴\", \"resolution\": \"1080脳1080\"}',0,NULL,NULL,NULL,'2026-03-12 09:15:00',NULL,'2026-03-17 15:11:05',0),(4,3,1,'闇€瑕佷竴濂楁敼鑹眽鏈?,NULL,'{\"chest\": \"92\", \"waist\": \"72\", \"length\": \"130\", \"shoulder\": \"40\", \"fabric_type\": \"浜氶夯\"}',1,NULL,1,NULL,'2026-03-08 16:00:00',NULL,'2026-03-17 15:11:05',0),(5,2,3,'璁捐鍏徃 Logo 鎵佸钩鍖栨彃鐢?,NULL,'{\"usage\": \"鍏徃鍝佺墝Logo\", \"art_style\": \"鎵佸钩鍖朶", \"resolution\": \"3000脳3000\"}',1,NULL,2,NULL,'2026-03-07 11:00:00',NULL,'2026-03-17 15:11:05',0),(6,3,2,'澶嶅彜椋庢牸鎵嬫彁鍖?,NULL,'{\"color\": \"閰掔孩鑹瞈", \"size_spec\": \"闀?0cm脳瀹?0cm脳楂?5cm\", \"leather_type\": \"鐗涚毊\"}',2,'瀹㈡埛鍙栨秷锛岄绠椾笉瓒?,NULL,NULL,'2026-03-05 08:45:00',NULL,'2026-03-17 15:11:05',0),(7,1,1,'','[]','{\"chest\": \"123\", \"waist\": \"32\", \"length\": \"123\", \"shoulder\": \"45\"}',1,NULL,8,1,'2026-04-05 17:45:08',1,'2026-04-05 17:45:08',0),(8,1,1,'','[]','{\"chest\": \"1\", \"waist\": \"2\", \"length\": \"4\", \"shoulder\": \"3\"}',1,NULL,5,1,'2026-04-05 17:46:11',1,'2026-04-05 17:46:11',0),(9,1,1,'','[]','{\"chest\": \"20\", \"waist\": \"30\", \"shoulder\": \"20\"}',1,NULL,6,1,'2026-04-09 21:37:09',1,'2026-04-09 21:37:09',0),(10,1,1,'','[]','{\"chest\": \"123\", \"waist\": \"12\", \"length\": \"3\", \"shoulder\": \"12\"}',1,NULL,9,1,'2026-04-11 18:01:09',1,'2026-04-11 18:01:09',0);
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
  `payment_no` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '绯荤粺鏀粯娴佹按鍙?,
  `order_id` bigint NOT NULL COMMENT '鍏宠仈璁㈠崟',
  `user_id` bigint NOT NULL COMMENT '鏀粯鐢ㄦ埛',
  `payment_type` tinyint(1) NOT NULL COMMENT '1=棰勪粯娆?2=灏炬',
  `amount` decimal(10,2) NOT NULL COMMENT '鏀粯閲戦',
  `wx_transaction_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '寰俊鏀粯浜ゆ槗鍙?,
  `wx_prepay_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '寰俊棰勬敮浠業D',
  `status` tinyint(1) DEFAULT '0' COMMENT '0=寰呮敮浠?1=鎴愬姛,2=澶辫触,3=宸插叧闂?,
  `pay_time` datetime DEFAULT NULL COMMENT '瀹為檯鏀粯鏃堕棿',
  `expire_time` datetime DEFAULT NULL COMMENT '鏀粯杩囨湡鏃堕棿',
  `notify_data` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci COMMENT '寰俊鍥炶皟鍘熷鏁版嵁',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `del_flag` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`payment_id`) USING BTREE,
  UNIQUE KEY `uk_payment_no` (`payment_no`) USING BTREE,
  KEY `idx_order` (`order_id`) USING BTREE,
  KEY `idx_user` (`user_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='鏀粯娴佹按琛?;
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
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '浣滃搧鏍囬',
  `category_id` bigint DEFAULT NULL COMMENT '鍏宠仈鍝佺被',
  `cover_url` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '灏侀潰鍥?,
  `image_urls` json NOT NULL COMMENT '鍥剧墖鍒楄〃(JSON鏁扮粍)',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci COMMENT '瀵屾枃鏈弿杩?,
  `status` tinyint(1) DEFAULT '0' COMMENT '0=鑽夌,1=鍙戝竷',
  `view_count` int DEFAULT '0' COMMENT '娴忚娆℃暟',
  `sort_order` int DEFAULT '0' COMMENT '鎺掑簭',
  `create_by` bigint DEFAULT NULL,
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_by` bigint DEFAULT NULL,
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `del_flag` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`portfolio_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='浣滃搧闆嗚〃';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ds_portfolio`
--

LOCK TABLES `ds_portfolio` WRITE;
/*!40000 ALTER TABLE `ds_portfolio` DISABLE KEYS */;
INSERT INTO `ds_portfolio` VALUES (1,'鐚?,1,'https://i0.hdslb.com/bfs/new_dyn/a4833ebe1038fcd60a196da9b53c0e44270317383.jpg@420w_560h_1e_1c.webp','[\"https://i0.hdslb.com/bfs/new_dyn/a4833ebe1038fcd60a196da9b53c0e44270317383.jpg@420w_560h_1e_1c.webp\", \"https://i0.hdslb.com/bfs/new_dyn/a42924b84d925cfabf5672f8e7373ee6270317383.jpg@264w_264h_1e_1c.webp\"]','',1,4,1,1,'2026-04-10 19:53:02',1,'2026-04-10 19:53:02',0),(2,'娴嬭瘯涓婁紶浣滃搧',1,'http://localhost:8081/uploads/fc1a62f7bca648898b01d8239d4fb54b.png','[]','',0,0,0,1,'2026-04-10 20:05:54',1,'2026-04-10 20:05:54',0);
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
  `refund_no` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '绯荤粺閫€娆炬祦姘村彿',
  `order_id` bigint NOT NULL COMMENT '鍏宠仈璁㈠崟',
  `payment_id` bigint DEFAULT NULL COMMENT '鍏宠仈鍘熸敮浠樿褰?,
  `refund_amount` decimal(10,2) NOT NULL COMMENT '閫€娆鹃噾棰?,
  `refund_reason` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '閫€娆惧師鍥?,
  `wx_refund_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '寰俊閫€娆惧崟鍙?,
  `status` tinyint(1) DEFAULT '0' COMMENT '0=澶勭悊涓?1=閫€娆炬垚鍔?2=閫€娆惧け璐?,
  `refund_time` datetime DEFAULT NULL COMMENT '瀹為檯閫€娆炬椂闂?,
  `operator_id` bigint DEFAULT NULL COMMENT '鎿嶄綔浜篒D',
  `notify_data` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci COMMENT '寰俊鍥炶皟鍘熷鏁版嵁',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `del_flag` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`refund_id`) USING BTREE,
  UNIQUE KEY `uk_refund_no` (`refund_no`) USING BTREE,
  KEY `idx_order` (`order_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='閫€娆捐褰曡〃';
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
  `openid` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '寰俊OpenID',
  `unionid` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '寰俊UnionID',
  `nickname` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '鏄电О',
  `avatar_url` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '澶村儚URL',
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '鎵嬫満鍙?,
  `status` tinyint(1) DEFAULT '1' COMMENT '0=绂佺敤,1=姝ｅ父',
  `gender` tinyint(1) DEFAULT NULL COMMENT '鎬у埆',
  `default_address_id` bigint DEFAULT NULL COMMENT '榛樿鍦板潃ID',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '娉ㄥ唽鏃堕棿',
  `last_login_time` datetime DEFAULT NULL COMMENT '鏈€鍚庣櫥褰?,
  `del_flag` tinyint(1) DEFAULT '0',
  `create_by` bigint DEFAULT NULL,
  `update_by` bigint DEFAULT NULL,
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`user_id`) USING BTREE,
  UNIQUE KEY `uk_openid` (`openid`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='灏忕▼搴忕敤鎴疯〃';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ds_user`
--

LOCK TABLES `ds_user` WRITE;
/*!40000 ALTER TABLE `ds_user` DISABLE KEYS */;
INSERT INTO `ds_user` VALUES (1,'wx_test_openid_001',NULL,'寮犲皬濮?,NULL,'13900001001',1,NULL,NULL,'2026-03-17 15:11:05','2026-04-30 13:04:23',0,NULL,5,'2026-03-24 16:43:20'),(2,'wx_test_openid_002',NULL,'鍒樺厛鐢?,NULL,'13900001002',1,NULL,NULL,'2026-03-17 15:11:05',NULL,0,NULL,NULL,'2026-03-24 16:43:20'),(3,'wx_test_openid_003',NULL,'闄堝コ澹?,NULL,'13900001003',1,NULL,NULL,'2026-03-17 15:11:05','2026-04-11 18:03:48',0,NULL,NULL,'2026-03-24 16:43:20'),(4,'wx_test_openid_13888888888',NULL,'瀹㈡埛8888',NULL,'13888888888',1,NULL,NULL,'2026-03-24 16:44:41','2026-03-25 19:19:38',0,NULL,4,'2026-03-24 16:44:41'),(5,'wx_test_openid_default',NULL,'ZeHana娴嬭瘯瀹㈡埛',NULL,'13888888888',1,NULL,NULL,'2026-03-25 19:24:46','2026-04-05 16:57:43',0,NULL,1,'2026-03-25 19:24:46');
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
  `category_id` bigint NOT NULL COMMENT '鍏宠仈鍝佺被(涓€瀵逛竴)',
  `workflow_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '宸ヤ綔娴佸悕绉?,
  `create_by` bigint DEFAULT NULL,
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_by` bigint DEFAULT NULL,
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `del_flag` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`workflow_id`) USING BTREE,
  UNIQUE KEY `uk_category` (`category_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='宸ヤ綔娴佹ā鏉胯〃';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ds_workflow`
--

LOCK TABLES `ds_workflow` WRITE;
/*!40000 ALTER TABLE `ds_workflow` DISABLE KEYS */;
INSERT INTO `ds_workflow` VALUES (1,1,'鏈嶈瀹氬埗娴佺▼',NULL,'2026-03-04 15:06:58',NULL,'2026-03-04 15:06:58',0),(2,2,'鐨叿鍒朵綔娴佺▼',NULL,'2026-03-04 15:06:58',NULL,'2026-03-04 15:06:58',0),(3,3,'鏁板瓧鎻掔敾娴佺▼',NULL,'2026-03-04 15:06:58',NULL,'2026-03-04 15:06:58',0);
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
  `workflow_id` bigint NOT NULL COMMENT '鎵€灞炲伐浣滄祦',
  `step_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '鑺傜偣鍚嶇О',
  `step_order` int NOT NULL DEFAULT '1' COMMENT '鑺傜偣椤哄簭',
  `is_start_step` tinyint(1) DEFAULT '0' COMMENT '鏄惁璧峰鑺傜偣',
  `is_end_step` tinyint(1) DEFAULT '0' COMMENT '鏄惁缁撴潫鑺傜偣',
  `node_description` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '????',
  `allowed_actions` json DEFAULT NULL COMMENT '????(JSON??)',
  `need_image_upload` tinyint(1) DEFAULT '0' COMMENT '????????',
  `visible_to_client` tinyint(1) DEFAULT '1' COMMENT '???????',
  `expected_duration_days` int DEFAULT NULL COMMENT '??????(?)',
  `node_form_fields` json DEFAULT NULL COMMENT '鑺傜偣琛ㄥ崟瀛楁閿垪琛?,
  `create_by` bigint DEFAULT NULL,
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_by` bigint DEFAULT NULL,
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `del_flag` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`step_id`) USING BTREE,
  KEY `idx_workflow` (`workflow_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='宸ヤ綔娴佽妭鐐硅〃';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ds_workflow_step`
--

LOCK TABLES `ds_workflow_step` WRITE;
/*!40000 ALTER TABLE `ds_workflow_step` DISABLE KEYS */;
INSERT INTO `ds_workflow_step` VALUES (1,1,'闇€姹傜‘璁?,1,1,0,'澶勭悊鑺傜偣锛氶渶姹傜‘璁?,'[\"save\", \"advance\", \"rollback\", \"block\", \"unblock\"]',0,1,1,'[\"chest\", \"waist\"]',NULL,'2026-03-04 15:06:58',NULL,'2026-04-10 15:43:02',0),(2,1,'闈㈡枡閲囪喘',2,0,0,'澶勭悊鑺傜偣锛氶潰鏂欓噰璐?,'[\"save\", \"advance\", \"rollback\", \"block\", \"unblock\"]',0,1,2,NULL,NULL,'2026-03-04 15:06:58',NULL,'2026-04-10 10:33:15',0),(3,1,'瑁佸壀',3,0,0,'澶勭悊鑺傜偣锛氳鍓?,'[\"save\", \"advance\", \"rollback\", \"block\", \"unblock\"]',1,1,3,NULL,NULL,'2026-03-04 15:06:58',NULL,'2026-04-10 10:33:15',0),(4,1,'缂濆埗',4,0,0,'澶勭悊鑺傜偣锛氱紳鍒?,'[\"save\", \"advance\", \"rollback\", \"block\", \"unblock\"]',1,1,3,NULL,NULL,'2026-03-04 15:06:58',NULL,'2026-04-10 10:33:15',0),(5,1,'璐ㄦ',5,0,0,'澶勭悊鑺傜偣锛氳川妫€','[\"save\", \"advance\", \"rollback\", \"block\", \"unblock\"]',1,1,1,NULL,NULL,'2026-03-04 15:06:58',NULL,'2026-04-10 10:33:15',0),(6,1,'鍖呰鍙戣揣',6,0,1,'澶勭悊鑺傜偣锛氬寘瑁呭彂璐?,'[\"save\", \"advance\", \"rollback\", \"block\", \"unblock\"]',0,1,1,NULL,NULL,'2026-03-04 15:06:58',NULL,'2026-04-10 10:33:15',0),(7,2,'闇€姹傜‘璁?,1,1,0,'澶勭悊鑺傜偣锛氶渶姹傜‘璁?,'[\"save\", \"advance\", \"rollback\", \"block\", \"unblock\"]',0,1,1,NULL,NULL,'2026-03-04 15:06:58',NULL,'2026-04-10 10:33:15',0),(8,2,'鐨枡瑁佸垏',2,0,0,'澶勭悊鑺傜偣锛氱毊鏂欒鍒?,'[\"save\", \"advance\", \"rollback\", \"block\", \"unblock\"]',0,1,2,NULL,NULL,'2026-03-04 15:06:58',NULL,'2026-04-10 10:33:15',0),(9,2,'缂濈嚎鎵撶（',3,0,0,'澶勭悊鑺傜偣锛氱紳绾挎墦纾?,'[\"save\", \"advance\", \"rollback\", \"block\", \"unblock\"]',1,1,3,NULL,NULL,'2026-03-04 15:06:58',NULL,'2026-04-10 10:33:15',0),(10,2,'涓婅壊灏佽竟',4,0,0,'澶勭悊鑺傜偣锛氫笂鑹插皝杈?,'[\"save\", \"advance\", \"rollback\", \"block\", \"unblock\"]',1,1,3,NULL,NULL,'2026-03-04 15:06:58',NULL,'2026-04-10 10:33:15',0),(11,2,'璐ㄦ鍑鸿揣',5,0,1,'澶勭悊鑺傜偣锛氳川妫€鍑鸿揣','[\"save\", \"advance\", \"rollback\", \"block\", \"unblock\"]',1,1,1,NULL,NULL,'2026-03-04 15:06:58',NULL,'2026-04-10 10:33:15',0),(12,3,'闇€姹傜‘璁?,1,1,0,'澶勭悊鑺傜偣锛氶渶姹傜‘璁?,'[\"save\", \"advance\", \"rollback\", \"block\", \"unblock\"]',0,1,1,NULL,NULL,'2026-03-04 15:06:58',NULL,'2026-04-10 10:33:15',0),(13,3,'鑽夌鏋勫浘',2,0,0,'澶勭悊鑺傜偣锛氳崏绋挎瀯鍥?,'[\"save\", \"advance\", \"rollback\", \"block\", \"unblock\"]',1,1,2,NULL,NULL,'2026-03-04 15:06:58',NULL,'2026-04-10 10:33:15',0),(14,3,'绾跨缁嗗寲',3,0,0,'澶勭悊鑺傜偣锛氱嚎绋跨粏鍖?,'[\"save\", \"advance\", \"rollback\", \"block\", \"unblock\"]',1,1,3,NULL,NULL,'2026-03-04 15:06:58',NULL,'2026-04-10 10:33:15',0),(15,3,'涓婅壊瀹岀',4,0,0,'澶勭悊鑺傜偣锛氫笂鑹插畬绋?,'[\"save\", \"advance\", \"rollback\", \"block\", \"unblock\"]',1,1,3,NULL,NULL,'2026-03-04 15:06:58',NULL,'2026-04-10 10:33:15',0),(16,3,'瀹㈡埛楠屾敹',5,0,1,'澶勭悊鑺傜偣锛氬鎴烽獙鏀?,'[\"save\", \"advance\", \"rollback\", \"block\", \"unblock\"]',1,1,1,NULL,NULL,'2026-03-04 15:06:58',NULL,'2026-04-10 10:33:15',0);
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
  `username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '鐧诲綍璐﹀彿',
  `password` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '瀵嗙爜(BCrypt)',
  `nickname` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '鏄电О',
  `avatar` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '澶村儚',
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '鎵嬫満鍙?,
  `email` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '閭',
  `status` tinyint(1) DEFAULT '1' COMMENT '0=绂佺敤,1=姝ｅ父',
  `create_by` bigint DEFAULT NULL,
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_by` bigint DEFAULT NULL,
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `last_login_time` datetime DEFAULT NULL COMMENT '鏈€鍚庣櫥褰?,
  `del_flag` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`admin_id`) USING BTREE,
  UNIQUE KEY `uk_username` (`username`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='鍚庡彴鐢ㄦ埛琛?;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_admin`
--

LOCK TABLES `sys_admin` WRITE;
/*!40000 ALTER TABLE `sys_admin` DISABLE KEYS */;
INSERT INTO `sys_admin` VALUES (1,'admin','$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2','瓒呯骇绠＄悊鍛?,NULL,NULL,NULL,1,NULL,'2026-03-04 15:06:58',NULL,'2026-03-04 15:06:58',NULL,0),(2,'designer1','$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2','鏉庤璁″笀',NULL,'13800001001',NULL,1,NULL,'2026-03-17 15:11:05',NULL,'2026-03-17 15:11:05',NULL,0),(3,'designer2','$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2','鐜嬭璁″笀',NULL,'13800001002',NULL,1,NULL,'2026-03-17 15:11:05',1,'2026-03-17 15:11:05',NULL,0),(4,'storekeeper','$2a$10$lquZWWPAEjT1D3Ugbh2NTuZURlkeRF.K3LJcRSDQSTq3ljats0T96','storekeeper',NULL,'',NULL,1,1,'2026-04-20 00:45:35',1,'2026-04-20 00:45:35',NULL,0),(5,'purchaser','$2a$10$MqEyuumZ9MXB/nmwzeV4euzEhnyxbn1Pvw.8b1S1V.g0BtZBrtgP2','purchaser',NULL,'',NULL,1,1,'2026-04-20 00:45:44',1,'2026-04-20 00:45:44',NULL,0),(6,'finance','$2a$10$7ahdyzysipm.sGUK/eC5u.kmXmANkbg6oHz/xJVympU3XDVbg1r.a','finance',NULL,'',NULL,1,1,'2026-04-20 00:45:54',1,'2026-04-20 00:45:54',NULL,0),(7,'customer_service','$2a$10$EI4ij7ybYwOwfck0R9xc7eYthj.vysnH7zYLup406nWkFLxXYqxXO','customer_service',NULL,'',NULL,1,1,'2026-04-20 00:46:07',1,'2026-04-20 00:46:07',NULL,0);
/*!40000 ALTER TABLE `sys_admin` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_admin_role`
--

DROP TABLE IF EXISTS `sys_admin_role`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_admin_role` (
  `admin_id` bigint NOT NULL COMMENT '鐢ㄦ埛ID',
  `role_id` bigint NOT NULL COMMENT '瑙掕壊ID',
  PRIMARY KEY (`admin_id`,`role_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='鐢ㄦ埛瑙掕壊鍏宠仈琛?;
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
  `api_path` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '鎺ュ彛璺緞',
  `http_method` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'HTTP鏂规硶',
  `stat_date` date NOT NULL COMMENT '缁熻鏃ユ湡',
  `stat_hour` int DEFAULT NULL COMMENT '缁熻灏忔椂(0-23)',
  `call_count` int DEFAULT '0' COMMENT '璋冪敤娆℃暟',
  `success_count` int DEFAULT '0',
  `fail_count` int DEFAULT '0',
  `avg_cost_ms` int DEFAULT '0' COMMENT '骞冲潎鑰楁椂(ms)',
  `max_cost_ms` int DEFAULT '0',
  `p99_cost_ms` int DEFAULT '0',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`metric_id`) USING BTREE,
  UNIQUE KEY `uk_api_date_hour` (`api_path`,`stat_date`,`stat_hour`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='鎺ュ彛鐩戞帶鎸囨爣琛?;
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
  `dict_type` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '瀛楀吀绫诲瀷鏍囪瘑',
  `dict_label` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '瀛楀吀鏍囩',
  `dict_value` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '瀛楀吀鍊?,
  `sort_order` int DEFAULT '0' COMMENT '鎺掑簭',
  `remark` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '澶囨敞',
  `del_flag` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`dict_code`) USING BTREE,
  KEY `idx_dict_type` (`dict_type`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='瀛楀吀鏁版嵁琛?;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_dict_data`
--

LOCK TABLES `sys_dict_data` WRITE;
/*!40000 ALTER TABLE `sys_dict_data` DISABLE KEYS */;
INSERT INTO `sys_dict_data` VALUES (1,'order_status','寰呮敮浠?,'0',0,NULL,0),(2,'order_status','鐢熶骇涓?,'1',1,NULL,0),(3,'order_status','寰呭彂璐?,'2',2,NULL,0),(4,'order_status','寰呮敹璐?,'3',3,NULL,0),(5,'order_status','宸插畬鎴?,'4',4,NULL,0),(6,'order_status','宸插彇娑?,'5',5,NULL,0),(7,'request_status','寰呭鐞?,'0',0,NULL,0),(8,'request_status','宸茶浆鍗?,'1',1,NULL,0),(9,'request_status','宸插叧闂?,'2',2,NULL,0),(10,'payment_type','棰勪粯娆?,'1',1,NULL,0),(11,'payment_type','灏炬','2',2,NULL,0),(12,'material_category','闈㈡枡','fabric',1,NULL,0),(13,'material_category','杈呮枡','accessory',2,NULL,0),(14,'material_category','浜旈噾浠?,'hardware',3,NULL,0);
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
  `dict_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '瀛楀吀鍚嶇О',
  `dict_type` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '瀛楀吀绫诲瀷鏍囪瘑',
  `remark` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '澶囨敞',
  `create_by` bigint DEFAULT NULL,
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_by` bigint DEFAULT NULL,
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `del_flag` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`dict_id`) USING BTREE,
  UNIQUE KEY `uk_dict_type` (`dict_type`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='瀛楀吀绫诲瀷琛?;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_dict_type`
--

LOCK TABLES `sys_dict_type` WRITE;
/*!40000 ALTER TABLE `sys_dict_type` DISABLE KEYS */;
INSERT INTO `sys_dict_type` VALUES (1,'璁㈠崟鐘舵€?,'order_status','璁㈠崟鐢熷懡鍛ㄦ湡鐘舵€?,NULL,'2026-03-04 15:06:58',NULL,'2026-03-04 15:06:58',0),(2,'鎰忓悜鐘舵€?,'request_status','瀹㈡埛鎰忓悜鐘舵€?,NULL,'2026-03-04 15:06:58',NULL,'2026-03-04 15:06:58',0),(3,'鏀粯绫诲瀷','payment_type','鏀粯绫诲瀷',NULL,'2026-03-04 15:06:58',NULL,'2026-03-04 15:06:58',0),(4,'鐗╂枡鍒嗙被','material_category','鐗╂枡鍒嗙被',NULL,'2026-03-04 15:06:58',NULL,'2026-03-04 15:06:58',0),(5,'1','1','',NULL,'2026-04-05 14:58:11',NULL,'2026-04-05 15:03:50',1),(7,'2','2','',NULL,'2026-04-05 15:00:09',NULL,'2026-04-05 15:03:49',1);
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
  `exception_type` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '寮傚父绫诲瀷(绫诲悕)',
  `exception_msg` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci COMMENT '寮傚父娑堟伅',
  `stack_trace` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci COMMENT '鍫嗘爤淇℃伅',
  `request_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '璇锋眰URL',
  `request_method` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'HTTP鏂规硶',
  `request_param` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci COMMENT '璇锋眰鍙傛暟',
  `operator_id` bigint DEFAULT NULL COMMENT '鎿嶄綔浜篒D',
  `operator_ip` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '鎿嶄綔浜篒P',
  `is_handled` tinyint(1) DEFAULT '0' COMMENT '鏄惁宸插鐞?,
  `handle_remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '澶勭悊澶囨敞',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '鍙戠敓鏃堕棿',
  PRIMARY KEY (`exception_id`) USING BTREE,
  KEY `idx_create_time` (`create_time`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='寮傚父鏃ュ織琛?;
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
  `admin_id` bigint DEFAULT NULL COMMENT '鐧诲綍鐢ㄦ埛ID',
  `username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '鐧诲綍璐﹀彿',
  `login_ip` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '鐧诲綍IP',
  `login_location` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '鐧诲綍鍦扮偣',
  `browser` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '娴忚鍣?,
  `os` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '鎿嶄綔绯荤粺',
  `status` tinyint(1) DEFAULT NULL COMMENT '0=鎴愬姛,1=澶辫触',
  `msg` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '鎻愮ず娑堟伅',
  `login_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '鐧诲綍鏃堕棿',
  PRIMARY KEY (`login_id`) USING BTREE,
  KEY `idx_admin` (`admin_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='鐧诲綍鏃ュ織琛?;
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
  `parent_id` bigint DEFAULT '0' COMMENT '鐖惰彍鍗旾D',
  `menu_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '鑿滃崟鍚嶇О',
  `menu_type` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'M=鐩綍,C=鑿滃崟,F=鎸夐挳',
  `path` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '璺敱鍦板潃',
  `component` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '缁勪欢璺緞',
  `perms` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '鏉冮檺鏍囪瘑(濡俹rder:list)',
  `icon` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '鍥炬爣',
  `sort_order` int DEFAULT '0' COMMENT '鎺掑簭',
  `visible` tinyint(1) DEFAULT '1' COMMENT '鏄惁鍙',
  `create_by` bigint DEFAULT NULL,
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_by` bigint DEFAULT NULL,
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `del_flag` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`menu_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=34 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='鑿滃崟鏉冮檺琛?;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_menu`
--

LOCK TABLES `sys_menu` WRITE;
/*!40000 ALTER TABLE `sys_menu` DISABLE KEYS */;
INSERT INTO `sys_menu` VALUES (1,0,'璁㈠崟绠＄悊','M','/order',NULL,NULL,'ShoppingCart',3,1,NULL,'2026-03-04 15:06:58',NULL,'2026-04-11 14:05:26',0),(2,0,'鎰忓悜绠＄悊','M','/request',NULL,NULL,'Mail',4,1,NULL,'2026-03-04 15:06:58',NULL,'2026-04-11 14:05:26',0),(3,0,'閰嶇疆涓績','M','/config',NULL,NULL,'Settings',8,1,NULL,'2026-03-04 15:06:58',NULL,'2026-04-11 14:05:26',0),(4,0,'渚涘簲閾?,'M','/supply',NULL,NULL,'Package',6,1,NULL,'2026-03-04 15:06:58',NULL,'2026-04-11 14:05:26',0),(5,0,'浣滃搧闆?,'M','/portfolio',NULL,NULL,'Image',5,1,NULL,'2026-03-04 15:06:58',NULL,'2026-03-04 15:06:58',0),(6,0,'鏁版嵁鍒嗘瀽','M','/statistics',NULL,NULL,'TrendingUp',7,1,NULL,'2026-03-04 15:06:58',NULL,'2026-04-11 14:05:26',0),(7,0,'绯荤粺绠＄悊','M','/system',NULL,NULL,'Tool',9,1,NULL,'2026-03-04 15:06:58',NULL,'2026-04-11 14:05:26',0),(8,1,'璁㈠崟鐪嬫澘','C','/order/kanban',NULL,'order:kanban',NULL,1,1,NULL,'2026-03-04 15:06:58',NULL,'2026-03-04 15:06:58',0),(9,1,'璁㈠崟鍒楄〃','C','/order/list',NULL,'order:list',NULL,2,1,NULL,'2026-03-04 15:06:58',NULL,'2026-03-04 15:06:58',0),(10,2,'鎰忓悜姹?,'C','/request/list',NULL,'request:list',NULL,1,1,NULL,'2026-03-04 15:06:58',NULL,'2026-03-04 15:06:58',0),(11,3,'鍝佺被绠＄悊','C','/config/category',NULL,'category:list',NULL,1,1,NULL,'2026-03-04 15:06:58',NULL,'2026-03-04 15:06:58',0),(12,3,'鍔ㄦ€佸瓧娈?,'C','/config/field',NULL,'field:list',NULL,2,1,NULL,'2026-03-04 15:06:58',NULL,'2026-03-04 15:06:58',0),(13,3,'宸ヤ綔娴佺鐞?,'C','/config/workflow',NULL,'workflow:list',NULL,3,1,NULL,'2026-03-04 15:06:58',NULL,'2026-03-04 15:06:58',0),(14,4,'鐗╂枡绠＄悊','C','/supply/material',NULL,'material:list',NULL,1,1,NULL,'2026-03-04 15:06:58',NULL,'2026-03-04 15:06:58',0),(15,4,'BOM妯℃澘','C','/supply/bom',NULL,'bom:list',NULL,2,1,NULL,'2026-03-04 15:06:58',NULL,'2026-03-04 15:06:58',0),(16,5,'浣滃搧绠＄悊','C','/portfolio/list',NULL,'portfolio:list',NULL,1,1,NULL,'2026-03-04 15:06:58',NULL,'2026-03-04 15:06:58',0),(17,6,'缁忚惀鐪嬫澘','C','/statistics/dashboard',NULL,'statistics:dashboard',NULL,1,1,NULL,'2026-03-04 15:06:58',NULL,'2026-03-04 15:06:58',0),(18,7,'鐢ㄦ埛绠＄悊','C','/system/admin',NULL,'admin:list',NULL,1,1,NULL,'2026-03-04 15:06:58',NULL,'2026-03-04 15:06:58',0),(19,7,'瑙掕壊绠＄悊','C','/system/role',NULL,'role:list',NULL,2,1,NULL,'2026-03-04 15:06:58',NULL,'2026-03-04 15:06:58',0),(20,7,'鑿滃崟绠＄悊','C','/system/menu',NULL,'menu:list',NULL,3,1,NULL,'2026-03-04 15:06:58',NULL,'2026-03-04 15:06:58',0),(21,7,'瀛楀吀绠＄悊','C','/system/dict',NULL,'dict:list',NULL,4,1,NULL,'2026-03-04 15:06:58',NULL,'2026-03-04 15:06:58',0),(22,7,'鎿嶄綔鏃ュ織','C','/system/log',NULL,'log:list',NULL,5,1,NULL,'2026-03-04 15:06:58',NULL,'2026-03-04 15:06:58',0),(23,0,'娑堟伅涓績','M','/chat',NULL,NULL,'ChatboxEllipsesOutline',2,1,NULL,'2026-03-25 19:24:46',NULL,'2026-04-11 14:05:26',0),(24,23,'鍦ㄧ嚎娌熼€?,'C','/chat/index',NULL,'chat:list',NULL,1,1,NULL,'2026-03-25 19:24:46',NULL,'2026-03-25 19:24:46',0),(25,0,'鑺傜偣宸ヤ綔鍙?,'M','/workbench','LAYOUT',NULL,'AppstoreOutlined',1,1,NULL,'2026-04-09 20:59:05',NULL,'2026-04-11 14:05:26',0),(26,25,'鑺傜偣宸ヤ綔鍙?,'C','nodes','/order/workbench','workbench:list',NULL,1,1,NULL,'2026-04-09 20:59:05',NULL,'2026-04-09 21:04:12',0),(27,4,'搴撳瓨绠＄悊','C','/supply/inventory',NULL,'inventory:list','CubeOutline',3,1,NULL,'2026-04-14 22:09:37',NULL,'2026-04-14 22:09:37',0),(28,4,'搴撳瓨璁板綍','C','/supply/inventory/record',NULL,'inventory:record','ListOutline',4,1,NULL,'2026-04-14 22:09:37',NULL,'2026-04-14 22:09:37',0),(29,0,'瀹㈡埛绠＄悊','M','/customer',NULL,NULL,'PeopleOutline',9,1,NULL,'2026-04-14 22:09:37',NULL,'2026-04-14 22:09:37',0),(30,29,'瀹㈡埛鍒楄〃','C','/customer/list',NULL,'customer:list',NULL,1,1,NULL,'2026-04-14 22:09:37',NULL,'2026-04-14 22:09:37',0),(31,29,'鍦板潃绠＄悊','C','/customer/address',NULL,'customer:address',NULL,2,1,NULL,'2026-04-14 22:09:37',NULL,'2026-04-14 22:09:37',0),(32,3,'杞挱鍥剧鐞?,'C','/config/banner',NULL,'banner:list','ImagesOutline',4,1,NULL,'2026-04-14 22:09:37',NULL,'2026-04-14 22:09:37',0),(33,3,'AI閰嶇疆','C','/config/ai',NULL,'ai:config','HardwareChipOutline',5,1,NULL,'2026-04-20 01:01:17',NULL,'2026-04-20 01:01:17',0);
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
  `role_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '瑙掕壊鍚嶇О',
  `role_key` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '瑙掕壊鏍囪瘑(admin/designer)',
  `role_type` varchar(50) DEFAULT NULL COMMENT '瑙掕壊绫诲瀷: admin/designer/storekeeper/purchaser/finance/customer_service',
  `remark` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '澶囨敞',
  `create_by` bigint DEFAULT NULL,
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_by` bigint DEFAULT NULL,
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `del_flag` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`role_id`) USING BTREE,
  UNIQUE KEY `uk_role_key` (`role_key`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='瑙掕壊琛?;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_role`
--

LOCK TABLES `sys_role` WRITE;
/*!40000 ALTER TABLE `sys_role` DISABLE KEYS */;
INSERT INTO `sys_role` VALUES (1,'绠＄悊鍛?,'admin','admin','Full backend access',NULL,'2026-03-04 15:06:58',NULL,'2026-04-14 22:09:37',0),(2,'璁捐甯?,'designer','designer','Order execution, request handling, portfolio and chat access',NULL,'2026-03-04 15:06:58',NULL,'2026-04-14 22:09:37',0),(3,'搴撶','storekeeper','storekeeper','璐熻矗鐗╂枡绠＄悊鍜屽簱瀛樻煡鐪?,NULL,'2026-04-14 22:09:37',NULL,'2026-04-14 22:09:37',0),(4,'閲囪喘','purchaser','purchaser','璐熻矗鐗╂枡閲囪喘鍜屽簱瀛樼鐞?,NULL,'2026-04-14 22:09:37',NULL,'2026-04-14 22:09:37',0),(5,'璐㈠姟','finance','finance','璐熻矗璁㈠崟鏀舵鍜岃储鍔℃姤琛?,NULL,'2026-04-14 22:09:37',NULL,'2026-04-14 22:09:37',0),(6,'瀹㈡湇','customer_service','customer_service','璐熻矗瀹㈡埛娌熼€氬拰鍦ㄧ嚎绛旂枒',NULL,'2026-04-14 22:09:37',NULL,'2026-04-14 22:09:37',0);
/*!40000 ALTER TABLE `sys_role` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_role_menu`
--

DROP TABLE IF EXISTS `sys_role_menu`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_role_menu` (
  `role_id` bigint NOT NULL COMMENT '瑙掕壊ID',
  `menu_id` bigint NOT NULL COMMENT '鑿滃崟ID',
  PRIMARY KEY (`role_id`,`menu_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='瑙掕壊鑿滃崟鍏宠仈琛?;
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
INSERT INTO `ds_ai_config` VALUES (1, 'OpenAI Compatible', 1, 'https://api.example.com/v1/chat/completions', 'your-api-key', 'your-model-name', '你是 ZeHana 独立设计师工作室的智能客服「小Z」。你的角色不是普通闲聊机器人，而是客户的专属定制管家，负责帮助客户理解定制流程、订单进度、付款节点、交付安排、作品案例和沟通方式。请使用温和、专业、简洁的中文，先回应客户真实诉求，再给出下一步建议。你会看到最近聊天记录，请把客户偏好、尺寸、风格、预算、交付时间、忌讳元素、沟通习惯当作短期记忆使用，但不能编造没有出现在系统上下文或聊天记录里的信息。涉及订单号、当前节点、金额、预计交付、最近进度时，只能基于系统注入的实时订单信息回答。不确定时说明暂时没有看到该信息。遇到投诉、退款、紧急交付、复杂改款等高风险问题，要建议联系人工客服或等待设计师确认。如果聊天中出现进度卡片、支付卡片、作品集卡片、定制入口卡片或通知卡片，要引导客户点击卡片继续操作。', 1, '2026-05-01 14:32:05', 1, '2026-05-01 14:32:05', 0);

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
  `title` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '鎿嶄綔妯″潡',
  `method` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '璇锋眰鏂规硶',
  `request_method` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'HTTP鏂规硶',
  `operator_id` bigint DEFAULT NULL COMMENT '鎿嶄綔浜篒D',
  `operator_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '鎿嶄綔浜鸿处鍙?,
  `oper_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '璇锋眰URL',
  `oper_ip` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '璇锋眰IP',
  `oper_param` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci COMMENT '璇锋眰鍙傛暟',
  `json_result` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci COMMENT '杩斿洖缁撴灉',
  `status` tinyint(1) DEFAULT NULL COMMENT '0=鎴愬姛,1=澶辫触',
  `error_msg` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci COMMENT '閿欒淇℃伅',
  `oper_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '鎿嶄綔鏃堕棿',
  PRIMARY KEY (`log_id`) USING BTREE,
  KEY `idx_operator` (`operator_id`) USING BTREE,
  KEY `idx_oper_time` (`oper_time`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=219 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='鎿嶄綔鏃ュ織琛?;
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

