<template>
  <view class="timeline">
    <view
      v-for="(item, index) in list"
      :key="index"
      class="timeline-item"
      :class="{
        completed: item.isCompleted,
        active: item.isCurrent,
        pending: !item.isCompleted && !item.isCurrent
      }"
    >
      <!-- 节点 -->
      <view class="dot">
        <view v-if="item.isCompleted" class="check-icon">✓</view>
      </view>

      <!-- 连接线 -->
      <view v-if="index < list.length - 1" class="line"></view>

      <!-- 内容 -->
      <view class="content">
        <text class="step-name">{{ item.stepName }}</text>
        <text v-if="item.isCompleted" class="time">{{ item.createTime }}</text>
        <text v-if="item.description" class="description">{{ item.description }}</text>
        <view v-if="item.imageUrls && item.imageUrls.length > 0" class="images">
          <image
            v-for="(img, i) in item.imageUrls"
            :key="i"
            :src="img"
            mode="aspectFill"
            @click="previewImage(item.imageUrls, i)"
          />
        </view>
      </view>
    </view>
  </view>
</template>

<script setup>
defineProps({
  list: {
    type: Array,
    default: () => []
  }
})

// 图片预览
const previewImage = (urls, current) => {
  uni.previewImage({
    urls,
    current
  })
}
</script>

<style lang="scss" scoped>
.timeline {
  padding: 20rpx;
}

.timeline-item {
  position: relative;
  padding-left: 50rpx;
  padding-bottom: 40rpx;

  &.completed .dot {
    background: #52c41a;
  }

  &.active .dot {
    background: #1890ff;
    animation: pulse 1.5s infinite;
  }

  &.pending .dot {
    background: #d9d9d9;
  }

  &:last-child {
    padding-bottom: 0;

    .line {
      display: none;
    }
  }
}

.dot {
  position: absolute;
  left: 0;
  top: 0;
  width: 24rpx;
  height: 24rpx;
  border-radius: 50%;
  background: #1890ff;
  display: flex;
  align-items: center;
  justify-content: center;

  .check-icon {
    color: #fff;
    font-size: 16rpx;
    font-weight: bold;
  }
}

.line {
  position: absolute;
  left: 11rpx;
  top: 24rpx;
  width: 2rpx;
  height: calc(100% + 16rpx);
  background: #e8e8e8;
}

.content {
  .step-name {
    display: block;
    font-size: 28rpx;
    color: #333;
    font-weight: 500;
  }

  .time {
    display: block;
    font-size: 24rpx;
    color: #999;
    margin-top: 8rpx;
  }

  .description {
    display: block;
    font-size: 26rpx;
    color: #666;
    margin-top: 10rpx;
  }

  .images {
    display: flex;
    flex-wrap: wrap;
    gap: 16rpx;
    margin-top: 16rpx;

    image {
      width: 140rpx;
      height: 140rpx;
      border-radius: 8rpx;
    }
  }
}

@keyframes pulse {
  0%,
  100% {
    transform: scale(1);
  }
  50% {
    transform: scale(1.3);
  }
}
</style>
