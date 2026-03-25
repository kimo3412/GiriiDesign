<template>
  <view class="order-detail-container">
    <!-- 订单状态 -->
    <view class="status-card">
      <text class="status-text">{{ getStatusText(order.status) }}</text>
      <text v-if="order.status === 1" class="status-desc">正在紧张制作中...</text>
      <text v-else-if="order.status === 2" class="status-desc">等待您确认收货</text>
    </view>

    <!-- 进度时间轴 -->
    <view class="progress-section">
      <text class="section-title">进度追踪</text>
      <timeline :list="progressList" />
    </view>

    <!-- 订单信息 -->
    <view class="info-section">
      <text class="section-title">订单信息</text>
      <view class="info-card">
        <view class="info-row">
          <text class="info-label">订单编号</text>
          <text class="info-value">{{ order.orderSn }}</text>
        </view>
        <view class="info-row">
          <text class="info-label">定制品类</text>
          <text class="info-value">{{ order.categoryName }}</text>
        </view>
        <view class="info-row">
          <text class="info-label">订单金额</text>
          <text class="info-value price">¥{{ order.totalAmount }}</text>
        </view>
        <view class="info-row">
          <text class="info-label">已付金额</text>
          <text class="info-value">¥{{ order.paidAmount }}</text>
        </view>
        <view v-if="order.expectedDate" class="info-row">
          <text class="info-label">预计完成</text>
          <text class="info-value">{{ order.expectedDate }}</text>
        </view>
        <view v-if="order.createTime" class="info-row">
          <text class="info-label">创建时间</text>
          <text class="info-value">{{ order.createTime }}</text>
        </view>
      </view>
    </view>

    <!-- 定制信息快照 -->
    <view v-if="customData" class="info-section">
      <text class="section-title">定制信息</text>
      <view class="info-card">
        <view v-for="(value, key) in customData" :key="key" class="info-row">
          <text class="info-label">{{ key }}</text>
          <text class="info-value">{{ value }}</text>
        </view>
      </view>
    </view>

    <!-- 底部操作 -->
    <view class="bottom-action">
      <button class="chat-btn" @click="goToChat">联系设计师</button>
      <button v-if="order.status === 2" class="confirm-btn" @click="handleConfirm">
        确认收货
      </button>
    </view>
  </view>
</template>

<script setup>
import { ref, computed } from 'vue'
import { onLoad } from '@dcloudio/uni-app'
import { getOrderDetail, getOrderProgress, confirmOrder } from '@/api/order'

const orderId = ref(0)
const order = ref({})
const progressList = ref([])

// 解析定制数据
const customData = computed(() => {
  if (!order.value.customDataSnapshot) return null
  try {
    return JSON.parse(order.value.customDataSnapshot)
  } catch {
    return null
  }
})

/**
 * 获取订单详情
 */
const fetchOrderDetail = async () => {
  try {
    const data = await getOrderDetail(orderId.value)
    order.value = data.order || {}
  } catch (err) {
    uni.showToast({ title: '获取订单失败', icon: 'none' })
  }
}

/**
 * 获取进度时间轴
 */
const fetchProgress = async () => {
  try {
    const data = await getOrderProgress(orderId.value)
    progressList.value = (data || []).map(item => ({
      stepName: item.description || '进度更新',
      description: item.description,
      imageUrl: item.imageUrls,
      imageUrls: item.imageUrls ? item.imageUrls.split(',') : [],
      createTime: item.createTime,
      isCompleted: true,
      isCurrent: false
    }))
  } catch (err) {
    console.error('获取进度失败', err)
  }
}

/**
 * 获取状态文本
 */
const getStatusText = (status) => {
  const map = {
    0: '待支付',
    1: '生产中',
    2: '待收货',
    3: '已完成',
    4: '已关闭'
  }
  return map[status] || '未知'
}

/**
 * 联系设计师（跳转聊天页）
 */
const goToChat = () => {
  uni.navigateTo({
    url: `/pages/chat/index?orderId=${orderId.value}`
  })
}

/**
 * 确认收货
 */
const handleConfirm = () => {
  uni.showModal({
    title: '确认收货',
    content: '确定已收到货物吗？',
    success: async (res) => {
      if (res.confirm) {
        try {
          await confirmOrder(orderId.value)
          uni.showToast({ title: '操作成功', icon: 'success' })
          fetchOrderDetail()
        } catch (err) {
          uni.showToast({ title: err.message || '操作失败', icon: 'none' })
        }
      }
    }
  })
}

onLoad((options) => {
  orderId.value = Number(options.id) || 0
  fetchOrderDetail()
  fetchProgress()
})
</script>

<style lang="scss" scoped>
.order-detail-container {
  min-height: 100vh;
  background: #f8f8f8;
  padding-bottom: 120rpx;
}

.status-card {
  background: #4A5D4E;
  padding: 60rpx 30rpx;
  text-align: center;

  .status-text {
    display: block;
    font-size: 36rpx;
    font-weight: bold;
    color: #fff;
    margin-bottom: 10rpx;
  }

  .status-desc {
    font-size: 26rpx;
    color: rgba(255, 255, 255, 0.8);
  }
}

.progress-section,
.info-section {
  background: #fff;
  margin-bottom: 20rpx;
  padding: 30rpx;
}

.section-title {
  display: block;
  font-size: 32rpx;
  font-weight: bold;
  color: #333;
  margin-bottom: 24rpx;
}

.info-card {
  background: #fafafa;
  border-radius: 12rpx;
  padding: 20rpx;
}

.info-row {
  display: flex;
  justify-content: space-between;
  padding: 16rpx 0;
  border-bottom: 1rpx solid #f0f0f0;

  &:last-child {
    border-bottom: none;
  }

  .info-label {
    font-size: 26rpx;
    color: #999;
  }

  .info-value {
    font-size: 26rpx;
    color: #333;

    &.price {
      color: #e74c3c;
      font-weight: bold;
    }
  }
}

.bottom-action {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  background: #fff;
  padding: 20rpx 30rpx;
  padding-bottom: calc(20rpx + env(safe-area-inset-bottom));
  box-shadow: 0 -2rpx 10rpx rgba(0, 0, 0, 0.05);
  display: flex;
  gap: 20rpx;
}

.chat-btn {
  flex: 1;
  height: 88rpx;
  background: transparent;
  color: #1a1a1a;
  font-size: 26rpx;
  letter-spacing: 2rpx;
  border-radius: 0;
  border: 1px solid #1a1a1a;

  &::after {
    border: none;
  }
}

.confirm-btn {
  flex: 1;
  height: 88rpx;
  background: #1a1a1a;
  color: #fff;
  font-size: 26rpx;
  letter-spacing: 2rpx;
  border-radius: 0;
  border: none;

  &::after {
    border: none;
  }
}
</style>
