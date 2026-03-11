import { Alova } from '@/utils/http/alova/index';

/** 品类列表 */
export function getCategoryList(params?: any) {
    return Alova.Get<any>('/v1/admin/categories', { params });
}

/** 品类详情 */
export function getCategoryDetail(id: number) {
    return Alova.Get<any>(`/v1/admin/categories/${id}`);
}

/** 新增品类 */
export function addCategory(data: any) {
    return Alova.Post<any>('/v1/admin/categories', data);
}

/** 修改品类 */
export function updateCategory(id: number, data: any) {
    return Alova.Put<any>(`/v1/admin/categories/${id}`, data);
}

/** 删除品类 */
export function deleteCategory(id: number) {
    return Alova.Delete<any>(`/v1/admin/categories/${id}`);
}

/** 获取品类下的动态字段列表 */
export function getFieldsByCategory(categoryId: number) {
    return Alova.Get<any>(`/v1/admin/categories/${categoryId}/fields`);
}

/** 保存动态字段（批量） */
export function saveFields(categoryId: number, data: any[]) {
    return Alova.Post<any>(`/v1/admin/categories/${categoryId}/fields`, data);
}

/** 获取品类的工作流 */
export function getWorkflowByCategory(categoryId: number) {
    return Alova.Get<any>(`/v1/admin/categories/${categoryId}/workflow`);
}

/** 保存工作流（含节点） */
export function saveWorkflow(categoryId: number, data: any) {
    return Alova.Post<any>(`/v1/admin/categories/${categoryId}/workflow`, data);
}
