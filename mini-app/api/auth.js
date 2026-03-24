import request from '../utils/request'

/**
 * 微信登录
 * @param {string} code - wx.login 返回的 code
 */
export const wxLogin = (code) => {
  return request({
    url: '/v1/app/auth/wx-login',
    method: 'POST',
    data: { code }
  })
}
