# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with this repository.

## 项目概述

这是一个面向独立设计师工作室的生产流程管理系统毕业设计项目，定位为“低代码生产管理平台”，重点解决非标定制、强沟通、长周期交付场景下的协同问题。

- 后端：Spring Boot 3.4.3 + Java 17 + MyBatis-Plus + Redis + MySQL 8.0+
- 管理后台：Vue 3 + TypeScript + Naive UI + Vite，基于 naive-ui-admin 二次开发
- 微信小程序：Uni-app + Vue 3 + Pinia
- 代码结构：
  - `Code/`：后端
  - `web-admin/`：Web 管理后台
  - `mini-app/`：微信小程序

## 常用命令

### 后端

```bash
cd Code
mvn spring-boot:run
mvn -q -DskipTests compile
mvn clean package -DskipTests
mvn test
```

### Web 管理后台

```bash
cd web-admin
pnpm install
pnpm run dev
pnpm run build
pnpm run lint:eslint
```

### 微信小程序

```bash
cd mini-app
npm install
npm run dev:mp-weixin
npm run build:mp-weixin
```

## 端口与连接

| 服务 | 端口 | 说明 |
| :--- | :--- | :--- |
| 后端 API | 8081 | Spring Boot |
| Web 管理后台 | 3100 | Vite dev server |
| 小程序 H5 调试 | 5173 | 仅 H5 调试场景 |

- Web 管理后台代理：`/api` -> `http://localhost:8081/api`
- 小程序请求基地址：`mini-app/utils/request.js`
- WebSocket：`ws://localhost:8081/ws/chat`

## 当前真实状态

以下内容反映当前仓库与本地数据库已经落地过的状态，不要再按早期计划文档假设它们“尚未开发”。

### 已完成或基本完成

- 管理后台核心页面已不再是空白页，订单、意向池、作品、客户、供应链、系统配置等页面均有实际 UI 与接口对接。
- 管理后台大卡片布局已经做过一轮压缩与视觉优化，订单工作台、订单看板、在线沟通、意向池、经营看板、角色/用户/订单列表等页面都做过针对性优化。
- 节点工作台已经改为更适合设计师使用的生产控制台视图：顶部流程感知、当前节点订单横向切换、节点录入主区域、右侧订单摘要与最近动态。
- 设计师视角的订单、节点工作台和看板已按“只看自己负责内容”的方向做了后端范围过滤。
- 小程序首页、订单列表、聊天页、个人中心已按 Atelier 风格做过重设；订单详情页按要求保留原有设计。
- 小程序首页轮播图已接入数据库与本地默认素材。
- Web 轮播图管理页的状态已改为开关切换启用/停用。
- 上传静态资源访问已打通：`/uploads/**` 由静态资源映射处理。
- 聊天 WebSocket 链路存在，支持客户、后台与 AI 客服消息。
- AI 客服已接入聊天链路，并支持后台配置优先生效。
- 通知系统已落地到小程序端，支持通知列表、未读数、单条已读、全部已读。
- 多角色菜单和基础角色体系已扩展，包含 `admin`、`designer`、`storekeeper`、`purchaser`、`finance`、`customer_service`。
- 客户管理、库存管理、库存记录等后台页面已补齐，避免空白页。
- 小程序订单列表、作品列表已修复“前端假分页导致滚动重复追加”的问题。

### 已完成但仍建议人工联调确认

- AI 客服：代码链路已通，但最终可用性取决于后台是否填写真实可用的 `apiUrl / apiKey / model / systemPrompt`。
- 通知触发：支付、节点推进、阻塞/解除阻塞、生产完成等触发点已存在，建议用测试库完整跑一次。
- 节点工作台写操作：保存、推进、阻塞、回退会改变订单状态和历史记录，建议人工确认表单必填、图片必填、JSON 字段、通知触发和历史展示。
- 浏览器自动化巡检时观察到一个警告：未登录状态直接访问 `/statistics/dashboard` 时，动态路由尚未注入前会出现 Vue Router “No match found” 警告。该路径来自后端菜单，登录后应由动态菜单注入，建议后续人工再点一次完整登录流程确认。

### 后续规划，不要误当成当前必须补完

- SaaS 多租户隔离。
- 聊天与订单的更强绑定协同。
- 更深度的库存与 BOM 联动。
- 更完整的视觉设计系统组件化沉淀。

## 最新巡检记录

发布前 bug 巡检记录在：

- `BUG_AUDIT.md`

已验证通过：

