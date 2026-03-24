<template>
  <view class="login-container">
    <view class="logo-section">
      <text class="title">ZeHana</text>
      <text class="subtitle">高定与专属体验</text>
      <view class="line"></view>
    </view>

    <!-- 模拟登录按钮 -->
    <button class="login-btn" hover-class="btn-hover" @click="handleSimulateLogin">
      测试一键登录
    </button>

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
import { useUserStore } from '@/store/user'
import request from '@/utils/request'

const userStore = useUserStore()

const handleSimulateLogin = async () => {
  try {
    uni.showLoading({ title: 'LOADING...' })
    
    // 调用我们在后端写的免密模拟登录接口
    const data = await request({
      url: '/v1/app/auth/mock-login',
      method: 'POST',
      data: { phone: '13888888888' }
    })
    
    if (data) {
      userStore.setToken(data.token)
      userStore.setUserInfo(data)
      
      uni.hideLoading()
      uni.showToast({ title: 'WELCOME', icon: 'none' })

      setTimeout(() => {
        uni.switchTab({ url: '/pages/index/index' })
      }, 1500)
    }
  } catch (err) {
    uni.hideLoading()
    console.error(err)
    uni.showToast({ title: '登录失败' || err.message, icon: 'none' })
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
  margin-top: -100rpx; // 稍微整体向上偏移
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
  background: $text-color; // 极黑底色
  color: $white;
  font-size: 24rpx;
  letter-spacing: 6rpx;
  border-radius: 0; // 高级感直角
  border: none;
  margin-bottom: 60rpx;

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
