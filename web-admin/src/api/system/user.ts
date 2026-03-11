import { Alova } from '@/utils/http/alova/index';

/**
 * 登录
 */
export function login(data: { username: string; password: string }) {
  return Alova.Post<any>('/v1/auth/login', data, {
    meta: { isReturnNativeResponse: true, ignoreToken: true },
  });
}

/**
 * 登出
 */
export function logout() {
  return Alova.Post<any>('/v1/auth/logout');
}

/**
 * 获取当前登录用户信息
 */
export function getUserInfo() {
  return Alova.Get<any>('/v1/admin/info', {
    meta: { isReturnNativeResponse: true },
  });
}

/**
 * 获取当前用户的菜单树（动态菜单）
 */
export function getMenuList() {
  return Alova.Get<any>('/v1/admin/menus');
}
