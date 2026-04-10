import { defineStore } from 'pinia'
import storage from '../utils/storage'

export const useUserStore = defineStore('user', {
  state: () => ({
    token: storage.getToken() || '',
    userInfo: storage.getUserInfo() || null
  }),

  getters: {
    isLoggedIn: (state) => !!state.token
  },

  actions: {
    setToken(token) {
      this.token = token
      storage.setToken(token)
    },

    setUserInfo(userInfo) {
      this.userInfo = userInfo
      storage.setUserInfo(userInfo)
    },

    logout() {
      this.token = ''
      this.userInfo = null
      storage.removeToken()
      storage.setUserInfo(null)
    }
  }
})
