import { Alova } from '@/utils/http/alova/index';

export interface SysMenu {
  menuId?: number;
  parentId: number;
  menuName: string;
  menuType: string;
  path?: string;
  component?: string;
  perms?: string;
  icon?: string;
  sortOrder: number;
  visible: number;
  children?: SysMenu[];
  createTime?: string;
}

export const getMenuList = () => Alova.Get<SysMenu[]>('/v1/admin/menu-list');
export const getMenuDetail = (id: number) => Alova.Get<SysMenu>(`/v1/admin/menu-list/${id}`);
export const addMenu = (data: SysMenu) => Alova.Post<void>('/v1/admin/menu-list', data);
export const updateMenu = (id: number, data: SysMenu) => Alova.Put<void>(`/v1/admin/menu-list/${id}`, data);
export const deleteMenu = (id: number) => Alova.Delete<void>(`/v1/admin/menu-list/${id}`);
