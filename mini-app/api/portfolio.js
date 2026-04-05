import request from '../utils/request'

/**
 * 获取作品集列表
 * @param {Object} params - 查询参数
 */
export const getPortfolioList = (params) => {
  return request({
    url: '/v1/app/public/portfolios',
    method: 'GET',
    data: params
  }).then(res => {
    // 后端返回List，直接包装成分页格式
    if (Array.isArray(res)) {
      return { list: res }
    }
    return res
  })
}

/**
 * 获取作品详情
 * @param {number} id - 作品ID
 */
export const getPortfolioDetail = (id) => {
  return request({
    url: `/v1/app/public/portfolios/${id}`,
    method: 'GET'
  })
}
