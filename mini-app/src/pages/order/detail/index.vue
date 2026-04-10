<template>
  <view class="order-detail-container">
    <view class="status-card">
      <text class="status-text">{{ getStatusText(order.status) }}</text>
      <text class="status-desc">{{ currentStepText }}</text>
      <view v-if="order.isBlocked === 1 && order.blockReason" class="status-alert">
        <text class="status-alert__label">当前暂停</text>
        <text class="status-alert__text">{{ order.blockReason }}</text>
      </view>
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
                预计 {{ step.expectedDurationDays }} 天
              </text>
            </view>
            <text class="timeline-desc">{{ step.nodeDescription || '该节点暂无说明' }}</text>
            <text v-if="getProgressAtStep(step.stepId)" class="timeline-time">
              {{ getProgressAtStep(step.stepId).createTime }}
            </text>
            <text
              v-if="index === currentStepIndex && hasRollback"
              class="timeline-rework"
            >
              当前节点存在返工记录，请以最新进度为准
            </text>
          </view>
        </view>
      </view>
    </view>

    <view class="progress-section">
      <text class="section-title">进度动态</text>
      <view class="timeline-card">
        <view v-if="timelineEvents.length === 0" class="empty-progress">
          <text>当前订单暂无进度记录</text>
        </view>
        <view v-else>
          <view
            v-for="item in timelineEvents"
            :key="item.progressId"
            class="progress-item"
          >
            <view class="progress-header">
              <text class="progress-time">{{ item.createTime }}</text>
              <text class="progress-tag" :class="`tag-${item.eventType}`">
                {{ item.eventLabel }}
              </text>
            </view>
            <text class="progress-step">{{ item.stepName }}</text>
            <text class="progress-desc">{{ item.description }}</text>
            <view v-if="parseImageUrls(item.imageUrls).length" class="progress-images">
              <image
                v-for="image in parseImageUrls(item.imageUrls)"
                :key="image"
                class="progress-image"
                :src="toFileUrl(image)"
                mode="aspectFill"
              />
            </view>
          </view>
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
          <text class="info-value price">¥{{ order.totalAmount || 0 }}</text>
        </view>
        <view class="info-row">
          <text class="info-label">已付金额</text>
          <text class="info-value">¥{{ order.paidAmount || 0 }}</text>
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
      <button v-if="order.status === 0" class="pay-btn" @click="handlePay">
        支付定金 ¥{{ order.prepayAmount || 0 }}
      </button>
      <button v-if="order.status === 6" class="pay-btn" @click="handlePay">
        支付尾款 ¥{{ balanceAmount }}
      </button>
    </view>
  </view>
</template>

<script setup>
import { computed, ref } from 'vue'
import { onLoad } from '@dcloudio/uni-app'
import { getOrderTimeline, payOrder } from '@/api/order'

const fileBaseUrl = 'http://localhost:8081'

const orderId = ref(0)
const order = ref({})
const workflowSteps = ref([])
const progressList = ref([])
const timelineEvents = ref([])
const currentStepIndex = ref(-1)
const currentStepName = ref('')
const hasRollback = ref(0)

const currentStepText = computed(() => {
  if (order.value.isBlocked === 1) {
    return currentStepName.value
      ? `当前暂停在：${currentStepName.value}`
      : '当前订单已暂停'
  }
  if (currentStepName.value) {
    return `当前节点：${currentStepName.value}`
  }
  return '等待系统分配生产节点'
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
    timelineEvents.value = [...(data.timelineEvents || [])].reverse()
    currentStepIndex.value = data.currentStepIndex ?? -1
    currentStepName.value = data.currentStepName || ''
    hasRollback.value = data.hasRollback || 0
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
  const matched = progressList.value.filter((item) => item.stepId === stepId)
  return matched.length ? matched[matched.length - 1] : null
}

const parseImageUrls = (value) => {
  if (!value) return []
  try {
    const parsed = JSON.parse(value)
    if (Array.isArray(parsed)) return parsed.filter(Boolean)
    if (typeof parsed === 'string' && parsed) return [parsed]
  } catch (err) {
    return value ? [value] : []
  }
  return []
}

const toFileUrl = (url) => {
  if (!url) return ''
  if (/^https?:\/\//i.test(url)) {
    return url
  }
  return `${fileBaseUrl}${url}`
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
  background: linear-gradient(135deg, #455a48 0%, #6f594c 100%);
  padding: 56rpx 32rpx;
}

.status-text {
  display: block;
  font-size: 38rpx;
  color: #fff;
  font-weight: 600;
}

.status-desc {
  display: block;
  margin-top: 12rpx;
  color: rgba(255, 255, 255, 0.82);
  font-size: 24rpx;
}

.status-alert {
  margin-top: 24rpx;
  padding: 18rpx 20rpx;
  border-radius: 18rpx;
  background: rgba(255, 244, 235, 0.18);
}

.status-alert__label {
  display: block;
  color: #ffd7be;
  font-size: 22rpx;
}

.status-alert__text {
  display: block;
  margin-top: 8rpx;
  color: #fff;
  font-size: 24rpx;
  line-height: 1.5;
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
}

.timeline-dot.done {
  background: #4a5d4e;
}

.timeline-dot.current {
  background: #c4785b;
  box-shadow: 0 0 0 8rpx rgba(196, 120, 91, 0.18);
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

.timeline-top,
.progress-header {
  display: flex;
  justify-content: space-between;
  gap: 16rpx;
}

.timeline-name,
.progress-step {
  font-size: 28rpx;
  color: #1f1f1f;
  font-weight: 600;
}

.timeline-days,
.timeline-time,
.progress-time {
  font-size: 22rpx;
  color: #999;
}

.timeline-desc,
.progress-desc {
  display: block;
  margin-top: 10rpx;
  color: #666;
  font-size: 24rpx;
  line-height: 1.6;
}

.timeline-rework {
  display: inline-block;
  margin-top: 12rpx;
  padding: 8rpx 16rpx;
  border-radius: 999rpx;
  background: #fff3ef;
  color: #c65a3b;
  font-size: 22rpx;
}

.empty-progress {
  padding: 36rpx 0;
  text-align: center;
  color: #999;
  font-size: 24rpx;
}

.progress-item {
  padding: 18rpx 0;
  border-bottom: 1rpx solid #f1f1f1;
}

.progress-item:last-child {
  border-bottom: none;
}

.progress-tag {
  padding: 6rpx 14rpx;
  border-radius: 999rpx;
  font-size: 20rpx;
}

.tag-progress {
  background: #eef3ff;
  color: #3f63b8;
}

.tag-rollback {
  background: #fff1eb;
  color: #c65a3b;
}

.tag-block {
  background: #fff0f1;
  color: #c93f55;
}

.tag-unblock {
  background: #eef9f1;
  color: #2d8a57;
}

.progress-images {
  display: flex;
  flex-wrap: wrap;
  gap: 14rpx;
  margin-top: 16rpx;
}

.progress-image {
  width: 160rpx;
  height: 160rpx;
  border-radius: 16rpx;
  background: #f1f1f1;
}

.info-row {
  display: flex;
  justify-content: space-between;
  padding: 18rpx 0;
  border-bottom: 1rpx solid #f1f1f1;
}

.info-row:last-child {
  border-bottom: none;
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
}

.chat-btn::after,
.pay-btn::after {
  border: none;
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
