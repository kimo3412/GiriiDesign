import { Alova } from '@/utils/http/alova/index';

export interface SysAdmin {
  adminId?: number;
  username: string;
  password?: string;
  nickname: string;
  phone?: string;
  email?: string;
  status: number;
  createTime?: string;
}

export interface AdminSaveDTO extends SysAdmin {
  roleIds: number[];
}

export interface AdminDetailVO {
  admin: SysAdmin;
  roleIds: number[];
}

export const getAdminList = () => Alova.Get<SysAdmin[]>('/v1/admin/users');
export const getAdminDetail = (id: number) => Alova.Get<AdminDetailVO>(`/v1/admin/users/${id}`);
export const addAdmin = (data: AdminSaveDTO) => Alova.Post<void>('/v1/admin/users', data);
export const updateAdmin = (id: number, data: AdminSaveDTO) => Alova.Put<void>(`/v1/admin/users/${id}`, data);
export const deleteAdmin = (id: number) => Alova.Delete<void>(`/v1/admin/users/${id}`);
