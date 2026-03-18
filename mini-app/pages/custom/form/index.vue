<template>
  <view class="form-container">
    <view class="header">
      <text class="title">填写定制需求</text>
      <text class="category">{{ categoryName }}</text>
    </view>

    <!-- 动态表单 -->
    <view class="form-content">
      <view v-for="field in schema" :key="field.fieldId" class="form-item">
        <!-- 必填标记 -->
        <text v-if="field.isRequired" class="required">*</text>
        <text class="label">{{ field.fieldLabel }}</text>

        <!-- 文本输入 -->
        <input
          v-if="field.fieldType === 'text'"
          v-model="formData[field.fieldName]"
          :placeholder="'请输入' + field.fieldLabel"
          class="input"
        />

        <!-- 数字输入 -->
        <input
          v-if="field.fieldType === 'number'"
          type="digit"
          v-model="formData[field.fieldName]"
          :placeholder="'请输入' + field.fieldLabel"
          class="input"
        />

        <!-- 多行文本 -->
        <textarea
          v-if="field.fieldType === 'textarea'"
          v-model="formData[field.fieldName]"
          :placeholder="'请输入' + field.fieldLabel"
          class="textarea"
          auto-height
        />

        <!-- 下拉选择 -->
        <picker
          v-if="field.fieldType === 'select'"
          :value="getSelectIndex(field)"
          :range="field.options"
          range-key="label"
          @change="(e) => onSelectChange(field, e)"
        >
          <view class="picker">
            {{ getSelectLabel(field) || '请选择' + field.fieldLabel }}
          </view>
        </picker>

        <!-- 单选 -->
        <radio-group
          v-if="field.fieldType === 'radio'"
          @change="(e) => formData[field.fieldName] = e.detail.value"
        >
          <label v-for="option in field.options" :key="option.value" class="radio-item">
            <radio :value="option.value" :checked="formData[field.fieldName] === option.value" />
            <text>{{ option.label }}</text>
          </label>
        </radio-group>

        <!-- 复选框 -->
        <checkbox-group
          v-if="field.fieldType === 'checkbox'"
          @change="(e) => formData[field.fieldName] = e.detail.value"
        >
          <label v-for="option in field.options" :key="option.value" class="checkbox-item">
            <checkbox :value="option.value" :checked="(formData[field.fieldName] || []).includes(option.value)" />
            <text>{{ option.label }}</text>
          </label>
        </checkbox-group>

        <!-- 图片上传 -->
        <view v-if="field.fieldType === 'image'" class="image-upload">
          <view
            v-for="(img, index) in (formData[field.fieldName] || [])"
            :key="index"
            class="image-item"
          >
            <image :src="img" mode="aspectFill" />
            <view class="delete-btn" @click="removeImage(field.fieldName, index)">×</view>
          </view>
          <view
            v-if="!field.maxImages || (formData[field.fieldName] || []).length < (field.maxImages || 9)"
            class="add-btn"
            @click="uploadImage(field.fieldName)"
          >
            <text>+</text>
          </view>
          <text class="upload-tip">最多上传 {{ field.maxImages || 9 }} 张图片</text>
        </view>
      </view>

      <!-- 需求描述 -->
      <view class="form-item">
        <text class="label">其他需求描述</text>
        <textarea
          v-model="description"
          placeholder="请详细描述您的定制需求..."
          class="textarea"
          auto-height
        />
      </view>
    </view>

    <!-- 提交按钮 -->
    <view class="submit-section">
      <button class="submit-btn" type="primary" @click="handleSubmit">提交意向</button>
    </view>
  </view>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { onLoad } from '@dcloudio/uni-app'
import { getFormSchema, submitRequest } from '@/api/custom'
import { uploadFile } from '@/api/upload'

const categoryId = ref(0)
const categoryName = ref('')
const schema = ref([])
const formData = reactive({})
const description = ref('')

/**
 * 获取表单 Schema
 */
const fetchSchema = async () => {
  try {
    const data = await getFormSchema(categoryId.value)
    schema.value = data || []
  } catch (err) {
    console.error('获取表单配置失败', err)
    uni.showToast({ title: '获取表单失败', icon: 'none' })
  }
}

/**
 * 获取下拉选择索引
 */
const getSelectIndex = (field) => {
  const value = formData[field.fieldName]
  return field.options?.findIndex(o => o.value === value) || -1
}

/**
 * 获取下拉显示文本
 */
const getSelectLabel = (field) => {
  const value = formData[field.fieldName]
  const option = field.options?.find(o => o.value === value)
  return option?.label
}

/**
 * 下拉选择变化
 */
const onSelectChange = (field, e) => {
  const index = e.detail.value
  formData[field.fieldName] = field.options[index].value
}

/**
 * 上传图片
 */
