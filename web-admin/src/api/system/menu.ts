import { Alova } from '@/utils/http/alova/index';

/**
 * 获取后台菜单列表（动态路由用）
 */
export function adminMenus() {
  return Alova.Get<any>('/v1/admin/menus');
}
