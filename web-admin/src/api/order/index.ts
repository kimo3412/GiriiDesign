import { Alova } from '@/utils/http/alova/index';

/** 订单列表（分页） */
export function getOrderList(params: any) {
    return Alova.Get<any>('/v1/admin/orders', { params });
}

/** 订单详情（360° 视图） */
export function getOrderDetail(id: number) {
    return Alova.Get<any>(`/v1/admin/orders/${id}`);
}

/** 订单看板数据（按品类分组，列=工作流节点） */
export function getKanbanData(params?: any) {
    return Alova.Get<any>('/v1/admin/orders/kanban', { params });
}

/** 推进订单到下一个工作流节点 */
export function advanceOrder(orderId: number, data: any) {
    return Alova.Post<any>(`/v1/admin/orders/${orderId}/advance`, data);
}

/** 阻塞订单 */
export function blockOrder(orderId: number, data: { blockReason: string }) {
    return Alova.Post<any>(`/v1/admin/orders/${orderId}/block`, data);
}

/** 解除阻塞 */
export function unblockOrder(orderId: number) {
    return Alova.Post<any>(`/v1/admin/orders/${orderId}/unblock`);
}

/** 添加进度记录 */
export function addProgress(orderId: number, data: any) {
    return Alova.Post<any>(`/v1/admin/orders/${orderId}/progress`, data);
}

/** 获取进度时间轴 */
export function getProgressList(orderId: number) {
    return Alova.Get<any>(`/v1/admin/orders/${orderId}/progress`);
}

/** 意向列表 */
export function getRequestList(params: any) {
    return Alova.Get<any>('/v1/admin/requests', { params });
}

/** 意向详情 */
export function getRequestDetail(id: number) {
    return Alova.Get<any>(`/v1/admin/requests/${id}`);
}

/** 意向转正订单 */
export function convertRequest(requestId: number, data: any) {
    return Alova.Post<any>(`/v1/admin/requests/${requestId}/convert`, data);
}

/** 关闭意向 */
export function closeRequest(requestId: number, data: { closeReason: string }) {
    return Alova.Post<any>(`/v1/admin/requests/${requestId}/close`, data);
}
