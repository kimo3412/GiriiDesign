# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目概述

这是一个**独立设计师工作室生产流程管理系统**的毕业设计项目，采用前后端分离架构：
- 后端: Spring Boot 3.4.3 (Java 17) + MyBatis-Plus + Redis + MySQL
- 前端: Vue 3 + Naive UI + TypeScript + Vite (Web后台) + Uni-app (微信小程序)
- 项目位于 `Code/` (后端)、`web-admin/` (前端管理后台)、`mini-app/` (微信小程序)

**系统定位**: 面向独立设计师的**低代码生产管理平台**，解决"非标定制、强沟通、长周期"的生产特点。

## 常用命令

### 后端 (Code/)

```bash
cd Code
./mvnw spring-boot:run          # 运行 (端口 8081)
./mvnw clean package -DskipTests # 打包
./mvnw test                      # 运行测试
```

### 前端 (web-admin/) — 基于 naive-ui-admin 模板

```bash
cd web-admin
pnpm install          # 安装依赖
pnpm run dev          # 开发模式 (端口 3100)
pnpm run build        # 构建生产版本
pnpm run lint:eslint  # 代码检查与修复
```

### 小程序 (mini-app/)

```bash
cd mini-app
npm install                # 安装依赖
npm run dev:mp-weixin      # 运行到微信开发者工具
npm run build:mp-weixin    # 打包发布
```

## 关键端口与代理

| 服务 | 端口 | 说明 |
| :--- | :--- | :--- |
| 后端 API | 8081 | Spring Boot (`application.yml` 中 `server.port=8081`) |
| Web 前端 | 3100 | Vite dev server，代理 `/api` → `http://localhost:8081/api` |
| 小程序 | 5173 | Vite dev server (仅 H5 模式有效) |

- Web 前端代理配置: `web-admin/.env.development` 中 `VITE_PROXY`
- 小程序直接请求后端: `mini-app/utils/request.js` 中硬编码 `http://localhost:8081/api`
- WebSocket: 后端通过 `ws://localhost:8081/ws/chat` 提供，前端 Vite 代理已启用 `ws: true`

## 后端架构 (com.designstudio)

### 模块结构

| 包 | 说明 |
| :--- | :--- |
| `common/` | 基础设施: `SecurityConfig`, `JwtAuthenticationFilter`, `JwtUtils`, `GlobalExceptionHandler`, `R<T>`, `ErrorCode`, `RedisConfig`, `WebSocketConfig`, `MyBatisPlusConfig`, `OperLog` 注解 |
| `system/` | RBAC 权限: 管理员(`sys_admin`)、角色(`sys_role`)、菜单(`sys_menu`)、字典、操作日志 |
| `config/` | 配置中心: 品类(`ds_category`)、动态字段(`ds_custom_field`)、工作流(`ds_workflow` + `ds_workflow_step`) |
| `order/` | 订单核心: 意向单(`ds_order_request`)、订单(`ds_order`)、进度(`ds_order_progress`)、BOM |
| `customer/` | C端用户: 微信登录(`DsUser` + OpenID)、地址管理(`DsAddress`) |
| `chat/` | WebSocket 聊天: `ChatWebSocketHandler`, `SessionManager`, `DsChatMessage` |
| `portfolio/` | 作品集展示: `PortfolioController`(后台) + `AppPortfolioController`(C端) |
| `supply/` | 供应链: 物料(`ds_material`)、BOM模板(`ds_bom_template`) |
| `statistics/` | 数据统计: Dashboard 接口 |

### 分层约定

**注意**: 大多数模块**没有 service 层**，直接 controller → mapper (MyBatis-Plus 的 `ServiceImpl` 提供基础 CRUD)。只有 `system/` 模块有独立的 `service/impl/` 层。

典型分层:
- `controller/` — REST API 接口层 (后台用 `XxxController`，C端用 `AppXxxController`)
- `mapper/` — MyBatis-Plus Mapper 接口
- `domain/` — 实体类 (使用 Lombok `@Data`)

