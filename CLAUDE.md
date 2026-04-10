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

- Web 前端代理配置: `web-admin/build/vite/proxy.ts` (Vite 代理) + `web-admin/.env.development` 中 `VITE_PROXY`
- 小程序直接请求后端: `mini-app/utils/request.js` 中 baseURL `http://localhost:8081/api`
- WebSocket: 后端通过 `ws://localhost:8081/ws/chat` 提供，前端 Vite 代理已启用 `ws: true`
- **微信小程序 AppID**: `wx5aeef2c8fab8bc4d`

## 后端架构 (com.designstudio)

### 模块结构

| 包 | 说明 |
| :--- | :--- |
| `common/` | 基础设施: `SecurityConfig`, `JwtAuthenticationFilter`, `JwtUtils`, `GlobalExceptionHandler`, `R<T>`, `ErrorCode`, `RedisConfig`, `WebSocketConfig`, `MyBatisPlusConfig`, `OperLog` 注解 |
| `system/` | RBAC 权限: 管理员(`sys_admin`)、角色(`sys_role`)、菜单(`sys_menu`)、字典、操作日志 |
| `config/` | 配置中心: 品类(`ds_category`)、动态字段(`ds_custom_field`)、工作流(`ds_workflow` + `ds_workflow_step`) |
| `order/` | 订单核心: 意向单(`ds_order_request`)、订单(`ds_order`)、进度(`ds_order_progress`)、工作台(`WorkbenchController`)，`OrderServiceImpl` 处理工作流流转 |
| `customer/` | C端用户: 微信登录(`DsUser` + OpenID)、地址管理(`DsAddress`) |
| `chat/` | WebSocket 聊天: `ChatWebSocketHandler`, `SessionManager`, `DsChatMessage` |
| `portfolio/` | 作品集展示: `PortfolioController`(后台) + `AppPortfolioController`(C端) |
| `supply/` | 供应链: 物料(`ds_material`)、BOM模板(`ds_bom_template`) |
| `statistics/` | 数据统计: Dashboard 接口 |

### 分层约定

典型分层 (按需出现，简单 CRUD 模块可省略 service 层):
- `controller/` — REST API 接口层 (后台用 `XxxController`，C端用 `AppXxxController`)
- `service/` + `service/impl/` — 业务逻辑层 (order、customer、supply、chat、statistics、config 等复杂模块均有)
- `mapper/` — MyBatis-Plus Mapper 接口 (继承 `BaseMapper<T>`)
- `domain/` — 实体类 (使用 Lombok `@Data`，继承 `BaseEntity`)

**编码约定**:
- 所有 Controller 和 Service 使用 `@RequiredArgsConstructor` 构造器注入，**不用** `@Autowired`
- DTO/VO 定义为 Controller 的**内部静态类** (`public static class XxxDTO`)，不单独建文件
- **无 Mapper XML 文件**，全部使用 MyBatis-Plus 的 `LambdaQueryWrapper` 构建查询
- `BaseEntity` 提供 `createBy/createTime/updateBy/updateTime/delFlag`，通过 `MyBatisPlusConfig` 的 `MetaObjectHandler` 自动填充

### 核心机制

- **JWT 鉴权**: Token 存储于 Redis，支持黑名单，7天过期；黑名单 Key 前缀 `token:blacklist:`
- **统一返回**: `R<T>` 封装 (`{code, msg, data}`)，错误码 5位数字格式 (10=系统, 20=鉴权, 30=订单, 40=支付, 50=物料)
- **乐观锁**: `ds_order` 和 `ds_material` 使用 `version` 字段（`@Version` 注解）
- **逻辑删除**: MyBatis-Plus 全局配置 `del_flag` 字段，删除值=1，未删除值=0
- **动态表单引擎**: EAV 模式，品类 → `ds_custom_field` 生成表单 Schema；支持 text/number/textarea/date/select/radio/checkbox/image 等8种字段类型
- **工作流状态机**: `ds_workflow_step` 按 `step_order` 排序，节点流转不可跳跃；每个节点支持5种动作：`save` `advance` `rollback` `block` `unblock`
- **操作日志**: `@OperLog` 注解 + `OperLogAspect` AOP切面记录到 `sys_oper_log`
- **文件上传**: `OssController` 本地磁盘存储 (`/data/uploads/`)，UUID 文件名，仅图片 (jpeg/png/webp/gif)，最大 5MB
- **API 文档**: SpringDoc OpenAPI 2.8.4，访问 `/swagger-ui.html`
- **测试**: `src/test/` 目录存在但**尚未编写测试**，依赖已声明 (spring-boot-starter-test, spring-security-test)

### API 路由规范

- 前缀: `/api/v1/`
- 鉴权: Header `Authorization: Bearer {token}`
- 后台管理接口: `/api/v1/admin/...`
- C端接口: `/api/v1/app/...` (如 `/api/v1/app/orders/my`, `/api/v1/app/auth/info`)

### 公开接口 (无需鉴权)

- `/api/v1/auth/**` — 后台登录
- `/api/v1/app/auth/**` — 小程序登录 (微信 + mock)
- `/api/v1/app/public/**` — 公开数据 (品类、作品集)
- `/api/v1/portfolios/**` — 作品集展示
- `/ws/**` — WebSocket
- `/uploads/**` — 静态文件访问
- Swagger 路径 (`/swagger-ui.html`, `/api-docs`)

## 前端架构 (web-admin/)

