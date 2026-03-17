-- ==================================================================
-- 测试数据（用于开发和联调验证）
-- 在执行 init_schema.sql 之后执行
-- ==================================================================

USE `design_studio`;

-- ========== 1. 追加设计师账号 ==========
INSERT INTO `sys_admin` (`username`, `password`, `nickname`, `phone`, `status`) VALUES
('designer1', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '李设计师', '13800001001', 1),
('designer2', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '王设计师', '13800001002', 1);

-- 给设计师分配角色（role_id=2 是设计师角色）
INSERT INTO `sys_admin_role` (`admin_id`, `role_id`) VALUES (2, 2), (3, 2);

-- ========== 2. 模拟小程序客户 ==========
INSERT INTO `ds_user` (`openid`, `nickname`, `avatar_url`, `phone`) VALUES
('wx_test_openid_001', '张小姐', NULL, '13900001001'),
('wx_test_openid_002', '刘先生', NULL, '13900001002'),
('wx_test_openid_003', '陈女士', NULL, '13900001003');

-- ========== 3. 意向数据（6条，覆盖待处理/已转单/已关闭） ==========
INSERT INTO `ds_order_request` (`user_id`, `category_id`, `description`, `custom_data`, `status`, `create_time`) VALUES
(1, 1, '想定制一件旗袍，用于参加朋友婚礼', '{"chest":"88","waist":"68","shoulder":"38","length":"120","fabric_type":"丝绸"}', 0, '2026-03-10 10:00:00'),
(2, 2, '想做一个手工皮革钱包，送给男朋友做生日礼物', '{"leather_type":"植鞣革","color":"深棕色","size_spec":"长20cm×宽10cm"}', 0, '2026-03-11 14:30:00'),
(1, 3, '需要一张日系风格的头像插画', '{"art_style":"日系","resolution":"1080×1080","usage":"社交媒体头像"}', 0, '2026-03-12 09:15:00'),
(3, 1, '需要一套改良汉服', '{"chest":"92","waist":"72","shoulder":"40","length":"130","fabric_type":"亚麻"}', 1, '2026-03-08 16:00:00'),
(2, 3, '设计公司 Logo 扁平化插画', '{"art_style":"扁平化","resolution":"3000×3000","usage":"公司品牌Logo"}', 1, '2026-03-07 11:00:00'),
(3, 2, '复古风格手提包', '{"leather_type":"牛皮","color":"酒红色","size_spec":"长30cm×宽20cm×高15cm"}', 2, '2026-03-05 08:45:00');

-- 关闭原因
UPDATE `ds_order_request` SET `close_reason` = '客户取消，预算不足' WHERE `request_id` = 6;

-- ========== 4. 订单数据（4条，覆盖不同状态） ==========

-- 订单1: 服装定制-生产中（在"裁剪"节点）
INSERT INTO `ds_order` (`order_sn`, `user_id`, `category_id`, `designer_id`, `current_step_id`, `status`,
  `custom_data_snapshot`, `total_amount`, `prepay_amount`, `paid_amount`, `expected_date`, `remark`, `is_blocked`, `create_time`) VALUES
('DS202603081601001', 3, 1, 2, 3, 1,
 '{"chest":"92","waist":"72","shoulder":"40","length":"130","fabric_type":"亚麻"}',
 3500.00, 1750.00, 1750.00, '2026-04-10', '改良汉服，客户要求宽松版型', 0, '2026-03-08 16:05:00');

-- 订单2: 数字插画-生产中（在"线稿细化"节点）
INSERT INTO `ds_order` (`order_sn`, `user_id`, `category_id`, `designer_id`, `current_step_id`, `status`,
  `custom_data_snapshot`, `total_amount`, `prepay_amount`, `paid_amount`, `expected_date`, `remark`, `is_blocked`, `create_time`) VALUES
('DS202603071102001', 2, 3, 3, 9, 1,
 '{"art_style":"扁平化","resolution":"3000×3000","usage":"公司品牌Logo"}',
 800.00, 400.00, 400.00, '2026-03-25', 'Logo设计，需要三个备选方案', 0, '2026-03-07 11:05:00');

-- 订单3: 手工皮具-生产中（在"皮料裁切"节点, 已阻塞）
INSERT INTO `ds_order` (`order_sn`, `user_id`, `category_id`, `designer_id`, `current_step_id`, `status`,
  `custom_data_snapshot`, `total_amount`, `prepay_amount`, `paid_amount`, `expected_date`, `remark`, `is_blocked`, `block_reason`, `create_time`) VALUES
('DS202603151400001', 1, 2, 2, 7, 1,
 '{"leather_type":"鳄鱼皮","color":"黑色","size_spec":"长25cm×宽15cm"}',
 5800.00, 2900.00, 2900.00, '2026-04-20', '鳄鱼皮手拿包，高端定制', 1, '鳄鱼皮原料缺货，预计3天到货', '2026-03-15 14:00:00');

