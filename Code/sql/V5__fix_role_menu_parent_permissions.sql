-- =====================================================
-- V5: fill missing parent menu permissions for new roles
-- Date: 2026-04-20
-- =====================================================

-- Storekeeper and purchaser need the supply parent menu.
INSERT INTO sys_role_menu (role_id, menu_id)
SELECT 3, 4 FROM DUAL
WHERE NOT EXISTS (
    SELECT 1 FROM sys_role_menu WHERE role_id = 3 AND menu_id = 4
);

INSERT INTO sys_role_menu (role_id, menu_id)
SELECT 4, 4 FROM DUAL
WHERE NOT EXISTS (
    SELECT 1 FROM sys_role_menu WHERE role_id = 4 AND menu_id = 4
);

-- Finance needs order/statistics parent menus.
INSERT INTO sys_role_menu (role_id, menu_id)
SELECT 5, 1 FROM DUAL
WHERE NOT EXISTS (
    SELECT 1 FROM sys_role_menu WHERE role_id = 5 AND menu_id = 1
);

INSERT INTO sys_role_menu (role_id, menu_id)
SELECT 5, 6 FROM DUAL
WHERE NOT EXISTS (
    SELECT 1 FROM sys_role_menu WHERE role_id = 5 AND menu_id = 6
);

-- Customer service needs customer/chat parent menus.
INSERT INTO sys_role_menu (role_id, menu_id)
SELECT 6, 29 FROM DUAL
WHERE NOT EXISTS (
    SELECT 1 FROM sys_role_menu WHERE role_id = 6 AND menu_id = 29
);

INSERT INTO sys_role_menu (role_id, menu_id)
SELECT 6, 23 FROM DUAL
WHERE NOT EXISTS (
    SELECT 1 FROM sys_role_menu WHERE role_id = 6 AND menu_id = 23
);
