<template>
  <view class="profile-container">
    <!-- 标题区域 -->
    <view class="header-section" v-if="isSetupMode">
      <text class="header-title">完善您的资料</text>
      <text class="header-desc">为了更好地为您服务，请完善以下信息</text>
    </view>

    <!-- 头像 -->
    <view class="avatar-section" @click="changeAvatar">
      <text class="label">头像</text>
      <view class="avatar-right">
        <image v-if="form.avatarUrl" class="avatar" :src="form.avatarUrl" mode="aspectFill" />
        <view v-else class="avatar-placeholder">Z</view>
        <text class="arrow">></text>
      </view>
    </view>

    <!-- 表单 -->
    <view class="form-section">
      <view class="form-item">
        <text class="label">昵称</text>
        <input v-model="form.nickname" placeholder="请输入您的称呼" class="input" maxlength="20" />
      </view>
      <view class="form-item">
        <text class="label">手机号</text>
        <view class="phone-wrap" v-if="!form.phone">
          <button class="phone-btn" open-type="getPhoneNumber" @getphonenumber="onGetPhoneNumber">
            微信一键授权
          </button>
        </view>
        <view class="phone-display" v-else>
          <text class="phone-text">{{ form.phone }}</text>
          <text class="phone-change" @click="clearPhone">更换</text>
        </view>
      </view>
    </view>

    <!-- 保存按钮 -->
    <view class="save-section">
      <button class="save-btn" @click="handleSave">
        {{ isSetupMode ? '开始探索 ZeHana' : '保存' }}
      </button>
      <text class="skip-text" v-if="isSetupMode" @click="handleSkip">稍后再说</text>
    </view>
  </view>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { onLoad, onShow } from '@dcloudio/uni-app'
import { getUserInfo, updateUserInfo as updateApi } from '@/api/user'
import { uploadFile } from '@/api/upload'
import { useUserStore } from '@/store/user'
import storage from '@/utils/storage'

const userStore = useUserStore()

const isSetupMode = ref(false)

const form = reactive({
  avatarUrl: '',
  nickname: '',
  phone: ''
})

onLoad((options) => {
  if (options.mode === 'setup') {
    isSetupMode.value = true
    // 设置导航标题
    uni.setNavigationBarTitle({ title: '完善资料' })
  }
})

/**
 * 获取用户信息
 */
const fetchUserInfo = async () => {
  try {
    const data = await getUserInfo()
    if (data) {
      form.avatarUrl = data.avatarUrl || ''
      form.nickname = data.nickname || ''
      form.phone = data.phone || ''
    }
  } catch (err) {
    // 降级: 使用本地缓存
    const info = storage.getUserInfo()
    if (info) {
      form.avatarUrl = info.avatarUrl || ''
      form.nickname = info.nickname || ''
      form.phone = info.phone || ''
    }
  }
}

/**
 * 更换头像（选择图片 → 上传 → 回填 URL）
 */
const changeAvatar = async () => {
  uni.chooseImage({
    count: 1,
    sizeType: ['compressed'],
    sourceType: ['album', 'camera'],
    success: async (res) => {
      const tempPath = res.tempFilePaths[0]
      uni.showLoading({ title: '上传中...' })
      try {
        const url = await uploadFile(tempPath)
        form.avatarUrl = url
        uni.hideLoading()
      } catch (err) {
        uni.hideLoading()
        // 上传失败时用本地路径做临时展示
        form.avatarUrl = tempPath
        console.error('头像上传失败', err)
      }
    }
  })
}

/**
 * 微信一键获取手机号
 */
const onGetPhoneNumber = (e) => {
  if (e.detail.errMsg === 'getPhoneNumber:ok') {
    // 个人开发者无法调用微信手机号解密（需企业认证）
    // 这里降级为手动输入
    uni.showModal({
      title: '输入手机号',
      editable: true,
      placeholderText: '请输入11位手机号',
      confirmColor: '#4A5D4E',
      success: (res) => {
        if (res.confirm && res.content) {
          const phone = res.content.trim()
          if (/^1\d{10}$/.test(phone)) {
            form.phone = phone
          } else {
            uni.showToast({ title: '请输入正确的手机号', icon: 'none' })
          }
        }
      }
    })
  } else {
    // 用户拒绝授权，提供手动输入
    uni.showModal({
      title: '输入手机号',
      editable: true,
      placeholderText: '请输入11位手机号',
      confirmColor: '#4A5D4E',
      success: (res) => {
        if (res.confirm && res.content) {
          const phone = res.content.trim()
          if (/^1\d{10}$/.test(phone)) {
            form.phone = phone
          } else {
            uni.showToast({ title: '请输入正确的手机号', icon: 'none' })
          }
        }
      }
    })
  }
}

/**
 * 清除手机号
 */
