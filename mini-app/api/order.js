import request from '../utils/request'

/**
 * 获取我的订单列表
 * @param {Object} params - 查询参数
 */
export const getOrderList = (params) => {
  return request({
    url: '/v1/app/orders/my',
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
    url: `/v1/app/orders/${id}`,
    method: 'GET'
  })
}

/**
 * 获取订单进度时间轴
 * @param {number} id - 订单ID
 */
export const getOrderProgress = (id) => {
  // 在后端并没有独立的 progress 接口，我们已经通过 detail 将其合并返回了
  // 所以这个接口实际上在前端应当被废弃或指向 detail（前端逻辑兼容处理）
  return request({
    url: `/v1/app/orders/${id}`,
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

/**
 * 模拟支付订单（定金/尾款）
 * @param {number} id - 订单ID
 */
export const payOrder = (id) => {
  return request({
    url: `/v1/app/orders/${id}/pay`,
    method: 'POST'
  })
}
