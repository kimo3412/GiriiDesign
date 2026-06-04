# Girii Design

> 面向独立设计师工作室的低代码生产管理平台

一个面向独立设计师 / 小型工作室的生产流程管理系统，定位"低代码生产管理平台"，解决"非标定制、强沟通、长周期交付"场景下的订单流转、动态表单、协同沟通、AI 客服等痛点。

## Features

### AI 智能客服
- 兼容 OpenAI 协议（DeepSeek / 火山方舟 / OpenAI 等）
- 后台可视化配置（apiUrl / apiKey / model / systemPrompt），数据库优先 + `application.yml` 兜底，修改后下次请求生效
- 上下文动态组装：订单实时信息（订单号 / 品类 / 状态 / 当前节点 / 应付已付 / 预计交付 / 最近 3 条进度） + 最近 20 条聊天历史
- 关键词触发业务卡片（进度 / 人工 / 作品 / 定制 / 通知 / 支付 共 5 类）
- 人机切换：检测"人工"关键词后暂停 AI 回复
- 失败兜底：HTTP 失败 / 解析异常 / 超时统一返回兜底话术
- 异步调用：`CompletableFuture` 异步调 LLM，不阻塞 WebSocket 主消息流

### 动态表单引擎（低代码核心）
- 品类 → 动态字段 → 表单 Schema，支持 7 种字段：text / number / textarea / select / radio / checkbox / image
- 新增定制品类**不需要改表、不需要发版**
- 订单创建时把表单数据冻结到 `ds_order.custom_data_snapshot`（JSON），避免后续字段变更影响历史订单

### 工作流节点推进
- 5 种节点动作：`save` / `advance` / `rollback` / `block` / `unblock`
- `ds_workflow_step.step_order` 排序 + 后端校验目标节点合法性，防止跳跃流转
- Web 端看板：vuedraggable 拖拽订单到下一列，后端校验 → 乐观锁写入 → 进度历史落库
- 阻塞机制：`block` 时记录原因进入阻塞列表，解除后从原节点继续


### WebSocket 实时聊天
- `/ws/chat?token=xxx` 鉴权后建立连接
- 后台管理员 / 客户 / AI 三方同时在线
- 小程序端断线重连 + 心跳检测
- 5 种消息类型：text / image / file / progress_card / action_card

### 多端协同
- Web 管理后台（Vue 3 + Naive UI）
- 微信小程序（Uni-app）
- Docker Compose 一键起 MySQL + Redis + Backend + Web

## Tech Stack

**Backend**
- Spring Boot 3.4.3
- Java 17
- MyBatis-Plus 3.5.9
- Spring Security
- JJWT 0.12.6
- SpringDoc OpenAPI
- Redis 7
- MySQL 8.0
- Hutool · Lombok

**Web Admin**
- Vue 3 · TypeScript · Pinia · Vite
- Naive UI · TailwindCSS
- ECharts · vuedraggable
- alova (HTTP)

**Mini-app**
- Uni-app · Vue 3 · Pinia
- 微信小程序

**Infra**
- Docker · Docker Compose
- Nginx

## Quick Start

### 环境要求
- JDK 17+
- Maven 3.8+ （或使用 `mvnw`）
- Node.js 18+ / pnpm
- MySQL 8.0+ / Redis 7+
- Docker（可选，推荐）

### 一、D键起（推荐）

```bash
git clone <repo-url>
cd GiriiDesign
docker-compose up -d
```

启动后访问：
- 后端 API：`http://localhost:8081`
- Swagger UI：`http://localhost:8081/swagger-ui.html`
- Web 管理后台：`http://localhost:80`
- 默认账号：`admin / admin123`

### 二、本地开发

```bash
# 1. 启动 MySQL 与 Redis（可用 Docker）
docker-compose up -d mysql redis

# 2. 导入数据库
mysql -uroot -p123456 < Code/sql/init_schema.sql
mysql -uroot -p123456 < Code/sql/test_data.sql

# 3. 启动后端
cd Code
./mvnw spring-boot:run  # 端口 8081

# 4. 启动 Web 管理后台
cd web-admin
pnpm install
pnpm run dev  # 端口 3100

# 5. 启动微信小程序（用微信开发者工具打开 mini-app/dist/build/mp-weixin）
cd mini-app
npm install
npm run build:mp-weixin
```

## 目录结构

```
GiriiDesign/
├── Code/                # 后端（Spring Boot）
│   ├── src/main/java/com/designstudio/
│   │   ├── common/      # JWT · WebSocket · Redis · AOP · 异常 · 通知 · AI 客服
│   │   ├── system/      # 管理员 · 角色 · 菜单 · 字典
│   │   ├── config/      # 品类 · 自定义字段 · 工作流 · 轮播图 · AI 配置
│   │   ├── order/       # 订单 · 进度 · 工作台 · 看板
│   │   ├── customer/    # C 端用户 · 地址 · 通知
│   │   ├── chat/        # WebSocket 聊天 · 消息记录
│   │   ├── portfolio/   # 作品集
│   │   ├── statistics/  # 经营看板
│   │   └── supply/      # 物料 · BOM 模板
│   ├── sql/             # 数据库脚本
│   └── pom.xml
├── web-admin/           # Web 管理后台（Vue 3）
├── mini-app/            # 微信小程序（Uni-app）
├── deploy/              # Docker 部署文件
├── docker-compose.yml
├── AGENTS.md            # 后端开发指南
├── CLAUDE.md            # 项目状态与架构
├── DEV_PLAN.md          # 迭代计划
├── BUG_AUDIT.md         # 发布前 Bug 巡检
└── PAGE_REDESIGN_PLAN.md
```

## 核心代码入口

| 模块 | 路径 |
| :--- | :--- |
| AI 智能客服 | `Code/src/main/java/com/designstudio/common/service/impl/AiCustomerServiceImpl.java` |
| WebSocket 聊天 | `Code/src/main/java/com/designstudio/chat/websocket/ChatWebSocketHandler.java` |
| 工作流节点推进 | `Code/src/main/java/com/designstudio/order/service/impl/OrderServiceImpl.java` |
| 动态表单 Schema | `Code/src/main/java/com/designstudio/config/service/WorkflowServiceImpl.java` |
| 设计师数据范围 | `Code/src/main/java/com/designstudio/order/service/impl/OrderServiceImpl.java#applyDesignerScope` |
| AI 配置后台 | `web-admin/src/views/config/ai/index.vue` |

## 数据库

- 数据库名：`design_studio`
- 29 张业务表
- 初始化脚本：`Code/sql/init_schema.sql`
- 测试数据：`Code/sql/test_data.sql`
- 迁移脚本：`Code/sql/V*.sql`

## 文档

仓库内仅保留核心架构文档，便于快速了解项目：

- [AGENTS.md](./AGENTS.md) — 后端开发指南（架构 / 模块 / 常用命令）
- [CLAUDE.md](./CLAUDE.md) — 项目当前真实状态

过程类文档（迭代计划、巡检记录、页面重构方案）仅本地维护，不对外公开。

## Roadmap

- SaaS 多租户隔离
- 聊天与订单的更强绑定协同
- 更深度的库存与 BOM 联动
- 视觉设计系统组件化沉淀

## License

MIT

## Author

单哲 · 徐州工程学院 · 软件工程
- GitHub: [@kimo3412](https://github.com/kimo3412)