- `mvn -q -DskipTests compile`
- `pnpm run build`
- `npm run build:mp-weixin`
- `POST /api/v1/auth/login`
- `GET /api/v1/admin/categories`
- `GET /api/v1/admin/orders`
- `GET /api/v1/admin/statistics/dashboard`
- `GET /api/v1/admin/banners`
- `GET /api/v1/admin/ai-config`
- `GET /api/v1/app/public/banners`
- `GET /api/v1/app/public/portfolios`
- `POST /api/v1/app/auth/mock-login`
- `GET /api/v1/app/auth/info`
- `GET /api/v1/app/address/list`
- `GET /api/v1/app/orders/my`
- `GET /api/v1/app/notifications/unread-count`
- `GET /api/v1/app/notifications`

权限实测结论：

- `designer1 / admin123`、`designer2 / admin123` 可以访问后台订单与节点工作台。
- `designer1`、`designer2` 访问 `GET /api/v1/admin/statistics/dashboard` 返回 403，经营看板没有暴露给设计师角色。

## 项目专用测试 Skill

仓库内已有全流程测试 skill：

- `.Codex/skills/girii-full-flow-test/SKILL.md`

用途：

- 后端 + `web-admin` 发布前回归。
- 角色权限隔离检查。
- AI 配置、聊天、通知等高风险链路检查。

建议直接使用：

```text
请使用 $girii-full-flow-test，对当前仓库做一轮完整回归测试，并输出：已验证项、发现的问题、未覆盖风险。
```

## 后端架构

核心包结构：`com.designstudio`

| 包 | 说明 |
| :--- | :--- |
| `common/` | JWT、Redis、统一返回、异常处理、静态资源映射、WebSocket、MyBatis-Plus 配置 |
| `system/` | 后台 RBAC：管理员、角色、菜单、字典、日志 |
| `config/` | 品类、动态字段、工作流、轮播图、AI 配置 |
| `order/` | 意向单、订单、进度、工作台、BOM |
| `customer/` | C 端用户、地址、后台客户管理 |
| `chat/` | WebSocket 聊天、消息记录、AI 客服消息 |
| `portfolio/` | 作品集 |
| `supply/` | 物料、BOM 模板、库存 |
| `statistics/` | 看板与统计接口 |

核心机制：

- JWT 鉴权：Token 存 Redis，支持黑名单。
- 统一返回：`R<T>`。
- 乐观锁：`ds_order`、`ds_material`。
- 逻辑删除：`del_flag`。
- 动态表单：品类 -> `ds_custom_field`。
- 工作流状态机：`ds_workflow_step`。
- OpenAPI：`/swagger-ui.html`。

## 数据库

- 数据库名：`design_studio`
- 初始化脚本：`Code/sql/init_schema.sql`
- 测试数据：`Code/sql/test_data.sql`
- 最新导出库：`Code/sql/design_studio.sql`

默认测试账号：

- `admin / admin123`
- `designer1 / admin123`
- `designer2 / admin123`

当前已确认存在的关键表：

- `ds_banner`
- `ds_notification`
- `ds_ai_config`
- `ds_order`
- `ds_chat_message`
- `sys_role`
- `sys_menu`
- `sys_role_menu`

当前已确认存在的关键菜单：

- `/config/banner`
- `/config/ai`
- `/chat/index`
- `/customer/list`
- `/customer/address`
- `/supply/inventory`
- `/supply/inventory/record`
- `/workbench/nodes`

## 前端架构

### Web 管理后台：`web-admin/`

- 基于 `naive-ui-admin` 二次开发。
- 路径别名：`@/` -> `src/`，`#/` -> `types/`。
- 请求层：使用 `alova`，不是 axios。
- 动态路由：由后端菜单驱动，入口在 `src/router/generator.ts`。

重点页面：

- `src/views/statistics/dashboard/index.vue`
- `src/views/order/workbench/index.vue`
- `src/views/order/kanban/index.vue`
- `src/views/order/list/index.vue`
- `src/views/request/list/index.vue`
- `src/views/chat/index.vue`
- `src/views/config/ai/index.vue`
- `src/views/config/banner/index.vue`
- `src/views/customer/list/index.vue`
- `src/views/supply/inventory/index.vue`
- `src/views/system/user/index.vue`
- `src/views/system/role/index.vue`

### 微信小程序：`mini-app/`

重点页面：

- `pages/index/`
- `pages/order/`
- `pages/chat/`
- `pages/user/`
- `pages/user/notification/`
- `pages/portfolio/`

注意：小程序目前存在双目录结构。

