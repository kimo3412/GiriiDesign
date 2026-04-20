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
      <view class="menu-item" @click="goTo('/pages/user/notification/index')">
        <text class="menu-text">通知中心</text>
        <view class="menu-right">
          <view v-if="unreadCount > 0" class="badge">{{ unreadCount > 99 ? '99+' : unreadCount }}</view>
          <text class="menu-cn">消息与进度提醒</text>
        </view>
      </view>
      <view class="menu-divider"></view>
      <view class="menu-item" @click="goTo('/pages/chat/index')">
        <text class="menu-text">专属客服</text>
        <text class="menu-cn">联系您的私人管家</text>
      </view>
      <view class="menu-divider"></view>
      <view class="menu-item" @click="goTo('/pages/user/profile/index')">
        <text class="menu-text">编辑资料</text>
        <text class="menu-cn">昵称、头像与手机号</text>
      </view>
      <view class="menu-divider"></view>
      <view class="menu-item" @click="goTo('/pages/user/address/index')">
        <text class="menu-text">收货地址</text>
        <text class="menu-cn">管理您的地址簿</text>
      </view>
      <view class="menu-divider"></view>
      <view class="menu-item" @click="showAbout">
        <text class="menu-text">关于品牌</text>
        <text class="menu-cn">ZeHana 独立设计工作室</text>
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
import { getUnreadCount } from '@/api/notification'

const userStore = useUserStore()

const userInfo = ref({})
const unreadCount = ref(0)

const updateUserInfo = () => {
  userInfo.value = storage.getUserInfo() || {}
}

const fetchUnreadCount = async () => {
  if (!userStore.isLoggedIn) return
  try {
    const count = await getUnreadCount()
    unreadCount.value = count || 0
  } catch (e) {
    // ignore
  }
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
  fetchUnreadCount()
})
</script>

<style lang="scss" scoped>
.user-container {
  min-height: 100vh;
  background: #F5F2EE;
  display: flex;
  flex-direction: column;
}

.user-header {
  padding: 80rpx 60rpx;
  background-color: #fff;
  display: flex;
  justify-content: center;
  align-items: center;
  box-shadow: 0 4rpx 24rpx rgba(74, 93, 78, 0.06);
  margin-bottom: 40rpx;
}

.user-info-wrap {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 30rpx;
}

.avatar-box {
  width: 140rpx;
  height: 140rpx;
  border-radius: 50%;
  padding: 6rpx;
  box-shadow: 0 0 0 2rpx $primary-color;
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
  color: #fff;
  display: flex;
  align-items: center;
  justify-content: center;
  font-family: 'Times New Roman', serif;
  font-size: 72rpx;
}

.user-info {
  text-align: center;

  .nickname {
    display: block;
    font-size: 30rpx;
    font-weight: 400;
    color: #2c2c2c;
    letter-spacing: 3rpx;
    margin-bottom: 8rpx;
  }

  .phone {
    font-size: 22rpx;
    color: #bbb;
    letter-spacing: 1px;
  }
}

.menu-section {
  background: #fff;
  padding: 0 40rpx;
}

.menu-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 36rpx 10rpx;
  &:active { opacity: 0.7; }

  .menu-text {
    font-size: 26rpx;
    color: #2c2c2c;
    letter-spacing: 2rpx;
  }

  .menu-right {
    display: flex;
    align-items: center;
    gap: 12rpx;
  }

  .menu-cn {
    font-size: 22rpx;
    color: #bbb;
  }
}

.badge {
  background: #E85D4A;
  color: #fff;
  font-size: 18rpx;
  min-width: 32rpx;
  height: 32rpx;
  line-height: 32rpx;
  border-radius: 16rpx;
  text-align: center;
  padding: 0 8rpx;
}

.menu-divider {
  height: 1rpx;
  background-color: #e8e4e0;
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
  color: #bbb;
  font-size: 24rpx;
  letter-spacing: 3rpx;
  border: 1rpx solid #e8e4e0;
  border-radius: 0;

  &::after { border: none; }
  &:active { background-color: rgba(0, 0, 0, 0.03); }
}
</style>
