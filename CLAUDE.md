# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目概述

这是一个面向独立设计师工作室的毕业设计项目，定位为“低代码生产流程管理平台”，用于解决非标定制、强沟通、长周期交付场景下的协同问题。

- 后端：Spring Boot 3.4.3 + Java 17 + MyBatis-Plus + Redis + MySQL 8.0+
- 管理后台：Vue 3 + TypeScript + Naive UI + Vite
- 微信小程序：Uni-app + Vue 3 + Pinia
- 仓库结构：
  - `Code/`：后端
  - `web-admin/`：管理后台
  - `mini-app/`：微信小程序

## 常用命令

### 后端

```bash
cd Code
./mvnw spring-boot:run
./mvnw clean package -DskipTests
./mvnw test
```

快速编译校验：

```bash
cd Code
mvn -q -DskipTests compile
```

### 管理后台

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
| 管理后台 | 3100 | Vite dev server |
| 小程序 H5 调试 | 5173 | 仅 H5 调试场景 |

- 管理后台代理：`/api` -> `http://localhost:8081/api`
- 小程序请求基地址：`mini-app/utils/request.js`
- WebSocket：`ws://localhost:8081/ws/chat`

## 当前真实状态

以下内容是当前仓库和本地数据库已经落地过的状态，不要再按旧计划文档假设它们“尚未开发”。

### 已完成或基本完成

1. 管理后台核心列表页已完成分页接入
   - 订单、意向、物料、BOM、作品集等都已按分页接口改造
2. 小程序订单流程已做“仅展示当前及后续步骤”的简化
3. 首页轮播图已数据库化
   - 后端有 `ds_banner`
   - 后台已有轮播图管理页
   - 小程序首页已对接
4. 上传静态资源访问已接通
   - `/uploads/**` 由静态资源映射处理
5. 聊天断线重连已落地
6. AI 客服已接入聊天链路
   - 客户消息可触发 AI 回复
   - AI 回复会写入聊天消息
   - AI 回复同时可推送到客户端和后台聊天端
7. AI 客服已支持后台配置
   - 后端有 `ds_ai_config`
   - 后台页面路径：`/config/ai`
   - 读取顺序：数据库优先，`application.yml` 兜底
8. 通知系统已落地到小程序端
   - 后端有 `ds_notification`
   - 小程序有通知中心、未读数、单条已读、全部已读
9. 多角色菜单和基础角色体系已扩展
   - 已包含 `admin`、`designer`、`storekeeper`、`purchaser`、`finance`、`customer_service`
10. 客户管理、库存管理、库存记录后台页已补齐，避免空白页

### 已完成但仍需人工联调确认

1. 角色隔离
   - 菜单级隔离已做
   - 后端接口级隔离已按模块和角色拆分
   - 设计师看板/工作台/订单详情已限制为只看自己负责的订单
2. AI 客服
   - 代码链路已通
   - 仍需配置真实 `apiUrl / apiKey / model / systemPrompt` 后再做最终验证
3. 通知系统
   - 当前只面向小程序端，不拆 web-admin 通知中心
   - 需要人工验证通知触发点链路

### 仍属后续规划

1. SaaS 多租户隔离
2. 聊天与订单强绑定协同
3. 更完整的库存与 BOM 深度联动
4. 更细致的前端体验抛光和统一视觉体系

## 测试方法

### 快速回归

后端：

```bash
cd Code
mvn -q -DskipTests compile
```

管理后台：

```bash
cd web-admin
pnpm run build
```

优先验证页面：

- 意向池
- 订单工作台
- 订单详情
- 聊天页
- AI 配置页
- 客户列表
- 库存管理

### 项目专用测试 Skill

仓库内已新增全流程测试 skill：

- `/.Codex/skills/girii-full-flow-test/SKILL.md`

用途：

- 后端 + `web-admin` 发版前回归
- 角色权限隔离检查
- AI 配置、聊天、通知等高风险链路检查

建议直接使用：

```text
请使用 $girii-full-flow-test，对当前仓库做一轮完整回归测试，并输出：已验证项、发现的问题、未覆盖风险。
```

## 后端架构

核心包结构（`com.designstudio`）：

| 包 | 说明 |
| :--- | :--- |
| `common/` | JWT、Redis、统一返回、异常处理、静态资源映射、WebSocket、MyBatis-Plus 配置 |
| `system/` | 后台 RBAC：管理员、角色、菜单、字典、日志 |
| `config/` | 品类、动态字段、工作流、轮播图、AI 配置 |
| `order/` | 意向单、订单、进度、工作台、BOM |
| `customer/` | C 端用户、地址、后台客户管理 |
| `chat/` | WebSocket 聊天、消息记录 |
| `portfolio/` | 作品集 |
| `supply/` | 物料、BOM 模板、库存 |
| `statistics/` | 看板与统计接口 |

### 核心机制

- JWT 鉴权：Token 存 Redis，支持黑名单
- 统一返回：`R<T>`
- 乐观锁：`ds_order`、`ds_material`
- 逻辑删除：`del_flag`
- 动态表单：品类 -> `ds_custom_field`
- 工作流状态机：`ds_workflow_step`
- OpenAPI：`/swagger-ui.html`

## 数据库

- 数据库名：`design_studio`
- 初始化脚本：`Code/sql/init_schema.sql`
- 测试数据：`Code/sql/test_data.sql`
- 默认测试账号：
  - `admin / admin123`
  - `designer1 / admin123`
  - `designer2 / admin123`

### 当前已确认存在的关键表

