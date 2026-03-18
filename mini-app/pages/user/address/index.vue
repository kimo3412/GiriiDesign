<template>
  <view class="address-container">
    <scroll-view scroll-y class="address-list">
      <view v-if="addresses.length > 0" class="address-list-inner">
        <view
          v-for="item in addresses"
          :key="item.addressId"
          class="address-item"
        >
          <view class="address-content" @click="selectAddress(item)">
            <view class="address-header">
              <text class="receiver">{{ item.receiverName }}</text>
              <text class="phone">{{ item.phone }}</text>
              <text v-if="item.isDefault" class="default-tag">默认</text>
            </view>
            <view class="address-detail">
              {{ item.province }}{{ item.city }}{{ item.district }}{{ item.detailAddress }}
            </view>
          </view>
          <view class="address-actions">
            <text class="action-text edit" @click="editAddress(item)">编辑</text>
            <text class="action-text delete" @click="deleteAddress(item.addressId)">删除</text>
          </view>
        </view>
      </view>

      <!-- 空状态 -->
      <view v-else class="empty">
        <text>暂无收货地址</text>
      </view>
    </scroll-view>

    <!-- 新增按钮 -->
    <view class="add-section">
      <button class="add-btn" type="primary" @click="addAddress">新增收货地址</button>
    </view>

    <!-- 地址编辑弹窗 -->
    <view v-if="showModal" class="modal-mask" @click="closeModal">
      <view class="modal-content" @click.stop>
        <view class="modal-header">
          <text>{{ isEdit ? '编辑' : '新增' }}地址</text>
          <text class="close" @click="closeModal">×</text>
        </view>

        <view class="form">
          <view class="form-item">
            <text class="label">收货人</text>
            <input v-model="form.receiverName" placeholder="请输入收货人姓名" class="input" />
          </view>
          <view class="form-item">
            <text class="label">手机号</text>
            <input v-model="form.phone" type="number" maxlength="11" placeholder="请输入手机号" class="input" />
          </view>
          <view class="form-item">
            <text class="label">省份</text>
            <input v-model="form.province" placeholder="请输入省份" class="input" />
          </view>
          <view class="form-item">
            <text class="label">城市</text>
            <input v-model="form.city" placeholder="请输入城市" class="input" />
          </view>
          <view class="form-item">
            <text class="label">区县</text>
            <input v-model="form.district" placeholder="请输入区县" class="input" />
          </view>
          <view class="form-item">
            <text class="label">详细地址</text>
            <textarea v-model="form.detailAddress" placeholder="请输入详细地址" class="textarea" auto-height />
          </view>
          <view class="form-item">
            <view class="switch-row">
              <text class="label">设为默认</text>
              <switch :checked="form.isDefault" @change="form.isDefault = !form.isDefault" color="#07c160" />
            </view>
          </view>
        </view>

        <view class="modal-footer">
          <button class="save-btn" type="primary" @click="saveAddress">保存</button>
        </view>
      </view>
    </view>
  </view>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { onShow } from '@dcloudio/uni-app'
import { getAddressList, addAddress as addApi, updateAddress as updateApi, deleteAddress as deleteApi } from '@/api/user'

const addresses = ref([])
const showModal = ref(false)
const isEdit = ref(false)
const form = reactive({
  addressId: null,
  receiverName: '',
  phone: '',
  province: '',
  city: '',
  district: '',
  detailAddress: '',
  isDefault: false
})

/**
 * 获取地址列表
 */
const fetchAddresses = async () => {
  try {
    const data = await getAddressList()
    addresses.value = data || []
  } catch (err) {
    console.error('获取地址失败', err)
  }
}

/**
 * 选择地址
 */
const selectAddress = (item) => {
  // 如果是选择模式，返回选中地址
  const pages = getCurrentPages()
  if (pages.length > 1) {
    const prevPage = pages[pages.length - 2]
    prevPage.$vm.selectedAddress = item
    uni.navigateBack()
  }
}

/**
 * 新增地址
 */
const addAddress = () => {
  isEdit.value = false
  resetForm()
  showModal.value = true
}

/**
 * 编辑地址
 */
const editAddress = (item) => {
  isEdit.value = true
  Object.assign(form, item)
  showModal.value = true
}

/**
 * 删除地址
 */
const deleteAddress = async (id) => {
  uni.showModal({
    title: '提示',
    content: '确定要删除该地址吗？',
    success: async (res) => {
      if (res.confirm) {
        try {
          await deleteApi(id)
          uni.showToast({ title: '删除成功', icon: 'success' })
          fetchAddresses()
        } catch (err) {
          uni.showToast({ title: '删除失败', icon: 'none' })
        }
      }
    }
  })
}

