<template>
  <view class="noti-container">
    <view class="noti-header">
      <text class="noti-title">通知中心</text>
      <text v-if="list.length > 0" class="read-all-btn" @click="handleMarkAllRead">全部已读</text>
    </view>

    <scroll-view
      class="noti-scroll"
      scroll-y
      @scrolltolower="loadMore"
      refresher-enabled
      :refresher-triggered="refreshing"
      @refresherrefresh="onRefresh"
    >
      <view v-if="list.length === 0 && !loading" class="noti-empty">
        <text class="empty-text">暂无通知</text>
      </view>

      <view v-for="item in list" :key="item.id" class="noti-item" :class="{ unread: item.isRead === 0 }" @click="handleRead(item)">
        <view class="noti-dot" v-if="item.isRead === 0"></view>
        <view class="noti-body">
          <view class="noti-row">
            <text class="noti-item-title">{{ item.title }}</text>
            <text class="noti-time">{{ formatTime(item.createTime) }}</text>
          </view>
          <text class="noti-content">{{ item.content }}</text>
          <view v-if="item.type === 'order_status' || item.type === 'payment' || item.type === 'workbench'" class="noti-link" @click.stop="goToOrder(item)">
            <text class="noti-link-text">查看订单 →</text>
          </view>
        </view>
      </view>

      <view v-if="noMore" class="noti-no-more">
        <text>已显示全部通知</text>
      </view>
    </scroll-view>
  </view>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { getNotifications, markAsRead, markAllAsRead } from '@/api/notification'

const list = ref([])
const loading = ref(false)
const refreshing = ref(false)
const noMore = ref(false)
const pageNum = ref(1)
const pageSize = 20

const fetchNotifications = async (reset = false) => {
  if (loading.value) return
  if (noMore.value && !reset) return
  loading.value = true
  try {
    if (reset) {
      pageNum.value = 1
      noMore.value = false
    }
    const res = await getNotifications(pageNum.value, pageSize)
    const data = res || {}
    const records = data.records || []
    if (reset) {
      list.value = records
    } else {
      list.value = [...list.value, ...records]
    }
    if (records.length < pageSize || list.value.length >= data.total) {
      noMore.value = true
    }
    pageNum.value++
  } catch (e) {
    uni.showToast({ title: '加载失败', icon: 'none' })
  } finally {
    loading.value = false
    refreshing.value = false
  }
}

const loadMore = () => {
  if (!noMore.value) fetchNotifications()
}

const onRefresh = () => {
  refreshing.value = true
  fetchNotifications(true)
}

const handleRead = async (item) => {
  if (item.isRead === 0) {
    item.isRead = 1
    await markAsRead(item.id)
  }
}

const handleMarkAllRead = async () => {
  await markAllAsRead()
  list.value.forEach(item => { item.isRead = 1 })
  uni.showToast({ title: '已全部标为已读', icon: 'success' })
}

const goToOrder = (item) => {
  if (item.relatedId && item.relatedType === 'order') {
    uni.navigateTo({ url: `/pages/order/detail/index?id=${item.relatedId}` })
  }
}

const formatTime = (timeStr) => {
  if (!timeStr) return ''
  const date = new Date(timeStr)
  const now = new Date()
  const diff = now - date
  if (diff < 60000) return '刚刚'
  if (diff < 3600000) return Math.floor(diff / 60000) + '分钟前'
  if (diff < 86400000) return Math.floor(diff / 3600000) + '小时前'
  if (diff < 2592000000) return Math.floor(diff / 86400000) + '天前'
  return `${date.getMonth() + 1}月${date.getDate()}日`
}

onMounted(() => {
  fetchNotifications(true)
})
</script>

<style lang="scss" scoped>
.noti-container {
  min-height: 100vh;
  background: #F5F2EE;
  display: flex;
  flex-direction: column;
}

.noti-header {
  background: #fff;
  padding: 100rpx 48rpx 40rpx;
  display: flex;
  justify-content: space-between;
  align-items: flex-end;
  box-shadow: 0 2rpx 16rpx rgba(74, 93, 78, 0.06);
}

.noti-title {
  font-size: 36rpx;
  color: #2c2c2c;
  letter-spacing: 4rpx;
  font-weight: 400;
}

.read-all-btn {
  font-size: 22rpx;
  color: #4A5D4E;
  letter-spacing: 1rpx;
  padding: 8rpx 16rpx;
  &:active { opacity: 0.6; }
}

.noti-scroll {
  flex: 1;
  padding: 24rpx 0;
}

.noti-empty {
  padding: 120rpx 0;
  text-align: center;

  .empty-text {
    font-size: 26rpx;
    color: #bbb;
    letter-spacing: 2rpx;
  }
}

.noti-item {
  background: #fff;
  margin: 0 24rpx 16rpx;
  border-radius: 8rpx;
  padding: 32rpx 32rpx 32rpx 48rpx;
  position: relative;
  display: flex;
  align-items: flex-start;
  gap: 16rpx;

  &.unread {
    border-left: 3rpx solid #4A5D4E;
  }

  &:active { opacity: 0.85; }
}

.noti-dot {
  width: 14rpx;
  height: 14rpx;
  border-radius: 50%;
  background: #4A5D4E;
  flex-shrink: 0;
  margin-top: 10rpx;
}

.noti-body {
  flex: 1;
}

.noti-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 10rpx;
}

.noti-item-title {
  font-size: 26rpx;
  color: #2c2c2c;
  letter-spacing: 1rpx;
  font-weight: 500;
}

.noti-time {
  font-size: 20rpx;
  color: #bbb;
}

.noti-content {
  font-size: 24rpx;
  color: #666;
  line-height: 1.6;
}

.noti-link {
  margin-top: 16rpx;
  &:active { opacity: 0.6; }

  .noti-link-text {
    font-size: 22rpx;
    color: #4A5D4E;
    letter-spacing: 1rpx;
  }
}

.noti-no-more {
  text-align: center;
  padding: 40rpx 0;
  font-size: 22rpx;
  color: #bbb;
}
</style>