-- 订单4: 已完成的订单
INSERT INTO `ds_order` (`order_sn`, `user_id`, `category_id`, `designer_id`, `current_step_id`, `status`,
  `custom_data_snapshot`, `total_amount`, `prepay_amount`, `paid_amount`, `expected_date`, `remark`, `is_blocked`, `finish_time`, `create_time`) VALUES
('DS202602201000001', 1, 3, 3, 11, 4,
 '{"art_style":"水彩风","resolution":"1920×1080","usage":"个人收藏"}',
 600.00, 300.00, 600.00, '2026-03-05', '水彩风景画', 0, '2026-03-03 18:00:00', '2026-02-20 10:00:00');

-- 关联意向与订单（意向4→订单1，意向5→订单2）
UPDATE `ds_order_request` SET `linked_order_id` = 1 WHERE `request_id` = 4;
UPDATE `ds_order_request` SET `linked_order_id` = 2 WHERE `request_id` = 5;

-- ========== 5. 进度记录 ==========
INSERT INTO `ds_order_progress` (`order_id`, `step_id`, `description`, `operator_id`, `create_time`) VALUES
-- 订单1的进度
(1, 1, '客户需求已确认，改良汉服宽松版型，亚麻面料', 2, '2026-03-08 16:10:00'),
(1, 2, '特选高品质亚麻面料已采购到位，颜色为浅米色', 2, '2026-03-10 09:00:00'),
(1, 3, '开始裁剪，按照客户尺寸放样', 2, '2026-03-12 14:00:00'),
-- 订单2的进度
(2, 6, '需求已确认，客户要求扁平化风格Logo', 3, '2026-03-07 11:10:00'),
(2, 7, '草稿完成，已提交3个备选方案给客户', 3, '2026-03-09 16:00:00'),
(2, 8, '客户选择方案B，开始线稿细化', 3, '2026-03-11 10:00:00'),
-- 订单4（已完成）的进度
(4, 6, '需求确认完毕', 3, '2026-02-20 10:10:00'),
(4, 7, '草稿完成', 3, '2026-02-22 15:00:00'),
(4, 8, '线稿已定稿', 3, '2026-02-25 11:00:00'),
(4, 9, '上色完成，最终稿已出', 3, '2026-02-28 17:00:00'),
(4, 10, '客户验收通过，交付完成', 3, '2026-03-03 18:00:00');

-- ========== 6. 物料测试数据 ==========
INSERT INTO `ds_material` (`name`, `sku`, `category`, `unit`, `unit_price`, `stock`, `warning_stock`, `remark`) VALUES
('高级亚麻面料（浅米色）', 'FAB-LINEN-001', '面料', '米', 120.00, 50.00, 10.00, '优质亚麻，适合春夏服装'),
('真丝面料（香槟色）', 'FAB-SILK-001', '面料', '米', 280.00, 30.00, 5.00, '100%桑蚕丝'),
('植鞣革（棕色）', 'FAB-LEATHER-001', '面料', '张', 350.00, 15.00, 3.00, '意大利进口植鞣革'),
('鳄鱼皮（黑色）', 'FAB-CROC-001', '面料', '张', 1200.00, 2.00, 2.00, '稀有鳄鱼皮，需进口'),
('YKK拉链（20cm）', 'ACC-ZIP-001', '辅料', '条', 8.50, 200.00, 50.00, 'YKK金属拉链'),
('纯棉衬里（白色）', 'FAB-COTTON-001', '面料', '米', 35.00, 100.00, 20.00, '纯棉里衬'),
('D型五金扣', 'HW-DRING-001', '五金件', '个', 5.00, 500.00, 100.00, '不锈钢D型环'),
('手缝蜡线（棕色）', 'ACC-WAX-001', '辅料', '卷', 25.00, 80.00, 20.00, '手工皮具专用'),
('暗扣', 'HW-SNAP-001', '五金件', '套', 3.00, 300.00, 60.00, '磁吸暗扣'),
('包装盒（大号）', 'PKG-BOX-001', '辅料', '个', 15.00, 100.00, 20.00, '高端定制包装盒');

-- ========== 7. BOM模板数据 ==========
INSERT INTO `ds_bom_template` (`name`, `category_id`, `remark`) VALUES
('旗袍标准BOM', 1, '旗袍类服装的标准物料清单'),
('手工钱包BOM', 2, '小型皮具钱包的标准物料清单');

INSERT INTO `ds_bom_template_item` (`template_id`, `material_id`, `quantity`) VALUES
-- 旗袍BOM
(1, 1, 3.5),   -- 亚麻面料 3.5米
(1, 6, 2.0),   -- 棉衬里 2米
(1, 5, 1),     -- 拉链 1条
(1, 9, 2),     -- 暗扣 2套
(1, 10, 1),    -- 包装盒 1个
-- 钱包BOM
(2, 3, 0.5),   -- 植鞣革 0.5张
(2, 8, 1),     -- 蜡线 1卷
(2, 7, 4),     -- D型扣 4个
(2, 9, 1),     -- 暗扣 1套
(2, 10, 1);    -- 包装盒 1个
