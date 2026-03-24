import request from '../utils/request'

/**
 * 获取激活的品类列表
 */
export const getCategoryList = () => {
  return request({
    url: '/v1/app/public/config/categories',
    method: 'GET'
  })
}

/**
 * 获取品类的动态表单 Schema
 * @param {number} categoryId - 品类ID
 */
export const getFormSchema = (categoryId) => {
  return request({
    url: `/v1/app/public/config/categories/${categoryId}/fields`,
    method: 'GET'
  })
}

/**
 * 提交定制意向
 * @param {Object} data - 意向数据
 */
export const submitRequest = (data) => {
  return request({
    url: '/v1/app/requests',
    method: 'POST',
    data
  })
}