const clearPhone = () => {
  form.phone = ''
}

/**
 * 保存资料
 */
const handleSave = async () => {
  if (!form.nickname || !form.nickname.trim()) {
    uni.showToast({ title: '请输入昵称', icon: 'none' })
    return
  }

  uni.showLoading({ title: '保存中...' })
  try {
    await updateApi({
      nickname: form.nickname.trim(),
      avatarUrl: form.avatarUrl,
      phone: form.phone
    })

    // 同步更新本地缓存和 store
    const updatedInfo = {
      ...storage.getUserInfo(),
      nickname: form.nickname.trim(),
      avatarUrl: form.avatarUrl,
      phone: form.phone
    }
    userStore.setUserInfo(updatedInfo)

    uni.hideLoading()
    uni.showToast({ title: '保存成功', icon: 'success' })

    setTimeout(() => {
      if (isSetupMode.value) {
        uni.switchTab({ url: '/pages/index/index' })
      } else {
        uni.navigateBack()
      }
    }, 1500)
  } catch (err) {
    uni.hideLoading()
    uni.showToast({ title: '保存失败', icon: 'none' })
  }
}

/**
 * 跳过完善（仅新用户首次出现）
 */
const handleSkip = () => {
  uni.switchTab({ url: '/pages/index/index' })
}

onShow(() => {
  fetchUserInfo()
})
</script>

<style lang="scss" scoped>
.profile-container {
  min-height: 100vh;
  background: $background-color;
}

.header-section {
  padding: 60rpx 40rpx 40rpx;
  background: $white;
  margin-bottom: 20rpx;
  text-align: center;

  .header-title {
    display: block;
    font-size: 36rpx;
    font-weight: 300;
    color: $text-color;
    letter-spacing: 4rpx;
    margin-bottom: 16rpx;
  }

  .header-desc {
    display: block;
    font-size: 22rpx;
    color: $text-color-light;
    letter-spacing: 2rpx;
  }
}

.avatar-section {
  display: flex;
  justify-content: space-between;
  align-items: center;
  background: $white;
  padding: 30rpx 40rpx;
  margin-bottom: 20rpx;

  .label {
    font-size: 26rpx;
    color: $text-color;
    letter-spacing: 2rpx;
  }

  .avatar-right {
    display: flex;
    align-items: center;
    gap: 16rpx;

    .avatar {
      width: 100rpx;
      height: 100rpx;
      border-radius: 50%;
      border: 1px solid $border-color;
    }

    .avatar-placeholder {
      width: 100rpx;
      height: 100rpx;
      border-radius: 50%;
      background: $primary-color;
      color: $white;
      display: flex;
      align-items: center;
      justify-content: center;
      font-family: 'Times New Roman', serif;
      font-size: 48rpx;
    }

    .arrow {
      font-size: 28rpx;
      color: #ccc;
    }
  }
}

.form-section {
  background: $white;
  margin-bottom: 20rpx;
}

.form-item {
  display: flex;
  align-items: center;
  padding: 30rpx 40rpx;
  border-bottom: 1rpx solid #f0f0f0;

  &:last-child {
    border-bottom: none;
  }

  .label {
    width: 160rpx;
    font-size: 26rpx;
    color: $text-color;
    letter-spacing: 2rpx;
    flex-shrink: 0;
  }

  .input {
    flex: 1;
    font-size: 26rpx;
    text-align: right;
    letter-spacing: 2rpx;
    color: $text-color;
  }

  .phone-wrap {
    flex: 1;
    display: flex;
    justify-content: flex-end;
  }

  .phone-btn {
    font-size: 22rpx;
    background: $text-color;
    color: $white;
    padding: 12rpx 32rpx;
    border-radius: 0;
    letter-spacing: 2rpx;
    line-height: 1.6;
    border: none;

    &::after {
      border: none;
    }
  }

  .phone-display {
    flex: 1;
    display: flex;
    justify-content: flex-end;
    align-items: center;
    gap: 20rpx;

    .phone-text {
      font-size: 26rpx;
      color: $text-color;
      letter-spacing: 2rpx;
    }

    .phone-change {
      font-size: 22rpx;
      color: $primary-color;
      text-decoration: underline;
    }
  }
}

.save-section {
  padding: 60rpx 40rpx 30rpx;
  display: flex;
  flex-direction: column;
  align-items: center;
}

.save-btn {
  width: 100%;
  height: 96rpx;
  line-height: 96rpx;
  background: $text-color;
  color: $white;
  font-size: 24rpx;
  letter-spacing: 6rpx;
  border-radius: 0;
  border: none;

  &::after {
    border: none;
  }
}

.skip-text {
  display: block;
  margin-top: 30rpx;
  font-size: 22rpx;
  color: $text-color-light;
  letter-spacing: 2rpx;
  text-decoration: underline;
}
</style>
