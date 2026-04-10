import { Alova } from '@/utils/http/alova/index';

/** 作品集列表（分页） */
export function getPortfolioList(params: any) {
    return Alova.Get<any>('/v1/admin/portfolios', { params });
}

/** 新增作品 */
export function addPortfolio(data: any) {
    return Alova.Post<any>('/v1/admin/portfolios', data);
}

/** 修改作品 */
export function updatePortfolio(id: number, data: any) {
    return Alova.Put<any>(`/v1/admin/portfolios/${id}`, data);
}

/** 删除作品 */
export function deletePortfolio(id: number) {
    return Alova.Delete<any>(`/v1/admin/portfolios/${id}`);
}

/** 批量删除作品 */
export function batchDeletePortfolios(ids: number[]) {
    return Alova.Delete<any>('/v1/admin/portfolios/batch', ids);
}

/** 发布/下架作品 */
export function togglePortfolioStatus(id: number, status: number) {
    return Alova.Put<any>(`/v1/admin/portfolios/${id}/status`, { status });
}
