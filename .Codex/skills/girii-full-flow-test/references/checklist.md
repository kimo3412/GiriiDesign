# GiriiDesign Full-Flow Checklist

## Build Gates

Backend:

```powershell
cd Code
mvn -q -DskipTests compile
```

Web admin:

```powershell
cd web-admin
pnpm run build
```

## Key Modules To Recheck

- Orders
- Request list / intent pool
- Workbench / kanban
- Chat
- AI config
- Customer management
- Inventory management

## High-Risk Web Pages

- `/config/ai`
- Request list / intent pool page
- Order workbench page
- Order detail page
- Chat page
- Customer list page
- Inventory page

## Backend / Database Checkpoints

Verify these tables exist when the branch touches their features:

- `ds_ai_config`
- `ds_notification`
- `ds_banner`
- `ds_order`
- `ds_chat_message`
- `sys_role`
- `sys_menu`
- `sys_role_menu`

## Known Test Accounts

- `admin / admin123`
- `designer1 / admin123`
- `designer2 / admin123`

Notes:

- Extra roles such as `finance`, `customer_service`, `storekeeper`, and `purchaser` may exist in `sys_role`, but often still require actual admin users to be created before manual role testing.

## Core Acceptance Themes

- No blank admin pages
- No broken route generation
- Buttons trigger real backend effects
- Role isolation matches backend restrictions, not only hidden menus
- Designer-scoped pages only show that designer's owned work
- AI config can load and save
- Chat unread state stays consistent
- Notifications remain healthy for mini-app flows
