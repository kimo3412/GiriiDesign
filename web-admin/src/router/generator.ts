import { adminMenus } from '@/api/system/menu';
import { constantRouterIcon } from './icons';
import { RouteRecordRaw } from 'vue-router';
import { Layout, ParentLayout } from '@/router/constant';
import type { AppRouteRecordRaw } from '@/router/types';

const LayoutMap = new Map<string, () => Promise<typeof import('*.vue')>>();

LayoutMap.set('LAYOUT', Layout);

/**
 * 将后端菜单数据转换为前端路由格式
 *
 * 后端格式:
 *   { menuId, menuName, menuType, path, component, perms, icon, sortOrder, visible, children }
 *
 * 前端期望:
 *   { name, path, component, meta: { title, icon, permissions }, children }
 */
export const transformMenuToRoute = (menus: any[], parent?: any): any[] => {
  return menus
    .filter((item) => item.menuType !== 'F') // 过滤按钮类型，只保留目录(M)和菜单(C)
    .map((item) => {
      const routePath =
        item.path && item.path.startsWith('/')
          ? item.path
          : `${(parent && parent.path) || ''}/${item.path || ''}`.replace('//', '/');
      const currentRoute: any = {
        path: routePath,
        name: item.path?.replace(/\//g, '-')?.replace(/^-/, '') || `menu-${item.menuId}`,
        component: item.menuType === 'M' ? 'LAYOUT' : (item.component || item.path),
        meta: {
          title: item.menuName,
          icon: constantRouterIcon[item.icon] || null,
          permissions: item.perms ? [item.perms] : null,
          sort: item.sortOrder,
          hidden: item.visible === 0,
        },
      };

      // 有子菜单时递归
      if (item.children && item.children.length > 0) {
        // 过滤掉按钮子菜单
        const childMenus = item.children.filter((c: any) => c.menuType !== 'F');
        if (childMenus.length > 0) {
          currentRoute.children = transformMenuToRoute(childMenus, currentRoute);
          // 默认重定向到第一个子路由
          if (!currentRoute.redirect && currentRoute.children.length > 0) {
            currentRoute.redirect = currentRoute.children[0].path;
          }
        }
      }

      return currentRoute;
    });
};

/**
 * 动态生成菜单
 */
export const generateDynamicRoutes = async (): Promise<RouteRecordRaw[]> => {
  const result = await adminMenus();
  const router = transformMenuToRoute(result);

  // 注入需要隐藏的业务路由（不在菜单中显示，但需要通过 URL 访问）
  const hiddenRoutes: any[] = [
    {
      path: '/order/detail/:id',
      name: 'order-detail',
      component: '/order/detail',
      meta: { title: '订单详情', hidden: true },
    },
  ];

  // 将隐藏路由挂到顶层 Layout 下
  router.push({
    path: '/order-hidden',
    name: 'order-hidden-layout',
    component: 'LAYOUT',
    meta: { title: '订单详情', hidden: true },
    children: hiddenRoutes,
  } as any);

  asyncImportRoute(router);
  return router;
};

// 保持原有的 generateRoutes 用于兼容
export const generateRoutes = transformMenuToRoute;

/**
 * 查找views中对应的组件文件
 */
let viewsModules: Record<string, () => Promise<Recordable>>;
export const asyncImportRoute = (routes: AppRouteRecordRaw[] | undefined): void => {
  viewsModules = viewsModules || import.meta.glob('../views/**/*.{vue,tsx}');
  if (!routes) return;
  routes.forEach((item) => {
    const { component, name } = item;
    const { children } = item;
    if (component) {
      const layoutFound = LayoutMap.get(component as string);
      if (layoutFound) {
        item.component = layoutFound;
      } else {
        item.component = dynamicImport(viewsModules, component as string);
      }
    } else if (name) {
      item.component = ParentLayout;
    }
    children && asyncImportRoute(children);
  });
};

/**
 * 动态导入组件
 */
export const dynamicImport = (
  viewsModules: Record<string, () => Promise<Recordable>>,
  component: string
) => {
  const keys = Object.keys(viewsModules);
  const matchKeys = keys.filter((key) => {
    let k = key.replace('../views', '');
    const lastIndex = k.lastIndexOf('.');
    k = k.substring(0, lastIndex);
    return k === component || k === component + '/index';
  });
  if (matchKeys?.length === 1) {
    const matchKey = matchKeys[0];
    return viewsModules[matchKey];
  }
  if (matchKeys?.length > 1) {
    console.warn(
      'Please do not create `.vue` and `.TSX` files with the same file name in the same hierarchical directory under the views folder.'
    );
    return;
  }
  console.warn(`[dynamic-route] Component not found for route component: ${component}`);
  return viewsModules['../views/exception/404.vue'];
};
