<template>
  <view class="profile-container">
    <view class="avatar-section" @click="changeAvatar">
      <text class="label">Avatar / 头像</text>
      <view class="avatar-right">
        <image v-if="form.avatar" class="avatar" :src="form.avatar" mode="aspectFill" />
        <view v-else class="avatar-placeholder">Y</view>
        <text class="arrow">></text>
      </view>
    </view>

    <view class="form-section">
      <view class="form-item">
        <text class="label">昵称</text>
        <input v-model="form.nickname" placeholder="请输入昵称" class="input" />
      </view>
      <view class="form-item">
        <text class="label">手机号</text>
        <input v-model="form.phone" type="number" maxlength="11" placeholder="请输入手机号" class="input" disabled />
      </view>
    </view>

    <view class="save-section">
      <button class="save-btn" type="primary" @click="handleSave">保存</button>
    </view>
  </view>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { onShow } from '@dcloudio/uni-app'
import { getUserInfo, updateUserInfo as updateApi } from '@/api/user'
import storage from '@/utils/storage'

const form = reactive({
  avatar: '',
  nickname: '',
  phone: ''
})

/**
 * 获取用户信息
 */
const fetchUserInfo = async () => {
  try {
    const data = await getUserInfo()
    form.avatar = data.avatar || ''
    form.nickname = data.nickname || ''
    form.phone = data.phone || ''
  } catch (err) {
    // 使用本地缓存
    const userInfo = storage.getUserInfo()
    if (userInfo) {
      form.avatar = userInfo.avatar || ''
      form.nickname = userInfo.nickname || ''
      form.phone = userInfo.phone || ''
    }
  }
}

/**
 * 更换头像
 */
const changeAvatar = async () => {
  const [err, res] = await uni.chooseImage({
    count: 1,
    sizeType: ['compressed'],
    sourceType: ['album', 'camera']
  })

  if (err) return

  // 这里应该上传到服务器
  // 简化：直接使用本地路径展示
  form.avatar = res.tempFilePaths[0]
}

/**
 * 保存资料
 */
const handleSave = async () => {
  try {
    await updateApi({
      nickname: form.nickname,
      avatar: form.avatar
    })

    // 更新本地缓存
    storage.setUserInfo({
      ...storage.getUserInfo(),
      nickname: form.nickname,
      avatar: form.avatar
    })

    uni.showToast({ title: '保存成功', icon: 'success' })
    setTimeout(() => {
      uni.navigateBack()
    }, 1500)
  } catch (err) {
    uni.showToast({ title: '保存失败', icon: 'none' })
  }
}

onShow(() => {
  fetchUserInfo()
})
</script>

<style lang="scss" scoped>
.profile-container {
  min-height: 100vh;
  background: #f8f8f8;
}

.avatar-section {
  display: flex;
  justify-content: space-between;
  align-items: center;
  background: #fff;
  padding: 30rpx;
  margin-bottom: 20rpx;

  .label {
    font-size: 30rpx;
    color: #333;
  }

  .avatar-right {
    display: flex;
    align-items: center;

    .avatar {
      width: 100rpx;
      height: 100rpx;
      border-radius: 50rpx;
      margin-right: 10rpx;
    }

    .avatar-placeholder {
      width: 100rpx;
      height: 100rpx;
      border-radius: 50rpx;
      margin-right: 10rpx;
      background: $primary-color;
      color: $white;
      display: flex;
      align-items: center;
      justify-content: center;
      font-family: 'Times New Roman', serif;
      font-size: 50rpx;
    }

    .arrow {
      font-size: 28rpx;
      color: #ccc;
    }
  }
}

.form-section {
  background: #fff;
}

.form-item {
  display: flex;
  align-items: center;
  padding: 30rpx;
  border-bottom: 1rpx solid #f5f5f5;

  &:last-child {
    border-bottom: none;
  }

  .label {
    width: 250rpx;
    font-size: 26rpx;
    color: #333;
    letter-spacing: 2rpx;
  }

  .input {
    flex: 1;
    font-size: 26rpx;
    text-align: right;
    letter-spacing: 2rpx;

    &[disabled] {
      color: #999;
    }
  }
}

.save-section {
  padding: 60rpx 40rpx;
}

.save-btn {
  width: 100%;
  height: 90rpx;
  line-height: 90rpx;
  background: $primary-color;
  color: #fff;
  font-size: 24rpx;
  letter-spacing: 6rpx;
  border-radius: 0;
  border: none;

  &::after {
    border: none;
  }
}
</style>
