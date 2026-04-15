import { Alova } from '@/utils/http/alova/index';

export interface SysRole {
  roleId?: number;
  roleName: string;
  roleKey: string;
  roleType?: string;
  remark?: string;
  createTime?: string;
}

export interface RoleSaveDTO extends SysRole {
  menuIds: number[];
}

/** 角色类型选项 */
export const ROLE_TYPE_OPTIONS = [
  { label: '管理员', value: 'admin' },
  { label: '设计师', value: 'designer' },
  { label: '库管', value: 'storekeeper' },
  { label: '采购', value: 'purchaser' },
  { label: '财务', value: 'finance' },
  { label: '客服', value: 'customer_service' }
];

/** 角色类型映射 */
export const ROLE_TYPE_MAP: Record<string, string> = {
  admin: '管理员',
  designer: '设计师',
  storekeeper: '库管',
  purchaser: '采购',
  finance: '财务',
  customer_service: '客服'
};

export interface RoleDetailVO {
  role: SysRole;
  menuIds: number[];
}

export const getRoleList = () => Alova.Get<SysRole[]>('/v1/admin/roles');
export const getRoleDetail = (id: number) => Alova.Get<RoleDetailVO>(`/v1/admin/roles/${id}`);
export const addRole = (data: RoleSaveDTO) => Alova.Post<void>('/v1/admin/roles', data);
export const updateRole = (id: number, data: RoleSaveDTO) => Alova.Put<void>(`/v1/admin/roles/${id}`, data);
export const deleteRole = (id: number) => Alova.Delete<void>(`/v1/admin/roles/${id}`);
