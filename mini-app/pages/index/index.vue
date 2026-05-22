<template>
  <view class="studio-page">
    <view class="top-bar">
      <view class="top-icon" @click="goTo('/pages/user/index')">
        <text class="top-icon__text">☰</text>
      </view>
      <text class="brand-word">ATELIER</text>
      <view class="top-icon" @click="goTo('/pages/user/notification/index')">
        <text class="top-icon__text">◔</text>
      </view>
    </view>

    <scroll-view scroll-y class="page-scroll" refresher-enabled :refresher-triggered="refreshing" @refresherrefresh="onRefresh">
      <view class="hero-section">
        <swiper class="hero-swiper" circular autoplay interval="4200" duration="700" indicator-dots indicator-color="rgba(255,255,255,0.42)" indicator-active-color="#ffffff">
          <swiper-item v-for="(item, index) in banners" :key="index">
            <view class="hero-frame">
              <image :src="item.image" mode="aspectFill" class="hero-image" />
              <view class="hero-shade"></view>
              <view class="hero-copy">
                <text class="hero-kicker">{{ item.label || 'ZeHana 工作室' }}</text>
                <text class="hero-title">{{ item.headline || '专属定制，优雅抵达' }}</text>
                <text class="hero-desc">从灵感沟通到生产交付，每一个节点都由工作室陪你推进。</text>
                <view class="hero-action" @click="goTo('/pages/custom/category/index')">
                  <text class="hero-action__text">开始定制</text>
                </view>
              </view>
            </view>
          </swiper-item>
        </swiper>
      </view>

      <view class="highlight-section">
        <view class="highlight-card">
          <text class="highlight-icon">✓</text>
          <text class="highlight-title">流程透明</text>
          <text class="highlight-desc">从需求确认到交付，每个生产节点都能清楚追踪。</text>
        </view>
        <view class="highlight-card">
          <text class="highlight-icon">✉</text>
          <text class="highlight-title">专属沟通</text>
          <text class="highlight-desc">设计师与客服持续在线，围绕订单保持沟通。</text>
          <view class="highlight-link" @click="goTo('/pages/chat/index')">
            <text>联系管家</text>
            <text class="highlight-link__arrow">→</text>
          </view>
        </view>
        <view class="highlight-card">
          <text class="highlight-icon">□</text>
          <text class="highlight-title">订单管理</text>
          <text class="highlight-desc">定金、尾款、收货确认和进度详情集中查看。</text>
          <view class="highlight-link" @click="goTo('/pages/order/list/index')">
            <text>查看订单</text>
            <text class="highlight-link__arrow">→</text>
          </view>
        </view>
      </view>

      <view class="masterpiece-section">
        <view class="section-head">
          <text class="section-title">近期作品</text>
          <view class="section-action" @click="goTo('/pages/portfolio/list/index')">
            <text>全部</text>
            <text class="section-action__arrow">→</text>
          </view>
        </view>

        <view class="masterpiece-grid">
          <view
            v-for="(item, index) in featuredPortfolios"
            :key="item.portfolioId || index"
            class="masterpiece-item"
            @click="goToDetail(item.portfolioId)"
          >
            <view class="masterpiece-cover">
              <image v-if="item.coverUrl" :src="item.coverUrl" mode="aspectFill" class="masterpiece-image" />
              <view v-else class="masterpiece-fallback">
                <text class="masterpiece-fallback__text">ZeHana</text>
              </view>
            </view>
            <text class="masterpiece-title">{{ item.title || '未命名作品' }}</text>
          </view>
        </view>

        <view v-if="featuredPortfolios.length === 0" class="empty-work">
          <text class="empty-work__title">作品正在整理中</text>
          <text class="empty-work__desc">你可以先发起定制，设计师会基于需求给出方案。</text>
        </view>
      </view>
    </scroll-view>
  </view>
</template>

<script setup>
import { computed, ref } from 'vue'
import { onLoad } from '@dcloudio/uni-app'
import { getBannerList } from '@/api/banner'
import { getPortfolioList } from '@/api/portfolio'

