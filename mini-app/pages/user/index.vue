<template>
  <view class="user-container">
    <!-- 用户信息极简版框 -->
    <view class="user-header">
      <view class="user-info-wrap" @click="goToProfile">
        <view class="avatar-box">
          <image v-if="userInfo.avatar" class="avatar" :src="userInfo.avatar" mode="aspectFill" />
          <view v-else class="avatar-placeholder">Z</view>
        </view>
        <view class="user-info">
          <text class="nickname">{{ userInfo.nickname || 'ZeHana 访客' }}</text>
          <text class="phone">{{ userInfo.phone || '请绑定手机号' }}</text>
        </view>
      </view>
    </view>

    <!-- 高级感菜单 -->
    <view class="menu-section">
      <view class="menu-item" @click="goTo('/pages/user/address/index')">
        <text class="menu-text">地址簿 Address</text>
        <text class="menu-cn">收货地址</text>
      </view>
      <view class="menu-divider"></view>
      <view class="menu-item" @click="showAbout">
        <text class="menu-text">关于品牌 About</text>
        <text class="menu-cn">关于独立工作室</text>
      </view>
    </view>

    <!-- 高级退出按钮 -->
    <view class="logout-section">
      <button class="logout-btn" @click="handleLogout">退出登录</button>
    </view>
  </view>
</template>

<script setup>
import { ref } from 'vue'
import { onShow } from '@dcloudio/uni-app'
import { useUserStore } from '@/store/user'
import storage from '@/utils/storage'

const userStore = useUserStore()

const userInfo = ref({})

const updateUserInfo = () => {
  userInfo.value = storage.getUserInfo() || {}
}

const goTo = (url) => {
  uni.navigateTo({ url })
}

const goToProfile = () => {
  if (!userStore.isLoggedIn) {
     uni.showToast({ title: '请先登录', icon: 'none' })
     return
  }
  uni.navigateTo({ url: '/pages/user/profile/index' })
}

const showAbout = () => {
  uni.showModal({
    title: 'ZeHana STUDIO',
    content: '高级定制独立设计师工作室\nVersion 1.0.0',
    showCancel: false,
    confirmColor: '#4A5D4E'
  })
}

const handleLogout = () => {
  if (!userStore.isLoggedIn) {
     uni.showToast({ title: '尚未登录', icon: 'none' })
     return
  }
  uni.showModal({
    title: 'SIGN OUT',
    content: '确定要退出当前账号吗？',
    confirmColor: '#4A5D4E',
    success: (res) => {
      if (res.confirm) {
        userStore.logout()
        updateUserInfo()
        uni.switchTab({ url: '/pages/index/index' })
      }
    }
  })
}

onShow(() => {
  updateUserInfo()
})
</script>

<style lang="scss" scoped>
.user-container {
  min-height: 100vh;
  background: $background-color;
  display: flex;
  flex-direction: column;
}

.user-header {
  padding: 80rpx 60rpx;
  background-color: $white;
  display: flex;
  justify-content: center;
  align-items: center;
  box-shadow: 0 10rpx 40rpx rgba(0,0,0,0.02);
  margin-bottom: 40rpx;
}

.user-info-wrap {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 30rpx;
}

.avatar-box {
  width: 160rpx;
  height: 160rpx;
  border-radius: 50%;
  border: 1px solid $border-color;
  padding: 8rpx;
}

.avatar {
  width: 100%;
  height: 100%;
  border-radius: 50%;
}

.avatar-placeholder {
  width: 100%;
  height: 100%;
  border-radius: 50%;
  background: $primary-color;
  color: $white;
  display: flex;
  align-items: center;
  justify-content: center;
  font-family: 'Times New Roman', serif;
  font-size: 80rpx;
}

.user-info {
  text-align: center;

  .nickname {
    display: block;
    font-size: 32rpx;
    font-weight: 300;
    color: $text-color;
    letter-spacing: 4rpx;
    margin-bottom: 8rpx;
  }

  .phone {
    font-size: 20rpx;
    color: $text-color-light;
    letter-spacing: 2rpx;
  }
}

.menu-section {
  background: $white;
  padding: 0 40rpx;
}

.menu-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 40rpx 10rpx;
  
  .menu-text {
    font-size: 26rpx;
    color: $text-color;
    letter-spacing: 2rpx;
  }

  .menu-cn {
    font-size: 22rpx;
    color: $text-color-light;
  }
}

.menu-divider {
  height: 1px;
  background-color: #f0f0f0;
  margin: 0 10rpx;
}

.logout-section {
  padding: 60rpx 40rpx;
  margin-top: auto;
}

.logout-btn {
  width: 100%;
  height: 90rpx;
  line-height: 90rpx;
  background: transparent;
  color: $text-color-light;
  font-size: 24rpx;
  letter-spacing: 4rpx;
  border: 1px solid $border-color;
  border-radius: 0; // 高定直角

  &::after {
    border: none;
  }
  
  &:active {
    background-color: #f9f9f9;
  }
}
</style>
