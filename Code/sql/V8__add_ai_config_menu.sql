-- =====================================================
-- V8: add ai config menu
-- Date: 2026-04-20
-- =====================================================

INSERT INTO sys_menu (menu_id, parent_id, menu_name, menu_type, path, component, perms, icon, sort_order, visible, create_time, del_flag)
SELECT 33, 3, 'AI配置', 'C', '/config/ai', NULL, 'ai:config', 'HardwareChipOutline', 5, 1, NOW(), 0
FROM DUAL
WHERE NOT EXISTS (
    SELECT 1 FROM sys_menu WHERE menu_id = 33
);

INSERT INTO sys_role_menu (role_id, menu_id)
SELECT 1, 33 FROM DUAL
WHERE NOT EXISTS (
    SELECT 1 FROM sys_role_menu WHERE role_id = 1 AND menu_id = 33
);