| 目录 | 用途 |
| :--- | :--- |
| `src/pages/` | 开发源代码 |
| `pages/` | 当前 `pages.json` 实际引用的页面目录 |

每次修改小程序页面后，必须同步 `src/pages/` 与 `pages/`，然后重新构建：

```bash
cd mini-app
npm run build:mp-weixin
```

## API 路由规范

- 统一前缀：`/api/v1/`
- 后台接口：`/api/v1/admin/...`
- C 端接口：`/api/v1/app/...`
- 开放接口：`/api/v1/auth/**`、`/api/v1/app/auth/**`、`/api/v1/app/public/**`、`/ws/**`、`/uploads/**`

## 订单状态与工作流

### 订单状态码

| 值 | 含义 |
| :--- | :--- |
| 0 | 待支付预付款 |
| 1 | 生产中 |
| 2 | 待发货 |
| 3 | 待收货 |
| 4 | 已完成 |
| 5 | 已取消 |
| 6 | 待付尾款 |

### 工作流动作

| 动作 | 说明 |
| :--- | :--- |
| `save` | 保存进度，不推进 |
| `advance` | 推进到下一节点 |
| `rollback` | 回退到前序节点 |
| `block` | 阻塞并记录原因 |
| `unblock` | 解除阻塞 |

## 角色体系

| 角色 | 说明 |
| :--- | :--- |
| `admin` | 全权限 |
| `designer` | 订单、意向、作品、工作台、聊天；核心看板和详情只看自己负责订单 |
| `storekeeper` | 物料与库存相关 |
| `purchaser` | 采购与库存相关 |
| `finance` | 订单查看、统计、财务相关 |
| `customer_service` | 客户管理、聊天、沟通相关 |

注意：

- 当前数据库里角色和菜单关系已存在，但不保证每种角色都有实际后台账号。
- 做权限验证时不能只看菜单，还要验证接口写操作是否被正确拦截。
- 设计师视角的工作台和看板应始终是“自己负责的内容”，不是全局数据。

## AI 客服与通知

### AI 客服

- 默认支持 OpenAI 兼容接口风格。
- 不绑定单一厂商。
- 后台 AI 配置页管理：
  - `enabled`
  - `provider`
  - `apiUrl`
  - `apiKey`
  - `model`
  - `systemPrompt`
- 配置读取顺序：数据库 `ds_ai_config` 优先，`application.yml` 兜底。

自动回复链路：

```text
客户端发消息 -> ChatWebSocketHandler.handleTextMessage()
  -> 持久化客户消息
  -> broadcastToAdmins()
  -> 判断 aiCustomerService.isEnabled() && userType == client
  -> CompletableFuture.runAsync()
  -> getRecentMessages(10)
  -> aiCustomerService.getResponse(userId, messages)
  -> 持久化 AI 消息(senderType=2)
  -> 推送给客户端与后台聊天端
```

### 通知系统

- 当前通知系统主要服务小程序端。
- 不额外拆 web-admin 通知中心，除非明确提出新需求。
- 触发点集中在订单支付、进度推进、阻塞/解除阻塞、生产完成等节点。

小程序通知接口：

- `GET /api/v1/app/notifications`
- `GET /api/v1/app/notifications/unread-count`
- `PUT /api/v1/app/notifications/{id}/read`
- `PUT /api/v1/app/notifications/read-all`

小程序通知页面：

- `src/pages/user/notification/index.vue`
- `pages/user/notification/index.vue`

## 行为准则

1. **始终使用中文回答。**
2. **修改文件前必须先搜索确认上下文** — 查找相关函数、接口、组件的实际实现，避免基于假设修改。
3. **严禁虚构不存在的函数、API 或接口** — 所有引用必须有源码依据。

## 已知注意事项

1. 仓库历史上存在乱码文档；修改文档时优先直接改为正常中文 UTF-8，不要继续复制乱码。
2. 判断数据库真实结构时，优先看当前 MySQL 或最新导出库 `Code/sql/design_studio.sql`，不要只依赖旧 SQL 文件。
3. 小程序页面变更要同步 `src/pages/` 与 `pages/` 两份目录。
4. 权限相关改动必须同时检查：`sys_menu`、`sys_role_menu`、后端接口拦截、前端菜单/按钮显隐。
5. AI 功能是否真正生效，取决于后台配置是否填写真实可用的模型参数。
6. 当前通知默认只验证小程序端，不要在未明确需求时扩展成 web-admin 通知中心。
7. `web-admin/src/api/common/index.ts` 中存在部分历史 API 包装未匹配当前后端接口，当前看主要是冗余代码，改动前先确认是否仍被页面引用。
