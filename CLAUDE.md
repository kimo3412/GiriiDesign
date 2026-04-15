# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目概述

这是一个面向独立设计师工作室的毕业设计项目，定位为"低代码生产管理平台"，解决非标定制、强沟通、长周期生产协同问题。

- 后端：Spring Boot 3.4.3 + Java 17 + MyBatis-Plus + Redis + MySQL 8.0+
- 管理后台：Vue 3 + TypeScript + Naive UI + Vite（基于 naive-ui-admin 二次开发）
- 微信小程序：Uni-app + Vue 3 + Pinia
- 仓库结构：
  - `Code/` 后端（Spring Boot）
  - `web-admin/` 管理后台（Vue 3）
  - `mini-app/` 微信小程序（Uni-app）

## 常用命令

### 后端

```bash
cd Code
./mvnw spring-boot:run
./mvnw clean package -DskipTests
./mvnw test
```

若 `spring-boot:run` 找不到配置：

```bash
./mvnw spring-boot:run -Dspring-boot.run.arguments=--spring.config.location=file:src/main/resources/application.yml
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
- 小程序请求基址：`mini-app/utils/request.js`
- WebSocket：`ws://localhost:8081/ws/chat`

## 测试方法

### Chrome DevTools MCP

使用 Chrome DevTools MCP 进行前端页面测试：

```bash
# 启动管理后台后，在 Claude Code 中使用以下工具测试
mcp__chrome-devtools__navigate_page   # 打开页面
mcp__chrome-devtools__take_snapshot   # 获取页面快照
mcp__chrome-devtools__take_screenshot # 截图
mcp__chrome-devtools__click          # 点击元素
mcp__chrome-devtools__fill_form       # 填写表单
mcp__chrome-devtools__evaluate_script # 执行 JS 检查状态
mcp__chrome-devtools__list_network_requests  # 查看网络请求
mcp__chrome-devtools__list_console_messages # 查看控制台错误
```

测试步骤：
1. 先启动后端 `cd Code && ./mvnw spring-boot:run`
2. 再启动管理后台 `cd web-admin && pnpm run dev`
3. 用 `mcp__chrome-devtools__navigate_page` 打开 `http://localhost:3100`
4. 登录后（admin / admin123）可测试各功能页面
5. 用 `list_network_requests` 验证 API 调用是否正常
6. 用 `list_console_messages` 检查前端错误

### 小程序 H5 调试

```bash
cd mini-app && npm run dev:h5
# 打开 http://localhost:5173 用 Chrome DevTools 测试
```

## 后端架构

核心包结构（`com.designstudio`）：

| 包 | 说明 |
| :--- | :--- |
| `common/` | 安全（JWT/Redis）、异常、OSS上传、统一返回（R）、MyBatis-Plus配置 |
| `system/` | 后台 RBAC：管理员、角色、菜单、字典、操作日志 |
| `config/` | 品类（ds_category）、动态字段（ds_custom_field）、工作流（ds_workflow + ds_workflow_step） |
| `order/` | 意向单（ds_order_request）、订单（ds_order）、进度（ds_order_progress）、BOM、库存扣减 |
| `customer/` | C 端用户（ds_user）、微信登录、地址管理 |
| `chat/` | WebSocket 聊天（ChatWebSocketHandler、SessionManager） |
| `portfolio/` | 作品集（后台+C端） |
| `supply/` | 物料（ds_material，含库存）、BOM模板（ds_bom_template）、库存管理 |
| `statistics/` | 经营看板与统计接口 |

### 核心业务服务（集中在 service/impl）

- `OrderServiceImpl` — 订单状态机、进度推进、BOM生成
- `WorkflowServiceImpl` — 工作流解析、节点流转
- `RequestServiceImpl` — 意向单管理
- `StatisticsServiceImpl` — 看板统计

### 核心机制

- **JWT 鉴权**：Token 存 Redis，7天过期，支持黑名单；Header：`Authorization: Bearer {token}`
- **统一返回**：`R<T>` 封装，错误码 5位数字格式（XXYYY）
- **乐观锁**：`ds_order` 和 `ds_material` 使用 `@Version` 字段
- **逻辑删除**：MyBatis-Plus 全局配置 `del_flag` 字段
- **动态表单引擎**：EAV 模式，品类 -> `ds_custom_field` 生成表单 Schema
- **工作流状态机**：`ds_workflow_step` 按 `step_order` 排序，节点流转不可跳跃
- **API 文档**：SpringDoc OpenAPI，访问 `/swagger-ui.html`

### 数据库

- 数据库名：`design_studio`（MySQL 8.0+）
- 初始化脚本：`Code/sql/init_schema.sql`（29 张表）
- 测试数据：`Code/sql/test_data.sql`
- **测试账号**：admin / admin123（BCrypt）
- **默认角色**：admin（全权限）、designer（订单/意向/作品集权限）
- **库存相关**：ds_material（物料表，含库存数量）、ds_bom_template（BOM模板）、ds_order_bom（订单BOM明细）
- **轮播图**：需新建 `ds_banner` 表存储小程序首页轮播图

## 前端架构

### 管理后台（web-admin/）

基于 `naive-ui-admin` 二次开发。