基于开源模板 [naive-ui-admin](https://github.com/jekip/naive-ui-admin) 二次开发。

### 路径别名

- `@/` → `src/`
- `#/` → `types/`

### 请求层

使用 **alova** (非 axios) 作为 HTTP 客户端，封装在 `src/utils/http/alova/`。
- 响应拦截器统一处理 `{ code, msg, data }`，`code === 401` 时跳转登录页
- 关闭 GET 请求缓存 (`cacheFor: null`)

### 动态路由机制

- `permissionMode: 'BACK'` — 路由从后端菜单树动态生成
- `src/router/generator.ts` 调用 `/v1/admin/menus` 获取后端菜单，过滤 `menuType='F'`（按钮），通过 `import.meta.glob('../views/**/*.{vue,tsx}')` 动态导入视图组件
- 隐藏路由（如 `/order/detail/:id`）注入到 `order-hidden-layout` 下

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

### 核心业务页面

- **订单看板** `order/kanban/` — 瀑布流布局，按工作流节点分组，支持拖拽推进
- **订单工作台** `order/workbench/` — 左侧订单卡片列表 + 右侧节点执行面板（save/advance/rollback/block/unblock）
- **工作流配置** `config/workflow/` — 拖拽排序节点，配置每个节点的允许动作、节点字段、客户可见性
- **订单详情** `order/detail/` — 基本信息/工作流进度/进度时间轴三个 Tab

## 小程序 (mini-app/)

详细开发指南见 [.claude/skills/uniapp-miniprogram.md](.claude/skills/uniapp-miniprogram.md)

- **框架**: Uni-app (Vue 3)，目标平台: 微信小程序
- **请求**: `utils/request.js` 封装 `uni.request`，baseURL `http://localhost:8081/api`，自动附加 JWT Bearer token，401 自动跳转登录页
- **状态管理**: Pinia (`store/user.js`)，持久化到 `uni.storageSync`
- **测试登录**: 登录页含"账号模拟登录"按钮，无需企业微信账号
- **动态表单**: 支持 text/number/textarea/date/select/radio/checkbox/image 等8种字段类型，根据后端 Schema 动态渲染
- **客服聊天**: WebSocket 连接 `ws://localhost:8081/ws/chat`，支持文字/图片消息、历史记录拉取

### 页面结构

| 页面 | 路径 | 作用 |
| :--- | :--- | :--- |
| 登录 | `pages/login/` | 微信授权登录 + 账号模拟登录 |
| 首页 | `pages/index/` | Banner 轮播 + 瀑布流作品 + 快捷入口 |
| 作品集 | `pages/portfolio/` | 列表(分类筛选) + 详情(轮播画廊) |
| 定制 | `pages/custom/` | 品类选择 + 动态表单提交意向 |
| 订单 | `pages/order/` | 列表(状态 Tab) + 详情(时间轴+节点产出+支付) |
| 用户 | `pages/user/` | 个人中心 + 资料编辑 + 地址管理 |
| 客服 | `pages/chat/` | WebSocket 即时通讯 |

## 项目级工具权限

此项目在 `.claude/settings.local.json` 中配置了专用工具权限：

| 工具 | 权限 | 用途 |
| :--- | :--- | :--- |
| `Bash(mysql ...)` | 直接操作 MySQL | 数据库初始化、维护 |
| `Bash(./mvnw compile)` | 编译后端 | 快速验证代码 |
| `mcp__chrome-devtools__*` | Chrome DevTools MCP | 前端自动化测试/调试 |
| `mcp__MiniMax__*` | MiniMax 扩展工具 | 搜索、图像理解 |

## 数据库

- 数据库: `design_studio` (MySQL 8.0+)
- 初始化脚本: `Code/sql/init_schema.sql` (29 张表)
- 测试数据: `Code/sql/test_data.sql`
- **连接配置**: `application.yml` 中 `localhost:3306`, 用户 `root/123456`
- **测试账号**: admin / admin123 (BCrypt)
- **默认角色**: admin (全权限), designer (订单/意向/作品集权限)
- **注意**: 未配置 Spring Profiles，所有环境共用 `application.yml`；微信 AppSecret 为占位符待替换

### 核心业务表关系

```
ds_category (1) ←→ (1) ds_workflow → (*) ds_workflow_step
                         ↓
ds_category (1) ←→ (*) ds_custom_field  (EAV 动态字段)
                         ↓
ds_order_request → ds_order → ds_order_progress (时间轴)
                         ↓
ds_bom_template → ds_bom_template_item → ds_material (供应链 BOM)

ds_user ← ds_address
ds_portfolio (作品集，无关联订单)
ds_chat_message (聊天记录)
```

### 订单状态流转

```
0=待支付 → 1=生产中 → 2=待发货 → 3=待收货 → 4=已完成
                    ↓
                5=已取消
                6=待尾款 (生产完成时若预付款<总价)
```

### 意向状态

```
0=待处理 → 1=已转单 → 2=已关闭
```

## 核心业务流程

### 意向转订单 (UC-02)
1. 客户小程序提交定制意向 → `ds_order_request` (status=0)，含品类+动态表单数据+参考图片
2. 设计师在后台审核 → 填写工期、总价、预付款
3. 系统创建订单 → `ds_order`，关联品类工作流，初始化 `current_step_id` 为起始节点
4. 更新意向状态为"已转单" (status=1)，`linked_order_id` 关联订单

### 生产进度推进 (UC-03)
1. 设计师拖拽订单至看板下一列 **或** 在工作台执行节点操作
2. 后端校验目标节点是否为当前节点的合法后继（`step_order` 连续，不可跳跃）
3. 更新订单 `current_step_id`，插入 `ds_order_progress` 进度记录（含产出图片/表单数据）
4. 客户小程序订单详情实时可见新进度

### 节点操作类型
- **save** — 保存节点产出（不推进）
- **advance** — 推进到下一节点
- **rollback** — 回退到上一节点
- **block** — 阻塞订单（需填写原因）
- **unblock** — 解除阻塞
