<template>
  <view class="portfolio-list-container">
    <!-- 筛选 -->
    <view class="filter-bar">
      <view
        v-for="item in categories"
        :key="item.id"
        class="filter-item"
        :class="{ active: currentCategory === item.id }"
        @click="switchCategory(item.id)"
      >
        {{ item.name }}
      </view>
    </view>

    <!-- 作品列表 -->
    <scroll-view scroll-y class="portfolio-scroll" @scrolltolower="loadMore">
      <view class="portfolio-grid">
        <view
          v-for="item in list"
          :key="item.portfolioId"
          class="portfolio-item"
          @click="goToDetail(item.portfolioId)"
        >
          <view class="img-placeholder" v-if="!item.coverUrl">
            <text class="placeholder-text">ZeHana</text>
          </view>
          <image v-else :src="item.coverUrl" mode="aspectFill" class="portfolio-cover" />
          <view class="portfolio-info">
            <text class="portfolio-title">{{ item.title }}</text>
            <text class="portfolio-desc">{{ item.description }}</text>
          </view>
        </view>
      </view>

      <!-- 空状态 -->
      <view v-if="list.length === 0 && !loading" class="empty">
        <text>期待与您共同创造</text>
      </view>

      <!-- 加载中 -->
      <view v-if="loading" class="loading">
        <text>静候加载加载中...</text>
      </view>
    </scroll-view>
  </view>
</template>

<script setup>
import { ref } from 'vue'
import { onShow, onLoad } from '@dcloudio/uni-app'
import { getPortfolioList } from '@/api/portfolio'

const categories = ref([
  { id: '', name: '全部作品' },
  { id: '1', name: '高级定制' },
  { id: '2', name: '手工皮具' },
  { id: '3', name: '数字插画' }
])

const currentCategory = ref('')
const list = ref([])
const page = ref(1)
const loading = ref(false)
const hasMore = ref(true)

/**
 * 切换分类
 */
const switchCategory = (id) => {
  currentCategory.value = id
  page.value = 1
  hasMore.value = true
  fetchList(true)
}

/**
 * 获取作品列表
 */
const fetchList = async (refresh = false) => {
  if (loading.value || (!hasMore.value && !refresh)) return

  loading.value = true

  try {
    const params = {
      page: page.value,
      size: 10,
      categoryId: currentCategory.value
    }

    const data = await getPortfolioList(params)

    if (refresh) {
      list.value = data.list || []
    } else {
      list.value = [...list.value, ...(data.list || [])]
    }

    hasMore.value = (data.list || []).length >= 10
  } catch (err) {
    uni.showToast({ title: '获取作品失败', icon: 'none' })
  }

  loading.value = false
}

/**
 * 加载更多
 */
const loadMore = () => {
  if (!hasMore.value) return
  page.value++
  fetchList()
}

/**
 * 跳转详情
 */
const goToDetail = (id) => {
  uni.navigateTo({ url: `/pages/portfolio/detail/index?id=${id}` })
}

onLoad(() => {
  fetchList(true)
})
</script>

<style lang="scss" scoped>
.portfolio-list-container {
  height: 100vh;
  display: flex;
  flex-direction: column;
  background: $background-color;
}

.filter-bar {
  display: flex;
  background: $white;
  padding: 30rpx 40rpx;
  overflow-x: auto;
  white-space: nowrap;
  box-shadow: 0 4rpx 20rpx rgba(0,0,0,0.02);
  z-index: 10;
}

.filter-item {
  display: inline-block;
  padding: 10rpx 0;
  font-size: 24rpx;
  color: $text-color-light;
  margin-right: 48rpx;
  letter-spacing: 2rpx;
  position: relative;

  &.active {
    color: $primary-color;
    font-weight: 500;
    
    &::after {
      content: '';
      position: absolute;
      bottom: 0;
      left: 0;
      width: 100%;
      height: 2px;
      background: $primary-color;
    }
  }
}

.portfolio-scroll {
  flex: 1;
}

.portfolio-grid {
  display: flex;
  flex-wrap: wrap;
  padding: 30rpx;
  gap: 30rpx;
}

.portfolio-item {
  width: calc(50% - 15rpx);
  background: $white;
  border-radius: $border-radius-sm;
  overflow: hidden;
  box-shadow: 0 6rpx 24rpx rgba(0,0,0,0.04);

  .img-placeholder {
    width: 100%;
    height: 380rpx;
    background: linear-gradient(135deg, #7F9E8B, #4A5D4E);
    display: flex;
    align-items: center;
    justify-content: center;
    
    .placeholder-text {
      color: rgba(255,255,255,0.6);
      font-family: 'Times New Roman', serif;
      letter-spacing: 4rpx;
      font-size: 24rpx;
    }
  }

  .portfolio-cover {
    width: 100%;
    height: 380rpx;
  }

  .portfolio-info {
    padding: 24rpx;

    .portfolio-title {
      display: block;
      font-size: 26rpx;
      font-weight: 400;
      color: $text-color;
      margin-bottom: 8rpx;
      letter-spacing: 2rpx;
    }

    .portfolio-desc {
      display: block;
      font-size: 20rpx;
      color: $text-color-light;
      overflow: hidden;
      text-overflow: ellipsis;
      white-space: nowrap;
    }
  }
}

.empty,
.loading {
  display: flex;
  justify-content: center;
  align-items: center;
  padding: 80rpx;
  font-size: 22rpx;
  color: $text-color-light;
  letter-spacing: 4rpx;
}
</style>
