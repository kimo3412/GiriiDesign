<template>
  <view class="app">
    <!-- 应用内容 -->
  </view>
</template>

<script setup>
import { onLaunch, onShow, onHide } from '@dcloudio/uni-app'

onLaunch(() => {
  console.log('App Launch')
})

onShow(() => {
  console.log('App Show')
})

onHide(() => {
  console.log('App Hide')
})
</script>

<style lang="scss">
@import '@/uni.scss';

.app {
  font-size: 28rpx;
  color: #333;
}
</style>
