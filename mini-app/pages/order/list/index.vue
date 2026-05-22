<template>
  <view class="orders-page">
    <view class="top-bar">
      <view class="top-icon" @click="goToStudio">
        <text class="top-icon__text">☰</text>
      </view>
      <text class="brand-word">ATELIER</text>
      <view class="top-icon" @click="goToNotifications">
        <text class="top-icon__text">◔</text>
      </view>
    </view>

    <view class="page-head">
      <text class="page-title">我的订单</text>
      <text class="page-desc">查看专属定制的当前状态、付款节点和交付进度。</text>
    </view>

    <view class="tabs-wrap">
      <scroll-view scroll-x class="tabs-scroll" show-scrollbar="false">
        <view class="tabs">
          <view
            v-for="tab in tabs"
            :key="tab.value"
            class="tab-item"
            :class="{ active: currentTab === tab.value }"
            @click="switchTab(tab.value)"
          >
            {{ tab.label }}
          </view>
        </view>
      </scroll-view>
    </view>

    <scroll-view scroll-y class="order-scroll" @scrolltolower="loadMore">
      <view v-if="orders.length" class="order-stack">
        <view
          v-for="order in orders"
          :key="order.orderId"
          class="order-card"
          @click="goToDetail(order.orderId)"
        >
          <view class="order-head">
            <view class="order-title-group">
              <text class="order-sn">#{{ order.orderSn || order.orderId }}</text>
              <text class="order-title">{{ order.categoryName || '专属定制订单' }}</text>
            </view>
            <view class="status-chip" :class="'status-' + order.status">
              {{ getStatusText(order.status) }}
            </view>
          </view>

          <view class="progress-panel">
            <view class="progress-line"></view>
            <view class="progress-line progress-line--active" :style="{ width: getProgressWidth(order.status) }"></view>
            <view
              v-for="(step, index) in progressSteps"
              :key="step"
              class="progress-step"
              :class="getStepClass(order.status, index)"
            >
              <view class="step-dot"></view>
              <text class="step-label">{{ step }}</text>
            </view>
          </view>

          <view class="order-bottom">
            <view class="order-meta">
              <text class="meta-label">{{ getMetaLabel(order.status) }}</text>
              <text class="meta-value">{{ getMetaValue(order) }}</text>
            </view>

            <button
              v-if="order.status === 0"
              class="card-action card-action--primary"
              @click.stop="handlePay(order, 0)"
            >
              支付定金
            </button>
            <button
              v-else-if="order.status === 6"
              class="card-action card-action--primary"
              @click.stop="handlePay(order, 6)"
            >
              支付尾款
            </button>
            <button
              v-else-if="order.status === 3"
              class="card-action card-action--primary"
              @click.stop="confirmReceive(order.orderId)"
            >
              确认收货
            </button>
            <button v-else class="card-action" @click.stop="goToDetail(order.orderId)">
              查看详情
            </button>
          </view>
        </view>
      </view>

      <view v-else class="empty-state">
        <text class="empty-state__title">暂无相关订单</text>
        <text class="empty-state__desc">提交定制需求后，订单会在这里持续更新。</text>
        <view class="empty-state__button" @click="goToCustom">开始定制</view>
      </view>

      <view v-if="loading" class="loading-state">加载中...</view>
      <view v-else-if="!hasMore && orders.length" class="loading-state">已显示全部订单</view>
    </scroll-view>
  </view>
</template>

<script setup>
import { ref } from 'vue'
import { onShow } from '@dcloudio/uni-app'
import { confirmOrder, getOrderList, payOrder } from '@/api/order'

const tabs = [
  { label: '进行中', value: 'active', statuses: [0, 1, 2, 6] },
  { label: '待收货', value: 'receive', statuses: [3] },
  { label: '已完成', value: 'done', statuses: [4] },
  { label: '全部', value: '', statuses: [] }
]

const progressSteps = ['沟通确认', '生产制作', '试穿验收', '交付完成']

const currentTab = ref('active')
const orders = ref([])
const loading = ref(false)
const hasMore = ref(false)

const switchTab = (value) => {
  currentTab.value = value
  fetchOrders(true)
}

const fetchOrders = async (refresh = false) => {
  if (loading.value || (!hasMore.value && !refresh)) return
  loading.value = true

  try {
    const data = await getOrderList({
      statuses: getCurrentStatuses().join(',')
    })
    const list = Array.isArray(data) ? data : (data.records || data.list || [])
    orders.value = list
    // 后端当前返回完整订单列表，不做分页；避免滚动到底部时重复追加同一批数据。
    hasMore.value = false
  } catch (err) {
    uni.showToast({ title: '获取订单失败', icon: 'none' })
  } finally {
    loading.value = false
  }
}

const loadMore = () => {
  // 预留分页入口；等后端支持 page/size 后再启用追加加载。
}

const getCurrentStatuses = () => {
  const tab = tabs.find((item) => item.value === currentTab.value)
  return tab?.statuses || []
}

const goToStudio = () => {
  uni.switchTab({ url: '/pages/index/index' })
}