const uploadImage = async (fieldName) => {
  // 找到对应的字段配置
  const field = schema.value.find(f => f.fieldName === fieldName)
  const images = formData[fieldName] || []

  const [err, res] = await uni.chooseImage({
    count: (field?.maxImages || 9) - images.length,
    sizeType: ['compressed'],
    sourceType: ['album', 'camera']
  })

  if (err) return

  // 上传到服务器
  uni.showLoading({ title: '上传中...' })
  try {
    for (const path of res.tempFilePaths) {
      const url = await uploadFile(path)
      images.push(url)
    }
    formData[fieldName] = [...images]
  } catch (err) {
    uni.showToast({ title: '上传失败', icon: 'none' })
  }
  uni.hideLoading()
}

/**
 * 删除图片
 */
const removeImage = (fieldName, index) => {
  const images = formData[fieldName]
  images.splice(index, 1)
}

/**
 * 提交表单
 */
const handleSubmit = async () => {
  // 验证必填项
  for (const field of schema.value) {
    if (field.isRequired && !formData[field.fieldName]) {
      uni.showToast({ title: `请填写${field.fieldLabel}`, icon: 'none' })
      return
    }
  }

  uni.showLoading({ title: '提交中...' })
  try {
    await submitRequest({
      categoryId: categoryId.value,
      customData: JSON.stringify(formData),
      description: description.value
    })

    uni.hideLoading()
    uni.showToast({ title: '提交成功', icon: 'success' })

    setTimeout(() => {
      uni.switchTab({ url: '/pages/order/list/index' })
    }, 1500)
  } catch (err) {
    uni.hideLoading()
    uni.showToast({ title: err.message || '提交失败', icon: 'none' })
  }
}

onLoad((options) => {
  categoryId.value = Number(options.categoryId) || 0
  categoryName.value = options.categoryName || ''
  uni.setNavigationBarTitle({ title: `定制 - ${categoryName.value}` })
  fetchSchema()
})
</script>

<style lang="scss" scoped>
.form-container {
  min-height: 100vh;
  background: #f8f8f8;
  padding-bottom: 120rpx;
}

.header {
  background: #fff;
  padding: 40rpx 30rpx;
  margin-bottom: 20rpx;

  .title {
    display: block;
    font-size: 40rpx;
    font-weight: bold;
    color: #333;
    margin-bottom: 8rpx;
  }

  .category {
    font-size: 28rpx;
    color: #07c160;
  }
}

.form-content {
  background: #fff;
  padding: 30rpx;
}

.form-item {
  margin-bottom: 36rpx;
}

.required {
  color: #e74c3c;
  margin-right: 8rpx;
}

.label {
  display: block;
  font-size: 28rpx;
  color: #333;
  margin-bottom: 16rpx;
  font-weight: 500;
}

.input {
  border: 1rpx solid #e5e5e5;
  border-radius: 8rpx;
  padding: 20rpx;
  font-size: 28rpx;
  background: #fafafa;
}

.textarea {
  border: 1rpx solid #e5e5e5;
  border-radius: 8rpx;
  padding: 20rpx;
  font-size: 28rpx;
  background: #fafafa;
  width: 100%;
  box-sizing: border-box;
}

.picker {
  border: 1rpx solid #e5e5e5;
  border-radius: 8rpx;
  padding: 20rpx;
  font-size: 28rpx;
  color: #666;
  background: #fafafa;
}

.radio-item,
.checkbox-item {
  display: inline-flex;
  align-items: center;
  margin-right: 30rpx;
  margin-bottom: 16rpx;

  text {
    margin-left: 10rpx;
    font-size: 28rpx;
  }
}

.image-upload {
  display: flex;
  flex-wrap: wrap;
  gap: 20rpx;
}

.image-item {
  position: relative;
  width: 160rpx;
  height: 160rpx;

  image {
    width: 100%;
    height: 100%;
    border-radius: 8rpx;
  }

  .delete-btn {
    position: absolute;
    top: -10rpx;
    right: -10rpx;
    width: 40rpx;
    height: 40rpx;
    background: #e74c3c;
    color: #fff;
    border-radius: 50%;
    text-align: center;
    line-height: 36rpx;
    font-size: 28rpx;
  }
}

.add-btn {
  width: 160rpx;
  height: 160rpx;
  border: 2rpx dashed #ddd;
  border-radius: 8rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 60rpx;
  color: #999;
}

.upload-tip {
  width: 100%;
  font-size: 24rpx;
  color: #999;
  margin-top: 10rpx;
}

.submit-section {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  background: #fff;
  padding: 20rpx 30rpx;
  padding-bottom: calc(20rpx + env(safe-area-inset-bottom));
  box-shadow: 0 -2rpx 10rpx rgba(0, 0, 0, 0.05);
}

.submit-btn {
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
