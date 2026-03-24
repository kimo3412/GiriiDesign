import request from '../utils/request'

/**
 * 获取当前用户信息
 */
export const getUserInfo = () => {
  return request({
    url: '/v1/app/auth/info',
    method: 'GET'
  })
}

/**
 * 更新用户资料
 * @param {Object} data - 用户资料
 */
export const updateUserInfo = (data) => {
  return request({
    url: '/v1/app/auth/update',
    method: 'POST',
    data
  })
}

/**
 * 获取地址列表
 */
export const getAddressList = () => {
  return request({
    url: '/v1/app/address/list',
    method: 'GET'
  })
}

/**
 * 新增地址
 * @param {Object} data - 地址信息
 */
export const addAddress = (data) => {
  return request({
    url: '/v1/app/address',
    method: 'POST',
    data
  })
}

/**
 * 编辑地址
 * @param {number} id - 地址ID
 * @param {Object} data - 地址信息
 */
export const updateAddress = (id, data) => {
  return request({
    url: `/v1/app/address/${id}`,
    method: 'PUT',
    data
  })
}

/**
 * 删除地址
 * @param {number} id - 地址ID
 */
export const deleteAddress = (id) => {
  return request({
    url: `/v1/app/address/${id}`,
    method: 'DELETE'
  })
}

/**
 * 设为默认地址
 * @param {number} id - 地址ID
 */
export const setDefaultAddress = (id) => {
  return request({
    url: `/v1/app/address/${id}/default`,
    method: 'PUT'
  })
}