const defaultBanners = [
  {
    image: '/static/images/home-banner-couture.png',
    label: '高级定制',
    headline: '把灵感缝进每一处细节'
  },
  {
    image: '/static/images/home-banner-leather.png',
    label: '手作皮具',
    headline: '材质、线迹与日常使用感'
  },
  {
    image: '/static/images/home-banner-suit.png',
    label: '量体西装',
    headline: '从版型到面料都可追踪'
  }
]

const banners = ref([...defaultBanners])
const portfolios = ref([])
const refreshing = ref(false)
const fileBaseUrl = 'http://localhost:8081'

const featuredPortfolios = computed(() => portfolios.value.slice(0, 4))

const tabBarPages = ['/pages/index/index', '/pages/order/list/index', '/pages/user/index']

const goTo = (url) => {
  if (tabBarPages.includes(url)) {
    uni.switchTab({ url })
    return
  }
  uni.navigateTo({ url })
}

const goToDetail = (id) => {
  if (!id) return
  uni.navigateTo({ url: `/pages/portfolio/detail/index?id=${id}` })
}

const fetchBanners = async () => {
  try {
    const data = await getBannerList()
    const list = Array.isArray(data) ? data : (data?.records || data?.list || [])
    if (!list.length) {
      banners.value = [...defaultBanners]
      return
    }
    banners.value = list.map(item => ({
      image: toFileUrl(item.imageUrl || item.image),
      label: item.title || 'ZeHana 工作室',
      headline: item.description || '专属定制，优雅抵达'
    }))
  } catch (err) {
    console.error('获取轮播图失败', err)
    banners.value = [...defaultBanners]
  }
}

const fetchPortfolios = async () => {
  try {
    const data = await getPortfolioList()
    const list = data?.records || data?.list || data || []
    portfolios.value = Array.isArray(list)
      ? list.map((item) => ({ ...item, coverUrl: toFileUrl(item.coverUrl) }))
      : []
  } catch (err) {
    console.error('获取作品列表失败', err)
    portfolios.value = []
  }
}

const loadPageData = async () => {
  await Promise.all([fetchBanners(), fetchPortfolios()])
}

const onRefresh = async () => {
  refreshing.value = true
  await loadPageData()
  refreshing.value = false
}

