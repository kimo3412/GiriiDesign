<template>
  <view class="login-container">
    <view class="logo-section">
      <image class="logo" src="/static/images/logo.png" mode="aspectFit" />
      <text class="title">独立设计师工作室</text>
      <text class="subtitle">定制您的专属体验</text>
    </view>

    <!-- 模拟登录按钮（测试用） -->
    <button class="login-btn" type="primary" @click="handleSimulateLogin">
      测试登录
    </button>

    <!-- 微信登录（需要企业账号） -->
    <button class="login-btn wechat" type="primary" open-type="getPhoneNumber" @getphonenumber="handleGetPhoneNumber">
      微信一键登录
    </button>

    <view class="agreement">
      <text>登录即表示同意</text>
      <text class="link" @click="showAgreement('user')">《用户协议》</text>
      <text>和</text>
      <text class="link" @click="showAgreement('privacy')">《隐私政策》</text>
    </view>
  </view>
</template>

<script setup>
import { wxLogin } from '@/api/auth'
import { useUserStore } from '@/store/user'
import storage from '@/utils/storage'

const userStore = useUserStore()

/**
 * 模拟登录（测试用）
 */
const handleSimulateLogin = () => {
  // 模拟登录成功
  const mockToken = 'mock_token_' + Date.now()
  const mockUserInfo = {
    userId: 1,
    nickname: '测试用户',
    phone: '13800138000',
    avatar: ''
  }

  userStore.setToken(mockToken)
  userStore.setUserInfo(mockUserInfo)

  uni.showToast({ title: '登录成功', icon: 'success' })

  setTimeout(() => {
    uni.switchTab({ url: '/pages/index/index' })
  }, 1500)
}

/**
 * 微信登录
 */
const handleGetPhoneNumber = async (e) => {
  if (e.detail.errMsg !== 'getPhoneNumber:ok') {
    return
  }

  try {
    uni.showLoading({ title: '登录中...' })

    // 1. 获取微信 code (使用 wx.login 作为后备)
    const loginRes = await uni.login()
    const code = loginRes.code

    // 2. 调用后端登录接口
    const data = await wxLogin(code)

    // 3. 保存 token 和用户信息
    userStore.setToken(data.token)
    userStore.setUserInfo(data.userInfo)

    uni.hideLoading()
    uni.showToast({ title: '登录成功', icon: 'success' })

    // 4. 跳转首页
    setTimeout(() => {
      uni.switchTab({ url: '/pages/index/index' })
    }, 1500)
  } catch (err) {
    uni.hideLoading()
    uni.showToast({ title: err.message || '登录失败', icon: 'none' })
  }
}

/**
 * 显示协议
 */
const showAgreement = (type) => {
  uni.showModal({
    title: type === 'user' ? '用户协议' : '隐私政策',
    content: '这里是协议内容...',
    showCancel: false
  })
}
</script>

<style lang="scss" scoped>
.login-container {
  min-height: 100vh;
  background: #fff;
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 100rpx 60rpx;
}

.logo-section {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
}

.logo {
  width: 200rpx;
  height: 200rpx;
  margin-bottom: 40rpx;
}

.title {
  font-size: 44rpx;
  font-weight: bold;
  color: #333;
  margin-bottom: 16rpx;
}

.subtitle {
  font-size: 28rpx;
  color: #999;
}

.login-btn {
  width: 100%;
  height: 96rpx;
  background: #07c160;
  color: #fff;
  font-size: 32rpx;
  border-radius: 48rpx;
  border: none;
  margin-bottom: 40rpx;

  &::after {
    border: none;
  }
}

.agreement {
  font-size: 24rpx;
  color: #999;
  text-align: center;

  .link {
    color: #07c160;
  }
}
</style>
