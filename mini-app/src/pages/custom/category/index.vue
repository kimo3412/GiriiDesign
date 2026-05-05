<template>
  <scroll-view scroll-y class="custom-page">
    <view class="hero">
      <text class="hero-kicker">ZEHANA ATELIER</text>
      <text class="hero-title">选择定制品类</text>
      <text class="hero-desc">从服装、皮具到插画，让设计师围绕你的需求开启一对一创作。</text>
    </view>

    <view v-if="categories.length > 0" class="category-list">
      <view
        v-for="(item, index) in categories"
        :key="item.categoryId"
        class="category-card"
        :class="`category-card--${index % 3}`"
        @click="selectCategory(item)"
      >
        <view class="category-mark">
          <text class="category-mark__text">{{ getInitial(item.name) }}</text>
        </view>
        <view class="category-main">
          <view class="category-row">
            <text class="category-name">{{ item.name }}</text>
            <text class="category-index">0{{ index + 1 }}</text>
          </view>
          <text class="category-desc">{{ getDesc(item, index) }}</text>
          <view class="category-action">
            <text>开始定制</text>
            <text class="category-action__arrow">→</text>
          </view>
        </view>
      </view>
    </view>

    <view v-else-if="!loading" class="empty-state">
      <text class="empty-state__icon">✦</text>
      <text class="empty-state__title">暂无定制方案</text>
      <text class="empty-state__desc">新的定制品类正在整理中，请稍后再来看看。</text>
    </view>

    <view v-if="loading" class="loading-state">
      <text>正在整理定制品类...</text>
    </view>

    <view v-if="categories.length > 0" class="service-note">
      <view class="service-note__line"></view>
      <text class="service-note__text">所有定制方案均由资深设计师一对一服务</text>
      <view class="service-note__line"></view>
    </view>
  </scroll-view>
</template>

<script setup>
import { ref } from 'vue'
import { onLoad } from '@dcloudio/uni-app'
import { getCategoryList } from '@/api/custom'

const categories = ref([])
const loading = ref(false)

const descMap = {
  服装: '量体、版型、面料与细节全程沟通，适合礼服、西装与日常定制。',
  皮具: '甄选皮料与五金，围绕使用习惯打造耐用又有个性的作品。',
  插画: '将灵感、人物和故事转化为专属画作，可用于礼物或收藏。',
}

const defaultDescs = [
  '独立设计师一对一沟通，完整跟进从灵感到交付的每个细节。',
  '围绕材料、工艺与使用场景定制，让作品更贴合你的日常。',
  '小批量手作流程，保留独特质感，也让每次定制更有仪式感。',
]

const getInitial = (name = '') => name.trim().slice(0, 1) || 'Z'

const getDesc = (item, index) => {
  if (item.description) return item.description
  for (const [key, value] of Object.entries(descMap)) {
    if (item.name && item.name.includes(key)) return value
  }
  return defaultDescs[index % defaultDescs.length]
}

const fetchCategories = async () => {
  loading.value = true
  try {
    const data = await getCategoryList()
    categories.value = Array.isArray(data) ? data : (data?.records || data?.list || [])
  } catch (err) {
    console.error('获取品类列表失败', err)
    uni.showToast({ title: '获取品类失败', icon: 'none' })
  } finally {
    loading.value = false
  }
}

const selectCategory = (item) => {
  uni.navigateTo({
    url: `/pages/custom/form/index?categoryId=${item.categoryId}&categoryName=${encodeURIComponent(item.name || '')}`,
  })
}

onLoad(() => {
  fetchCategories()
})
</script>

