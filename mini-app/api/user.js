import request from '../utils/request'

/**
 * 获取当前用户信息
 */
export const getUserInfo = () => {
  return request({
    url: '/api/v1/users/me',
    method: 'GET'
  })
}

/**
 * 更新用户资料
 * @param {Object} data - 用户资料
 */
export const updateUserInfo = (data) => {
  return request({
    url: '/api/v1/users/me',
    method: 'PUT',
    data
  })
}

/**
 * 获取地址列表
 */
export const getAddressList = () => {
  return request({
    url: '/api/v1/users/me/addresses',
    method: 'GET'
  })
}

/**
 * 新增地址
 * @param {Object} data - 地址信息
 */
export const addAddress = (data) => {
  return request({
    url: '/api/v1/users/me/addresses',
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
    url: `/api/v1/addresses/${id}`,
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
    url: `/api/v1/addresses/${id}`,
    method: 'DELETE'
  })
}

/**
 * 设为默认地址
 * @param {number} id - 地址ID
 */
export const setDefaultAddress = (id) => {
  return request({
    url: `/api/v1/addresses/${id}/default`,
    method: 'PUT'
  })
}
