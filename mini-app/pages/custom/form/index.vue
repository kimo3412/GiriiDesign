<template>
  <view class="form-page">
    <!-- 顶部进度条 -->
    <view class="progress-bar">
      <view class="progress-fill" :style="{ width: progressPercent + '%' }"></view>
    </view>

    <!-- 品牌头部 -->
    <view class="hero">
      <text class="hero-brand">ZeHana</text>
      <text class="hero-title">{{ categoryName }}</text>
      <text class="hero-subtitle">请填写您的定制需求，我们将为您量身打造</text>
    </view>

    <!-- 分步表单区 -->
    <view class="form-body">
      <!-- 动态字段 -->
      <view v-for="(field, idx) in schema" :key="field.fieldId" class="field-group">
        <view class="field-header">
          <view class="field-number">{{ String(idx + 1).padStart(2, '0') }}</view>
          <view class="field-label-wrap">
            <text class="field-label">{{ field.label }}</text>
            <text v-if="field.unit" class="field-unit">（{{ field.unit }}）</text>
            <text v-if="field.isRequired" class="field-required">必填</text>
          </view>
        </view>

        <view class="field-control">
          <!-- 文本输入 -->
          <input
            v-if="field.fieldType === 'text'"
            v-model="formData[field.fieldKey]"
            :placeholder="field.placeholder || '请输入' + field.label"
            class="ctrl-input"
          />

          <!-- 数字输入 -->
          <view v-if="field.fieldType === 'number'" class="ctrl-number-wrap">
            <input
              type="digit"
              v-model="formData[field.fieldKey]"
              :placeholder="field.placeholder || '请输入'"
              class="ctrl-input"
            />
            <text v-if="field.unit" class="ctrl-unit">{{ field.unit }}</text>
          </view>

          <!-- 多行文本 -->
          <textarea
            v-if="field.fieldType === 'textarea'"
            v-model="formData[field.fieldKey]"
            :placeholder="field.placeholder || '请详细描述...'"
            class="ctrl-textarea"
            :maxlength="500"
            auto-height
          />

          <!-- 日期选择 -->
          <picker
            v-if="field.fieldType === 'date'"
            mode="date"
            :value="formData[field.fieldKey] || ''"
            @change="(e) => formData[field.fieldKey] = e.detail.value"
          >
            <view class="ctrl-picker">
              <text :class="{ placeholder: !formData[field.fieldKey] }">
                {{ formData[field.fieldKey] || '请选择日期' }}
              </text>
              <text class="picker-arrow">▾</text>
            </view>
          </picker>

          <!-- 下拉选择 -->
          <picker
            v-if="field.fieldType === 'select'"
            :value="getSelectIndex(field)"
            :range="field.parsedOptions || []"
            range-key="label"
            @change="(e) => onSelectChange(field, e)"
          >
            <view class="ctrl-picker">
              <text :class="{ placeholder: !getSelectLabel(field) }">
                {{ getSelectLabel(field) || field.placeholder || '请选择' + field.label }}
              </text>
              <text class="picker-arrow">▾</text>
            </view>
          </picker>

          <!-- 单选（标签风格） -->
          <view v-if="field.fieldType === 'radio'" class="ctrl-tags">
            <view
              v-for="option in (field.parsedOptions || [])"
              :key="option.value"
              class="tag-item"
              :class="{ active: formData[field.fieldKey] === option.value }"
              @click="formData[field.fieldKey] = option.value"
            >
              <text>{{ option.label }}</text>
            </view>
          </view>

          <!-- 复选框（标签风格） -->
          <view v-if="field.fieldType === 'checkbox'" class="ctrl-tags">
            <view
              v-for="option in (field.parsedOptions || [])"
              :key="option.value"
              class="tag-item"
              :class="{ active: (formData[field.fieldKey] || []).includes(option.value) }"
              @click="toggleCheckbox(field.fieldKey, option.value)"
            >
              <text>{{ option.label }}</text>
            </view>
          </view>

          <!-- 图片上传 -->
          <view v-if="field.fieldType === 'image'" class="ctrl-images">
            <view
              v-for="(img, index) in (formData[field.fieldKey] || [])"
              :key="index"
              class="img-item"
            >
              <image :src="img" mode="aspectFill" />
              <view class="img-delete" @click="removeImage(field.fieldKey, index)">×</view>
            </view>
            <view
              v-if="(formData[field.fieldKey] || []).length < (field.maxImages || 9)"
              class="img-add"
              @click="uploadImage(field.fieldKey)"
            >
              <text class="img-add-icon">+</text>
              <text class="img-add-text">添加图片</text>
            </view>
          </view>
        </view>
      </view>

      <!-- 分隔 -->
      <view class="divider" v-if="schema.length > 0">
        <view class="divider-line"></view>
        <text class="divider-text">补充说明</text>
        <view class="divider-line"></view>
      </view>

      <!-- 参考图片上传 -->
      <view class="field-group">
        <view class="field-header">
          <view class="field-number">✦</view>
          <view class="field-label-wrap">
            <text class="field-label">参考图片</text>
          </view>
        </view>
        <view class="field-control">
          <view class="ctrl-images">
            <view v-for="(img, index) in refImages" :key="index" class="img-item">
              <image :src="img" mode="aspectFill" />
              <view class="img-delete" @click="refImages.splice(index, 1)">×</view>
            </view>
            <view v-if="refImages.length < 9" class="img-add" @click="chooseRefImages">
              <text class="img-add-icon">+</text>
              <text class="img-add-text">灵感图片</text>
            </view>
          </view>
          <text class="field-hint">上传参考图片有助于设计师理解您的需求</text>
        </view>
      </view>

      <!-- 需求描述 -->
      <view class="field-group">
        <view class="field-header">
          <view class="field-number">✦</view>
          <view class="field-label-wrap">
            <text class="field-label">其他需求</text>
          </view>
        </view>
        <view class="field-control">
          <textarea
            v-model="description"
            placeholder="如有特殊需求、交付时间要求等，请在此说明..."
            class="ctrl-textarea"
            :maxlength="500"
            auto-height
          />
        </view>
      </view>
    </view>

    <!-- 底部提交 -->
    <view class="submit-bar">
      <view class="submit-info">
        <text class="submit-note">提交后设计师将在24小时内与您联系</text>
      </view>
      <button class="submit-btn" :disabled="submitting" @click="handleSubmit">
        {{ submitting ? '提交中...' : '提交定制意向' }}
      </button>
    </view>
  </view>