### 核心机制

- **JWT 鉴权**: Token 存储于 Redis，支持黑名单，7天过期
- **统一返回**: `R<T>` 封装，统一错误码 5位数字格式 (XXYYY)
- **乐观锁**: `ds_order` 和 `ds_material` 使用 `version` 字段
- **逻辑删除**: MyBatis-Plus 全局配置 `del_flag` 字段
- **动态表单引擎**: EAV 模式，品类 → `ds_custom_field` 生成表单 Schema
- **工作流状态机**: `ds_workflow_step` 按 `step_order` 排序，节点流转不可跳跃
- **API 文档**: SpringDoc OpenAPI，访问 `/swagger-ui.html`

### API 路由规范

- 前缀: `/api/v1/`
- 鉴权: Header `Authorization: Bearer {token}`
- 后台管理接口: `/api/v1/admin/...`
- C端接口: `/api/v1/...` (如 `/api/v1/users/me/...`, `/api/v1/portfolios`)

## 前端架构 (web-admin/)

基于开源模板 [naive-ui-admin](https://github.com/jekip/naive-ui-admin) 二次开发。

### 路径别名

- `@/` → `src/`
- `#/` → `types/`

### 请求层

使用 **alova** (非 axios) 作为 HTTP 客户端，封装在 `src/utils/http/alova/`。

### 关键目录

| 目录 | 说明 |
| :--- | :--- |
| `src/api/` | 按业务域拆分的 API 定义 (chat, config, dashboard, order, portfolio, supply, system) |
| `src/views/` | 页面视图: `chat/`, `config/`(品类/字段/工作流), `dashboard/`, `order/`(看板/列表/详情), `request/`, `statistics/`, `supply/`(物料/BOM), `system/`(管理员/角色/菜单/字典/日志) |
| `src/components/` | 通用组件: Form(BasicForm), Table(支持可编辑单元格), Modal, Upload |
| `src/hooks/` | 组合式函数: breakpoint, ECharts, permission, async 等 |
| `src/directives/` | Vue 指令: permission(权限控制), draggable, copy, debounce, throttle |
| `src/store/` | Pinia: asyncRoute(动态路由), user, tabsView, projectSetting |
| `src/router/` | 动态路由: 从后端菜单生成路由 (`generator.ts`) |

### 重要依赖

- `vuedraggable` — 看板拖拽
- `echarts` — Dashboard 图表
- `@vueup/vue-quill` — 富文本编辑器
- `tailwindcss` — 样式
- `@alova/adapter-xhr` — HTTP 适配器

## 小程序 (mini-app/)

详细开发指南见 [.claude/skills/uniapp-miniprogram.md](.claude/skills/uniapp-miniprogram.md)

- **框架**: Uni-app (Vue 3)，目标平台: 微信小程序
- **请求**: `utils/request.js` 封装 `uni.request`，自动附加 JWT Bearer token
- **状态管理**: Pinia (`store/user.js`)
- **测试登录**: 登录页含"测试登录"按钮，无需企业微信账号 (userId=1)
- **动态表单支持字段类型**: text, number, textarea, select, radio, checkbox, image

## 数据库

- 数据库: `design_studio` (MySQL 8.0+)
- 初始化脚本: `Code/sql/init_schema.sql` (29 张表)
- 测试数据: `Code/sql/test_data.sql`
- **测试账号**: admin / admin123 (BCrypt)
- **默认角色**: admin (全权限), designer (订单/意向/作品集权限)

## 核心业务流程

### 意向转订单 (UC-02)
1. 客户提交定制意向 → `ds_order_request` (status=0)
2. 设计师审核 → 填写工期、总价、预付款
3. 系统创建订单 → `ds_order`，获取品类初始工作流节点
4. 更新意向状态为"已转单"

### 生产进度推进 (UC-03)
1. 设计师拖拽订单至下一列
2. 后端校验目标节点是否为当前节点的合法后继
3. 更新订单 `current_step_id`，插入进度记录
4. 客户小程序实时可见新进度
