<template>
  <view class="portfolio-detail-container">
    <!-- 图片画廊 -->
    <swiper class="gallery" circular indicator-dots indicator-color="rgba(255,255,255,0.5)" indicator-active-color="#fff">
      <swiper-item v-for="(img, index) in portfolio.images" :key="index">
        <image :src="img" mode="aspectFill" @click="previewImage(index)" />
      </swiper-item>
    </swiper>

    <!-- 内容区 -->
    <view class="content">
      <text class="title">{{ portfolio.title }}</text>

      <view class="meta">
        <text class="category">高级定制</text>
      </view>

      <view class="description">
        <text class="desc-title">作品描述</text>
        <text class="desc-content">{{ portfolio.description || '暂无描述' }}</text>
      </view>

      <!-- 底部按钮 -->
      <view class="bottom-action">
        <button class="custom-btn" type="primary" @click="goToCustom">
          立即定制
        </button>
      </view>
    </view>
  </view>
</template>

<script setup>
import { ref } from 'vue'
import { onShow, onLoad } from '@dcloudio/uni-app'
import { getPortfolioDetail } from '@/api/portfolio'
import { getCategoryList } from '@/api/custom'

const portfolioId = ref(0)
const portfolio = ref({
  images: [],
  title: '',
  description: ''
})
const categories = ref([])

/**
 * 获取作品详情
 */
const fetchDetail = async () => {
  try {
    const data = await getPortfolioDetail(portfolioId.value)

    // 处理图片
    // imageUrls 后端已通过 JacksonTypeHandler 反序列化为数组
    let images = []
    if (Array.isArray(data.imageUrls)) {
      images = data.imageUrls
    } else if (typeof data.imageUrls === 'string') {
      try { images = JSON.parse(data.imageUrls) } catch { images = [] }
    }

    portfolio.value = {
      ...data,
      images
    }
  } catch (err) {
    uni.showToast({ title: '获取详情失败', icon: 'none' })
  }
}

/**
 * 跳转定制
 */
const goToCustom = async () => {
  // 获取第一个品类跳转
  try {
    const data = await getCategoryList()
    if (data && data.length > 0) {
      uni.navigateTo({
        url: `/pages/custom/form/index?categoryId=${data[0].categoryId}&categoryName=${data[0].name}`
      })
    }
  } catch (err) {
    uni.showToast({ title: '获取品类失败', icon: 'none' })
  }
}

/**
 * 预览图片
 */
const previewImage = (current) => {
  uni.previewImage({
    urls: portfolio.value.images,
    current
  })
}

onLoad((options) => {
  portfolioId.value = Number(options.id) || 0
  fetchDetail()
})
</script>

<style lang="scss" scoped>
.portfolio-detail-container {
  min-height: 100vh;
  background: #f8f8f8;
  padding-bottom: 120rpx;
}

.gallery {
  height: 600rpx;
  background: #000;

  image {
    width: 100%;
    height: 100%;
  }
}

.content {
  background: #fff;
  padding: 30rpx;
}

.title {
  display: block;
  font-size: 40rpx;
  font-weight: bold;
  color: #333;
  margin-bottom: 16rpx;
}

.meta {
  margin-bottom: 30rpx;

  .category {
    display: inline-block;
    padding: 8rpx 20rpx;
    font-size: 24rpx;
    color: #4A5D4E;
    background: rgba(74, 93, 78, 0.1);
    border-radius: 0;
  }
}

.description {
  .desc-title {
    display: block;
    font-size: 30rpx;
    font-weight: 500;
    color: #333;
    margin-bottom: 16rpx;
  }

  .desc-content {
    font-size: 28rpx;
    color: #666;
    line-height: 1.6;
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
}

.custom-btn {
  width: 100%;
  height: 88rpx;
  background: #1a1a1a;
  color: #fff;
  font-size: 32rpx;
  border-radius: 0;
  border: none;

  &::after {
    border: none;
  }
}
</style>