</template>

<script setup>
import { ref, reactive, computed } from 'vue'
import { onLoad } from '@dcloudio/uni-app'
import { getFormSchema, submitRequest } from '@/api/custom'

const categoryId = ref(0)
const categoryName = ref('')
const schema = ref([])
const formData = reactive({})
const description = ref('')
const refImages = ref([])
const submitting = ref(false)

// 进度百分比
const progressPercent = computed(() => {
  if (schema.value.length === 0) return 0
  const total = schema.value.length
  const filled = schema.value.filter(f => {
    const val = formData[f.fieldKey]
    if (Array.isArray(val)) return val.length > 0
    return val !== undefined && val !== null && val !== ''
  }).length
  return Math.round((filled / total) * 100)
})

/**
 * 获取表单 Schema
 */
const fetchSchema = async () => {
  try {
    const data = await getFormSchema(categoryId.value)
    const list = data || []
    list.forEach(item => {
      // 解析 options JSON 字符串
      if (typeof item.options === 'string' && item.options) {
        try { item.parsedOptions = JSON.parse(item.options) }
        catch { item.parsedOptions = [] }
      } else if (Array.isArray(item.options)) {
        item.parsedOptions = item.options
      } else {
        item.parsedOptions = []
      }
    })
    schema.value = list
  } catch (err) {
    console.error('获取表单配置失败', err)
    uni.showToast({ title: '获取表单失败', icon: 'none' })
  }
}

const getSelectIndex = (field) => {
  const value = formData[field.fieldKey]
  return (field.parsedOptions || []).findIndex(o => o.value === value)
}

const getSelectLabel = (field) => {
  const value = formData[field.fieldKey]
  const option = (field.parsedOptions || []).find(o => o.value === value)
  return option?.label
}

const onSelectChange = (field, e) => {
  const index = e.detail.value
  formData[field.fieldKey] = field.parsedOptions[index].value
}

const toggleCheckbox = (fieldKey, value) => {
  const arr = formData[fieldKey] || []
  const idx = arr.indexOf(value)
  if (idx >= 0) {
    arr.splice(idx, 1)
  } else {
    arr.push(value)
  }
  formData[fieldKey] = [...arr]
}

