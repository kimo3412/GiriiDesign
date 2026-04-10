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
          @click="goToDetail(order.orderId)"
        >
          <view class="order-header">
            <text class="order-no">订单号: {{ order.orderSn }}</text>
            <text class="order-status">{{ getStatusText(order.status) }}</text>
          </view>
          <view class="order-body">
            <text class="order-category">{{ order.categoryName }}</text>
            <text class="order-amount">¥{{ order.totalAmount }}</text>
          </view>
          <view class="order-footer">
            <text class="order-time">{{ order.createTime }}</text>
            <view class="order-actions">
              <button v-if="order.status === 0" class="action-btn pay-btn" @click.stop="handlePay(order, 0)">
                支付定金 ¥{{ order.prepayAmount }}
              </button>
              <button v-if="order.status === 6" class="action-btn pay-btn" @click.stop="handlePay(order, 6)">
                支付尾款 ¥{{ (order.totalAmount - order.prepayAmount).toFixed(2) }}
              </button>
              <button v-if="order.status === 2" class="action-btn" @click.stop="confirmReceive(order.orderId)">
                确认收货
              </button>
            </view>
          </view>
        </view>
      </view>

      <!-- 空状态 -->
      <view v-else class="empty">
        <text class="empty-text">暂无订单</text>
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
  { label: '待收货', value: '2' },
  { label: '已完成', value: '3' }
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

    // 后端返回的是 List 数组，不是分页对象
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

import { onShow } from '@dcloudio/uni-app'

// tabBar 页面每次显示时刷新
onShow(() => {
  fetchOrders(true)
})
</script>

<style lang="scss" scoped>
.order-list-container {
  height: 100vh;
  display: flex;
  flex-direction: column;
  background: #f8f8f8;
}

.tabs {
  display: flex;
  background: #fff;
  border-bottom: 1rpx solid #e5e5e5;
}

.tab-item {
  flex: 1;
  text-align: center;
  padding: 24rpx 0;
  font-size: 28rpx;
  color: #666;
  position: relative;

  &.active {
    color: #4A5D4E;
    font-size: 30rpx;
    font-weight: bold;

    &::after {
      content: '';
      position: absolute;
      bottom: 0;
      left: 50%;
      transform: translateX(-50%);
      width: 40rpx;
      height: 4rpx;
      background: #1a1a1a;
      border-radius: 2rpx;
    }
  }
}

.order-scroll {
  flex: 1;
}

.order-list {
  padding: 20rpx;
}

.order-card {
  background: #fff;
  border-radius: 12rpx;
  padding: 24rpx;
  margin-bottom: 20rpx;
}

.order-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16rpx;

  .order-no {
    font-size: 24rpx;
    color: #999;
  }

  .order-status {
    font-size: 26rpx;
    color: #4A5D4E;
    font-weight: 500;
  }
}

.order-body {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16rpx 0;
  border-top: 1rpx solid #f5f5f5;
  border-bottom: 1rpx solid #f5f5f5;

  .order-category {
    font-size: 30rpx;
    font-weight: 500;
    color: #333;
  }

  .order-amount {
    font-size: 32rpx;
    font-weight: bold;
    color: #e74c3c;
  }
}

.order-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: 16rpx;

  .order-time {
    font-size: 24rpx;
    color: #999;
  }
}

.order-actions {
  display: flex;
  gap: 16rpx;

  .action-btn {
    padding: 10rpx 28rpx;
    font-size: 24rpx;
    background: #1a1a1a;
    color: #fff;
    border-radius: 4rpx;
    border: none;
    margin: 0;

    &::after {
      border: none;
    }
  }

  .pay-btn {
    background: #4A5D4E;
  }
}

.empty {
  display: flex;
  justify-content: center;
  align-items: center;
  height: 400rpx;

  .empty-text {
    font-size: 28rpx;
    color: #999;
  }
}

.loading {
  text-align: center;
  padding: 20rpx;
  font-size: 24rpx;
  color: #999;
}
</style>
