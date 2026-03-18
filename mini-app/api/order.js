import request from '../utils/request'

/**
 * 获取我的订单列表
 * @param {Object} params - 查询参数
 */
export const getOrderList = (params) => {
  return request({
    url: '/api/v1/users/me/orders',
    method: 'GET',
    data: params
  })
}

/**
 * 获取订单详情
 * @param {number} id - 订单ID
 */
export const getOrderDetail = (id) => {
  return request({
    url: `/api/v1/orders/${id}`,
    method: 'GET'
  })
}

/**
 * 获取订单进度时间轴
 * @param {number} id - 订单ID
 */
export const getOrderProgress = (id) => {
  return request({
    url: `/api/v1/orders/${id}/progress`,
    method: 'GET'
  })
}

/**
 * 确认收货
 * @param {number} id - 订单ID
 */
export const confirmOrder = (id) => {
  return request({
    url: `/api/v1/orders/${id}/confirm`,
    method: 'POST'
  })
}
