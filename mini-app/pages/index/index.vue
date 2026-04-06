<template>
  <view class="index-container">
    <!-- 顶部品牌介绍 -->
    <view class="brand-header">
      <text class="brand-title">ZeHana</text>
      <text class="brand-subtitle">独立设计师工作室</text>
    </view>

    <!-- 极简轮播 Banner -->
    <view class="banner">
      <swiper class="banner-swiper" circular autoplay interval="4000" duration="800">
        <swiper-item v-for="(item, index) in banners" :key="index">
          <view class="banner-image-wrapper">
            <image :src="item.image" mode="aspectFill" class="banner-img" />
            <view class="banner-mask"></view>
            <view class="banner-text-box">
              <text class="banner-label">{{ item.label }}</text>
              <text class="banner-headline">{{ item.headline }}</text>
            </view>
          </view>
        </swiper-item>
      </swiper>
    </view>

    <!-- 典雅入口 -->
    <view class="entry-list">
      <view class="entry-card" @click="goTo('/pages/custom/category/index')">
        <text class="entry-en">专属定制</text>
        <text class="entry-cn">发起私人定制</text>
        <text class="entry-arrow">→</text>
      </view>
      <view class="entry-card" @click="goTo('/pages/order/list/index')">
        <text class="entry-en">我的订单</text>
        <text class="entry-cn">订单进度查询</text>
        <text class="entry-arrow">→</text>
      </view>
    </view>

    <!-- 经典作品集瀑布流 (模拟) -->
    <view class="portfolio-section">
      <view class="section-title-wrap">
        <text class="section-title">往期作品大赏</text>
        <text class="section-desc">ZeHana 过往经典设计精粹</text>
      </view>
      
      <view class="waterfall">
        <view class="waterfall-col" v-for="(col, colIndex) in splitPortfolios" :key="colIndex">
          <view 
            class="portfolio-card" 
            v-for="item in col" 
            :key="item.portfolioId"
            @click="goToDetail(item.portfolioId)"
          >
            <!-- 若无图则用模拟的高定灰绿色块占位 -->
            <view class="img-placeholder" v-if="!item.coverUrl">
              <text class="placeholder-text">ZeHana</text>
            </view>
            <image v-else :src="item.coverUrl" mode="widthFix" class="portfolio-img"></image>
            
            <view class="portfolio-info">
              <text class="p-title">{{ item.title }}</text>
              <view class="p-bottom">
                <text class="p-category">高级定制</text>
                <text class="p-views">{{ item.viewCount || 0 }} 次浏览</text>
              </view>
            </view>
          </view>
        </view>
      </view>
    <!-- 全局私人管家悬浮按钮 -->
    <view class="floating-chat" @click="goTo('/pages/chat/index')">
      <text class="chat-icon">✉</text>
    </view>
  </view>
</template>

<script setup>
import { ref, computed } from 'vue'
import { onShow, onLoad } from '@dcloudio/uni-app'
import { getPortfolioList } from '@/api/portfolio'

// 新生成的绝美高定绿调展示图
const banners = ref([
  { image: '/static/images/zehana_couture_1774340712019.png', label: '2026 高定系列', headline: '静谧奢华' },
  { image: '/static/images/zehana_leather_1774340726407.png', label: '手工皮具', headline: '永恒优雅' }
])

const portfolios = ref([])

// 把数据平分为两列，做简单的瀑布流
const splitPortfolios = computed(() => {
  const col1 = []
  const col2 = []
  portfolios.value.forEach((item, index) => {
    if (index % 2 === 0) col1.push(item)
    else col2.push(item)
  })
  return [col1, col2]
})

const tabBarPages = ['/pages/index/index', '/pages/order/list/index', '/pages/user/index']

const goTo = (url) => {
  if (tabBarPages.includes(url)) {
    uni.switchTab({ url })
  } else {
    uni.navigateTo({ url })
  }
}

const goToDetail = (id) => {
  uni.navigateTo({ url: `/pages/portfolio/detail/index?id=${id}` })
}

