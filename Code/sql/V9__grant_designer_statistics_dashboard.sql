-- V9: allow designer role to open the scoped statistics dashboard.
-- The backend filters dashboard data by current designer, so designers can safely view this menu.

INSERT INTO sys_role_menu (role_id, menu_id)
SELECT 2, 6
WHERE NOT EXISTS (
    SELECT 1 FROM sys_role_menu WHERE role_id = 2 AND menu_id = 6
);

INSERT INTO sys_role_menu (role_id, menu_id)
SELECT 2, 17
WHERE NOT EXISTS (
    SELECT 1 FROM sys_role_menu WHERE role_id = 2 AND menu_id = 17
);
