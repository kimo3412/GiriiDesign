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
          :key="item.id"
          class="portfolio-item"
          @click="goToDetail(item.id)"
        >
          <image :src="item.thumbnail" mode="aspectFill" class="portfolio-cover" />
          <view class="portfolio-info">
            <text class="portfolio-title">{{ item.title }}</text>
            <text class="portfolio-desc">{{ item.description }}</text>
          </view>
        </view>
      </view>

      <!-- 空状态 -->
      <view v-if="list.length === 0 && !loading" class="empty">
        <text>暂无作品</text>
      </view>

      <!-- 加载中 -->
      <view v-if="loading" class="loading">
        <text>加载中...</text>
      </view>
    </scroll-view>
  </view>
</template>

<script setup>
import { ref } from 'vue'
import { onShow, onLoad } from '@dcloudio/uni-app'
import { getPortfolioList } from '@/api/portfolio'

const categories = ref([
  { id: '', name: '全部' },
  { id: '1', name: '服装' },
  { id: '2', name: '皮具' },
  { id: '3', name: '插画' }
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
  background: #f8f8f8;
}

.filter-bar {
  display: flex;
  background: #fff;
  padding: 20rpx 30rpx;
  overflow-x: auto;
  white-space: nowrap;
}

.filter-item {
  display: inline-block;
  padding: 12rpx 28rpx;
  font-size: 26rpx;
  color: #666;
  background: #f5f5f5;
  border-radius: 30rpx;
  margin-right: 16rpx;

  &.active {
    background: #07c160;
    color: #fff;
  }
}

.portfolio-scroll {
  flex: 1;
}

.portfolio-grid {
  display: flex;
  flex-wrap: wrap;
  padding: 20rpx;
  gap: 20rpx;
}

.portfolio-item {
  width: calc(50% - 10rpx);
  background: #fff;
  border-radius: 12rpx;
  overflow: hidden;

  .portfolio-cover {
    width: 100%;
    height: 350rpx;
    background: #f0f0f0;
  }

  .portfolio-info {
    padding: 20rpx;

    .portfolio-title {
      display: block;
      font-size: 28rpx;
      font-weight: 500;
      color: #333;
      margin-bottom: 8rpx;
    }

    .portfolio-desc {
      display: block;
      font-size: 24rpx;
      color: #999;
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
  padding: 60rpx;
  font-size: 26rpx;
  color: #999;
}
</style>