- `ds_banner`
- `ds_notification`
- `ds_ai_config`
- `ds_order`
- `ds_chat_message`
- `sys_role`
- `sys_menu`
- `sys_role_menu`

### 当前已确认存在的关键菜单

- `/config/banner`
- `/config/ai`
- `/chat/index`
- `/customer/list`
- `/customer/address`
- `/supply/inventory`
- `/supply/inventory/record`

## 前端架构

### 管理后台（`web-admin/`）

- 基于 `naive-ui-admin` 二次开发
- 路径别名：`@/` -> `src/`，`#/` -> `types/`
- 请求层：使用 `alova`
- 动态路由：由后端菜单驱动，入口在 `src/router/generator.ts`

当前重点页面：

- `src/views/request/list/index.vue`
- `src/views/order/workbench/index.vue`
- `src/views/order/detail/index.vue`
- `src/views/chat/index.vue`
- `src/views/config/ai/index.vue`
- `src/views/config/banner/index.vue`
- `src/views/customer/list/index.vue`
- `src/views/supply/inventory/index.vue`

### 微信小程序（`mini-app/`）

当前重点页面：

- `pages/index/`
- `pages/order/`
- `pages/chat/`
- `pages/user/notification/`
- `pages/user/`

## API 路由规范

- 统一前缀：`/api/v1/`
- 后台接口：`/api/v1/admin/...`
- C 端接口：`/api/v1/app/...`
- 开放接口：`/api/v1/auth/**`、`/api/v1/app/auth/**`、`/api/v1/portfolios/**`、`/ws/**`、`/uploads/**`

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

当前系统已支持以下角色：

| 角色 | 说明 |
| :--- | :--- |
| `admin` | 全权限 |
| `designer` | 订单、意向、作品、工作台、聊天；仅能查看自己负责订单的核心看板与详情 |
| `storekeeper` | 物料与库存相关 |
| `purchaser` | 采购与库存相关 |
| `finance` | 订单查看、统计、财务相关 |
| `customer_service` | 客户管理、聊天、沟通相关 |

注意：

- 当前数据库里角色和菜单关系已存在，但不保证每种角色都已有实际后台账号。
- 做权限验证时，不能只看菜单，还要验证接口写操作是否被正确拦截。

## AI 客服与通知

### AI 客服

- 默认支持 OpenAI 兼容接口风格
- 不绑定单一厂商
- 当前通过后台 AI 配置页管理
- 配置项包括：
  - `enabled`
  - `provider`
  - `apiUrl`
  - `apiKey`
  - `model`
  - `systemPrompt`

### 通知系统

- 当前通知系统主要服务小程序端
- 不额外拆 web-admin 通知中心
- 触发点集中在订单支付、进度推进、阻塞/解除阻塞、生产完成等节点

## 小程序双源码结构

`mini-app/` 有两套页面源码，编译时 `pages.json` 引用的是 `pages/` 目录：

| 目录 | 用途 |
| :--- | :--- |
| `src/pages/` | 开发源码（我们在哪里改代码） |
| `pages/` | 编译输出（`pages.json` 实际引用） |

**每次修改小程序页面后，必须同步到 `pages/` 并重新编译：**
```bash
# 手动同步后重新编译
cp src/pages/user/index.vue pages/user/index.vue
npm run dev:mp-weixin
# 编译后需重新导入 dist/build/mp-weixin 到微信开发者工具
```

## 开发注意事项

1. 仓库里历史上存在乱码文档；修改文档时优先直接修正为正常中文，不要继续复制乱码。
2. 需要判断数据库真实结构时，优先读真实 MySQL，不要只依赖 SQL 文件。
3. 涉及小程序页面变更时，要重新编译并重新导入 `dist/build/mp-weixin`。
4. 权限相关改动必须同时检查：`sys_menu`、`sys_role_menu`、后端接口拦截、前端菜单/按钮显隐。
5. 设计师视角的工作台和看板应始终是”自己负责的内容”，不是全局数据。
6. AI 功能是否真正生效，取决于后台配置是否已填入真实可用的模型参数。
7. 当前通知默认只验证小程序端，不要在未明确需求时扩展成 web-admin 通知中心。

## 关键链路

### AI 客服自动回复
```
客户端发消息 → ChatWebSocketHandler.handleTextMessage()
  → 持久化客户消息 → broadcastToAdmins()
  → 判断 aiCustomerService.isEnabled() && “client”.equals(userType)
  → 异步 CompletableFuture.runAsync() → getRecentMessages(10)
  → aiCustomerService.getResponse(userId, messages)
  → 持久化 AI 消息 (senderType=2) → sessionManager.sendTo(clientKey, pushJson)
```
- 开启：后台 AI 配置页填入真实 `apiUrl / apiKey / model`，`enabled=true`
- 配置读取：数据库 `ds_ai_config` 优先，`application.yml` 兜底

### 通知触发点
```
OrderServiceImpl:
  payOrder() → 支付成功后 → notificationService.sendToUser(..., “payment”)
  advance() → 节点推进后 → notificationService.sendToUser(..., “workbench”)
  block() / unblock() → 阻塞/解除后 → notificationService.sendToUser(..., “order_status”)
  finishOrder() → 生产完毕后 → notificationService.sendToUser(..., “order_status”)
```

### 小程序通知中心
- API: `GET /api/v1/app/notifications`、`GET /api/v1/app/notifications/unread-count`
- `PUT /api/v1/app/notifications/{id}/read`、`PUT /api/v1/app/notifications/read-all`
- 页面：`src/pages/user/notification/index.vue`
- 入口：用户中心显示未读红色 badge（超过99显示”99+”）
