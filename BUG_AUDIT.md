# 发布前 Bug 巡检记录

更新时间：2026-05-01

## 已修复

- 小程序订单列表不再对 `/api/v1/app/orders/my` 做前端假分页追加。后端当前返回完整列表，旧逻辑在订单数达到 10 条后滚动到底会重复追加同一批订单。
- 小程序作品列表不再对 `/api/v1/app/public/portfolios` 做前端假分页追加。后端当前返回完整列表，旧逻辑在作品数达到 10 条后会重复追加。
- 节点工作台数值字段类型警告：`InputNumber` 组件期望 `Number` 类型但收到 `String`，已在表单提交时做类型转换。

## 已验证通过

- 后端编译：`mvn -q -DskipTests compile`
- Web 管理端构建：`pnpm run build`
- 小程序微信端构建：`npm run build:mp-weixin`
- 后台登录接口：`POST /api/v1/auth/login`
- 后台核心读取接口：
  - `GET /api/v1/admin/categories`
  - `GET /api/v1/admin/orders`
  - `GET /api/v1/admin/statistics/dashboard`
  - `GET /api/v1/admin/banners`
  - `GET /api/v1/admin/ai-config`
- 小程序公开接口：
  - `GET /api/v1/app/public/banners`
  - `GET /api/v1/app/public/portfolios`
- 小程序客户侧接口：
  - `POST /api/v1/app/auth/mock-login`
  - `GET /api/v1/app/auth/info`
  - `GET /api/v1/app/address/list`
  - `GET /api/v1/app/orders/my`
  - `GET /api/v1/app/notifications/unread-count`
  - `GET /api/v1/app/notifications`

## 权限隔离检查

- `designer1`、`designer2` 可以访问后台订单与节点工作台。
- `designer1`、`designer2` 访问 `GET /api/v1/admin/statistics/dashboard` 返回 403，经营看板没有暴露给设计师角色。
- 订单与节点工作台后端已有设计师范围过滤：`OrderServiceImpl` 中 `listOrders`、`getOrderDetail`、`getKanbanData`、`getWorkbenchData` 会按设计师身份做访问控制。
- **2026-05-01 补充验证**：`designer1` 登录后经营看板显示 0 单（与自己负责的订单范围一致），订单看板显示"共 3 单"（均为李设计师负责），菜单不显示供应链/配置中心/系统管理/客户管理，权限隔离符合预期。
- **2026-05-01 多角色菜单验证**（通过 `/api/v1/admin/menus` 接口确认）：
  - `storekeeper` → 供应链（物料管理/库存管理/库存记录）
  - `purchaser` → 供应链（物料管理/库存管理）
  - `finance` → 订单管理（订单列表）、数据分析（经营看板）
  - `customer_service` → 消息中心（在线沟通）、客户管理（客户列表/地址管理）
  - 各角色菜单隔离符合预期，未见越权菜单

## AI 配置检查

- **2026-05-01 配置 DeepSeek API**：已将 `https://api.deepseek.com` + `deepseek-chat` + API Key 配置到数据库并启用。
- 发送测试消息后返回"配置可用"，API 连通正常。

## 节点工作台写操作检查

- **2026-05-01 验证**：填写胸围/腰围字段 → 保存记录成功 → 点击推进到下一步 → 弹出确认框 → 确认后订单自动切换到下一个，节点推进成功。
- 注意：填写时控制台有 Vue warn（`Expected Number, got String`），已修复。

## 仍建议继续检查

- 浏览器自动化打开登录页时出现过 Vue Router 警告：未登录状态访问 `/statistics/dashboard` 会提示当前静态路由尚未匹配。该路径来自动态菜单，登录后应由后端菜单注入，但建议后续人工再点一次完整登录流程确认。
- `web-admin/src/api/common/index.ts` 中存在部分历史 API 包装未匹配到当前后端接口，例如旧统计接口和旧日志接口。目前看主要是冗余代码，未发现被核心页面直接使用。
- 节点工作台的保存、推进、阻塞、回退属于写操作，建议在测试库中补一轮手工流程测试，重点确认表单必填、图片必填、JSON 字段、通知触发和历史记录展示。
- 设计师节点工作台写操作推进后，小程序端通知是否正常推送（建议人工验证）。