const toFileUrl = (url) => {
  if (!url) return ''
  if (/^https?:\/\//i.test(url) || url.startsWith('/static/')) return url
  if (url.startsWith('/uploads/')) return fileBaseUrl + url
  const normalized = url.startsWith('/') ? url : `/${url}`
  return fileBaseUrl + '/uploads' + normalized
}

onLoad(() => {
  loadPageData()
})
</script>

<style lang="scss" scoped>
.studio-page {
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
  background: rgba(249, 248, 246, 0.96);
  border-bottom: 1rpx solid rgba(229, 226, 218, 0.72);
  flex-shrink: 0;
}

.brand-word {
  font-family: 'Times New Roman', serif;
  font-size: 34rpx;
  line-height: 1;
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

.page-scroll {
  flex: 1;
}

.hero-section {
  padding: 32rpx 24rpx 0;
}

.hero-swiper,
.hero-frame {
  height: 780rpx;
}

.hero-frame {
  position: relative;
  overflow: hidden;
  border-radius: 24rpx;
  background: #e9e7e9;
  box-shadow: 0 10rpx 26rpx rgba(26, 43, 60, 0.06);
}

.hero-image,
.hero-shade {
  width: 100%;
  height: 100%;
}

.hero-image {
  display: block;
}

.hero-shade {
  position: absolute;
  inset: 0;
  background: linear-gradient(180deg, rgba(251, 249, 250, 0.02) 0%, rgba(251, 249, 250, 0.36) 45%, rgba(251, 249, 250, 0.94) 100%);
}

.hero-copy {
  position: absolute;
  left: 36rpx;
  right: 36rpx;
  bottom: 42rpx;
}

.hero-kicker {
  display: block;
  margin-bottom: 14rpx;
  font-size: 22rpx;
  color: #4f6073;
  letter-spacing: 4rpx;
  text-transform: uppercase;
}

.hero-title {
  display: block;
  max-width: 560rpx;
  font-family: 'Times New Roman', serif;
  font-size: 54rpx;
  line-height: 1.18;
  color: #1a2b3c;
  font-weight: 600;
}

.hero-desc {
  display: block;
  max-width: 540rpx;
  margin-top: 18rpx;
  font-size: 26rpx;
  line-height: 1.62;
  color: #44474c;
}

.hero-action {
  display: inline-flex;
  margin-top: 34rpx;
  padding: 20rpx 34rpx;
  border-radius: 8rpx;
  background: #1a2b3c;
}

.hero-action__text {
  color: #ffffff;
  font-size: 22rpx;
  font-weight: 700;
  letter-spacing: 3rpx;
}

.highlight-section {
  display: grid;
  grid-template-columns: repeat(3, minmax(0, 1fr));
  gap: 16rpx;
  padding: 30rpx 24rpx 0;
}

.highlight-card {
  min-height: 228rpx;
  padding: 24rpx 20rpx;
  border-radius: 16rpx;
  border: 1rpx solid #e5e2da;
  background: #ffffff;
  box-shadow: 0 6rpx 24rpx rgba(26, 43, 60, 0.03);
}

.highlight-icon {
  display: block;
  height: 34rpx;
  margin-bottom: 14rpx;
  color: #1a2b3c;
  font-size: 34rpx;
  line-height: 1;
}

.highlight-title {
  display: block;
  font-size: 26rpx;
  line-height: 1.35;
  color: #1a2b3c;
  font-weight: 700;
}

.highlight-desc {
  display: block;
  margin-top: 12rpx;
  font-size: 22rpx;
  line-height: 1.55;
  color: #6b6b6b;
}

.highlight-link {
  display: inline-flex;
  align-items: center;
  gap: 6rpx;
  margin-top: 18rpx;
  color: #1a2b3c;
  font-size: 20rpx;
  font-weight: 700;
  letter-spacing: 2rpx;
}

.highlight-link__arrow {
  font-size: 20rpx;
}

.masterpiece-section {
  padding: 42rpx 24rpx 120rpx;
}

.section-head {
  display: flex;
  justify-content: space-between;
  align-items: flex-end;
  gap: 24rpx;
  padding-bottom: 18rpx;
  border-bottom: 1rpx solid #e5e2da;
}

.section-title {
  font-family: 'Times New Roman', serif;
  font-size: 38rpx;
  line-height: 1.2;
  color: #1a2b3c;
  font-weight: 600;
}

.section-action {
  display: flex;
  align-items: center;
  gap: 8rpx;
  color: #1a2b3c;
  font-size: 22rpx;
  font-weight: 700;
}

.section-action__arrow {
  font-size: 24rpx;
}

.masterpiece-grid {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 18rpx;
  margin-top: 24rpx;
}

.masterpiece-item {
  min-width: 0;
  overflow: hidden;
  border-radius: 16rpx;
  background: #ffffff;
  box-shadow: 0 12rpx 28rpx rgba(26, 43, 60, 0.08);
}

.masterpiece-cover {
  width: 100%;
  height: 360rpx;
  background: #e4e2e3;
}

.masterpiece-image,
.masterpiece-fallback {
  width: 100%;
  height: 100%;
}

.masterpiece-image {
  display: block;
}

.masterpiece-title {
  display: block;
  min-height: 72rpx;
  padding: 18rpx 18rpx 20rpx;
  color: #1a2b3c;
  font-size: 26rpx;
  line-height: 1.35;
  font-weight: 700;
  text-align: center;
  overflow: hidden;
  text-overflow: ellipsis;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
}

.masterpiece-fallback {
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #b7c8de, #4f6073);
}

.masterpiece-fallback__text {
  color: rgba(255, 255, 255, 0.76);
  font-family: 'Times New Roman', serif;
  font-size: 28rpx;
  letter-spacing: 4rpx;
}

.empty-work {
  padding: 80rpx 20rpx 40rpx;
  text-align: center;
}

.empty-work__title {
  display: block;
  font-size: 30rpx;
  color: #1a2b3c;
  font-weight: 700;
}

.empty-work__desc {
  display: block;
  margin-top: 14rpx;
  font-size: 24rpx;
  line-height: 1.6;
  color: #74777d;
}
</style>