const goToNotifications = () => {
  uni.navigateTo({ url: '/pages/user/notification/index' })
}

const goToCustom = () => {
  uni.navigateTo({ url: '/pages/custom/category/index' })
}

const goToDetail = (id) => {
  uni.navigateTo({ url: `/pages/order/detail/index?id=${id}` })
}

const confirmReceive = async (id) => {
  uni.showModal({
    title: '确认收货',
    content: '确定已收到货物吗？',
    success: async (res) => {
      if (!res.confirm) return
      try {
        await confirmOrder(id)
        uni.showToast({ title: '操作成功', icon: 'success' })
        fetchOrders(true)
      } catch (err) {
        uni.showToast({ title: err.message || '操作失败', icon: 'none' })
      }
    }
  })
}

const handlePay = (order, type) => {
  const typeName = type === 0 ? '定金' : '尾款'
  const amount = type === 0
    ? Number(order.prepayAmount || 0)
    : Number(order.totalAmount || 0) - Number(order.prepayAmount || 0)

  uni.showModal({
    title: `支付${typeName}`,
    content: `将模拟支付 ¥${formatAmount(amount)}，确定要付款吗？`,
    success: async (res) => {
      if (!res.confirm) return
      uni.showLoading({ title: '支付中...' })
      try {
        await payOrder(order.orderId)
        uni.hideLoading()
        uni.showToast({ title: '支付成功', icon: 'success' })
        fetchOrders(true)
      } catch (err) {
        uni.hideLoading()
        uni.showToast({ title: err.message || '支付失败', icon: 'none' })
      }
    }
  })
}

const getStatusText = (status) => {
  const map = {
    0: '待付定金',
    1: '生产中',
    2: '待发货',
    3: '待收货',
    4: '已完成',
    5: '已取消',
    6: '待付尾款'
  }
  return map[status] || '未知状态'
}

const getProgressIndex = (status) => {
  if (status === 4) return 3
  if (status === 3) return 2
  if (status === 1 || status === 2 || status === 6) return 1
  return 0
}

const getProgressWidth = (status) => {
  const index = getProgressIndex(status)
  return `${Math.max(0, Math.min(100, (index / (progressSteps.length - 1)) * 100))}%`
}

const getStepClass = (status, index) => {
  const current = getProgressIndex(status)
  return {
    'is-complete': index < current,
    'is-current': index === current,
    'is-pending': index > current
  }
}

const getMetaLabel = (status) => {
  if (status === 0 || status === 6) return '待支付金额'
  if (status === 1 || status === 2) return '预计完成'
  if (status === 3) return '收货确认'
  if (status === 4) return '订单金额'
  return '订单金额'
}

const getMetaValue = (order) => {
  if (order.status === 0) return `¥${formatAmount(order.prepayAmount)}`
  if (order.status === 6) {
    return `¥${formatAmount(Number(order.totalAmount || 0) - Number(order.prepayAmount || 0))}`
  }
  if (order.status === 1 || order.status === 2) return order.expectedDate || '待设计师确认'
  if (order.status === 3) return '等待确认收货'
  return `¥${formatAmount(order.totalAmount)}`
}

const formatAmount = (value) => Number(value || 0).toFixed(2)

onShow(() => {
  fetchOrders(true)
})
</script>

<style lang="scss" scoped>
.orders-page {
  height: 100vh;
  display: flex;
  flex-direction: column;
  background: #fbf9fa;
  color: #1c1c1c;
}

.top-bar {
  height: 116rpx;
  padding: 34rpx 36rpx 20rpx;
  display: flex;
  align-items: center;
  justify-content: space-between;
  background: #f9f8f6;
  border-bottom: 1rpx solid rgba(229, 226, 218, 0.72);
  flex-shrink: 0;
}

.brand-word {
  font-family: 'Times New Roman', serif;
  font-size: 34rpx;
  color: #1a2b3c;
  letter-spacing: 12rpx;
  font-weight: 600;
}

.top-icon {
  width: 56rpx;
  height: 56rpx;
  display: flex;
  align-items: center;
  justify-content: center;
}

.top-icon__text {
  font-size: 34rpx;
  color: #74777d;
}

.page-head {
  padding: 42rpx 48rpx 28rpx;
}

.page-title {
  display: block;
  font-family: 'Times New Roman', serif;
  font-size: 58rpx;
  line-height: 1.2;
  color: #1a2b3c;
  font-weight: 600;
}

.page-desc {
  display: block;
  margin-top: 12rpx;
  font-size: 26rpx;
  line-height: 1.58;
  color: #6b6b6b;
}

.tabs-wrap {
  padding: 0 48rpx 44rpx;
}

.tabs-scroll {
  white-space: nowrap;
}

.tabs {
  display: flex;
  gap: 52rpx;
  border-bottom: 1rpx solid #e5e2da;
}

.tab-item {
  position: relative;
  padding: 0 0 18rpx;
  color: #6b6b6b;
  font-size: 28rpx;
  white-space: nowrap;
}

.tab-item.active {
  color: #1a2b3c;
  font-weight: 700;
}

