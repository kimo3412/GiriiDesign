<template>
  <view class="profile-page">
    <view class="atelier-topbar">
      <button class="topbar-action" @click="goToHome">☰</button>
      <text class="topbar-brand">ATELIER</text>
      <button class="topbar-action topbar-action--notice" @click="goTo('/pages/user/notification/index')">
        <text>通知</text>
        <text v-if="unreadCount > 0" class="topbar-dot"></text>
      </button>
    </view>

    <scroll-view scroll-y class="profile-scroll" :show-scrollbar="false">
      <view class="greeting-section" @click="goToProfile">
        <view class="avatar-frame">
          <image v-if="avatarUrl" class="avatar" :src="avatarUrl" mode="aspectFill" />
          <view v-else class="avatar-fallback">{{ avatarText }}</view>
        </view>
        <text class="greeting-title">{{ greetingText }}</text>
        <text class="greeting-subtitle">{{ greetingSubtitle }}</text>
      </view>

      <view class="action-grid">
        <view class="suite-card suite-card--featured" @click="goTo('/pages/chat/index')">
          <view class="suite-card__left">
            <view class="suite-card__icon suite-card__icon--light">聊</view>
            <view class="suite-card__copy">
              <text class="suite-card__title">专属沟通</text>
              <text class="suite-card__desc">联系你的设计师与工作室管家</text>
            </view>
          </view>
          <text class="suite-card__arrow">›</text>
        </view>

        <view class="suite-card suite-card--wide" @click="goTo('/pages/user/notification/index')">
          <view class="suite-card__left">
            <view class="suite-card__icon">信</view>
            <view class="suite-card__copy">
              <text class="suite-card__title">通知中心</text>
              <text class="suite-card__desc">
                {{ unreadCount > 0 ? `${unreadCountLabel} 条订单更新待查看` : '订单提醒与进度通知会在这里汇总' }}
              </text>
            </view>
          </view>
          <view v-if="unreadCount > 0" class="notice-pulse"></view>
        </view>

        <view class="suite-card suite-card--small" @click="goTo('/pages/user/profile/index')">
          <view class="suite-card__icon">资</view>
          <view class="suite-card__copy">
            <text class="suite-card__title">编辑资料</text>
            <text class="suite-card__desc">昵称、头像与手机号</text>
          </view>
        </view>

        <view class="suite-card suite-card--small" @click="goTo('/pages/user/address/index')">
          <view class="suite-card__icon">地</view>
          <view class="suite-card__copy">
            <text class="suite-card__title">收货地址</text>
            <text class="suite-card__desc">管理常用地址</text>
          </view>
        </view>
      </view>

      <view class="bottom-actions">
        <text class="support-link" @click="showAbout">帮助与品牌信息</text>
        <button class="logout-btn" @click="handleLogout">
          {{ userStore.isLoggedIn ? '退出登录' : '前往登录' }}
        </button>
      </view>
    </scroll-view>
  </view>
</template>

<script setup>
import { computed, ref } from 'vue'
import { onShow } from '@dcloudio/uni-app'
import { getUnreadCount } from '@/api/notification'
import { useUserStore } from '@/store/user'
import storage from '@/utils/storage'

const userStore = useUserStore()
const userInfo = ref({})
const unreadCount = ref(0)

const avatarUrl = computed(() => userInfo.value.avatar || userInfo.value.avatarUrl || '')

const avatarText = computed(() => {
  const name = userInfo.value.nickname || 'Z'
  return String(name).slice(0, 1).toUpperCase()
})

const displayName = computed(() => userInfo.value.nickname || 'ZeHana 访客')

const greetingText = computed(() => {
  if (!userStore.isLoggedIn) return '欢迎来到 ZeHana'
  return `早上好，${displayName.value}`
})

const greetingSubtitle = computed(() => {
  if (!userStore.isLoggedIn) return '登录后查看订单、通知与专属沟通记录'
  return userInfo.value.phone || '欢迎回到你的私人定制套间'
})

const unreadCountLabel = computed(() => (unreadCount.value > 99 ? '99+' : unreadCount.value))

const updateUserInfo = () => {
  userInfo.value = storage.getUserInfo() || {}
}

const fetchUnreadCount = async () => {
  if (!userStore.isLoggedIn) {
    unreadCount.value = 0
    return
  }
  try {
    const count = await getUnreadCount()
    unreadCount.value = count || 0
  } catch (e) {
    unreadCount.value = 0
  }
}

const goToHome = () => {
  uni.switchTab({ url: '/pages/index/index' })
}

const goTo = (url) => {
  if (!userStore.isLoggedIn) {
    uni.showToast({ title: '请先登录', icon: 'none' })
    return
  }
  uni.navigateTo({ url })
}

const goToProfile = () => {
  if (!userStore.isLoggedIn) {
    uni.navigateTo({ url: '/pages/login/index' })
    return
  }
  uni.navigateTo({ url: '/pages/user/profile/index' })
}

const showAbout = () => {
  uni.showModal({
    title: 'ZeHana 工作室',
    content: '高级定制独立设计师工作室\n让定制体验更清晰，也更有温度。',
    showCancel: false,
    confirmColor: '#1A2B3C'
  })
}

const handleLogout = () => {
  if (!userStore.isLoggedIn) {
    uni.navigateTo({ url: '/pages/login/index' })
    return
  }

  uni.showModal({
    title: '退出登录',
    content: '确定要退出当前账号吗？',
    confirmColor: '#1A2B3C',
    success: (res) => {
      if (!res.confirm) return
      userStore.logout()
      updateUserInfo()
      unreadCount.value = 0
      uni.switchTab({ url: '/pages/index/index' })
    }
  })
}

