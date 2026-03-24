<template>
  <view class="category-container">
    <view class="header">
      <text class="title">专属定制</text>
      <text class="desc">选择您期待的定制形式</text>
    </view>

    <view class="category-list">
      <view
        v-for="item in categories"
        :key="item.categoryId"
        class="category-item"
        @click="selectCategory(item)"
      >
        <view class="icon-placeholder" v-if="!item.icon">
          <text>{{ item.name ? item.name.substring(0, 1) : 'Z' }}</text>
        </view>
        <image v-else :src="item.icon" mode="aspectFill" class="category-icon" />
        <view class="category-info">
          <text class="category-name">{{ item.name }}</text>
          <text class="category-desc">{{ item.description || 'ZeHana Exclusive Studio' }}</text>
        </view>
        <text class="arrow">→</text>
      </view>
    </view>
  </view>
</template>

<script setup>
import { ref } from 'vue'
import { onShow, onLoad } from '@dcloudio/uni-app'
import { getCategoryList } from '@/api/custom'

const categories = ref([])

/**
 * 获取品类列表
 */
const fetchCategories = async () => {
  try {
    const data = await getCategoryList()
    categories.value = data || []
    // 塞点假数据测试展示效果
    if (categories.value.length === 0) {
      categories.value = [
        { categoryId: 1, name: '高定礼服 Couture', description: '量身定制专属晚装' },
        { categoryId: 2, name: '手工皮具 Leather', description: '私人订制头层皮艺' }
      ]
    }
  } catch (err) {
    console.error('获取品类列表失败', err)
    uni.showToast({ title: '获取品类失败', icon: 'none' })
  }
}

/**
 * 选择品类，跳转到动态表单
 */
const selectCategory = (item) => {
  uni.navigateTo({
    url: `/pages/custom/form/index?categoryId=${item.categoryId}&categoryName=${item.name}`
  })
}

onLoad(() => {
  fetchCategories()
})
</script>

<style lang="scss" scoped>
.category-container {
  min-height: 100vh;
  background: $background-color;
  padding: 40rpx 40rpx;
}

.header {
  margin-bottom: 60rpx;

  .title {
    display: block;
    font-size: 56rpx;
    font-weight: 300;
    font-family: 'Times New Roman', serif;
    color: $primary-color;
    margin-bottom: 16rpx;
    letter-spacing: 6rpx;
  }

  .desc {
    font-size: 22rpx;
    color: $text-color-light;
    letter-spacing: 4rpx;
  }
}

.category-list {
  background: transparent;
  display: flex;
  flex-direction: column;
  gap: 30rpx;
}

.category-item {
  display: flex;
  align-items: center;
  padding: 40rpx 30rpx;
  background: $white;
  box-shadow: 0 4rpx 20rpx rgba(0,0,0,0.02);
  border: 1px solid $border-color;
  transition: all 0.3s ease;

  &:active {
    background: #fafafa;
  }

  .icon-placeholder {
    width: 100rpx;
    height: 100rpx;
    border-radius: 0; // 高定直角
    margin-right: 30rpx;
    background: $primary-color;
    color: white;
    display: flex;
    align-items: center;
    justify-content: center;
    font-family: 'Times New Roman', serif;
    font-size: 44rpx;
    font-weight: 300;
  }

  .category-icon {
    width: 100rpx;
    height: 100rpx;
    margin-right: 30rpx;
    border-radius: 0;
  }

  .category-info {
    flex: 1;

    .category-name {
      display: block;
      font-size: 28rpx;
      font-weight: 400;
      color: $text-color;
      margin-bottom: 12rpx;
      letter-spacing: 2rpx;
    }

    .category-desc {
      font-size: 20rpx;
      color: $text-color-light;
      letter-spacing: 1rpx;
    }
  }

  .arrow {
    font-size: 36rpx;
    color: $primary-color;
    font-weight: 300;
  }
}
</style>