/**
 * 上传图片
 */
const uploadImage = async (fieldKey) => {
  const images = formData[fieldKey] || []
  uni.chooseImage({
    count: 9 - images.length,
    sizeType: ['compressed'],
    sourceType: ['album', 'camera'],
    success: (res) => {
      // 暂时用本地路径（正式环境需上传到 OSS）
      formData[fieldKey] = [...images, ...res.tempFilePaths]
    }
  })
}

const removeImage = (fieldKey, index) => {
  const images = formData[fieldKey]
  images.splice(index, 1)
}

const chooseRefImages = () => {
  uni.chooseImage({
    count: 9 - refImages.value.length,
    sizeType: ['compressed'],
    sourceType: ['album', 'camera'],
    success: (res) => {
      refImages.value = [...refImages.value, ...res.tempFilePaths]
    }
  })
}

/**
 * 提交表单
 */
const handleSubmit = async () => {
  // 验证必填项
  for (const field of schema.value) {
    if (field.isRequired && !formData[field.fieldKey]) {
      uni.showToast({ title: `请填写${field.label}`, icon: 'none' })
      return
    }
  }

  submitting.value = true
  try {
    await submitRequest({
      categoryId: categoryId.value,
      customData: JSON.stringify(formData),
      imageUrls: JSON.stringify(refImages.value),
      description: description.value
    })

    uni.showToast({ title: '提交成功！', icon: 'success' })
    setTimeout(() => {
      uni.switchTab({ url: '/pages/order/list/index' })
    }, 1500)
  } catch (err) {
    uni.showToast({ title: err.message || '提交失败', icon: 'none' })
  }
  submitting.value = false
}

onLoad((options) => {
  categoryId.value = Number(options.categoryId) || 0
  categoryName.value = options.categoryName || '定制服务'
  uni.setNavigationBarTitle({ title: categoryName.value })
  fetchSchema()
})
</script>

<style lang="scss" scoped>
.form-page {
  min-height: 100vh;
  background: #F5F2EE;
  padding-bottom: 200rpx;
}

/* 进度条 */
.progress-bar {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  height: 4rpx;
  background: rgba(0,0,0,0.05);
  z-index: 100;

  .progress-fill {
    height: 100%;
    background: $primary-color;
    transition: width 0.4s ease;
  }
}

/* 品牌头部 */
.hero {
  padding: 60rpx 40rpx 40rpx;
  text-align: center;

  .hero-brand {
    display: block;
    font-family: 'Times New Roman', serif;
    font-size: 20rpx;
    color: $primary-color;
    letter-spacing: 10rpx;
    text-transform: uppercase;
    margin-bottom: 16rpx;
  }

  .hero-title {
    display: block;
    font-size: 44rpx;
    font-weight: 300;
    color: $text-color;
    letter-spacing: 6rpx;
    margin-bottom: 16rpx;
  }

  .hero-subtitle {
    display: block;
    font-size: 22rpx;
    color: $text-color-light;
    letter-spacing: 2rpx;
  }
}

/* 表单区 */
.form-body {
  margin: 0 30rpx;
}

.field-group {
  background: #fff;
  border-radius: 4rpx;
  padding: 36rpx 32rpx;
  margin-bottom: 20rpx;
  box-shadow: 0 2rpx 16rpx rgba(0,0,0,0.03);
}

.field-header {
  display: flex;
  align-items: flex-start;
  margin-bottom: 24rpx;

  .field-number {
    width: 48rpx;
    height: 48rpx;
    background: $primary-color;
    color: #fff;
    font-size: 20rpx;
    font-family: 'Times New Roman', serif;
    display: flex;
    align-items: center;
    justify-content: center;
    margin-right: 20rpx;
    flex-shrink: 0;
    border-radius: 2rpx;
  }

  .field-label-wrap {
    flex: 1;
    display: flex;
    align-items: center;
    flex-wrap: wrap;
    padding-top: 6rpx;
  }

  .field-label {
    font-size: 28rpx;
    font-weight: 500;
    color: $text-color;
    letter-spacing: 2rpx;
  }

  .field-unit {
    font-size: 22rpx;
    color: $text-color-light;
    margin-left: 4rpx;
  }

  .field-required {
    font-size: 18rpx;
    color: #C4785B;
    background: rgba(196,120,91,0.1);
    padding: 2rpx 12rpx;
    margin-left: 12rpx;
    border-radius: 2rpx;
  }
}