<style lang="scss" scoped>
.custom-page {
  min-height: 100vh;
  box-sizing: border-box;
  background:
    radial-gradient(circle at 85% 8%, rgba(210, 228, 251, 0.72), transparent 34%),
    linear-gradient(180deg, #fbf9fa 0%, #f5f3f4 100%);
  color: #1b1c1d;
}

.hero {
  padding: 84rpx 44rpx 44rpx;
  display: flex;
  flex-direction: column;
  align-items: center;
  text-align: center;
}

.hero-kicker {
  font-family: 'Times New Roman', serif;
  font-size: 22rpx;
  letter-spacing: 12rpx;
  color: #2d4b41;
  margin-bottom: 24rpx;
}

.hero-title {
  font-family: 'Times New Roman', serif;
  font-size: 58rpx;
  line-height: 1.16;
  letter-spacing: 6rpx;
  color: #1a2b3c;
  margin-bottom: 20rpx;
}

.hero-desc {
  max-width: 560rpx;
  font-size: 26rpx;
  line-height: 1.72;
  color: #6b6b6b;
}

.category-list {
  padding: 0 32rpx;
  display: flex;
  flex-direction: column;
  gap: 24rpx;
}

.category-card {
  position: relative;
  min-height: 188rpx;
  padding: 34rpx 32rpx;
  display: flex;
  align-items: center;
  box-sizing: border-box;
  border: 1rpx solid rgba(229, 226, 218, 0.9);
  border-radius: 16rpx;
  background: rgba(255, 255, 255, 0.92);
  box-shadow: 0 14rpx 38rpx rgba(26, 43, 60, 0.06);
  overflow: hidden;
}

.category-card::after {
  content: '';
  position: absolute;
  inset: 0;
  background: linear-gradient(135deg, rgba(255, 255, 255, 0.16), transparent 52%);
  pointer-events: none;
}

.category-card:active {
  transform: scale(0.985);
  opacity: 0.92;
}

.category-card--1 {
  background: #2d4b41;
  border-color: rgba(45, 75, 65, 0.24);
  box-shadow: 0 18rpx 44rpx rgba(45, 75, 65, 0.18);
}

.category-card--2 {
  background: #1a2b3c;
  border-color: rgba(26, 43, 60, 0.18);
  box-shadow: 0 18rpx 44rpx rgba(26, 43, 60, 0.18);
}

.category-mark {
  width: 112rpx;
  height: 112rpx;
  margin-right: 32rpx;
  flex-shrink: 0;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 10rpx;
  background: #2d4b41;
}

.category-card--1 .category-mark,
.category-card--2 .category-mark {
  background: rgba(255, 255, 255, 0.16);
}

.category-mark__text {
  font-family: 'Times New Roman', serif;
  font-size: 56rpx;
  line-height: 1;
  color: #ffffff;
}

.category-main {
  position: relative;
  z-index: 1;
  flex: 1;
  min-width: 0;
}

.category-row {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: 20rpx;
  margin-bottom: 12rpx;
}

.category-name {
  font-size: 34rpx;
  line-height: 1.32;
  font-weight: 600;
  color: #1a2b3c;
}

.category-index {
  font-family: 'Times New Roman', serif;
  font-size: 24rpx;
  color: rgba(26, 43, 60, 0.35);
}

.category-desc {
  display: block;
  max-width: 430rpx;
  font-size: 25rpx;
  line-height: 1.58;
  color: #74777d;
}

.category-action {
  margin-top: 22rpx;
  display: inline-flex;
  align-items: center;
  gap: 12rpx;
  font-size: 22rpx;
  letter-spacing: 2rpx;
  color: #1a2b3c;
}

.category-action__arrow {
  font-size: 30rpx;
  line-height: 1;
}

.category-card--1 .category-name,
.category-card--1 .category-action,
.category-card--2 .category-name,
.category-card--2 .category-action {
  color: #ffffff;
}

.category-card--1 .category-desc,
.category-card--1 .category-index,
.category-card--2 .category-desc,
.category-card--2 .category-index {
  color: rgba(255, 255, 255, 0.72);
}

.empty-state,
.loading-state {
  margin: 0 32rpx;
  padding: 96rpx 44rpx;
  display: flex;
  flex-direction: column;
  align-items: center;
  border: 1rpx solid rgba(229, 226, 218, 0.9);
  border-radius: 18rpx;
  background: rgba(255, 255, 255, 0.88);
  color: #6b6b6b;
}

.empty-state__icon {
  font-size: 46rpx;
  color: #2d4b41;
  margin-bottom: 20rpx;
}

.empty-state__title {
  font-size: 30rpx;
  color: #1a2b3c;
  font-weight: 600;
  margin-bottom: 12rpx;
}

.empty-state__desc,
.loading-state {
  font-size: 24rpx;
  line-height: 1.6;
}

.service-note {
  padding: 54rpx 36rpx 90rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 22rpx;
}

.service-note__line {
  width: 72rpx;
  height: 1rpx;
  background: #d8d4cf;
}

.service-note__text {
  font-size: 22rpx;
  color: #74777d;
}
</style>
