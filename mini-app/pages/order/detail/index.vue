<template>
  <view class="order-detail-container">
    <view class="status-card">
      <text class="status-text">{{ getStatusText(order.status) }}</text>
      <text class="status-desc">{{ currentStepText }}</text>
    </view>

    <view class="timeline-section">
      <text class="section-title">流程进度</text>
      <view class="timeline-card">
        <view
          v-for="(step, index) in workflowSteps"
          :key="step.stepId || index"
          class="timeline-item"
        >
          <view class="timeline-left">
            <view
              class="timeline-dot"
              :class="{
                done: index < currentStepIndex,
                current: index === currentStepIndex,
                pending: index > currentStepIndex
              }"
            ></view>
            <view v-if="index < workflowSteps.length - 1" class="timeline-line"></view>
          </view>
          <view class="timeline-body">
            <view class="timeline-top">
              <text class="timeline-name">{{ step.stepName }}</text>
              <text v-if="step.expectedDurationDays != null" class="timeline-days">
                {{ step.expectedDurationDays }}天
              </text>
            </view>
            <text class="timeline-desc">{{ step.nodeDescription || '暂无节点说明' }}</text>
            <text v-if="getProgressAtStep(step.stepId)" class="timeline-time">
              {{ getProgressAtStep(step.stepId).createTime }}
            </text>
          </view>
        </view>
      </view>
    </view>

    <view class="progress-section">
      <text class="section-title">最新进度</text>
      <view class="timeline-card">
        <view v-for="item in progressList" :key="item.progressId" class="progress-item">
          <text class="progress-time">{{ item.createTime }}</text>
          <text class="progress-desc">{{ item.description }}</text>
        </view>
      </view>
    </view>

    <view class="info-section">
      <text class="section-title">订单信息</text>
      <view class="info-card">
        <view class="info-row">
          <text class="info-label">订单编号</text>
          <text class="info-value">{{ order.orderSn }}</text>
        </view>
        <view class="info-row">
          <text class="info-label">订单金额</text>
          <text class="info-value price">￥{{ order.totalAmount }}</text>
        </view>
        <view class="info-row">
          <text class="info-label">已付金额</text>
          <text class="info-value">￥{{ order.paidAmount }}</text>
        </view>
        <view v-if="order.expectedDate" class="info-row">
          <text class="info-label">预计完成</text>
          <text class="info-value">{{ order.expectedDate }}</text>
        </view>
        <view v-if="order.remark" class="info-row">
          <text class="info-label">备注</text>
          <text class="info-value">{{ order.remark }}</text>
        </view>
      </view>
    </view>

    <view class="bottom-action">
      <button class="chat-btn" @click="goToChat">联系设计师</button>
      <button v-if="order.status === 0" class="pay-btn" @click="handlePay(0)">
        支付定金 ￥{{ order.prepayAmount }}
      </button>
      <button v-if="order.status === 6" class="pay-btn" @click="handlePay(6)">
        支付尾款 ￥{{ balanceAmount }}
      </button>
    </view>
  </view>
</template>

<script setup>
import { computed, ref } from 'vue'
import { onLoad } from '@dcloudio/uni-app'
import { getOrderTimeline, payOrder } from '@/api/order'

const orderId = ref(0)
const order = ref({})
const workflowSteps = ref([])
const progressList = ref([])
const currentStepIndex = ref(-1)

const currentStepText = computed(() => {
  if (currentStepIndex.value < 0 || !workflowSteps.value[currentStepIndex.value]) {
    return '等待系统分配生产节点'
  }
  return `当前节点：${workflowSteps.value[currentStepIndex.value].stepName}`
})

const balanceAmount = computed(() => {
  const total = Number(order.value.totalAmount || 0)
  const prepay = Number(order.value.prepayAmount || 0)
  return (total - prepay).toFixed(2)
})

const fetchTimeline = async () => {
  try {
    const data = await getOrderTimeline(orderId.value)
    order.value = data.order || {}
    workflowSteps.value = data.workflowSteps || []
    progressList.value = data.progressList || []
    currentStepIndex.value = data.currentStepIndex ?? -1
  } catch (err) {
    uni.showToast({ title: '获取订单失败', icon: 'none' })
  }
}

const getStatusText = (status) => {
  const map = {
    0: '待支付',
    1: '生产中',
    2: '待发货',
    3: '待收货',
    4: '已完成',
    5: '已取消',
    6: '待付尾款'
  }
  return map[status] || '未知状态'
}