.tab-item.active::after {
  content: '';
  position: absolute;
  left: 0;
  right: 0;
  bottom: -1rpx;
  height: 4rpx;
  background: #1a2b3c;
}

.order-scroll {
  flex: 1;
}

.order-stack {
  padding: 0 48rpx 140rpx;
  display: flex;
  flex-direction: column;
  gap: 24rpx;
}

.order-card {
  padding: 34rpx 32rpx;
  border-radius: 8rpx;
  background: #ffffff;
  border: 1rpx solid #e5e2da;
  box-shadow: 0 6rpx 24rpx rgba(26, 43, 60, 0.03);
}

.order-head {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 24rpx;
  margin-bottom: 42rpx;
}

.order-title-group {
  flex: 1;
  min-width: 0;
}

.order-sn {
  display: block;
  margin-bottom: 8rpx;
  color: #6b6b6b;
  font-size: 20rpx;
  font-weight: 700;
  letter-spacing: 2rpx;
}

.order-title {
  display: block;
  font-family: 'Times New Roman', serif;
  font-size: 38rpx;
  line-height: 1.3;
  color: #1a2b3c;
  font-weight: 600;
}

.status-chip {
  flex-shrink: 0;
  padding: 10rpx 18rpx;
  border-radius: 999rpx;
  background: #e4e2e3;
  color: #1c1c1c;
  font-size: 20rpx;
  font-weight: 700;
}

.status-1,
.status-2 {
  background: #c8eadc;
  color: #2f4d42;
}

.status-3,
.status-6,
.status-0 {
  background: #feddb5;
  color: #584326;
}

.status-4 {
  background: rgba(45, 75, 65, 0.12);
  color: #2d4b41;
}

.status-5 {
  background: #e4e2e3;
  color: #74777d;
}

.progress-panel {
  position: relative;
  display: flex;
  justify-content: space-between;
  margin: 0 0 48rpx;
  padding: 0 4rpx;
}

.progress-line,
.progress-line--active {
  position: absolute;
  left: 18rpx;
  right: 18rpx;
  top: 11rpx;
  height: 1rpx;
  background: #e5e2da;
  z-index: 0;
}

.progress-line--active {
  right: auto;
  background: #1a2b3c;
}

.progress-step {
  position: relative;
  z-index: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 14rpx;
  width: 25%;
  background: #ffffff;
}

.step-dot {
  width: 16rpx;
  height: 16rpx;
  border-radius: 50%;
  background: #c4c6cd;
}

.is-complete .step-dot {
  background: #1a2b3c;
}

.is-current .step-dot {
  width: 24rpx;
  height: 24rpx;
  margin-top: -4rpx;
  border: 4rpx solid #1a2b3c;
  background: #ffffff;
}

.step-label {
  max-width: 112rpx;
  text-align: center;
  color: #6b6b6b;
  font-size: 18rpx;
  line-height: 1.2;
}

.is-complete .step-label,
.is-current .step-label {
  color: #1a2b3c;
  font-weight: 700;
}

.order-bottom {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 24rpx;
  padding-top: 28rpx;
  border-top: 1rpx solid #e5e2da;
}

.order-meta {
  display: flex;
  flex-direction: column;
  gap: 8rpx;
  min-width: 0;
}

.meta-label {
  color: #6b6b6b;
  font-size: 20rpx;
  font-weight: 700;
  letter-spacing: 2rpx;
}

.meta-value {
  color: #1a2b3c;
  font-size: 30rpx;
  line-height: 1.3;
  font-weight: 700;
}

.card-action {
  flex-shrink: 0;
  margin: 0;
  min-width: 190rpx;
  height: 76rpx;
  line-height: 76rpx;
  padding: 0 28rpx;
  border-radius: 8rpx;
  border: 1rpx solid #e5e2da;
  background: #ffffff;
  color: #1a2b3c;
  font-size: 20rpx;
  font-weight: 700;
  letter-spacing: 2rpx;
}

.card-action::after {
  border: none;
}

.card-action--primary {
  background: #1a2b3c;
  color: #ffffff;
  border-color: #1a2b3c;
}

.empty-state {
  margin: 0 48rpx 140rpx;
  padding: 96rpx 40rpx;
  border: 1rpx solid #e5e2da;
  border-radius: 8rpx;
  background: #ffffff;
  text-align: center;
}

.empty-state__title {
  display: block;
  color: #1a2b3c;
  font-size: 34rpx;
  font-weight: 700;
}

.empty-state__desc {
  display: block;
  margin-top: 16rpx;
  color: #6b6b6b;
  font-size: 24rpx;
  line-height: 1.6;
}

.empty-state__button {
  display: inline-flex;
  margin-top: 34rpx;
  padding: 18rpx 34rpx;
  border-radius: 8rpx;
  background: #1a2b3c;
  color: #ffffff;
  font-size: 22rpx;
  font-weight: 700;
  letter-spacing: 2rpx;
}

.loading-state {
  padding: 24rpx 0 140rpx;
  color: #74777d;
  font-size: 22rpx;
  text-align: center;
}
</style>
