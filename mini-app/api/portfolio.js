import request from '../utils/request'

/**
 * 获取作品集列表
 * @param {Object} params - 查询参数
 */
export const getPortfolioList = (params) => {
  return request({
    url: '/api/v1/portfolios',
    method: 'GET',
    data: params
  })
}

/**
 * 获取作品详情
 * @param {number} id - 作品ID
 */
export const getPortfolioDetail = (id) => {
  return request({
    url: `/api/v1/portfolios/${id}`,
    method: 'GET'
  })
}
