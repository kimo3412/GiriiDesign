<template>
  <view class="order-list-container">
    <!-- Tab 切换 -->
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

    <!-- 订单列表 -->
    <scroll-view scroll-y class="order-scroll" @scrolltolower="loadMore">
      <view v-if="orders.length > 0" class="order-list">
        <view
          v-for="order in orders"
          :key="order.orderId"
          class="order-card"
          :class="{ 'order-card--active': order.status === 1 }"
          @click="goToDetail(order.orderId)"
        >
          <!-- 卡片顶部：订单号 + 状态标签 -->
          <view class="order-card__top">
            <text class="order-no">#{{ order.orderSn }}</text>
            <view
              class="status-tag"
              :style="{
                background: getStatusBg(order.status),
                color: getStatusColor(order.status)
              }"
            >
              <text class="status-tag__dot" :style="{ background: getStatusColor(order.status) }"></text>
              {{ getStatusText(order.status) }}
            </view>
          </view>

          <!-- 卡片中部：品类 + 金额 -->
          <view class="order-card__body">
            <view class="order-info">
              <text class="order-category">{{ order.categoryName || '轻奢定制' }}</text>
              <text class="order-time">{{ order.createTime }}</text>
            </view>
            <view class="order-price">
              <text class="price-symbol">¥</text>
              <text class="price-value">{{ order.totalAmount }}</text>
            </view>
          </view>

          <!-- 卡片底部：操作按钮 -->
          <view v-if="order.status === 0 || order.status === 3 || order.status === 6" class="order-card__footer">
            <view class="order-actions">
              <button
                v-if="order.status === 0"
                class="action-btn action-btn--primary"
                @click.stop="handlePay(order, 0)"
              >
                支付定金 ¥{{ order.prepayAmount }}
              </button>
              <button
                v-if="order.status === 6"
                class="action-btn action-btn--primary"
                @click.stop="handlePay(order, 6)"
              >
                支付尾款 ¥{{ (order.totalAmount - order.prepayAmount).toFixed(2) }}
              </button>
              <button
                v-if="order.status === 3"
                class="action-btn"
                @click.stop="confirmReceive(order.orderId)"
              >
                确认收货
              </button>
            </view>
          </view>
        </view>
      </view>

      <!-- 空状态 -->
      <view v-else class="empty">
        <view class="empty-icon">📋</view>
        <text class="empty-text">暂无相关订单</text>
      </view>

      <!-- 加载更多 -->
      <view v-if="loading" class="loading">
        <text>加载中...</text>
      </view>
    </scroll-view>
  </view>
</template>

<script setup>
import { ref } from 'vue'
import { getOrderList, confirmOrder, payOrder } from '@/api/order'

const tabs = [
  { label: '全部', value: '' },
  { label: '进行中', value: '1' },
  { label: '待收货', value: '3' },
  { label: '已完成', value: '4' }
]

const currentTab = ref('')
const orders = ref([])
const page = ref(1)
const loading = ref(false)
const hasMore = ref(true)

/**
 * 切换 Tab
 */
const switchTab = (value) => {
  currentTab.value = value
  page.value = 1
  hasMore.value = true
  fetchOrders(true)
}

/**
 * 获取订单列表
 */
const fetchOrders = async (refresh = false) => {
  if (loading.value || (!hasMore.value && !refresh)) return

  loading.value = true

  try {
    const params = {
      page: page.value,
      size: 10,
      status: currentTab.value
    }

    const data = await getOrderList(params)

    const list = Array.isArray(data) ? data : (data.list || [])

    if (refresh) {
      orders.value = list
    } else {
      orders.value = [...orders.value, ...list]
    }

    hasMore.value = list.length >= 10
  } catch (err) {
    uni.showToast({ title: '获取订单失败', icon: 'none' })
  }

  loading.value = false
}

/**
 * 加载更多
 */
const loadMore = () => {
  if (!hasMore.value) return
  page.value++
  fetchOrders()
}

/**
 * 跳转详情
 */
const goToDetail = (id) => {
  uni.navigateTo({ url: `/pages/order/detail/index?id=${id}` })
}

/**
 * 确认收货
 */
const confirmReceive = async (id) => {
  uni.showModal({
    title: '确认收货',
    content: '确定已收到货物吗？',
    success: async (res) => {
      if (res.confirm) {
        try {
          await confirmOrder(id)
          uni.showToast({ title: '操作成功', icon: 'success' })
          fetchOrders(true)
        } catch (err) {
          uni.showToast({ title: err.message || '操作失败', icon: 'none' })
        }
      }
    }
  })
}

/**
 * 模拟支付
 */
