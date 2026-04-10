<template>
  <view class="login-container">
    <view class="logo-section">
      <text class="title">ZeHana</text>
      <text class="subtitle">高定与专属体验</text>
      <view class="line"></view>
    </view>

    <!-- 微信一键登录（真机使用） -->
    <button class="login-btn" hover-class="btn-hover" @click="handleWxLogin">
      微信授权登录
    </button>

    <!-- 分割线 -->
    <view class="divider">
      <view class="divider-line"></view>
      <text class="divider-text">或使用账号登录</text>
      <view class="divider-line"></view>
    </view>

    <!-- 账号登录表单 -->
    <view class="form-section">
      <view class="form-item">
        <input
          v-model="username"
          class="form-input"
          placeholder="请输入用户名"
          maxlength="20"
          @confirm="handleAccountLogin"
        />
      </view>
      <button class="account-btn" hover-class="btn-hover" @click="handleAccountLogin">
        登录
      </button>
    </view>

    <view class="agreement">
      <text>使用即表示您同意我们的</text>
      <view class="links">
        <text class="link" @click="showAgreement('user')">《用户协议》</text>
        <text class="link" @click="showAgreement('privacy')">《隐私政策》</text>
      </view>
    </view>
  </view>
</template>

<script setup>
import { ref } from 'vue'
import { useUserStore } from '@/store/user'
import { wxLogin } from '@/api/auth'
import request from '@/utils/request'

const userStore = useUserStore()

const username = ref('')

/**
 * 登录成功后的统一处理
 */
const handleLoginSuccess = (data) => {
  userStore.setToken(data.token)
  userStore.setUserInfo(data)
  uni.hideLoading()
  
  if (data.isNewUser) {
    uni.showToast({ title: '欢迎加入 ZeHana', icon: 'none' })
    setTimeout(() => {
      uni.navigateTo({ url: '/pages/user/profile/index?mode=setup' })
    }, 1000)
  } else {
    uni.showToast({ title: '欢迎回来', icon: 'none' })
    setTimeout(() => {
      uni.switchTab({ url: '/pages/index/index' })
    }, 1000)
  }
}

/**
 * 真实微信登录
 */
const handleWxLogin = () => {
  uni.showLoading({ title: '安全连接中...' })
  uni.login({
    provider: 'weixin',
    success: async (loginRes) => {
      if (loginRes.code) {
        try {
          const data = await wxLogin(loginRes.code)
          if (data) handleLoginSuccess(data)
        } catch (err) {
          uni.hideLoading()
          console.error(err)
          uni.showToast({ title: '身份验证失败', icon: 'none' })
        }
      } else {
        uni.hideLoading()
        uni.showToast({ title: '获取权限失败', icon: 'none' })
      }
    },
    fail: () => {
      uni.hideLoading()
      uni.showToast({ title: '微信服务不可用', icon: 'none' })
    }
  })
}

/**
 * 账号登录
 */
const handleAccountLogin = async () => {
  if (!username.value.trim()) {
    uni.showToast({ title: '请输入用户名', icon: 'none' })
    return
  }

  try {
    uni.showLoading({ title: '登录中...' })
    const data = await request({
      url: '/v1/app/auth/mock-login',
      method: 'POST',
      data: {
        username: username.value.trim()
      }
    })
    if (data) handleLoginSuccess(data)
  } catch (err) {
    uni.hideLoading()
    console.error(err)
    uni.showToast({ title: err.message || '登录失败', icon: 'none' })
  }
}

const showAgreement = (type) => {
  uni.showModal({
    title: type === 'user' ? '用户协议' : '隐私政策',
    content: 'ZeHana Studio Terms & Conditions...',
    showCancel: false,
    confirmColor: '#4A5D4E'
  })
}
</script>

<style lang="scss" scoped>
.login-container {
  min-height: 100vh;
  background: $background-color;
  display: flex;
  flex-direction: column;
  padding: 100rpx 60rpx;
}

.logo-section {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  margin-top: -60rpx;
}

.title {
  font-size: 64rpx;
  font-weight: 300;
  color: $primary-color;
  letter-spacing: 8rpx;
  font-family: 'Times New Roman', serif;
  margin-bottom: 24rpx;
}

.subtitle {
  font-size: 20rpx;
  color: $text-color-light;
  letter-spacing: 6rpx;
}

.line {
  width: 40rpx;
  height: 1px;
  background-color: $primary-color;
  margin-top: 40rpx;
  opacity: 0.5;
}

.login-btn {
  width: 100%;
  height: 100rpx;
  line-height: 100rpx;
  background: $text-color;
  color: $white;
  font-size: 24rpx;
  letter-spacing: 6rpx;
  border-radius: 0;
  border: none;

  &::after {
    border: none;
  }
}

.divider {
  display: flex;
  align-items: center;
  margin: 40rpx 0;
  gap: 20rpx;

  .divider-line {
    flex: 1;
    height: 1px;
    background: #ddd;
  }

  .divider-text {
    font-size: 20rpx;
    color: $text-color-light;
    letter-spacing: 2rpx;
    white-space: nowrap;
  }
}

.form-section {
  margin-bottom: 40rpx;
}

.form-item {
  margin-bottom: 20rpx;
}

.form-input {
  width: 100%;
  height: 88rpx;
  background: $white;
  border: 1px solid #e0e0e0;
  padding: 0 28rpx;
  font-size: 26rpx;
  letter-spacing: 2rpx;
  color: $text-color;
  box-sizing: border-box;
}

.account-btn {
  width: 100%;
  height: 88rpx;
  line-height: 88rpx;
  background: $primary-color;
  color: $white;
  font-size: 24rpx;
  letter-spacing: 6rpx;
  border-radius: 0;
  border: none;
  margin-top: 10rpx;

  &::after {
    border: none;
  }
}

.btn-hover {
  opacity: 0.8;
}

.agreement {
  font-size: 18rpx;
  color: $text-color-light;
  text-align: center;
  letter-spacing: 2rpx;
  margin-bottom: 40rpx;

  .links {
    margin-top: 10rpx;
    display: flex;
    justify-content: center;
    gap: 20rpx;
  }

  .link {
    color: $primary-color;
    text-decoration: underline;
  }
}
</style>
