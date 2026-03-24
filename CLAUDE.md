# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目概述

这是一个**独立设计师工作室生产流程管理系统**的毕业设计项目，采用前后端分离架构：
- 后端: Spring Boot 3.x + MyBatis-Plus + Redis + MySQL
- 前端: Vue 3 + Naive UI + TypeScript + Vite (Web后台) + Uni-app (微信小程序)
- 项目位于 [Code/](Code/) (后端) 和 [web-admin/](web-admin/) (前端)

**系统定位**: 面向独立设计师的**低代码生产管理平台**，解决"非标定制、强沟通、长周期"的生产特点。

## 三大核心创新点

1. **低代码业务扩展引擎**: 动态表单 + 可视化工作流编排，管理员可通过后台配置新增品类和定制流程，无需修改代码
2. **多维度生产效能分析**: 基于 ECharts 的可视化 Dashboard，提供订单趋势、设计师效率、库存周转等数据分析
3. **全链路实时协同**: WebSocket 即时通讯 + 拖拽式看板 + 进度时间轴

## 用户角色

| 角色 | 端 | 说明 |
| :--- | :--- | :--- |
| 客户 (Client) | 小程序 + Web端 | 提交定制需求、查看进度、在线沟通、支付 |
| 设计师 (Designer) | Web后台 | 评估意向、转单、生产进度管理、回复客户 |
| 管理员 (Admin) | Web后台 | 品类配置、物料管理、员工权限、数据看板 |

## 六大功能子系统

1. **客户服务子系统** (C端): 微信登录、地址簿、消息通知
2. **内容展示子系统** (C端): 作品集瀑布流、定制服务说明
3. **核心业务子系统** (C/B端): 动态表单提交、意向池、看板管理、进度追踪
4. **实时通讯子系统** (C/B端): 基于 WebSocket 的订单内聊天
5. **供应链管理子系统** (B端): 物料库、BOM模板、库存预警
6. **平台基础子系统** (B端): RBAC权限、品类/工作流配置、数据字典

## 常用命令

### 后端 (Code/)

```bash
cd Code

# 运行Spring Boot应用
./mvnw spring-boot:run

# 打包
./mvnw clean package -DskipTests

# 运行测试
./mvnw test
```

### 前端 (web-admin/)

```bash
cd web-admin

# 安装依赖
pnpm install

# 开发模式运行
pnpm run dev

# 构建生产版本
pnpm run build

# 代码检查与修复
pnpm run lint:eslint
```

## 项目架构

### 后端模块结构 (com.designstudio)

| 模块 | 说明 |
| :--- | :--- |
| `common` | 通用组件: 配置类、安全模块、异常处理、统一返回封装 |
| `system` | 系统管理: 管理员、角色、菜单、字典管理 |
| `config` | 配置中心: 品类、动态字段、工作流管理 |
| `order` | 订单核心: 意向单、订单、进度管理 |
| `supply` | 供应链: 物料、BOM模板管理 |

### 分层约定

- `controller/` - REST API 接口层
- `service/` - 业务逻辑层 (impl/ 为实现类)
- `mapper/` - 数据访问层 (MyBatis-Plus)
- `domain/` - 实体类

### 核心特性

1. **动态表单引擎**: 根据品类动态生成表单 Schema (EAV 模式)
2. **工作流状态机**: 控制订单生产流程节点流转，不可跳跃
3. **JWT 鉴权**: Token 存储于 Redis，支持黑名单机制
4. **统一错误码**: 5位数字格式 (XXYYY)

### API 路由规范

- 前缀: `/api/v1/`
- 鉴权: Header `Authorization: Bearer {token}`
- 后台管理接口: `/api/v1/admin/...`
- C端接口: `/api/v1/...`

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

## 数据库

- 初始化脚本: [Code/sql/init_schema.sql](Code/sql/init_schema.sql)
- 测试数据: [Code/sql/test_data.sql](Code/sql/test_data.sql)
- 配置文件: [Code/src/main/resources/application.yml](Code/src/main/resources/application.yml)

## 前端目录结构