const handlePay = (order, type) => {
  const typeName = type === 0 ? '定金' : '尾款'
  const amount = type === 0 ? order.prepayAmount : (order.totalAmount - order.prepayAmount).toFixed(2)

  uni.showModal({
    title: `支付${typeName}`,
    content: `将模拟支付 ¥${amount}，确定要付款吗？`,
    success: async (res) => {
      if (res.confirm) {
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
    }
  })
}

/**
 * 获取状态文本
 */
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
  return map[status] || '未知'
}

/**
 * 订单状态颜色
 */
const statusColorMap = {
  0: '#f39c12',
  1: '#4A5D4E',
  2: '#9b59b6',
  3: '#3498db',
  4: '#95a5a6',
  5: '#e0e0e0',
  6: '#f39c12'
}

const getStatusColor = (status) => {
  return statusColorMap[status] || '#999'
}

const getStatusBg = (status) => {
  const color = getStatusColor(status)
  return color + '18'
}

import { onShow } from '@dcloudio/uni-app'

onShow(() => {
  fetchOrders(true)
})
</script>

<style lang="scss" scoped>
.order-list-container {
  height: 100vh;
  display: flex;
  flex-direction: column;
  background: #F5F2EE;
}

.tabs {
  display: flex;
  background: #fff;
  border-bottom: 1rpx solid #e8e4e0;
  padding: 0 8rpx;
}

.tab-item {
  flex: 1;
  text-align: center;
  padding: 28rpx 0;
  font-size: 28rpx;
  color: #999;
  position: relative;
  transition: color 0.2s;

  &.active {
    color: #4A5D4E;
    font-weight: 600;

    &::after {
      content: '';
      position: absolute;
      bottom: 0;
      left: 50%;
      transform: translateX(-50%);
      width: 48rpx;
      height: 4rpx;
      background: #4A5D4E;
      border-radius: 2rpx;
    }
  }
}

.order-scroll {
  flex: 1;
}

.order-list {
  padding: 20rpx;
  display: flex;
  flex-direction: column;
  gap: 20rpx;
}

.order-card {
  background: #fff;
  border-radius: 16rpx;
  padding: 28rpx;
  box-shadow: 0 2rpx 12rpx rgba(74, 93, 78, 0.06);
  transition: transform 0.18s, box-shadow 0.18s;

  &:active {
    transform: scale(0.975);
  }

  &--active {
    border-left: 5rpx solid #4A5D4E;
  }
}

.order-card__top {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20rpx;
}

.order-no {
  font-size: 22rpx;
  color: #bbb;
  letter-spacing: 0.5px;
}

.status-tag {
  display: inline-flex;
  align-items: center;
  gap: 8rpx;
  padding: 6rpx 16rpx;
  border-radius: 999rpx;
  font-size: 22rpx;
  font-weight: 500;
}

.status-tag__dot {
  width: 8rpx;
  height: 8rpx;
  border-radius: 50%;
  flex-shrink: 0;
}

.order-card__body {
  display: flex;
  justify-content: space-between;
  align-items: flex-end;
  padding: 18rpx 0;
  border-top: 1rpx dashed #e8e4e0;
  border-bottom: 1rpx dashed #e8e4e0;
}

.order-info {
  display: flex;
  flex-direction: column;
  gap: 6rpx;
}

.order-category {
  font-size: 30rpx;
  font-weight: 600;
  color: #2c2c2c;
}

.order-time {
  font-size: 22rpx;
  color: #bbb;
}

.order-price {
  display: flex;
  align-items: baseline;
  gap: 2rpx;
}

.price-symbol {
  font-size: 22rpx;
  color: #d35d6e;
  font-weight: 500;
}

.price-value {
  font-size: 36rpx;
  font-weight: 700;
  color: #d35d6e;
  letter-spacing: -0.5px;
}

.order-card__footer {
  margin-top: 20rpx;
}

.order-actions {
  display: flex;
  gap: 16rpx;
  justify-content: flex-end;
}

.action-btn {
  padding: 12rpx 28rpx;
  font-size: 24rpx;
  background: #2c2c2c;
  color: #fff;
  border-radius: 999rpx;
  border: none;
  margin: 0;
  transition: opacity 0.15s;

  &:active { opacity: 0.8; }
  &::after { border: none; }

  &--primary {
    background: #4A5D4E;
  }
}

.empty {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  height: 400rpx;
  gap: 16rpx;
}

.empty-icon { font-size: 72rpx; opacity: 0.4; }

.empty-text {
  font-size: 28rpx;
  color: #bbb;
}

.loading {
  text-align: center;
  padding: 20rpx;
  font-size: 24rpx;
  color: #bbb;
}
</style>
