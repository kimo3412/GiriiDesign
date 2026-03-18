import request from '../utils/request'

/**
 * 微信登录
 * @param {string} code - wx.login 返回的 code
 */
export const wxLogin = (code) => {
  return request({
    url: '/api/v1/auth/wx-login',
    method: 'POST',
    data: { code }
  })
}
