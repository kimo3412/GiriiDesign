<template>
  <view class="category-container">
    <!-- 顶部品牌区 -->
    <view class="header">
      <text class="brand">ZeHana</text>
      <text class="title">专属定制</text>
      <text class="subtitle">选择您期待的定制形式，开启专属之旅</text>
    </view>

    <!-- 品类卡片列表 -->
    <view class="category-list" v-if="categories.length > 0">
      <view
        v-for="(item, index) in categories"
        :key="item.categoryId"
        class="category-card"
        :class="'card-theme-' + (index % 3)"
        @click="selectCategory(item)"
      >
        <view class="card-bg">
          <view class="card-icon">
            <text class="icon-text">{{ item.name ? item.name.substring(0, 1) : 'Z' }}</text>
          </view>
          <view class="card-content">
            <text class="card-name">{{ item.name }}</text>
            <text class="card-desc">{{ getDesc(item, index) }}</text>
          </view>
          <view class="card-action">
            <text class="action-text">开始定制</text>
            <text class="action-arrow">→</text>
          </view>
        </view>
      </view>
    </view>

    <!-- 空状态 -->
    <view class="empty-state" v-else-if="!loading">
      <text class="empty-icon">✦</text>
      <text class="empty-text">暂无定制方案</text>
      <text class="empty-hint">敬请期待更多定制服务</text>
    </view>

    <!-- 加载中 -->
    <view class="loading-state" v-if="loading">
      <text>加载中...</text>
    </view>

    <!-- 底部说明 -->
    <view class="footer-note" v-if="categories.length > 0">
      <view class="note-line"></view>
      <text class="note-text">所有定制方案均由资深设计师一对一服务</text>
      <view class="note-line"></view>
    </view>
  </view>
</template>

<script setup>
import { ref } from 'vue'
import { onLoad } from '@dcloudio/uni-app'
import { getCategoryList } from '@/api/custom'

const categories = ref([])
const loading = ref(false)

// 品类描述映射（根据品类名称智能匹配）
const descMap = {
  '高级定制': '量身定制专属礼服，展现独特气质',
  '手工皮具': '甄选头层皮料，手工精心打造',
  '数字插画': '将灵感化为艺术，定制专属画作',
}

const defaultDescs = [
  '独立设计师一对一沟通，完整跟进定制细节',
  '从版型到材料都围绕你的需求打磨',
  '小批量手作流程，让作品更有个人印记'
]

const getDesc = (item, index) => {
  if (item.description) return item.description
  for (const [key, value] of Object.entries(descMap)) {
    if (item.name && item.name.includes(key)) return value
  }
  return defaultDescs[index % defaultDescs.length]
}

/**
 * 获取品类列表（动态从数据库加载）
 */
const fetchCategories = async () => {
  loading.value = true
  try {
    const data = await getCategoryList()
    categories.value = data || []
  } catch (err) {
    console.error('获取品类列表失败', err)
    uni.showToast({ title: '获取品类失败', icon: 'none' })
  }
  loading.value = false
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
  background: linear-gradient(180deg, #F5F0EB 0%, #F8F8F8 40%);
  padding: 0 40rpx 60rpx;
}

.header {
  padding: 80rpx 0 50rpx;
  text-align: center;

  .brand {
    display: block;
    font-family: 'Times New Roman', serif;
    font-size: 24rpx;
    color: $primary-color;
    letter-spacing: 10rpx;
    margin-bottom: 20rpx;
    text-transform: uppercase;
  }

  .title {
    display: block;
    font-size: 52rpx;
    font-weight: 300;
    color: $text-color;
    letter-spacing: 8rpx;
    margin-bottom: 20rpx;
  }

  .subtitle {
    display: block;
    font-size: 22rpx;
    color: $text-color-light;
    letter-spacing: 4rpx;
  }
}

.category-list {
  display: flex;
  flex-direction: column;
  gap: 30rpx;
}

.category-card {
  border-radius: 4rpx;
  overflow: hidden;
  box-shadow: 0 8rpx 40rpx rgba(0,0,0,0.06);
  transition: all 0.3s ease;

  &:active {
    transform: scale(0.98);
    box-shadow: 0 4rpx 20rpx rgba(0,0,0,0.08);
  }

  .card-bg {
    padding: 48rpx 40rpx;
    display: flex;
    align-items: center;
  }

  .card-icon {
    width: 110rpx;
    height: 110rpx;
    border-radius: 4rpx;
    display: flex;
    align-items: center;
    justify-content: center;
    margin-right: 36rpx;
    flex-shrink: 0;

    .icon-text {
      font-family: 'Times New Roman', serif;
      font-size: 48rpx;
      font-weight: 300;
    }
  }

  .card-content {
    flex: 1;
    min-width: 0;

    .card-name {
      display: block;
      font-size: 30rpx;
      font-weight: 500;
      letter-spacing: 3rpx;
      margin-bottom: 12rpx;
    }

    .card-desc {
      display: block;
      font-size: 22rpx;
      letter-spacing: 1rpx;
      line-height: 1.5;
    }
  }

  .card-action {
    display: flex;
    flex-direction: column;
    align-items: center;
    margin-left: 20rpx;
    flex-shrink: 0;

    .action-text {
      font-size: 18rpx;
      letter-spacing: 2rpx;
      margin-bottom: 8rpx;
    }

    .action-arrow {
      font-size: 32rpx;
      font-weight: 300;
    }
  }
}

/* 三种主题色交替 */
.card-theme-0 {
  .card-bg { background: #FFFFFF; }
  .card-icon { background: $primary-color; .icon-text { color: #fff; } }
  .card-name { color: $text-color; }
  .card-desc { color: $text-color-light; }
  .action-text { color: $primary-color; }
  .action-arrow { color: $primary-color; }
}

.card-theme-1 {
  .card-bg { background: $primary-color; }
  .card-icon { background: rgba(255,255,255,0.2); .icon-text { color: #fff; } }
  .card-name { color: #fff; }
  .card-desc { color: rgba(255,255,255,0.75); }
  .action-text { color: rgba(255,255,255,0.9); }
  .action-arrow { color: #fff; }
}

.card-theme-2 {
  .card-bg { background: #2C2C2C; }
  .card-icon { background: rgba(255,255,255,0.12); .icon-text { color: rgba(255,255,255,0.9); } }
  .card-name { color: #fff; }
  .card-desc { color: rgba(255,255,255,0.6); }
  .action-text { color: rgba(255,255,255,0.8); }
  .action-arrow { color: #fff; }
}

.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 120rpx 0;

  .empty-icon {
    font-size: 60rpx;
    color: $primary-color;
    margin-bottom: 30rpx;
  }

  .empty-text {
    font-size: 28rpx;
    color: $text-color;
    letter-spacing: 4rpx;
    margin-bottom: 12rpx;
  }

  .empty-hint {
    font-size: 22rpx;
    color: $text-color-light;
    letter-spacing: 2rpx;
  }
}

.loading-state {
  display: flex;
  justify-content: center;
  padding: 120rpx 0;
  font-size: 22rpx;
  color: $text-color-light;
  letter-spacing: 4rpx;
}

.footer-note {
  display: flex;
  align-items: center;
  justify-content: center;
  margin-top: 60rpx;
  gap: 20rpx;

  .note-line {
    width: 60rpx;
    height: 1px;
    background: $border-color;
  }

  .note-text {
    font-size: 20rpx;
    color: $text-color-light;
    letter-spacing: 2rpx;
  }
}
</style>