const fetchPortfolios = async () => {
  try {
    const data = await getPortfolioList()
    // 后端返回格式可能是 { list: [...] } 或直接是 [...]
    portfolios.value = (data && data.list) ? data.list : (Array.isArray(data) ? data : [])
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
  background: $background-color;
  min-height: 100vh;
  padding-bottom: 60rpx;
}

.brand-header {
  padding: 60rpx 40rpx 30rpx;
  display: flex;
  flex-direction: column;
  align-items: center;
  background-color: $white;
  letter-spacing: 4rpx;

  .brand-title {
    font-size: 56rpx;
    font-weight: 300;
    color: $primary-color;
    font-family: 'Times New Roman', serif;
  }
  .brand-subtitle {
    margin-top: 12rpx;
    font-size: 20rpx;
    color: $text-color-light;
    letter-spacing: 4rpx;
  }
}

.banner {
  height: 800rpx;
  width: 100%;
  
  .banner-swiper {
    height: 100%;
  }

  .banner-image-wrapper {
    position: relative;
    width: 100%;
    height: 100%;

    .banner-img {
      width: 100%;
      height: 100%;
    }

    .banner-mask {
      position: absolute;
      top: 0; left: 0; right: 0; bottom: 0;
      background: linear-gradient(to bottom, rgba(0,0,0,0.1), rgba(0,0,0,0.6));
    }

    .banner-text-box {
      position: absolute;
      bottom: 80rpx;
      left: 40rpx;
      display: flex;
      flex-direction: column;
      
      .banner-label {
        font-size: 20rpx;
        color: rgba(255,255,255,0.8);
        letter-spacing: 6rpx;
        margin-bottom: 12rpx;
      }
      .banner-headline {
        font-size: 48rpx;
        color: #fff;
        font-weight: 300;
        letter-spacing: 4rpx;
      }
    }
  }
}

.entry-list {
  padding: 40rpx 40rpx;
  display: flex;
  gap: 30rpx;
  background-color: $white;

  .entry-card {
    flex: 1;
    background: #fdfdfd;
    border: 1px solid $border-color;
    padding: 40rpx 30rpx;
    display: flex;
    flex-direction: column;
    position: relative;
    box-shadow: 0 4rpx 20rpx rgba(0,0,0,0.02);
    transition: all 0.3s ease;

    .entry-en {
      font-size: 20rpx;
      color: $text-color-light;
      letter-spacing: 2rpx;
      margin-bottom: 8rpx;
    }
    .entry-cn {
      font-size: 32rpx;
      color: $text-color;
      font-weight: 400;
    }
    .entry-arrow {
      position: absolute;
      bottom: 40rpx;
      right: 30rpx;
      color: $primary-color;
      font-size: 36rpx;
      font-weight: 300;
    }
  }
}

.portfolio-section {
  padding: 60rpx 30rpx;

  .section-title-wrap {
    display: flex;
    flex-direction: column;
    align-items: center;
    margin-bottom: 40rpx;
  }


    .section-title {
      font-size: 32rpx;
      font-weight: 400;
      color: $text-color;
      letter-spacing: 4rpx;
    }
    .section-desc {
      font-size: 22rpx;
      color: $text-color-light;
      margin-top: 10rpx;
      letter-spacing: 2rpx;
    }
  }

  .waterfall {
    display: flex;
    justify-content: space-between;
    align-items: flex-start;

    .waterfall-col {
      width: 48%;
      display: flex;
      flex-direction: column;
      gap: 30rpx;
    }
  }
}

.portfolio-card {
  background: $white;
  border-radius: $border-radius-sm;
  overflow: hidden;
  box-shadow: 0 6rpx 24rpx rgba(0,0,0,0.04);
  
  .img-placeholder {
    width: 100%;
    height: 480rpx; 
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

  .portfolio-img {
    width: 100%;
    display: block; 
  }

  .portfolio-info {
    padding: 24rpx 20rpx;

    .p-title {
      font-size: 26rpx;
      color: $text-color;
      font-weight: 500;
      line-height: 1.4;
      display: block;
      margin-bottom: 16rpx;
    }

    .p-bottom {
      display: flex;
      justify-content: space-between;
      align-items: center;
      
      .p-category {
        font-size: 20rpx;
        color: $primary-color;
        border: 1px solid rgba(74, 93, 78, 0.3);
        padding: 2rpx 12rpx;
        border-radius: 4rpx;
      }
      .p-views {
        font-size: 20rpx;
        color: $text-color-light;
      }
    }
  }
}
</style>

<style lang="scss" scoped>
.floating-chat {
  position: fixed;
  right: 40rpx;
  bottom: 160rpx;
  width: 100rpx;
  height: 100rpx;
  background: #1a1a1a;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 10rpx 30rpx rgba(0,0,0,0.15);
  z-index: 999;
  transition: transform 0.3s ease;

  &:active {
    transform: scale(0.9);
  }

  .chat-icon {
    color: #fff;
    font-size: 48rpx;
  }
}
</style>
