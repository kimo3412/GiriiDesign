import { Alova } from '@/utils/http/alova/index';

export interface SysOperLog {
  logId: number;
  title: string;
  method: string;
  requestMethod: string;
  operatorId: number;
  operatorName: string;
  operUrl: string;
  operIp: string;
  operParam: string;
  jsonResult: string;
  status: number;
  errorMsg: string;
  operTime: string;
}

/** 查询操作日志列表 */
export const getOperLogList = (params?: { title?: string; operatorName?: string; status?: number }) => {
  return Alova.Get<SysOperLog[]>('/v1/admin/logs', { params });
};

/** 删除操作日志 */
export const deleteOperLog = (id: number) => {
  return Alova.Delete<void>(`/v1/admin/logs/${id}`);
};

/** 清空操作日志 */
export const cleanOperLog = () => {
  return Alova.Delete<void>('/v1/admin/logs/clean');
};
