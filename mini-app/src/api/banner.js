import request from '../utils/request'

/**
 * 获取轮播图列表
 */
export const getBannerList = () => {
  return request({
    url: '/v1/app/public/banners',
    method: 'GET'
  })
}
