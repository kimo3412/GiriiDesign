<template>
  <view class="index-container">
    <!-- 顶部Banner -->
    <view class="banner">
      <swiper class="banner-swiper" circular indicator-dots autoplay interval="3000">
        <swiper-item v-for="(item, index) in banners" :key="index">
          <image :src="item.image" mode="aspectFill" />
        </swiper-item>
      </swiper>
    </view>

    <!-- 功能入口 -->
    <view class="entry-grid">
      <view class="entry-item" @click="goTo('/pages/portfolio/list/index')">
        <view class="entry-icon">🎨</view>
        <text class="entry-text">作品集</text>
      </view>
      <view class="entry-item" @click="goTo('/pages/custom/category/index')">
        <view class="entry-icon">✨</view>
        <text class="entry-text">发起定制</text>
      </view>
      <view class="entry-item" @click="goTo('/pages/order/list/index')">
        <view class="entry-icon">📋</view>
        <text class="entry-text">我的订单</text>
      </view>
      <view class="entry-item" @click="goTo('/pages/user/index')">
        <view class="entry-icon">👤</view>
        <text class="entry-text">个人中心</text>
      </view>
    </view>

    <!-- 推荐作品 -->
    <view class="section">
      <view class="section-header">
        <text class="section-title">推荐作品</text>
        <text class="section-more" @click="goTo('/pages/portfolio/list/index')">更多 ></text>
      </view>
      <view class="portfolio-grid">
        <view
          v-for="item in portfolios"
          :key="item.id"
          class="portfolio-item"
          @click="goToDetail(item.id)"
        >
          <image :src="item.thumbnail" mode="aspectFill" class="portfolio-cover" />
          <view class="portfolio-info">
            <text class="portfolio-title">{{ item.title }}</text>
          </view>
        </view>
      </view>
    </view>
  </view>
</template>

<script setup>
import { ref } from 'vue'
import { onShow, onLoad } from '@dcloudio/uni-app'
import { getPortfolioList } from '@/api/portfolio'

const banners = ref([
  { image: '/static/images/banner1.jpg' },
  { image: '/static/images/banner2.jpg' }
])

const portfolios = ref([])

/**
 * 跳转页面
 */
const goTo = (url) => {
  uni.navigateTo({ url })
}

/**
 * 跳转作品详情
 */
const goToDetail = (id) => {
  uni.navigateTo({ url: `/pages/portfolio/detail/index?id=${id}` })
}

/**
 * 获取推荐作品
 */
const fetchPortfolios = async () => {
  try {
    const data = await getPortfolioList({ page: 1, size: 6 })
    portfolios.value = data.list || []
  } catch (err) {
    console.error('获取作品列表失败', err)
  }
}

onLoad(() => {
  fetchPortfolios()
})
</script>

<style lang="scss" scoped>
.index-container {
  background: #f8f8f8;
  min-height: 100vh;
}

.banner {
  height: 350rpx;

  .banner-swiper {
    height: 100%;

    image {
      width: 100%;
      height: 100%;
    }
  }
}

.entry-grid {
  display: flex;
  background: #fff;
  padding: 40rpx 0;
  margin-bottom: 20rpx;
}

.entry-item {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;

  .entry-icon {
    font-size: 48rpx;
    margin-bottom: 16rpx;
  }

  .entry-text {
    font-size: 24rpx;
    color: #333;
  }
}

.section {
  background: #fff;
  padding: 30rpx;
  margin-bottom: 20rpx;
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24rpx;

  .section-title {
    font-size: 32rpx;
    font-weight: bold;
    color: #333;
  }

  .section-more {
    font-size: 24rpx;
    color: #999;
  }
}

.portfolio-grid {
  display: flex;
  flex-wrap: wrap;
  gap: 20rpx;
}

.portfolio-item {
  width: calc(50% - 10rpx);
  border-radius: 12rpx;
  overflow: hidden;
  background: #f8f8f8;

  .portfolio-cover {
    width: 100%;
    height: 300rpx;
  }

  .portfolio-info {
    padding: 16rpx;

    .portfolio-title {
      font-size: 26rpx;
      color: #333;
    }
  }
}
</style>
