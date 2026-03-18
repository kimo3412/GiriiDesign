<template>
  <view class="user-container">
    <!-- 用户信息 -->
    <view class="user-header" @click="goToProfile">
      <image class="avatar" :src="userInfo.avatar || '/static/images/default-avatar.png'" mode="aspectFill" />
      <view class="user-info">
        <text class="nickname">{{ userInfo.nickname || '未设置昵称' }}</text>
        <text class="phone">{{ userInfo.phone || '未绑定手机' }}</text>
      </view>
      <text class="arrow">></text>
    </view>

    <!-- 功能菜单 -->
    <view class="menu-section">
      <view class="menu-item" @click="goTo('/pages/user/address/index')">
        <text class="menu-icon">📍</text>
        <text class="menu-text">收货地址</text>
        <text class="arrow">></text>
      </view>
      <view class="menu-item" @click="showAbout">
        <text class="menu-icon">ℹ️</text>
        <text class="menu-text">关于我们</text>
        <text class="arrow">></text>
      </view>
    </view>

    <!-- 退出登录 -->
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

/**
 * 更新用户信息
 */
const updateUserInfo = () => {
  userInfo.value = storage.getUserInfo() || {}
}

/**
 * 跳转页面
 */
const goTo = (url) => {
  uni.navigateTo({ url })
}

/**
 * 跳转个人资料
 */
const goToProfile = () => {
  uni.navigateTo({ url: '/pages/user/profile/index' })
}

/**
 * 显示关于
 */
const showAbout = () => {
  uni.showModal({
    title: '关于我们',
    content: '独立设计师工作室\n版本 1.0.0',
    showCancel: false
  })
}

/**
 * 退出登录
 */
const handleLogout = () => {
  uni.showModal({
    title: '提示',
    content: '确定要退出登录吗？',
    success: (res) => {
      if (res.confirm) {
        userStore.logout()
        uni.reLaunch({ url: '/pages/login/index' })
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
  background: #f8f8f8;
}

.user-header {
  display: flex;
  align-items: center;
  background: linear-gradient(135deg, #07c160, #06ad56);
  padding: 60rpx 30rpx;
}

.avatar {
  width: 120rpx;
  height: 120rpx;
  border-radius: 60rpx;
  border: 4rpx solid rgba(255, 255, 255, 0.3);
  margin-right: 24rpx;
  background: #fff;
}

.user-info {
  flex: 1;

  .nickname {
    display: block;
    font-size: 36rpx;
    font-weight: bold;
    color: #fff;
    margin-bottom: 10rpx;
  }

  .phone {
    font-size: 26rpx;
    color: rgba(255, 255, 255, 0.8);
  }
}

.user-header .arrow {
  font-size: 32rpx;
  color: rgba(255, 255, 255, 0.6);
}

.menu-section {
  background: #fff;
  margin-top: 20rpx;
}

.menu-item {
  display: flex;
  align-items: center;
  padding: 30rpx;
  border-bottom: 1rpx solid #f5f5f5;

  &:last-child {
    border-bottom: none;
  }

  .menu-icon {
    font-size: 40rpx;
    margin-right: 20rpx;
  }

  .menu-text {
    flex: 1;
    font-size: 30rpx;
    color: #333;
  }

  .arrow {
    font-size: 28rpx;
    color: #ccc;
  }
}

.logout-section {
  padding: 40rpx 30rpx;
}

.logout-btn {
  width: 100%;
  height: 88rpx;
  background: #fff;
  color: #e74c3c;
  font-size: 30rpx;
  border-radius: 12rpx;
  border: none;

  &::after {
    border: none;
  }
}
</style>
