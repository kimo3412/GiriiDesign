-- ==========================================
-- 独立设计师工作室生产流程管理系统
-- 完整数据库初始化脚本
-- MySQL 8.0+ | utf8mb4 | InnoDB
-- ==========================================

-- 创建数据库（如已创建可跳过）
CREATE DATABASE IF NOT EXISTS `design_studio` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE `design_studio`;

-- ==================================================================
-- 一、配置中心模块
-- ==================================================================

-- 1. 品类表
DROP TABLE IF EXISTS `ds_category`;
CREATE TABLE `ds_category` (
  `category_id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '品类ID',
  `name` VARCHAR(100) NOT NULL COMMENT '品类名称',
  `icon_url` VARCHAR(512) DEFAULT NULL COMMENT '图标URL',
  `is_active` TINYINT(1) DEFAULT 1 COMMENT '是否启用',
  `has_bom` TINYINT(1) DEFAULT 0 COMMENT '是否需要BOM',
  `is_physical` TINYINT(1) DEFAULT 1 COMMENT '是否实体产品',
  `sort_order` INT DEFAULT 0 COMMENT '排序',
  `create_by` BIGINT DEFAULT NULL COMMENT '创建人',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_by` BIGINT DEFAULT NULL COMMENT '更新人',
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `del_flag` TINYINT(1) DEFAULT 0 COMMENT '逻辑删除',
  PRIMARY KEY (`category_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='品类表';

-- 2. 动态字段定义表
DROP TABLE IF EXISTS `ds_custom_field`;
CREATE TABLE `ds_custom_field` (
  `field_id` BIGINT NOT NULL AUTO_INCREMENT,
  `category_id` BIGINT NOT NULL COMMENT '所属品类',
  `label` VARCHAR(100) NOT NULL COMMENT '字段显示名',
  `field_key` VARCHAR(50) NOT NULL COMMENT '字段键名',
  `field_type` VARCHAR(50) NOT NULL COMMENT '控件类型: text/number/select/date/image',
  `unit` VARCHAR(20) DEFAULT NULL COMMENT '单位',
  `options` JSON DEFAULT NULL COMMENT '选项列表(select用)',
  `placeholder` VARCHAR(200) DEFAULT NULL COMMENT '输入提示',
  `is_required` TINYINT(1) DEFAULT 0 COMMENT '是否必填',
  `sort_order` INT DEFAULT 0 COMMENT '排序',
  `create_by` BIGINT DEFAULT NULL,
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `update_by` BIGINT DEFAULT NULL,
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `del_flag` TINYINT(1) DEFAULT 0,
  PRIMARY KEY (`field_id`),
  KEY `idx_category` (`category_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='动态字段定义表';

-- 3. 工作流模板表
DROP TABLE IF EXISTS `ds_workflow`;
CREATE TABLE `ds_workflow` (
  `workflow_id` BIGINT NOT NULL AUTO_INCREMENT,
  `category_id` BIGINT NOT NULL COMMENT '关联品类(一对一)',
  `workflow_name` VARCHAR(100) NOT NULL COMMENT '工作流名称',
  `create_by` BIGINT DEFAULT NULL,
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `update_by` BIGINT DEFAULT NULL,
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `del_flag` TINYINT(1) DEFAULT 0,
  PRIMARY KEY (`workflow_id`),
  UNIQUE KEY `uk_category` (`category_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='工作流模板表';

-- 4. 工作流节点表
DROP TABLE IF EXISTS `ds_workflow_step`;
CREATE TABLE `ds_workflow_step` (
  `step_id` BIGINT NOT NULL AUTO_INCREMENT,
  `workflow_id` BIGINT NOT NULL COMMENT '所属工作流',
  `step_name` VARCHAR(100) NOT NULL COMMENT '节点名称',
  `step_order` INT NOT NULL DEFAULT 1 COMMENT '节点顺序',
  `is_start_step` TINYINT(1) DEFAULT 0 COMMENT '是否起始节点',
  `is_end_step` TINYINT(1) DEFAULT 0 COMMENT '是否结束节点',
  `create_by` BIGINT DEFAULT NULL,
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `update_by` BIGINT DEFAULT NULL,
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `del_flag` TINYINT(1) DEFAULT 0,
  PRIMARY KEY (`step_id`),
  KEY `idx_workflow` (`workflow_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='工作流节点表';

-- ==================================================================
-- 二、客户中心模块
-- ==================================================================

-- 5. 小程序用户表
DROP TABLE IF EXISTS `ds_user`;
CREATE TABLE `ds_user` (
  `user_id` BIGINT NOT NULL AUTO_INCREMENT,
  `openid` VARCHAR(128) NOT NULL COMMENT '微信OpenID',
  `unionid` VARCHAR(128) DEFAULT NULL COMMENT '微信UnionID',
  `nickname` VARCHAR(100) DEFAULT NULL COMMENT '昵称',
  `avatar_url` VARCHAR(512) DEFAULT NULL COMMENT '头像URL',
  `phone` VARCHAR(20) DEFAULT NULL COMMENT '手机号',
  `status` TINYINT(1) DEFAULT 1 COMMENT '0=禁用,1=正常',
  `gender` TINYINT(1) DEFAULT NULL COMMENT '性别',
  `default_address_id` BIGINT DEFAULT NULL COMMENT '默认地址ID',
  `last_login_time` DATETIME DEFAULT NULL COMMENT '最后登录',
  `create_by` BIGINT DEFAULT NULL,
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '注册时间',
  `update_by` BIGINT DEFAULT NULL,
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `del_flag` TINYINT(1) DEFAULT 0,
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `uk_openid` (`openid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='小程序用户表';

-- 6. 客户地址表
DROP TABLE IF EXISTS `ds_address`;
CREATE TABLE `ds_address` (
  `address_id` BIGINT NOT NULL AUTO_INCREMENT,
  `user_id` BIGINT NOT NULL COMMENT '所属用户',
  `receiver_name` VARCHAR(100) NOT NULL COMMENT '收货人',
  `phone` VARCHAR(20) NOT NULL COMMENT '联系电话',
  `province` VARCHAR(50) DEFAULT NULL COMMENT '省',
  `city` VARCHAR(50) DEFAULT NULL COMMENT '市',
  `district` VARCHAR(50) DEFAULT NULL COMMENT '区',
  `detail_address` VARCHAR(500) NOT NULL COMMENT '详细地址',
  `is_default` TINYINT(1) DEFAULT 0 COMMENT '是否默认',
  `create_by` BIGINT DEFAULT NULL,
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `update_by` BIGINT DEFAULT NULL,
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `del_flag` TINYINT(1) DEFAULT 0,
  PRIMARY KEY (`address_id`),
  KEY `idx_user` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='客户地址表';

-- 7. 作品集表
DROP TABLE IF EXISTS `ds_portfolio`;
CREATE TABLE `ds_portfolio` (
  `portfolio_id` BIGINT NOT NULL AUTO_INCREMENT,
  `title` VARCHAR(255) NOT NULL COMMENT '作品标题',
  `category_id` BIGINT DEFAULT NULL COMMENT '关联品类',
  `cover_url` VARCHAR(512) DEFAULT NULL COMMENT '封面图',
  `image_urls` JSON NOT NULL COMMENT '图片列表(JSON数组)',
  `description` TEXT DEFAULT NULL COMMENT '富文本描述',
  `status` TINYINT(1) DEFAULT 0 COMMENT '0=草稿,1=发布',
  `view_count` INT DEFAULT 0 COMMENT '浏览次数',
  `sort_order` INT DEFAULT 0 COMMENT '排序',
  `create_by` BIGINT DEFAULT NULL,
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `update_by` BIGINT DEFAULT NULL,
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `del_flag` TINYINT(1) DEFAULT 0,
  PRIMARY KEY (`portfolio_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='作品集表';

-- ==================================================================
-- 三、供应链模块
-- ==================================================================

-- 8. 物料表（含乐观锁 version 字段）
DROP TABLE IF EXISTS `ds_material`;
CREATE TABLE `ds_material` (
  `material_id` BIGINT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(200) NOT NULL COMMENT '物料名称',
  `sku` VARCHAR(100) DEFAULT NULL COMMENT '物料编码',
  `category` VARCHAR(100) DEFAULT NULL COMMENT '物料分类(面料/辅料/五金)',
  `unit` VARCHAR(20) DEFAULT NULL COMMENT '单位(米/个/kg)',
  `unit_price` DECIMAL(10,2) DEFAULT NULL COMMENT '单价',
  `stock` DECIMAL(10,2) DEFAULT 0 COMMENT '当前库存',
  `warning_stock` DECIMAL(10,2) DEFAULT NULL COMMENT '预警阈值',
  `image_url` VARCHAR(512) DEFAULT NULL COMMENT '物料图片',
  `remark` VARCHAR(500) DEFAULT NULL COMMENT '备注',
  `version` INT DEFAULT 0 COMMENT '版本号(乐观锁)',
  `create_by` BIGINT DEFAULT NULL,
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `update_by` BIGINT DEFAULT NULL,
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `del_flag` TINYINT(1) DEFAULT 0,
  PRIMARY KEY (`material_id`),
  UNIQUE KEY `uk_sku` (`sku`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='物料表';

-- 9. BOM模板表
DROP TABLE IF EXISTS `ds_bom_template`;
CREATE TABLE `ds_bom_template` (
  `template_id` BIGINT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(200) NOT NULL COMMENT '模板名称',
  `category_id` BIGINT DEFAULT NULL COMMENT '关联品类',
  `remark` VARCHAR(500) DEFAULT NULL COMMENT '备注',
  `create_by` BIGINT DEFAULT NULL,
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `update_by` BIGINT DEFAULT NULL,
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `del_flag` TINYINT(1) DEFAULT 0,
  PRIMARY KEY (`template_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='BOM模板表';

-- 10. BOM模板明细表
DROP TABLE IF EXISTS `ds_bom_template_item`;
CREATE TABLE `ds_bom_template_item` (
  `item_id` BIGINT NOT NULL AUTO_INCREMENT,
  `template_id` BIGINT NOT NULL COMMENT '所属模板',
  `material_id` BIGINT NOT NULL COMMENT '物料ID',
  `quantity` DECIMAL(10,2) NOT NULL COMMENT '所需数量',
  `del_flag` TINYINT(1) DEFAULT 0,
  PRIMARY KEY (`item_id`),
  KEY `idx_template` (`template_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='BOM模板明细表';

-- ==================================================================
-- 四、订单中心模块
-- ==================================================================

-- 11. 订单意向/需求表
DROP TABLE IF EXISTS `ds_order_request`;
CREATE TABLE `ds_order_request` (
  `request_id` BIGINT NOT NULL AUTO_INCREMENT,
  `user_id` BIGINT NOT NULL COMMENT '提交客户',
  `category_id` BIGINT NOT NULL COMMENT '定制品类',
  `description` TEXT DEFAULT NULL COMMENT '客户文字描述',
  `image_urls` JSON DEFAULT NULL COMMENT '参考图片(JSON数组)',
  `custom_data` JSON DEFAULT NULL COMMENT '动态表单数据',
  `status` TINYINT(1) DEFAULT 0 COMMENT '0=待处理,1=已转单,2=已关闭',
  `close_reason` VARCHAR(500) DEFAULT NULL COMMENT '关闭原因',
  `linked_order_id` BIGINT DEFAULT NULL COMMENT '转化后的订单ID',
  `create_by` BIGINT DEFAULT NULL,
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `update_by` BIGINT DEFAULT NULL,
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `del_flag` TINYINT(1) DEFAULT 0,
  PRIMARY KEY (`request_id`),
  KEY `idx_user` (`user_id`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='订单意向表';

-- 12. 订单主表（含乐观锁 version 字段）
DROP TABLE IF EXISTS `ds_order`;
CREATE TABLE `ds_order` (
  `order_id` BIGINT NOT NULL AUTO_INCREMENT,
  `order_sn` VARCHAR(64) NOT NULL COMMENT '订单编号',
  `user_id` BIGINT NOT NULL COMMENT '客户ID',
  `category_id` BIGINT NOT NULL COMMENT '品类ID',
  `designer_id` BIGINT DEFAULT NULL COMMENT '指派的设计师ID',
  `current_step_id` BIGINT DEFAULT NULL COMMENT '当前工作流节点',
  `status` TINYINT(1) DEFAULT 0 COMMENT '0=待支付,1=生产中,2=待发货,3=待收货,4=已完成,5=已取消',
  `custom_data_snapshot` JSON DEFAULT NULL COMMENT '定制参数快照',
  `total_amount` DECIMAL(10,2) DEFAULT NULL COMMENT '总金额',
  `prepay_amount` DECIMAL(10,2) DEFAULT NULL COMMENT '预付款',
  `paid_amount` DECIMAL(10,2) DEFAULT 0 COMMENT '已支付金额',
  `expected_date` DATE DEFAULT NULL COMMENT '预计交付日期',
  `address_snapshot` JSON DEFAULT NULL COMMENT '收货地址快照',
  `remark` VARCHAR(1000) DEFAULT NULL COMMENT '备注',
  `is_blocked` TINYINT(1) DEFAULT 0 COMMENT '是否阻塞',
  `block_reason` VARCHAR(500) DEFAULT NULL COMMENT '阻塞原因',
  `version` INT DEFAULT 0 COMMENT '版本号(乐观锁)',
  `create_by` BIGINT DEFAULT NULL,
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `update_by` BIGINT DEFAULT NULL,
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `finish_time` DATETIME DEFAULT NULL COMMENT '完成时间',
  `del_flag` TINYINT(1) DEFAULT 0,
  PRIMARY KEY (`order_id`),
  UNIQUE KEY `uk_order_sn` (`order_sn`),
  KEY `idx_user_status` (`user_id`, `status`),
  KEY `idx_designer` (`designer_id`),
  KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='订单主表';

-- 13. 订单进度表
DROP TABLE IF EXISTS `ds_order_progress`;
CREATE TABLE `ds_order_progress` (
  `progress_id` BIGINT NOT NULL AUTO_INCREMENT,
  `order_id` BIGINT NOT NULL COMMENT '所属订单',
  `step_id` BIGINT NOT NULL COMMENT '对应工作流节点',
  `description` VARCHAR(1000) DEFAULT NULL COMMENT '进度描述',
  `image_urls` JSON DEFAULT NULL COMMENT '进度图片',
  `operator_id` BIGINT DEFAULT NULL COMMENT '操作人ID',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `del_flag` TINYINT(1) DEFAULT 0,
  PRIMARY KEY (`progress_id`),
  KEY `idx_order` (`order_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='订单进度表';

-- 14. 订单BOM清单表
DROP TABLE IF EXISTS `ds_bom_item`;
CREATE TABLE `ds_bom_item` (
  `bom_item_id` BIGINT NOT NULL AUTO_INCREMENT,
  `order_id` BIGINT NOT NULL COMMENT '所属订单',
  `material_id` BIGINT NOT NULL COMMENT '物料ID',
  `quantity` DECIMAL(10,2) NOT NULL COMMENT '实际用量',
  `material_snapshot` JSON DEFAULT NULL COMMENT '物料快照(名称、单价)',
  `is_allocated` TINYINT(1) DEFAULT 0 COMMENT '是否已出库',
  `del_flag` TINYINT(1) DEFAULT 0,
  PRIMARY KEY (`bom_item_id`),
  KEY `idx_order` (`order_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='订单BOM清单表';

-- 15. 聊天记录表
DROP TABLE IF EXISTS `ds_chat_message`;
CREATE TABLE `ds_chat_message` (
  `msg_id` BIGINT NOT NULL AUTO_INCREMENT,
  `user_id` BIGINT NOT NULL COMMENT '所属客户',
  `sender_type` TINYINT(1) NOT NULL COMMENT '0=客户,1=设计师',
  `sender_id` BIGINT NOT NULL COMMENT '发送方ID',
  `content_type` TINYINT(1) DEFAULT 0 COMMENT '0=文本,1=图片',
  `content` TEXT NOT NULL COMMENT '消息内容',
  `is_read` TINYINT(1) DEFAULT 0 COMMENT '是否已读',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `del_flag` TINYINT(1) DEFAULT 0,
  PRIMARY KEY (`msg_id`),
  KEY `idx_user` (`user_id`),
  KEY `idx_sender` (`sender_type`, `sender_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='聊天记录表';

-- ==================================================================
-- 五、支付与交易模块
-- ==================================================================

-- 16. 支付流水表（幂等：out_trade_no 唯一索引）
DROP TABLE IF EXISTS `ds_payment_record`;
CREATE TABLE `ds_payment_record` (
  `payment_id` BIGINT NOT NULL AUTO_INCREMENT,
  `payment_no` VARCHAR(64) NOT NULL COMMENT '系统支付流水号',
  `order_id` BIGINT NOT NULL COMMENT '关联订单',
  `user_id` BIGINT NOT NULL COMMENT '支付用户',
  `payment_type` TINYINT(1) NOT NULL COMMENT '1=预付款,2=尾款',
  `amount` DECIMAL(10,2) NOT NULL COMMENT '支付金额',
  `wx_transaction_id` VARCHAR(64) DEFAULT NULL COMMENT '微信支付交易号',
  `wx_prepay_id` VARCHAR(64) DEFAULT NULL COMMENT '微信预支付ID',
  `status` TINYINT(1) DEFAULT 0 COMMENT '0=待支付,1=成功,2=失败,3=已关闭',
  `pay_time` DATETIME DEFAULT NULL COMMENT '实际支付时间',
  `expire_time` DATETIME DEFAULT NULL COMMENT '支付过期时间',
  `notify_data` TEXT DEFAULT NULL COMMENT '微信回调原始数据',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `del_flag` TINYINT(1) DEFAULT 0,
  PRIMARY KEY (`payment_id`),
  UNIQUE KEY `uk_payment_no` (`payment_no`),
  KEY `idx_order` (`order_id`),
  KEY `idx_user` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='支付流水表';

-- 17. 退款记录表（幂等：out_refund_no 唯一索引）
DROP TABLE IF EXISTS `ds_refund_record`;
CREATE TABLE `ds_refund_record` (
  `refund_id` BIGINT NOT NULL AUTO_INCREMENT,
  `refund_no` VARCHAR(64) NOT NULL COMMENT '系统退款流水号',
  `order_id` BIGINT NOT NULL COMMENT '关联订单',
  `payment_id` BIGINT DEFAULT NULL COMMENT '关联原支付记录',
  `refund_amount` DECIMAL(10,2) NOT NULL COMMENT '退款金额',
  `refund_reason` VARCHAR(500) NOT NULL COMMENT '退款原因',
  `wx_refund_id` VARCHAR(64) DEFAULT NULL COMMENT '微信退款单号',
  `status` TINYINT(1) DEFAULT 0 COMMENT '0=处理中,1=退款成功,2=退款失败',
  `refund_time` DATETIME DEFAULT NULL COMMENT '实际退款时间',
  `operator_id` BIGINT DEFAULT NULL COMMENT '操作人ID',
  `notify_data` TEXT DEFAULT NULL COMMENT '微信回调原始数据',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `del_flag` TINYINT(1) DEFAULT 0,
  PRIMARY KEY (`refund_id`),
  UNIQUE KEY `uk_refund_no` (`refund_no`),
  KEY `idx_order` (`order_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='退款记录表';

-- 18. 对账记录表
DROP TABLE IF EXISTS `ds_bill_record`;
CREATE TABLE `ds_bill_record` (
  `bill_id` BIGINT NOT NULL AUTO_INCREMENT,
  `bill_date` DATE NOT NULL COMMENT '账单日期',
  `wx_transaction_id` VARCHAR(64) DEFAULT NULL COMMENT '微信交易号',
  `local_payment_no` VARCHAR(64) DEFAULT NULL COMMENT '本地流水号',
  `wx_amount` DECIMAL(10,2) DEFAULT NULL COMMENT '微信账单金额',
  `local_amount` DECIMAL(10,2) DEFAULT NULL COMMENT '本地记录金额',
  `match_status` TINYINT(1) DEFAULT NULL COMMENT '0=匹配,1=金额不符,2=本地缺失,3=微信缺失',
  `handle_status` TINYINT(1) DEFAULT 0 COMMENT '0=待处理,1=已处理',
  `handle_remark` VARCHAR(500) DEFAULT NULL COMMENT '处理备注',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`bill_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='对账记录表';

-- ==================================================================
-- 六、系统基础模块 (RBAC 权限)
-- ==================================================================

-- 19. 后台用户表
DROP TABLE IF EXISTS `sys_admin`;
CREATE TABLE `sys_admin` (
  `admin_id` BIGINT NOT NULL AUTO_INCREMENT,
  `username` VARCHAR(50) NOT NULL COMMENT '登录账号',
  `password` VARCHAR(200) NOT NULL COMMENT '密码(BCrypt)',
  `nickname` VARCHAR(100) DEFAULT NULL COMMENT '昵称',
  `avatar` VARCHAR(512) DEFAULT NULL COMMENT '头像',
  `phone` VARCHAR(20) DEFAULT NULL COMMENT '手机号',
  `email` VARCHAR(100) DEFAULT NULL COMMENT '邮箱',
  `status` TINYINT(1) DEFAULT 1 COMMENT '0=禁用,1=正常',
  `create_by` BIGINT DEFAULT NULL,
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `update_by` BIGINT DEFAULT NULL,
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `last_login_time` DATETIME DEFAULT NULL COMMENT '最后登录',
  `del_flag` TINYINT(1) DEFAULT 0,
  PRIMARY KEY (`admin_id`),
  UNIQUE KEY `uk_username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='后台用户表';

-- 20. 角色表
DROP TABLE IF EXISTS `sys_role`;
CREATE TABLE `sys_role` (
  `role_id` BIGINT NOT NULL AUTO_INCREMENT,
  `role_name` VARCHAR(50) NOT NULL COMMENT '角色名称',
  `role_key` VARCHAR(50) NOT NULL COMMENT '角色标识(admin/designer)',
  `remark` VARCHAR(200) DEFAULT NULL COMMENT '备注',
  `create_by` BIGINT DEFAULT NULL,
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `update_by` BIGINT DEFAULT NULL,
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `del_flag` TINYINT(1) DEFAULT 0,
  PRIMARY KEY (`role_id`),
  UNIQUE KEY `uk_role_key` (`role_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='角色表';

-- 21. 用户角色关联表
DROP TABLE IF EXISTS `sys_admin_role`;
CREATE TABLE `sys_admin_role` (
  `admin_id` BIGINT NOT NULL COMMENT '用户ID',
  `role_id` BIGINT NOT NULL COMMENT '角色ID',
  PRIMARY KEY (`admin_id`, `role_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户角色关联表';

-- 22. 菜单/权限表
DROP TABLE IF EXISTS `sys_menu`;
CREATE TABLE `sys_menu` (
  `menu_id` BIGINT NOT NULL AUTO_INCREMENT,
  `parent_id` BIGINT DEFAULT 0 COMMENT '父菜单ID',
  `menu_name` VARCHAR(100) NOT NULL COMMENT '菜单名称',
  `menu_type` CHAR(1) DEFAULT NULL COMMENT 'M=目录,C=菜单,F=按钮',
  `path` VARCHAR(200) DEFAULT NULL COMMENT '路由地址',
  `component` VARCHAR(200) DEFAULT NULL COMMENT '组件路径',
  `perms` VARCHAR(100) DEFAULT NULL COMMENT '权限标识(如order:list)',
  `icon` VARCHAR(100) DEFAULT NULL COMMENT '图标',
  `sort_order` INT DEFAULT 0 COMMENT '排序',
  `visible` TINYINT(1) DEFAULT 1 COMMENT '是否可见',
  `create_by` BIGINT DEFAULT NULL,
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `update_by` BIGINT DEFAULT NULL,
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `del_flag` TINYINT(1) DEFAULT 0,
  PRIMARY KEY (`menu_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='菜单权限表';

-- 23. 角色菜单关联表
DROP TABLE IF EXISTS `sys_role_menu`;
CREATE TABLE `sys_role_menu` (
  `role_id` BIGINT NOT NULL COMMENT '角色ID',
  `menu_id` BIGINT NOT NULL COMMENT '菜单ID',
  PRIMARY KEY (`role_id`, `menu_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='角色菜单关联表';

-- ==================================================================
-- 七、监控运维模块
-- ==================================================================

-- 24. 操作日志表
DROP TABLE IF EXISTS `sys_oper_log`;
CREATE TABLE `sys_oper_log` (
  `log_id` BIGINT NOT NULL AUTO_INCREMENT,
  `title` VARCHAR(100) DEFAULT NULL COMMENT '操作模块',
  `method` VARCHAR(200) DEFAULT NULL COMMENT '请求方法',
  `request_method` VARCHAR(10) DEFAULT NULL COMMENT 'HTTP方法',
  `operator_id` BIGINT DEFAULT NULL COMMENT '操作人ID',
  `operator_name` VARCHAR(50) DEFAULT NULL COMMENT '操作人账号',
  `oper_url` VARCHAR(500) DEFAULT NULL COMMENT '请求URL',
  `oper_ip` VARCHAR(50) DEFAULT NULL COMMENT '请求IP',
  `oper_param` TEXT DEFAULT NULL COMMENT '请求参数',
  `json_result` TEXT DEFAULT NULL COMMENT '返回结果',
  `status` TINYINT(1) DEFAULT NULL COMMENT '0=成功,1=失败',
  `error_msg` TEXT DEFAULT NULL COMMENT '错误信息',
  `oper_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '操作时间',
  PRIMARY KEY (`log_id`),
  KEY `idx_operator` (`operator_id`),
  KEY `idx_oper_time` (`oper_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='操作日志表';

-- 25. 登录日志表
DROP TABLE IF EXISTS `sys_login_log`;
CREATE TABLE `sys_login_log` (
  `login_id` BIGINT NOT NULL AUTO_INCREMENT,
  `admin_id` BIGINT DEFAULT NULL COMMENT '登录用户ID',
  `username` VARCHAR(50) DEFAULT NULL COMMENT '登录账号',
  `login_ip` VARCHAR(50) DEFAULT NULL COMMENT '登录IP',
  `login_location` VARCHAR(100) DEFAULT NULL COMMENT '登录地点',
  `browser` VARCHAR(100) DEFAULT NULL COMMENT '浏览器',
  `os` VARCHAR(100) DEFAULT NULL COMMENT '操作系统',
  `status` TINYINT(1) DEFAULT NULL COMMENT '0=成功,1=失败',
  `msg` VARCHAR(500) DEFAULT NULL COMMENT '提示消息',
  `login_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '登录时间',
  PRIMARY KEY (`login_id`),
  KEY `idx_admin` (`admin_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='登录日志表';

-- 26. 字典类型表
DROP TABLE IF EXISTS `sys_dict_type`;
CREATE TABLE `sys_dict_type` (
  `dict_id` BIGINT NOT NULL AUTO_INCREMENT,
  `dict_name` VARCHAR(100) NOT NULL COMMENT '字典名称',
  `dict_type` VARCHAR(100) NOT NULL COMMENT '字典类型标识',
  `remark` VARCHAR(200) DEFAULT NULL COMMENT '备注',
  `create_by` BIGINT DEFAULT NULL,
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `update_by` BIGINT DEFAULT NULL,
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `del_flag` TINYINT(1) DEFAULT 0,
  PRIMARY KEY (`dict_id`),
  UNIQUE KEY `uk_dict_type` (`dict_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='字典类型表';

-- 27. 字典数据表
DROP TABLE IF EXISTS `sys_dict_data`;
CREATE TABLE `sys_dict_data` (
  `dict_code` BIGINT NOT NULL AUTO_INCREMENT,
  `dict_type` VARCHAR(100) NOT NULL COMMENT '字典类型标识',
  `dict_label` VARCHAR(100) NOT NULL COMMENT '字典标签',
  `dict_value` VARCHAR(100) NOT NULL COMMENT '字典值',
  `sort_order` INT DEFAULT 0 COMMENT '排序',
  `remark` VARCHAR(200) DEFAULT NULL COMMENT '备注',
  `del_flag` TINYINT(1) DEFAULT 0,
  PRIMARY KEY (`dict_code`),
  KEY `idx_dict_type` (`dict_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='字典数据表';

-- 28. 接口监控指标表
DROP TABLE IF EXISTS `sys_api_metrics`;
CREATE TABLE `sys_api_metrics` (
  `metric_id` BIGINT NOT NULL AUTO_INCREMENT,
  `api_path` VARCHAR(200) NOT NULL COMMENT '接口路径',
  `http_method` VARCHAR(10) DEFAULT NULL COMMENT 'HTTP方法',
  `stat_date` DATE NOT NULL COMMENT '统计日期',
  `stat_hour` INT DEFAULT NULL COMMENT '统计小时(0-23)',
  `call_count` INT DEFAULT 0 COMMENT '调用次数',
  `success_count` INT DEFAULT 0,
  `fail_count` INT DEFAULT 0,
  `avg_cost_ms` INT DEFAULT 0 COMMENT '平均耗时(ms)',
  `max_cost_ms` INT DEFAULT 0,
  `p99_cost_ms` INT DEFAULT 0,
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`metric_id`),
  UNIQUE KEY `uk_api_date_hour` (`api_path`, `stat_date`, `stat_hour`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='接口监控指标表';

-- 29. 异常日志表
DROP TABLE IF EXISTS `sys_exception_log`;
CREATE TABLE `sys_exception_log` (
  `exception_id` BIGINT NOT NULL AUTO_INCREMENT,
  `exception_type` VARCHAR(200) DEFAULT NULL COMMENT '异常类型(类名)',
  `exception_msg` TEXT DEFAULT NULL COMMENT '异常消息',
  `stack_trace` TEXT DEFAULT NULL COMMENT '堆栈信息',
  `request_url` VARCHAR(500) DEFAULT NULL COMMENT '请求URL',
  `request_method` VARCHAR(10) DEFAULT NULL COMMENT 'HTTP方法',
  `request_param` TEXT DEFAULT NULL COMMENT '请求参数',
  `operator_id` BIGINT DEFAULT NULL COMMENT '操作人ID',
  `operator_ip` VARCHAR(50) DEFAULT NULL COMMENT '操作人IP',
  `is_handled` TINYINT(1) DEFAULT 0 COMMENT '是否已处理',
  `handle_remark` VARCHAR(500) DEFAULT NULL COMMENT '处理备注',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '发生时间',
  PRIMARY KEY (`exception_id`),
  KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='异常日志表';

-- ==================================================================
-- 八、初始数据
-- ==================================================================

-- 默认管理员账号（密码: admin123，BCrypt 加密）
INSERT INTO `sys_admin` (`username`, `password`, `nickname`, `status`) VALUES
('admin', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '超级管理员', 1);

-- 默认角色
INSERT INTO `sys_role` (`role_name`, `role_key`, `remark`) VALUES
('管理员', 'admin', '拥有全部权限'),
('设计师', 'designer', '查看和操作被指派的订单');

-- 给管理员分配角色
INSERT INTO `sys_admin_role` (`admin_id`, `role_id`) VALUES (1, 1);

-- 示例品类数据
INSERT INTO `ds_category` (`name`, `is_active`, `has_bom`, `is_physical`, `sort_order`) VALUES
('服装定制', 1, 1, 1, 1),
('手工皮具', 1, 1, 1, 2),
('数字插画', 1, 0, 0, 3);

-- 服装定制 - 动态字段
INSERT INTO `ds_custom_field` (`category_id`, `label`, `field_key`, `field_type`, `unit`, `placeholder`, `is_required`, `sort_order`) VALUES
(1, '胸围', 'chest', 'number', 'cm', '请输入胸围尺寸', 1, 1),
(1, '腰围', 'waist', 'number', 'cm', '请输入腰围尺寸', 1, 2),
(1, '肩宽', 'shoulder', 'number', 'cm', '请输入肩宽尺寸', 1, 3),
(1, '衣长', 'length', 'number', 'cm', '请输入衣长', 0, 4),
(1, '面料偏好', 'fabric_type', 'select', NULL, '请选择面料', 0, 5);

-- 更新面料偏好的选项
UPDATE `ds_custom_field` SET `options` = '["纯棉", "亚麻", "丝绸", "羊毛", "混纺"]' WHERE `field_key` = 'fabric_type';

-- 手工皮具 - 动态字段
INSERT INTO `ds_custom_field` (`category_id`, `label`, `field_key`, `field_type`, `unit`, `placeholder`, `is_required`, `sort_order`) VALUES
(2, '皮革类型', 'leather_type', 'select', NULL, '请选择皮革', 1, 1),
(2, '颜色', 'color', 'text', NULL, '期望的颜色', 1, 2),
(2, '尺寸规格', 'size_spec', 'text', NULL, '如：长20cm×宽15cm', 0, 3);

UPDATE `ds_custom_field` SET `options` = '["牛皮", "羊皮", "鳄鱼皮", "植鞣革"]' WHERE `field_key` = 'leather_type';

-- 数字插画 - 动态字段
INSERT INTO `ds_custom_field` (`category_id`, `label`, `field_key`, `field_type`, `placeholder`, `is_required`, `sort_order`) VALUES
(3, '画风', 'art_style', 'select', '请选择画风', 1, 1),
(3, '分辨率', 'resolution', 'select', '请选择分辨率', 0, 2),
(3, '用途', 'usage', 'text', '如：头像、海报、插图等', 0, 3);

UPDATE `ds_custom_field` SET `options` = '["日系", "欧美", "水彩风", "扁平化", "写实"]' WHERE `field_key` = 'art_style';
UPDATE `ds_custom_field` SET `options` = '["1080×1080", "1920×1080", "3000×3000", "自定义"]' WHERE `field_key` = 'resolution';

-- 工作流模板
INSERT INTO `ds_workflow` (`category_id`, `workflow_name`) VALUES
(1, '服装定制流程'),
(2, '皮具制作流程'),
(3, '数字插画流程');

-- 服装定制 - 工作流节点
INSERT INTO `ds_workflow_step` (`workflow_id`, `step_name`, `step_order`, `is_start_step`, `is_end_step`) VALUES
(1, '需求确认', 1, 1, 0),
(1, '面料采购', 2, 0, 0),
(1, '裁剪', 3, 0, 0),
(1, '缝制', 4, 0, 0),
(1, '质检', 5, 0, 0),
(1, '包装发货', 6, 0, 1);

-- 手工皮具 - 工作流节点
INSERT INTO `ds_workflow_step` (`workflow_id`, `step_name`, `step_order`, `is_start_step`, `is_end_step`) VALUES
(2, '需求确认', 1, 1, 0),
(2, '皮料裁切', 2, 0, 0),
(2, '缝线打磨', 3, 0, 0),
(2, '上色封边', 4, 0, 0),
(2, '质检出货', 5, 0, 1);

-- 数字插画 - 工作流节点
INSERT INTO `ds_workflow_step` (`workflow_id`, `step_name`, `step_order`, `is_start_step`, `is_end_step`) VALUES
(3, '需求确认', 1, 1, 0),
(3, '草稿构图', 2, 0, 0),
(3, '线稿细化', 3, 0, 0),
(3, '上色完稿', 4, 0, 0),
(3, '客户验收', 5, 0, 1);

-- 常用字典数据
INSERT INTO `sys_dict_type` (`dict_name`, `dict_type`, `remark`) VALUES
('订单状态', 'order_status', '订单生命周期状态'),
('意向状态', 'request_status', '客户意向状态'),
('支付类型', 'payment_type', '支付类型'),
('物料分类', 'material_category', '物料分类');

INSERT INTO `sys_dict_data` (`dict_type`, `dict_label`, `dict_value`, `sort_order`) VALUES
('order_status', '待支付', '0', 0),
('order_status', '生产中', '1', 1),
('order_status', '待发货', '2', 2),
('order_status', '待收货', '3', 3),
('order_status', '已完成', '4', 4),
('order_status', '已取消', '5', 5),
('request_status', '待处理', '0', 0),
('request_status', '已转单', '1', 1),
('request_status', '已关闭', '2', 2),
('payment_type', '预付款', '1', 1),
('payment_type', '尾款', '2', 2),
('material_category', '面料', 'fabric', 1),
('material_category', '辅料', 'accessory', 2),
('material_category', '五金件', 'hardware', 3);

-- 默认菜单结构
INSERT INTO `sys_menu` (`parent_id`, `menu_name`, `menu_type`, `path`, `perms`, `icon`, `sort_order`) VALUES
-- 一级目录
(0, '订单管理', 'M', '/order', NULL, 'ShoppingCart', 1),
(0, '意向管理', 'M', '/request', NULL, 'Mail', 2),
(0, '配置中心', 'M', '/config', NULL, 'Settings', 3),
(0, '供应链', 'M', '/supply', NULL, 'Package', 4),
(0, '作品集', 'M', '/portfolio', NULL, 'Image', 5),
(0, '数据分析', 'M', '/statistics', NULL, 'TrendingUp', 6),
(0, '系统管理', 'M', '/system', NULL, 'Tool', 7),
-- 订单管理子菜单
(1, '订单看板', 'C', '/order/kanban', 'order:kanban', NULL, 1),
(1, '订单列表', 'C', '/order/list', 'order:list', NULL, 2),
-- 意向管理子菜单
(2, '意向池', 'C', '/request/list', 'request:list', NULL, 1),
-- 配置中心子菜单
(3, '品类管理', 'C', '/config/category', 'category:list', NULL, 1),
(3, '动态字段', 'C', '/config/field', 'field:list', NULL, 2),
(3, '工作流管理', 'C', '/config/workflow', 'workflow:list', NULL, 3),
-- 供应链子菜单
(4, '物料管理', 'C', '/supply/material', 'material:list', NULL, 1),
(4, 'BOM模板', 'C', '/supply/bom', 'bom:list', NULL, 2),
-- 作品集子菜单
(5, '作品管理', 'C', '/portfolio/list', 'portfolio:list', NULL, 1),
-- 数据分析子菜单
(6, '经营看板', 'C', '/statistics/dashboard', 'statistics:dashboard', NULL, 1),
-- 系统管理子菜单
(7, '用户管理', 'C', '/system/admin', 'admin:list', NULL, 1),
(7, '角色管理', 'C', '/system/role', 'role:list', NULL, 2),
(7, '菜单管理', 'C', '/system/menu', 'menu:list', NULL, 3),
(7, '字典管理', 'C', '/system/dict', 'dict:list', NULL, 4),
(7, '操作日志', 'C', '/system/log', 'log:list', NULL, 5);

-- 管理员角色拥有全部菜单权限
INSERT INTO `sys_role_menu` (`role_id`, `menu_id`)
SELECT 1, menu_id FROM `sys_menu`;

-- 设计师角色拥有订单、意向、作品集菜单权限
INSERT INTO `sys_role_menu` (`role_id`, `menu_id`)
SELECT 2, menu_id FROM `sys_menu` WHERE parent_id IN (1, 2, 5) OR menu_id IN (1, 2, 5);

-- 6. 客户收货地址表
DROP TABLE IF EXISTS `ds_address`;
CREATE TABLE `ds_address` (
  `address_id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '地址ID',
  `user_id` BIGINT NOT NULL COMMENT '所属用户',
  `receiver_name` VARCHAR(100) NOT NULL COMMENT '收货人姓名',
  `phone` VARCHAR(20) NOT NULL COMMENT '手机号',
  `province` VARCHAR(50) DEFAULT NULL COMMENT '省份',
  `city` VARCHAR(50) DEFAULT NULL COMMENT '城市',
  `district` VARCHAR(50) DEFAULT NULL COMMENT '区县',
  `detail_address` VARCHAR(255) DEFAULT NULL COMMENT '详细地址',
  `is_default` TINYINT(1) DEFAULT 0 COMMENT '否是默认地址',
  `create_by` BIGINT DEFAULT NULL,
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `update_by` BIGINT DEFAULT NULL,
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `del_flag` TINYINT(1) DEFAULT 0,
  PRIMARY KEY (`address_id`),
  KEY `idx_user` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='客户收货地址表';

-- 7. 聊天消息表
DROP TABLE IF EXISTS `ds_chat_message`;
CREATE TABLE `ds_chat_message` (
  `message_id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '消息ID',
  `order_id` BIGINT NOT NULL COMMENT '关联订单',
  `sender_type` VARCHAR(10) NOT NULL COMMENT '发送方: client/admin',
  `sender_id` BIGINT NOT NULL COMMENT '发送人ID',
  `content` TEXT COMMENT '消息内容',
  `msg_type` VARCHAR(20) DEFAULT 'text' COMMENT '消息类型: text/image',
  `is_read` TINYINT(1) DEFAULT 0 COMMENT '是否已读',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '发送时间',
  PRIMARY KEY (`message_id`),
  KEY `idx_order_id` (`order_id`),
  KEY `idx_sender` (`sender_type`, `sender_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='聊天消息表';