onShow(() => {
  updateUserInfo()
  fetchUnreadCount()
})
</script>

<style lang="scss" scoped>
.profile-page {
  min-height: 100vh;
  background: #fbf9fa;
  color: #1c1c1c;
}

.atelier-topbar {
  position: relative;
  z-index: 10;
  display: flex;
  align-items: center;
  justify-content: space-between;
  height: 112rpx;
  padding: 0 48rpx;
  background: #f9f8f6;
  box-shadow: 0 8rpx 24rpx rgba(26, 43, 60, 0.04);
}

.topbar-brand {
  color: #1a2b3c;
  font-family: Georgia, 'Times New Roman', serif;
  font-size: 36rpx;
  font-weight: 600;
  letter-spacing: 12rpx;
}

.topbar-action {
  position: relative;
  display: flex;
  align-items: center;
  justify-content: center;
  min-width: 68rpx;
  height: 68rpx;
  padding: 0;
  border: none;
  background: transparent;
  color: #1a2b3c;
  font-size: 30rpx;
  line-height: 68rpx;
}

.topbar-action::after {
  border: none;
}

.topbar-action--notice {
  font-size: 24rpx;
  letter-spacing: 1rpx;
}

.topbar-dot {
  position: absolute;
  top: 14rpx;
  right: 4rpx;
  width: 14rpx;
  height: 14rpx;
  border-radius: 50%;
  background: #4a6e8f;
}

.profile-scroll {
  height: calc(100vh - 112rpx);
}

.greeting-section {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 64rpx 48rpx 80rpx;
  text-align: center;
}

.avatar-frame {
  width: 184rpx;
  height: 184rpx;
  padding: 6rpx;
  border: 4rpx solid #ffffff;
  border-radius: 50%;
  background: linear-gradient(135deg, #d2e4fb, #c8eadc);
  box-shadow: 0 18rpx 42rpx rgba(26, 43, 60, 0.08);
}

.avatar,
.avatar-fallback {
  width: 100%;
  height: 100%;
  border-radius: 50%;
}

.avatar-fallback {
  display: flex;
  align-items: center;
  justify-content: center;
  background: #ffffff;
  color: #1a2b3c;
  font-family: Georgia, 'Times New Roman', serif;
  font-size: 68rpx;
  font-weight: 600;
}

.greeting-title {
  margin-top: 28rpx;
  color: #1c1c1c;
  font-family: Georgia, 'Times New Roman', serif;
  font-size: 48rpx;
  font-weight: 600;
  letter-spacing: -1rpx;
}

.greeting-subtitle {
  margin-top: 12rpx;
  color: #6b6b6b;
  font-size: 28rpx;
  line-height: 1.6;
}

.action-grid {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 18rpx;
  padding: 0 48rpx 72rpx;
}

.suite-card {
  box-sizing: border-box;
  border: 1rpx solid #e5e2da;
  border-radius: 32rpx;
  background: #ffffff;
  box-shadow: 0 8rpx 28rpx rgba(26, 43, 60, 0.035);
}

.suite-card--featured,
.suite-card--wide {
  grid-column: span 2;
  display: flex;
  align-items: center;
  justify-content: space-between;
  min-height: 132rpx;
  padding: 28rpx 32rpx;
}

.suite-card--featured {
  border-color: transparent;
  background: #c8eadc;
  box-shadow: 0 12rpx 36rpx rgba(70, 101, 90, 0.08);
}

.suite-card--small {
  min-height: 212rpx;
  padding: 30rpx;
}

.suite-card__left {
  display: flex;
  align-items: center;
  gap: 24rpx;
  min-width: 0;
}

.suite-card__icon {
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
  width: 76rpx;
  height: 76rpx;
  border-radius: 50%;
  background: #f5f3f4;
  color: #1a2b3c;
  font-size: 28rpx;
  font-weight: 700;
}

.suite-card__icon--light {
  background: #ffffff;
  color: #46655a;
}

.suite-card__copy {
  min-width: 0;
}

.suite-card__title {
  display: block;
  color: #1c1c1c;
  font-size: 32rpx;
  font-weight: 700;
}

.suite-card__desc {
  display: block;
  margin-top: 8rpx;
  color: #6b6b6b;
  font-size: 24rpx;
  line-height: 1.45;
}

.suite-card--featured .suite-card__title,
.suite-card--featured .suite-card__desc {
  color: #012018;
}

.suite-card__arrow {
  color: #2f4d42;
  font-size: 48rpx;
  line-height: 1;
}

.notice-pulse {
  width: 16rpx;
  height: 16rpx;
  border-radius: 50%;
  background: #4a6e8f;
  box-shadow: 0 0 0 10rpx rgba(74, 110, 143, 0.08);
}

.bottom-actions {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 16rpx;
  padding: 0 48rpx 156rpx;
}

.support-link {
  padding: 18rpx 24rpx;
  color: #6b6b6b;
  font-size: 28rpx;
}

.logout-btn {
  height: 72rpx;
  padding: 0 34rpx;
  border: none;
  border-radius: 999rpx;
  background: transparent;
  color: #ba1a1a;
  font-size: 24rpx;
  font-weight: 700;
  letter-spacing: 3rpx;
}

.logout-btn::after {
  border: none;
}
</style>
