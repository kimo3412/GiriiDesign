/**
 * 本地存储封装
 */
const storage = {
  // Token
  setToken(token) {
    uni.setStorageSync('token', token)
  },
  getToken() {
    return uni.getStorageSync('token') || ''
  },
  removeToken() {
    uni.removeStorageSync('token')
  },

  // 用户信息
  setUserInfo(info) {
    uni.setStorageSync('userInfo', info)
  },
  getUserInfo() {
    return uni.getStorageSync('userInfo') || null
  },

  // 通用方法
  set(key, value) {
    uni.setStorageSync(key, value)
  },
  get(key) {
    return uni.getStorageSync(key)
  },
  remove(key) {
    uni.removeStorageSync(key)
  },
  clear() {
    uni.clearStorageSync()
  }
}

export default storage
