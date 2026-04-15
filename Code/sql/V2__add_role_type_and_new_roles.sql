-- =====================================================
-- V2: 添加角色类型字段和新角色
-- 日期: 2026-04-14
-- =====================================================

-- 1. 给 sys_role 表添加 role_type 字段
ALTER TABLE sys_role ADD COLUMN role_type VARCHAR(50) NULL DEFAULT NULL COMMENT '角色类型: admin/designer/storekeeper/purchaser/finance/customer_service' AFTER role_key;

-- 2. 更新现有角色的 role_type
UPDATE sys_role SET role_type = 'admin' WHERE role_key = 'admin';
UPDATE sys_role SET role_type = 'designer' WHERE role_key = 'designer';

-- 3. 新增菜单 (库存管理、客户管理)
-- 库存管理菜单 (parent_id=4 供应链)
INSERT INTO sys_menu (menu_id, parent_id, menu_name, menu_type, path, component, perms, icon, sort_order, visible, create_time, del_flag) VALUES
(27, 4, '库存管理', 'C', '/supply/inventory', NULL, 'inventory:list', 'CubeOutline', 3, 1, NOW(), 0),
(28, 4, '库存记录', 'C', '/supply/inventory/record', NULL, 'inventory:record', 'ListOutline', 4, 1, NOW(), 0);

-- 客户管理菜单 (新顶级目录)
INSERT INTO sys_menu (menu_id, parent_id, menu_name, menu_type, path, component, perms, icon, sort_order, visible, create_time, del_flag) VALUES
(29, 0, '客户管理', 'M', '/customer', NULL, NULL, 'PeopleOutline', 9, 1, NOW(), 0),
(30, 29, '客户列表', 'C', '/customer/list', NULL, 'customer:list', NULL, 1, 1, NOW(), 0),
(31, 29, '地址管理', 'C', '/customer/address', NULL, 'customer:address', NULL, 2, 1, NOW(), 0);

-- 4. 新增角色
INSERT INTO sys_role (role_id, role_name, role_key, role_type, remark, create_time, del_flag) VALUES
(3, '库管', 'storekeeper', 'storekeeper', '负责物料管理和库存查看', NOW(), 0),
(4, '采购', 'purchaser', 'purchaser', '负责物料采购和库存管理', NOW(), 0),
(5, '财务', 'finance', 'finance', '负责订单收款和财务报表', NOW(), 0),
(6, '客服', 'customer_service', 'customer_service', '负责客户沟通和在线答疑', NOW(), 0);

-- 5. 角色菜单权限分配
-- 库管角色: 物料管理(14) + 库存管理(27) + 库存记录(28)
INSERT INTO sys_role_menu (role_id, menu_id) VALUES
(3, 14), (3, 27), (3, 28);

-- 采购角色: 物料管理(14) + 库存管理(27) + 库存记录(28)
INSERT INTO sys_role_menu (role_id, menu_id) VALUES
(4, 14), (4, 27), (4, 28);

-- 财务角色: 订单列表(9) + 经营看板(17)
INSERT INTO sys_role_menu (role_id, menu_id) VALUES
(5, 9), (5, 17);

-- 客服角色: 客户列表(30) + 地址管理(31) + 在线沟通(24)
INSERT INTO sys_role_menu (role_id, menu_id) VALUES
(6, 30), (6, 31), (6, 24);

-- 6. 更新 admin 角色菜单 (增加新菜单权限)
INSERT INTO sys_role_menu (role_id, menu_id) VALUES
(1, 27), (1, 28), (1, 29), (1, 30), (1, 31);

-- 7. 更新 designer 角色 (增加在线沟通)
INSERT INTO sys_role_menu (role_id, menu_id) VALUES
(2, 24);