.field-hint {
  display: block;
  font-size: 20rpx;
  color: $text-color-light;
  margin-top: 12rpx;
  letter-spacing: 1rpx;
}

/* 控件样式 */
.ctrl-input {
  border: none;
  border-bottom: 1rpx solid #E8E4E0;
  padding: 16rpx 0;
  font-size: 28rpx;
  color: $text-color;
  background: transparent;
  width: 100%;
}

.ctrl-number-wrap {
  display: flex;
  align-items: center;

  .ctrl-input { flex: 1; }
  .ctrl-unit {
    font-size: 24rpx;
    color: $text-color-light;
    margin-left: 12rpx;
    flex-shrink: 0;
  }
}

.ctrl-textarea {
  border: 1rpx solid #E8E4E0;
  border-radius: 4rpx;
  padding: 24rpx;
  font-size: 26rpx;
  color: $text-color;
  background: #FAFAF8;
  width: 100%;
  box-sizing: border-box;
  min-height: 160rpx;
  line-height: 1.6;
}

.ctrl-picker {
  display: flex;
  align-items: center;
  justify-content: space-between;
  border-bottom: 1rpx solid #E8E4E0;
  padding: 16rpx 0;
  font-size: 28rpx;
  color: $text-color;

  .placeholder { color: #C0BDB9; }
  .picker-arrow {
    font-size: 22rpx;
    color: $text-color-light;
  }
}

/* 标签选择 */
.ctrl-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 16rpx;

  .tag-item {
    padding: 14rpx 32rpx;
    border: 1rpx solid #E0DCD8;
    font-size: 24rpx;
    color: $text-color-light;
    letter-spacing: 2rpx;
    background: transparent;
    transition: all 0.25s ease;
    border-radius: 2rpx;

    &.active {
      background: $primary-color;
      border-color: $primary-color;
      color: #fff;
    }

    &:active { opacity: 0.7; }
  }
}

/* 图片上传 */
.ctrl-images {
  display: flex;
  flex-wrap: wrap;
  gap: 16rpx;
}

.img-item {
  position: relative;
  width: 160rpx;
  height: 160rpx;

  image {
    width: 100%;
    height: 100%;
    border-radius: 4rpx;
    object-fit: cover;
  }

  .img-delete {
    position: absolute;
    top: -12rpx;
    right: -12rpx;
    width: 36rpx;
    height: 36rpx;
    background: #2C2C2C;
    color: #fff;
    border-radius: 50%;
    text-align: center;
    line-height: 34rpx;
    font-size: 24rpx;
  }
}

.img-add {
  width: 160rpx;
  height: 160rpx;
  border: 2rpx dashed #D0CCC8;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  border-radius: 4rpx;
  background: #FAFAF8;

  .img-add-icon {
    font-size: 48rpx;
    color: $primary-color;
    line-height: 1;
    margin-bottom: 8rpx;
  }

  .img-add-text {
    font-size: 18rpx;
    color: $text-color-light;
    letter-spacing: 1rpx;
  }
}

/* 分隔线 */
.divider {
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 20rpx 0;
  gap: 20rpx;

  .divider-line {
    width: 80rpx;
    height: 1rpx;
    background: #D8D4D0;
  }

  .divider-text {
    font-size: 22rpx;
    color: $text-color-light;
    letter-spacing: 4rpx;
  }
}

/* 底部提交 */
.submit-bar {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  background: rgba(255,255,255,0.96);
  backdrop-filter: blur(20px);
  padding: 20rpx 40rpx;
  padding-bottom: calc(20rpx + env(safe-area-inset-bottom));
  box-shadow: 0 -2rpx 20rpx rgba(0,0,0,0.04);

  .submit-info {
    text-align: center;
    margin-bottom: 16rpx;
  }

  .submit-note {
    font-size: 20rpx;
    color: $text-color-light;
    letter-spacing: 2rpx;
  }
}

.submit-btn {
  width: 100%;
  height: 92rpx;
  background: #2C2C2C;
  color: #fff;
  font-size: 28rpx;
  letter-spacing: 6rpx;
  border: none;
  border-radius: 2rpx;
  line-height: 92rpx;

  &::after { border: none; }

  &[disabled] {
    background: #999;
    color: rgba(255,255,255,0.7);
  }
}
</style>
