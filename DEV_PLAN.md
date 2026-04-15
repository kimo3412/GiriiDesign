# 开发计划

> 最后更新：2026-04-14

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

---

## 阶段1：多角色权限体系（基础）

> 先完善角色体系，才能给不同角色分配不同菜单

| 序号 | 任务 | 状态 |
| :--- | :--- | :--- |
| 1.1 | 角色表完善（`sys_role` 新增 role_type 字段） | ✅ 已完成 |
| 1.2 | 后台菜单根据角色动态显示 | ✅ 已实现（后端已支持） |
| 1.3 | 角色权限分配页面开发 | ✅ 已存在 |
| 1.4-1.7 | 新角色菜单配置（库管/采购/财务/客服） | ✅ SQL迁移已准备 |
| 1.8 | 客户管理菜单与页面（`sys_menu` + 后台页面） | 待开发 |

---

## 阶段2：管理功能分页

> 所有列表页面加上分页，支持大数据量

| 序号 | 任务 | 状态 |
| :--- | :--- | :--- |
| 2.1 | 订单列表分页（web-admin） | ✅ 已完成 |
| 2.2 | 物料列表分页 | ✅ 已完成 |
| 2.3 | C端用户列表分页 | 待开发 |
| 2.4 | 作品集列表分页 | ✅ 已完成 |
| 2.5 | BOM模板列表分页 | ✅ 已完成 |
| 2.6 | 意向单列表分页（后端完成，前端页面较复杂） | ⚠️ 后端完成 |

---

## 阶段3：小程序增强

> 轮播图数据库化 + 流程精简

| 序号 | 任务 | 状态 |
| :--- | :--- | :--- |
| 3.1 | 新建 `ds_banner` 表存储轮播图 | ✅ 代码与SQL已完成，待执行迁移 |
| 3.2 | 后台轮播图管理页面 | ✅ 已完成 |
| 3.3 | 小程序首页轮播图从数据库读取 | ✅ 已完成 |
| 3.4 | 用户端订单流程精简（仅显示当前及后续步骤） | ✅ 已完成 |

---

## 阶段4：库存与BOM联动

> 核心生产流程

| 序号 | 任务 | 状态 |
| :--- | :--- | :--- |
| 4.1 | 库存扣减逻辑（订单完成时） | 待开发 |
| 4.2 | 库存不足提示与采购联动 | 待开发 |
| 4.3 | 后台库存管理页面（入库、出库记录） | 待开发 |

---

## 阶段5：其他功能优化

| 序号 | 任务 | 状态 |
| :--- | :--- | :--- |
| 5.1 | 预付款模拟页面完善 | 待开发 |
| 5.2 | 图片防盗链修复 | ✅ 已完成静态资源映射，待联调验证 |
| 5.3 | WebSocket断线重连机制 | ✅ 已完成 |
| 5.4 | 完整履约状态机 | ⚠️ 部分完成，仍需继续梳理尾款/发货/收货约束 |

---

## 开发顺序

阶段1（基础）→ 阶段2 → 阶段3 → 阶段4 → 阶段5

---

## 已完成的后端改动

### 角色相关
- `SysRole.java` - 新增 `roleType` 字段
- `SysRoleController.java` - RoleSaveDTO 新增 `roleType`
- `SysRoleServiceImpl.java` - add/update 时处理 `roleType`

### 分页相关
- `PageResult.java` - 分页结果封装类（已存在）
- `OrderController.java` - 订单列表支持分页
- `OrderService.java` - listOrders 增加分页参数
- `MaterialController.java` - 物料列表支持分页
- `BomTemplateController.java` - BOM模板列表支持分页
- `RequestController.java` - 意向单列表支持分页
- `PortfolioController.java` - 作品集列表支持分页

### 前端改动
- `web-admin/src/api/system/roleList.ts` - 新增 ROLE_TYPE_OPTIONS
- `web-admin/src/views/system/role/index.vue` - 角色类型显示/选择
- `web-admin/src/views/order/list/index.vue` - 订单列表分页
- `web-admin/src/views/supply/material/index.vue` - 物料列表分页
- `web-admin/src/views/supply/bom/index.vue` - BOM模板列表分页
- `web-admin/src/views/portfolio/list/index.vue` - 作品集列表分页
- `web-admin/src/views/config/banner/index.vue` - 轮播图管理页面
- `mini-app/pages/index/index.vue` - 首页轮播图改为接口获取
- `mini-app/pages/order/detail/index.vue` - 流程精简与确认收货
- `mini-app/pages/chat/index.vue` - WebSocket 断线重连

### SQL迁移
- `Code/sql/V2__add_role_type_and_new_roles.sql` - 新增角色类型字段、新菜单、新角色（待执行）
- `Code/sql/V3__add_banner_table.sql` - 新增轮播图表（待执行）
- `Code/sql/V4__add_banner_menu.sql` - 新增轮播图菜单（待执行）
