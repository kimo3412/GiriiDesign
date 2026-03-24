// 开发环境后端地址
const BASE_URL = 'http://localhost:8081/api'

// 请求封装
const request = (options) => {
  return new Promise((resolve, reject) => {
    const token = uni.getStorageSync('token') || ''

    uni.request({
      url: BASE_URL + options.url,
      method: options.method || 'GET',
      header: {
        'Authorization': token ? `Bearer ${token}` : '',
        'Content-Type': 'application/json',
        ...options.header
      },
      data: options.data,
      success: (res) => {
        if (res.statusCode === 200) {
          if (res.data.code === 200) {
            resolve(res.data.data)
          } else if (res.data.code === 401) {
            // token 过期或无效
            uni.removeStorageSync('token')
            uni.reLaunch({ url: '/pages/login/index' })
            reject(new Error(res.data.msg || '请重新登录'))
          } else {
            uni.showToast({ title: res.data.msg || '请求失败', icon: 'none' })
            reject(new Error(res.data.msg))
          }
        } else {
          uni.showToast({ title: '服务器错误', icon: 'none' })
          reject(new Error('服务器错误'))
        }
      },
      fail: (err) => {
        uni.showToast({ title: '网络请求失败', icon: 'none' })
        reject(err)
      }
    })
  })
}

export default request
