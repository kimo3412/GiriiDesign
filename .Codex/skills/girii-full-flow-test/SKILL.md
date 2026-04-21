---
name: girii-full-flow-test
description: End-to-end verification workflow for the GiriiDesign backend and web-admin. Use when validating release readiness, regression-checking core business flows, or confirming that backend APIs, admin pages, role-based access, AI config, chat, and notifications still work together after code changes.
---

# Girii Full Flow Test

## Overview

Use this skill when you need a reliable, project-specific release check for GiriiDesign's Spring Boot backend and `web-admin` frontend. It is optimized for fast regression verification after feature work, bug fixes, database migrations, permission changes, or deployment prep.

Load `references/checklist.md` before running the workflow so you can reuse the project's current test accounts, key pages, and database checkpoints.

## Workflow

### 1. Build And Environment Sanity

- Confirm you are in the GiriiDesign workspace with `Code/` and `web-admin/`.
- Check whether the local database is expected to be available before any DB-dependent verification.
- Prefer quick blockers first:
  - Backend compile
  - Frontend build
  - Critical env/config mismatches

Run:

```powershell
cd Code
mvn -q -DskipTests compile
```

```powershell
cd web-admin
pnpm run build
```

If either command fails, stop the flow, capture the blocker clearly, and fix compile/build issues before doing manual page testing.

### 2. Backend Verification

Focus on whether the backend is structurally healthy and whether recent business changes are actually reachable.

Check:

- Security and role gating still compile after any auth or menu changes.
- Core tables required by recent features exist.
- New admin endpoints are reachable in principle and mapped to the expected modules.
- Order, chat, AI config, and notification paths still line up with the current code.

For DB-backed release checks, verify the presence of the project-critical tables and menus from `references/checklist.md`.

When the change touches permissions or menu-driven pages, verify both:

- `sys_menu` / `sys_role_menu` data exists as expected
- backend route protection still matches the intended role scope

### 3. Web-Admin Verification

Test the admin UI as an operator would use it, not just as a renderer.

Always cover these behaviors:

- Login succeeds
- Dynamic routes resolve
- Menu visibility matches the logged-in role
- Buttons that mutate state actually call working backend endpoints
- Empty, loading, and error states do not strand the user on blank pages

Prioritize the highest-risk pages first:

- Request list / intent pool
- Order workbench and order detail
- Chat
- AI config
- Customer and inventory pages if the current branch touched them

For each page under test:

1. Open the page through the real menu when possible.
2. Confirm the initial data load succeeds.
3. Click at least one meaningful action button.
4. Confirm UI feedback changes after the action.
5. Check console/network only if behavior is unclear.

### 4. Role Isolation Verification

When the branch changes auth, menus, or workflow behavior, verify role isolation explicitly instead of assuming menu filtering is enough.

Minimum role pass:

- `admin`: should see and operate full management scope
- `designer`: should only see and act on owned work where the project enforces designer scoping

If the environment has users for these roles, also verify:

- `finance`
- `customer_service`
- `storekeeper`
- `purchaser`

Check both:

- menu visibility
- blocked write access to out-of-scope backend actions

Do not call permissions complete unless a lower-privilege account has actually been exercised.

### 5. AI, Chat, And Notification Paths

These are cross-cutting flows, so test them as linked behavior rather than isolated pages.

AI config:

- Open the admin AI config page
- Confirm current values load
- Save a safe configuration change if the task requires it
- If credentials are available, run the built-in test action

Chat:

- Confirm a conversation list can load
- Confirm unread state changes when a conversation is opened or marked read
- If AI customer service is enabled, verify an AI reply can be persisted and surfaced to the expected chat clients

Notifications:

- Treat notifications as mini-app-facing unless the project explicitly adds a web-admin notification surface
- Verify backend notification logic and data integrity when recent order/payment/workbench changes touched notification triggers

### 6. Reporting Results

Report findings in this order:

1. Build or runtime blockers
2. Broken business flows
3. Permission or data-scope leaks
4. UI defects that mislead the operator
5. Residual risks or untested areas

When no issue is found, say what you actually verified so the result is auditable.