```
web-admin/src/
├── api/          # API 接口定义
├── components/  # 公共组件 (Form, Table, Modal)
├── views/        # 页面视图
├── stores/       # Pinia 状态管理
└── router/       # 路由配置
```

## 开发注意事项

- 后端使用 Lombok 减少样板代码
- 前端使用 alova 作为请求库
- 前后端通过 JSON 交互，统一使用 `R<T>` 封装返回值
- 前端代理配置见 [web-admin/build/vite/proxy.ts](web-admin/build/vite/proxy.ts)
- 动态表单 Schema 存储于 `ds_custom_field` 表
- 工作流节点定义存储于 `ds_workflow_step` 表，按 `step_order` 排序

## 小程序端开发

开发小程序端时，可使用专门的 Claude Code skill：

```bash
# 加载 skill
安装 skill: .claude/skills/uniapp-miniprogram.md
```

详细开发指南见 [.claude/skills/uniapp-miniprogram.md](.claude/skills/uniapp-miniprogram.md)

### 小程序技术栈
- **框架**: Uni-app (Vue 3)
- **状态管理**: Pinia
- **请求库**: uni.request 封装
- **目标平台**: 微信小程序

### 小程序目录结构 (mini-app/)

```
mini-app/
├── api/                    # API 接口
│   ├── auth.js            # 登录认证
│   ├── user.js            # 用户信息、地址管理
│   ├── order.js           # 订单相关
│   ├── portfolio.js       # 作品集
│   ├── custom.js          # 定制意向
│   └── upload.js          # 文件上传
├── components/            # 公共组件
│   └── timeline/          # 进度时间轴组件
├── pages/                 # 页面
│   ├── login/             # 登录页
│   ├── index/             # 首页
│   ├── portfolio/         # 作品集 (列表、详情)
│   ├── custom/            # 定制 (品类选择、动态表单)
│   ├── order/             # 订单 (列表、详情)
│   └── user/              # 个人中心 (主页、资料、地址)
├── store/                 # Pinia 状态管理
│   └── user.js            # 用户状态
├── utils/                 # 工具函数
│   ├── request.js         # 请求封装
│   └── storage.js         # 本地存储
├── static/                # 静态资源
│   ├── images/            # 图片
│   └── icons/             # 图标
├── App.vue                # 应用入口
├── main.js                # 入口文件
├── pages.json             # 页面配置
├── manifest.json          # 应用配置
└── vite.config.js         # Vite 配置
```

### 小程序 API 端点

| 模块 | 端点 | 说明 |
| :--- | :--- | :--- |
| 登录 | `POST /api/v1/auth/login` | 微信登录 |
| 用户 | `GET /api/v1/users/me` | 获取当前用户信息 |
| 地址 | `GET/POST /api/v1/users/me/addresses` | 地址列表/新增 |
| 作品集 | `GET /api/v1/portfolios` | 作品列表 |
| 品类 | `GET /api/v1/categories/active` | 活跃品类列表 |
| 表单 | `GET /api/v1/categories/{id}/schema` | 获取动态表单 Schema |
| 意向 | `POST /api/v1/requests` | 提交定制意向 |
| 订单 | `GET /api/v1/users/me/orders` | 订单列表 |
| 进度 | `GET /api/v1/orders/{id}/progress` | 订单进度时间轴 |

### 小程序开发命令

```bash
cd mini-app

# 安装依赖
npm install

# 运行到微信开发者工具
npm run dev:mp-weixin

# 打包发布
npm run build:mp-weixin

# HBuilderX 运行 (需安装 HBuilderX)
# 导入项目到 HBuilderX，点击运行
```

### 测试登录

小程序登录页面包含"测试登录"按钮，用于模拟登录（无需企业微信账号）:

```javascript
// 模拟登录数据
const mockUserInfo = {
  userId: 1,
  nickname: '测试用户',
  phone: '13800138000',
  avatar: ''
}
```

### 注意事项

- 后端需运行在 `http://localhost:8080`
- 小程序请求使用 `uni.request`，已封装 JWT token
- 动态表单支持: text, number, textarea, select, radio, checkbox, image
- TabBar 页面: 首页、订单、个人中心
