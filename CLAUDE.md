# CLAUDE.md

This file provides guidance to Claude Code when working with code in this repository.

## 项目概述

这是一个面向独立设计师工作室的毕业设计项目，定位为“低代码生产管理平台”，解决非标定制、强沟通、长周期生产协同问题。

- 后端：Spring Boot 3.4.3 + Java 17 + MyBatis-Plus + Redis + MySQL
- 管理后台：Vue 3 + TypeScript + Naive UI + Vite
- 微信小程序：Uni-app + Vue 3 + Pinia
- 仓库结构：
  - `Code/` 后端
  - `web-admin/` 管理后台
  - `mini-app/` 微信小程序

## 常用命令

### 后端

```bash
cd Code
./mvnw spring-boot:run
./mvnw clean package -DskipTests
./mvnw test
```

在当前仓库里，若 `spring-boot:run` 启动时找不到配置，可使用：

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

## 后端架构

核心包结构：

| 包 | 说明 |
| :--- | :--- |
| `common/` | 安全、异常、Redis、WebSocket、MyBatis-Plus、统一返回 |
| `system/` | 后台 RBAC、菜单、角色、字典、操作日志 |
| `config/` | 品类、动态字段、工作流、工作流节点配置 |
| `order/` | 意向单、订单、进度、工作台、时间线 |
| `customer/` | C 端用户、微信登录、地址管理 |
| `chat/` | WebSocket 聊天 |
| `portfolio/` | 作品集 |
| `supply/` | 物料、BOM 模板 |
| `statistics/` | 经营看板与统计接口 |

当前代码分层以 `controller + service + mapper + domain` 为主，复杂业务已经集中在 `service/impl`，尤其是：

- `OrderServiceImpl`
- `WorkflowServiceImpl`
- `RequestServiceImpl`
- `StatisticsServiceImpl`

### 当前核心业务能力

1. 品类 -> 动态字段 -> 工作流配置闭环
2. 客户提交意向 -> 转订单 -> 初始化工作流节点
3. 后台订单看板 + 节点工作台
4. 节点动作：
   - `save`
   - `advance`
   - `rollback`
   - `block`
   - `unblock`
5. 节点字段动态渲染与进度留痕
6. 小程序时间线、返工事件、阻塞状态、节点产出展示

### 当前工作台与时间线增强

这是最近一轮迭代的重点，已经落地：

- `ds_workflow_step` 已支持：
  - `node_description`
  - `allowed_actions`
  - `need_image_upload`
  - `visible_to_client`
  - `expected_duration_days`
  - `node_form_fields`
- `ds_order_progress` 已支持：
  - `form_data`
- 工作台支持：
  - 按品类流程自动渲染节点执行面板
  - 退回任意前序节点，不只是上一步
  - 必填字段校验
  - 真实图片上传
  - 客户/设计师显示昵称或姓名，而不是编号
- 小程序订单详情支持：
  - 当前节点产出
  - 时间线事件标签
  - 返工/阻塞可视化
  - 节点字段值展示
  - 预计完成倒计时/逾期提示
  - 当前节点已耗时与预计耗时
  - 操作者姓名展示

## 前端架构

### 管理后台

项目基于 `naive-ui-admin` 二次开发。

- 路径别名：
  - `@/` -> `src/`
  - `#/` -> `types/`
- 请求层使用 `alova`
- 路由模式为后端动态菜单驱动

关键目录：

| 目录 | 说明 |
| :--- | :--- |
| `src/api/` | API 定义 |
| `src/views/` | 页面视图 |
| `src/store/` | Pinia |
| `src/router/` | 动态路由生成 |
| `src/components/` | 通用表单、表格、上传等组件 |

当前核心页面：

- `src/views/config/workflow/index.vue`
  - 工作流节点配置
  - 节点动作配置
  - 节点字段绑定
- `src/views/order/workbench/index.vue`
  - 节点工作台
  - 节点字段动态表单
  - 返工、阻塞、恢复、推进、记录
  - 历史进度查看
- `src/views/order/kanban/index.vue`
  - 看板视图

### 微信小程序

关键页面：

| 页面 | 路径 | 说明 |
| :--- | :--- | :--- |
| 登录 | `pages/login/` | 微信登录 + mock 登录 |
| 首页 | `pages/index/` | 首页展示 |
| 定制表单 | `pages/custom/` | 动态字段表单提交 |
| 订单列表/详情 | `pages/order/` | 状态、时间线、支付 |
| 聊天 | `pages/chat/` | WebSocket 沟通 |
| 用户中心 | `pages/user/` | 个人资料、地址 |

当前订单详情页不仅展示流程步骤，还展示：

- 当前节点产出字段
- 返工/阻塞/恢复事件
- 操作者
- 逾期与预计时间信息

## 数据库

- 数据库名：`design_studio`
- 当前实际连接：
  - host: `localhost:3306`
  - user: `root`
  - password: `123456`
- 初始化脚本：`Code/sql/init_schema.sql`

注意：

- `init_schema.sql` 以当前真实库结构为准，但不一定始终包含最新运行期数据清理结果
- 开发期间应优先以真实 MySQL 结构为准，再回写 SQL 文件

## 认证与接口

- 所有接口统一前缀：`/api/v1/`
- 后台接口：`/api/v1/admin/...`
- C 端接口：`/api/v1/app/...`
- 鉴权：`Authorization: Bearer {token}`

开放接口包括：

- `/api/v1/auth/**`
- `/api/v1/app/auth/**`
- `/api/v1/portfolios/**`
- `/ws/**`
- `/uploads/**`

## 当前功能进度判断

### 已基本完成

1. 配置中心基础能力
2. 意向转订单主链路
3. 节点工作台
4. 节点字段低代码渲染第一版
5. 小程序时间线第一版
6. 返工/阻塞/恢复可视化

### 正在完善

1. 完整履约状态机
   - 已有：`block / unblock / rollback / advance / save`
   - 待补：`cancel / 完成确认 / 延期原因 / 更明确状态流转约束`
2. 小程序订单详情体验
   - 已有节点产出、进度事件、逾期文案
   - 仍需继续打磨文案、图片可访问与一致性
3. 工作台体验
   - 已有字段校验与历史展示
   - 仍可继续补字段联动、复杂校验、审批/负责人

### 尚未深入

1. BOM 与订单/库存联动
2. 经营分析统计升级
3. 聊天与订单强绑定协同
4. 更完整的低代码平台能力

## 近期推荐开发顺序

按当前项目状态，建议继续按这个顺序推进：

1. 补完整履约状态机
   - 取消
   - 完成确认
   - 延期原因
   - 客户端同步展示
2. 升级统计分析
   - 品类转化率
   - 设计师效率
   - 工作流瓶颈
   - 客单价趋势
3. 再做 BOM/库存联动
4. 最后再做聊天协同升级

## 开发注意事项

1. 仓库里存在部分历史中文乱码，修改文档和页面时优先直接修正，不要继续复制乱码文本。
2. 涉及数据库结构判断时，优先读真实 MySQL，不要只信 SQL 文件。
3. 小程序构建可用，但验证页面变化时要重新编译并重新导入 `dist/build/mp-weixin`。
4. `/uploads/**` 当前是否能直接访问，取决于后端静态资源映射是否已接通；上传成功不等于可直接访问。
5. 工作台和小程序时间线是当前项目最重要的展示亮点，后续增强尽量围绕这条主线继续做深。
