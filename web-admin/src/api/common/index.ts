import { Alova } from '@/utils/http/alova/index';

/** 数据看板 - 概览统计 */
export function getDashboardOverview() {
    return Alova.Get<any>('/v1/admin/statistics/overview');
}

/** 订单趋势（近30天） */
export function getOrderTrend(params?: any) {
    return Alova.Get<any>('/v1/admin/statistics/order-trend', { params });
}

/** 品类分布 */
export function getCategoryDistribution() {
    return Alova.Get<any>('/v1/admin/statistics/category-distribution');
}

/** 设计师工作负载 */
export function getDesignerWorkload() {
    return Alova.Get<any>('/v1/admin/statistics/designer-workload');
}

/** 字典类型列表 */
export function getDictTypeList(params?: any) {
    return Alova.Get<any>('/v1/admin/dict/types', { params });
}

/** 字典数据列表 */
export function getDictDataList(dictType: string) {
    return Alova.Get<any>(`/v1/admin/dict/data/${dictType}`);
}

/** 操作日志列表 */
export function getOperLogList(params: any) {
    return Alova.Get<any>('/v1/admin/logs/oper', { params });
}

/** 登录日志列表 */
export function getLoginLogList(params: any) {
    return Alova.Get<any>('/v1/admin/logs/login', { params });
}
