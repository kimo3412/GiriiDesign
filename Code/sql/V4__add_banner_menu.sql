-- =====================================================
-- V4: 添加轮播图管理菜单
-- 日期: 2026-04-14
-- =====================================================

-- 添加轮播图管理菜单（挂在配置中心下）
INSERT INTO sys_menu (menu_id, parent_id, menu_name, menu_type, path, component, perms, icon, sort_order, visible, create_time, del_flag) VALUES
(32, 3, '轮播图管理', 'C', '/config/banner', NULL, 'banner:list', 'ImagesOutline', 4, 1, NOW(), 0);

-- 给admin角色分配轮播图管理权限
INSERT INTO sys_role_menu (role_id, menu_id) VALUES (1, 32);
