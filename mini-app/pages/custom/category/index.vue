<template>
  <view class="category-container">
    <view class="header">
      <text class="title">选择定制品类</text>
      <text class="desc">选择您需要定制的类型</text>
    </view>

    <view class="category-list">
      <view
        v-for="item in categories"
        :key="item.categoryId"
        class="category-item"
        @click="selectCategory(item)"
      >
        <image :src="item.icon" mode="aspectFill" class="category-icon" />
        <view class="category-info">
          <text class="category-name">{{ item.name }}</text>
          <text class="category-desc">{{ item.description }}</text>
        </view>
        <text class="arrow">></text>
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
  background: #f8f8f8;
}

.header {
  background: #fff;
  padding: 40rpx 30rpx;

  .title {
    display: block;
    font-size: 40rpx;
    font-weight: bold;
    color: #333;
    margin-bottom: 16rpx;
  }

  .desc {
    font-size: 28rpx;
    color: #999;
  }
}

.category-list {
  background: #fff;
}

.category-item {
  display: flex;
  align-items: center;
  padding: 30rpx;
  border-bottom: 1rpx solid #f0f0f0;

  &:last-child {
    border-bottom: none;
  }

  .category-icon {
    width: 120rpx;
    height: 120rpx;
    border-radius: 12rpx;
    margin-right: 24rpx;
    background: #f8f8f8;
  }

  .category-info {
    flex: 1;

    .category-name {
      display: block;
      font-size: 32rpx;
      font-weight: 500;
      color: #333;
      margin-bottom: 8rpx;
    }

    .category-desc {
      font-size: 24rpx;
      color: #999;
    }
  }

  .arrow {
    font-size: 32rpx;
    color: #ccc;
  }
}
</style>