/**
 * 保存地址
 */
const saveAddress = async () => {
  if (!form.receiverName || !form.phone || !form.detailAddress) {
    uni.showToast({ title: '请填写完整信息', icon: 'none' })
    return
  }

  try {
    if (isEdit.value) {
      await updateApi(form.addressId, form)
    } else {
      await addApi(form)
    }
    uni.showToast({ title: '保存成功', icon: 'success' })
    closeModal()
    fetchAddresses()
  } catch (err) {
    uni.showToast({ title: '保存失败', icon: 'none' })
  }
}

/**
 * 重置表单
 */
const resetForm = () => {
  form.addressId = null
  form.receiverName = ''
  form.phone = ''
  form.province = ''
  form.city = ''
  form.district = ''
  form.detailAddress = ''
  form.isDefault = false
}

/**
 * 关闭弹窗
 */
const closeModal = () => {
  showModal.value = false
  resetForm()
}

onShow(() => {
  fetchAddresses()
})
</script>

<style lang="scss" scoped>
.address-container {
  height: 100vh;
  display: flex;
  flex-direction: column;
  background: #f8f8f8;
}

.address-list {
  flex: 1;
}

.address-list-inner {
  padding: 20rpx;
}

.address-item {
  background: #fff;
  border-radius: 12rpx;
  padding: 24rpx;
  margin-bottom: 20rpx;
}

.address-header {
  display: flex;
  align-items: center;
  margin-bottom: 12rpx;

  .receiver {
    font-size: 30rpx;
    font-weight: 500;
    color: #333;
    margin-right: 20rpx;
  }

  .phone {
    font-size: 28rpx;
    color: #666;
  }

  .default-tag {
    margin-left: 16rpx;
    padding: 4rpx 12rpx;
    font-size: 22rpx;
    color: #07c160;
    background: rgba(7, 193, 96, 0.1);
    border-radius: 4rpx;
  }
}

.address-detail {
  font-size: 26rpx;
  color: #666;
  line-height: 1.5;
}

.address-actions {
  display: flex;
  justify-content: flex-end;
  margin-top: 20rpx;
  padding-top: 20rpx;
  border-top: 1rpx solid #f5f5f5;

  .action-text {
    font-size: 26rpx;
    margin-left: 30rpx;

    &.edit {
      color: #07c160;
    }

    &.delete {
      color: #e74c3c;
    }
  }
}

.empty {
  display: flex;
  justify-content: center;
  align-items: center;
  height: 400rpx;
  font-size: 28rpx;
  color: #999;
}

.add-section {
  padding: 20rpx 30rpx;
  padding-bottom: calc(20rpx + env(safe-area-inset-bottom));
  background: #fff;
}

.add-btn {
  width: 100%;
  height: 88rpx;
  background: #07c160;
  color: #fff;
  font-size: 32rpx;
  border-radius: 44rpx;
  border: none;

  &::after {
    border: none;
  }
}

/* 弹窗 */
.modal-mask {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: flex-end;
  z-index: 100;
}

.modal-content {
  width: 100%;
  max-height: 85vh;
  background: #fff;
  border-radius: 24rpx 24rpx 0 0;
  overflow: hidden;
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 30rpx;
  border-bottom: 1rpx solid #f5f5f5;
  font-size: 32rpx;
  font-weight: bold;

  .close {
    font-size: 44rpx;
    color: #999;
  }
}

.form {
  padding: 30rpx;
  max-height: 60vh;
  overflow-y: auto;
}

.form-item {
  margin-bottom: 30rpx;

  .label {
    display: block;
    font-size: 28rpx;
    color: #333;
    margin-bottom: 16rpx;
  }

  .input {
    border: 1rpx solid #e5e5e5;
    border-radius: 8rpx;
    padding: 20rpx;
    font-size: 28rpx;
  }

  .textarea {
    border: 1rpx solid #e5e5e5;
    border-radius: 8rpx;
    padding: 20rpx;
    font-size: 28rpx;
    width: 100%;
    box-sizing: border-box;
  }

  .switch-row {
    display: flex;
    justify-content: space-between;
    align-items: center;
  }
}

.modal-footer {
  padding: 20rpx 30rpx;
  padding-bottom: calc(20rpx + env(safe-area-inset-bottom));
  border-top: 1rpx solid #f5f5f5;
}

.save-btn {
  width: 100%;
  height: 88rpx;
  background: #07c160;
  color: #fff;
  font-size: 32rpx;
  border-radius: 44rpx;
  border: none;

  &::after {
    border: none;
  }
}
</style>
