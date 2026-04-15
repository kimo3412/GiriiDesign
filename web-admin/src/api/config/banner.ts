import { Alova } from '@/utils/http/alova/index';

/** 轮播图列表（分页） */
export function getBannerList(params: any) {
    return Alova.Get<any>('/v1/admin/banners', { params });
}

/** 轮播图详情 */
export function getBannerDetail(id: number) {
    return Alova.Get<any>(`/v1/admin/banners/${id}`);
}

/** 新增轮播图 */
export function addBanner(data: any) {
    return Alova.Post<any>('/v1/admin/banners', data);
}

/** 修改轮播图 */
export function updateBanner(id: number, data: any) {
    return Alova.Put<any>(`/v1/admin/banners/${id}`, data);
}

/** 删除轮播图 */
export function deleteBanner(id: number) {
    return Alova.Delete<any>(`/v1/admin/banners/${id}`);
}

/** C端 - 获取轮播图列表 */
export function getAppBannerList() {
    return Alova.Get<any>('/v1/app/public/banners');
}
