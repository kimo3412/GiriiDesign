import { Alova } from '@/utils/http/alova/index';

/** 物料列表（分页） */
export function getMaterialList(params: any) {
    return Alova.Get<any>('/v1/admin/materials', { params });
}

/** 物料详情 */
export function getMaterialDetail(id: number) {
    return Alova.Get<any>(`/v1/admin/materials/${id}`);
}

/** 新增物料 */
export function addMaterial(data: any) {
    return Alova.Post<any>('/v1/admin/materials', data);
}

/** 修改物料 */
export function updateMaterial(id: number, data: any) {
    return Alova.Put<any>(`/v1/admin/materials/${id}`, data);
}

/** 删除物料 */
export function deleteMaterial(id: number) {
    return Alova.Delete<any>(`/v1/admin/materials/${id}`);
}

/** 入库（增加库存） */
export function stockIn(id: number, data: { quantity: number; remark?: string }) {
    return Alova.Post<any>(`/v1/admin/materials/${id}/stock-in`, data);
}

/** 出库（扣减库存） */
export function stockOut(id: number, data: { quantity: number; remark?: string }) {
    return Alova.Post<any>(`/v1/admin/materials/${id}/stock-out`, data);
}

/** BOM 模板列表 */
export function getBomTemplateList(params?: any) {
    return Alova.Get<any>('/v1/admin/bom-templates', { params });
}

/** BOM 模板详情（含明细） */
export function getBomTemplateDetail(id: number) {
    return Alova.Get<any>(`/v1/admin/bom-templates/${id}`);
}

/** 新增 BOM 模板 */
export function addBomTemplate(data: any) {
    return Alova.Post<any>('/v1/admin/bom-templates', data);
}

/** 修改 BOM 模板 */
export function updateBomTemplate(id: number, data: any) {
    return Alova.Put<any>(`/v1/admin/bom-templates/${id}`, data);
}

/** 删除 BOM 模板 */
export function deleteBomTemplate(id: number) {
    return Alova.Delete<any>(`/v1/admin/bom-templates/${id}`);
}

/** 库存预警列表 */
export function getLowStock() {
    return Alova.Get<any>('/v1/admin/materials/low-stock');
}