const getProgressAtStep = (stepId) => {
  return progressList.value.find((item) => item.stepId === stepId)
}

const goToChat = () => {
  uni.navigateTo({ url: '/pages/chat/index' })
}

const handlePay = () => {
  uni.showLoading({ title: '支付中...' })
  payOrder(orderId.value)
    .then(() => {
      uni.hideLoading()
      uni.showToast({ title: '支付成功', icon: 'success' })
      fetchTimeline()
    })
    .catch((err) => {
      uni.hideLoading()
      uni.showToast({ title: err.message || '支付失败', icon: 'none' })
    })
}

onLoad((options) => {
  orderId.value = Number(options.id) || 0
  fetchTimeline()
})
</script>

<style lang="scss" scoped>
.order-detail-container {
  min-height: 100vh;
  background: #f5f2ee;
  padding-bottom: 120rpx;
}

.status-card {
  background: #4a5d4e;
  padding: 56rpx 32rpx;

  .status-text {
    display: block;
    font-size: 38rpx;
    color: #fff;
    font-weight: 600;
  }

  .status-desc {
    display: block;
    margin-top: 12rpx;
    color: rgba(255, 255, 255, 0.8);
    font-size: 24rpx;
  }
}

.timeline-section,
.progress-section,
.info-section {
  margin-top: 20rpx;
  padding: 0 24rpx;
}

.section-title {
  display: block;
  margin-bottom: 18rpx;
  font-size: 30rpx;
  color: #2c2c2c;
  font-weight: 600;
}

.timeline-card,
.info-card {
  background: #fff;
  border-radius: 18rpx;
  padding: 24rpx;
}

.timeline-item {
  display: flex;
  gap: 20rpx;
}

.timeline-left {
  display: flex;
  flex-direction: column;
  align-items: center;
}

.timeline-dot {
  width: 22rpx;
  height: 22rpx;
  border-radius: 50%;
  background: #d9d9d9;

  &.done {
    background: #4a5d4e;
  }

  &.current {
    background: #c4785b;
    box-shadow: 0 0 0 8rpx rgba(196, 120, 91, 0.18);
  }
}

.timeline-line {
  width: 2rpx;
  flex: 1;
  background: #e8e4e0;
  min-height: 60rpx;
}

.timeline-body {
  flex: 1;
  padding-bottom: 28rpx;
}

.timeline-top {
  display: flex;
  justify-content: space-between;
  gap: 16rpx;
}

.timeline-name {
  font-size: 28rpx;
  color: #1f1f1f;
  font-weight: 600;
}

.timeline-days,
.timeline-time {
  font-size: 22rpx;
  color: #999;
}

.timeline-desc {
  display: block;
  margin-top: 10rpx;
  color: #666;
  font-size: 24rpx;
  line-height: 1.6;
}

.progress-item {
  padding: 18rpx 0;
  border-bottom: 1rpx solid #f1f1f1;

  &:last-child {
    border-bottom: none;
  }
}

.progress-time {
  display: block;
  color: #999;
  font-size: 22rpx;
}

.progress-desc {
  display: block;
  margin-top: 8rpx;
  color: #333;
  font-size: 26rpx;
  line-height: 1.6;
}

.info-row {
  display: flex;
  justify-content: space-between;
  padding: 18rpx 0;
  border-bottom: 1rpx solid #f1f1f1;

  &:last-child {
    border-bottom: none;
  }
}

.info-label {
  color: #999;
  font-size: 24rpx;
}

.info-value {
  max-width: 60%;
  text-align: right;
  color: #333;
  font-size: 24rpx;
}

.price {
  color: #d35d6e;
  font-weight: 600;
}

.bottom-action {
  position: fixed;
  left: 0;
  right: 0;
  bottom: 0;
  display: flex;
  gap: 20rpx;
  padding: 20rpx 24rpx;
  padding-bottom: calc(20rpx + env(safe-area-inset-bottom));
  background: rgba(255, 255, 255, 0.95);
}

.chat-btn,
.pay-btn {
  flex: 1;
  height: 88rpx;
  line-height: 88rpx;
  border-radius: 44rpx;
  font-size: 26rpx;
  border: none;

  &::after {
    border: none;
  }
}

.chat-btn {
  background: #fff;
  color: #2c2c2c;
  border: 1rpx solid #2c2c2c;
}

.pay-btn {
  background: #2c2c2c;
  color: #fff;
}
</style>
