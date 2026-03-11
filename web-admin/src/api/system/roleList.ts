import { Alova } from '@/utils/http/alova/index';

export interface SysRole {
  roleId?: number;
  roleName: string;
  roleKey: string;
  remark?: string;
  createTime?: string;
}

export interface RoleSaveDTO extends SysRole {
  menuIds: number[];
}

export interface RoleDetailVO {
  role: SysRole;
  menuIds: number[];
}

export const getRoleList = () => Alova.Get<SysRole[]>('/v1/admin/roles');
export const getRoleDetail = (id: number) => Alova.Get<RoleDetailVO>(`/v1/admin/roles/${id}`);
export const addRole = (data: RoleSaveDTO) => Alova.Post<void>('/v1/admin/roles', data);
export const updateRole = (id: number, data: RoleSaveDTO) => Alova.Put<void>(`/v1/admin/roles/${id}`, data);
export const deleteRole = (id: number) => Alova.Delete<void>(`/v1/admin/roles/${id}`);