- 路径别名：`@/` -> `src/`、`#/` -> `types/`
- 请求层：使用 **alova**（非 axios），封装在 `src/utils/http/alova/`
- 路由模式：后端动态菜单驱动（`GET /v1/admin/menus` -> `router/generator.ts`）

关键目录：

| 目录 | 说明 |
| :--- | :--- |
| `src/api/` | 按业务域拆分的 API 定义 |
| `src/views/` | 页面视图：config/（品类/字段/工作流）、order/（看板/列表/详情/工作台）、request/、statistics/、supply/、system/ |
| `src/store/` | Pinia：asyncRoute（动态路由）、user、tabsView |
| `src/router/` | 动态路由生成（`generator.ts`） |
| `src/components/` | 通用组件：Form（动态表单）、Table、Modal、Upload |

核心页面：

- `src/views/order/workbench/index.vue` — 节点工作台（save/advance/rollback/block/unblock）
- `src/views/order/kanban/index.vue` — 看板视图
- `src/views/config/workflow/index.vue` — 工作流节点配置

### 微信小程序（mini-app/）

关键页面：

| 页面 | 路径 | 说明 |
| :--- | :--- | :--- |
| 登录 | `pages/login/` | 微信登录 + mock 登录 |
| 首页 | `pages/index/` | Banner + 作品集瀑布流 |
| 定制表单 | `pages/custom/` | 动态字段表单提交 |
| 订单列表/详情 | `pages/order/` | 状态、时间线、支付 |
| 聊天 | `pages/chat/` | WebSocket 沟通 |
| 用户中心 | `pages/user/` | 个人资料、地址 |

## API 路由规范

- 所有接口统一前缀：`/api/v1/`
- 后台管理接口：`/api/v1/admin/...`
- C 端接口：`/api/v1/app/...`（如 `/api/v1/app/orders/my`）
- 开放接口：`/api/v1/auth/**`、`/api/v1/app/auth/**`、`/api/v1/portfolios/**`、`/ws/**`、`/uploads/**`

## 订单状态与工作流

### 订单状态码

| 值 | 含义 |
| :--- | :--- |
| 0 | 待支付（预付款） |
| 1 | 生产中 |
| 2 | 待发货 |
| 3 | 待收货 |
| 4 | 已完成 |
| 5 | 已取消 |
| 6 | 待付尾款 |

### 工作流节点动作

| 动作 | 说明 |
| :--- | :--- |
| `save` | 保存进度记录（不推进） |
| `advance` | 推进到下一节点 |
| `rollback` | 退回任意前序节点 |
| `block` | 阻塞（需填写原因） |
| `unblock` | 解除阻塞 |

### ds_workflow_step 关键字段

- `node_description` — 节点描述
- `allowed_actions` — 允许的动作（JSON 数组）
- `need_image_upload` — 是否必须上传图片
- `visible_to_client` — 客户是否可见
- `expected_duration_days` — 预计天数
- `node_form_fields` — 该节点需要填写的字段（JSON 数组）

## 角色体系

系统面向**大型工作室**，需要支持多角色：

| 角色 | 权限范围 |
| :--- | :--- |
| admin | 全权限 |
| designer | 订单/意向/作品集 |
| 库管 | 物料管理、库存查看 |
| 采购 | 物料采购、库存管理 |
| 财务 | 订单收款、统计报表 |
| 客服 | 客户沟通、聊天管理 |
| ... | 可扩展 |

### 库存与 BOM 联动

- BOM 物料消耗与库存联动
- 订单完成生产时自动扣减对应物料库存
- 库存不足时提示采购

## 功能优先级

### P0 — 核心流程（优先完成）

1. **管理功能分页** — 所有列表页面（订单/物料/用户等）加上分页
2. **用户端流程精简** — 仅展示当前及后续步骤，避免信息过载
3. **预付款模拟页面完善** — 已有 pay/confirm 接口，流程页面打磨
4. **图片防盗链修复** — `/uploads/**` 无法直接访问，需修复

### P1 — 体验优化（次优先）

5. **小程序首页轮播图数据库化** — 从数据库读取，支持后台配置
6. **WebSocket 断线重连** — 聊天页面断线重连机制未实现
7. **完整履约状态机** — 完成确认流程、延期原因、状态流转约束
8. **多角色权限体系** — 完善角色配置、权限分配菜单

### P2 — 架构扩展（后续规划）

9. **BOM 与库存联动** — 完成生产扣减库存
10. **SaaS 多租户数据隔离** — 工作室维度数据隔离
11. **智能客服接入** — 接入第三方 API 应对客服人力不足
12. **工作提醒与通知功能**
13. **聊天与订单强绑定协同**

## 开发注意事项

1. 仓库里存在部分历史中文乱码，修改文档和页面时优先直接修正，不要继续复制乱码文本。
2. 涉及数据库结构判断时，优先读真实 MySQL，不要只信 SQL 文件。
3. 小程序构建可用，但验证页面变化时要重新编译并重新导入 `dist/build/mp-weixin`。
4. `/uploads/**` 当前是否能直接访问，取决于后端静态资源映射是否已接通；上传成功不等于可直接访问（防盗链问题待解决）。
5. 工作台和小程序时间线是当前项目最重要的展示亮点，后续增强尽量围绕这条主线继续做深。
6. WebSocket 聊天页面的断线重连机制尚未实现。
