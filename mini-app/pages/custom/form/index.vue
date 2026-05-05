<template>
  <view class="form-page">
    <view class="progress-bar">
      <view class="progress-fill" :style="{ width: progressPercent + '%' }"></view>
    </view>

    <scroll-view scroll-y class="form-scroll">
      <view class="hero">
        <text class="hero-kicker">CUSTOM BRIEF</text>
        <text class="hero-title">{{ categoryName }}</text>
        <text class="hero-desc">填写你的定制需求，设计师会根据这些信息给出方案和报价。</text>
      </view>

      <view class="brief-panel">
        <view class="brief-item">
          <text class="brief-value">{{ progressPercent }}%</text>
          <text class="brief-label">资料完成度</text>
        </view>
        <view class="brief-divider"></view>
        <view class="brief-item">
          <text class="brief-value">{{ requiredFilled }}/{{ requiredCount }}</text>
          <text class="brief-label">必填项</text>
        </view>
        <view class="brief-divider"></view>
        <view class="brief-item">
          <text class="brief-value">{{ refImages.length }}</text>
          <text class="brief-label">参考图</text>
        </view>
      </view>

      <view v-if="schema.length > 0" class="section-label">
        <text>定制信息</text>
        <text class="section-label__hint">带“必填”的信息请尽量完整填写</text>
      </view>

      <view class="form-body">
        <view v-for="(field, idx) in schema" :key="field.fieldId || field.fieldKey" class="field-card">
          <view class="field-head">
            <view class="field-number">{{ String(idx + 1).padStart(2, '0') }}</view>
            <view class="field-title-wrap">
              <view class="field-title-row">
                <text class="field-title">{{ field.label }}</text>
                <text v-if="field.isRequired" class="field-required">必填</text>
              </view>
              <text v-if="field.unit" class="field-subtitle">单位：{{ field.unit }}</text>
            </view>
          </view>

          <view class="field-control">
            <input
              v-if="field.fieldType === 'text'"
              v-model="formData[field.fieldKey]"
              :placeholder="field.placeholder || `请输入${field.label}`"
              placeholder-class="placeholder"
              class="ctrl-input"
            />

            <view v-else-if="field.fieldType === 'number'" class="ctrl-number-wrap">
              <input
                type="digit"
                v-model="formData[field.fieldKey]"
                :placeholder="field.placeholder || `请输入${field.label}`"
                placeholder-class="placeholder"
                class="ctrl-input"
              />
              <text v-if="field.unit" class="ctrl-unit">{{ field.unit }}</text>
            </view>

            <textarea
              v-else-if="field.fieldType === 'textarea'"
              v-model="formData[field.fieldKey]"
              :placeholder="field.placeholder || '请详细描述你的偏好、场景或注意事项'"
              placeholder-class="placeholder"
              class="ctrl-textarea"
              maxlength="500"
              auto-height
            />

            <picker
              v-else-if="field.fieldType === 'date'"
              mode="date"
              :value="formData[field.fieldKey] || ''"
              @change="(e) => setValue(field.fieldKey, e.detail.value)"
            >
              <view class="ctrl-picker">
                <text :class="{ 'is-placeholder': !formData[field.fieldKey] }">
                  {{ formData[field.fieldKey] || '请选择日期' }}
                </text>
                <text class="picker-arrow">›</text>
              </view>
            </picker>

            <view
              v-else-if="field.fieldType === 'select'"
              class="ctrl-picker"
              @click="openSelectSheet(field)"
            >
              <text :class="{ 'is-placeholder': !getSelectLabel(field) }">
                {{ getSelectLabel(field) || field.placeholder || `请选择${field.label}` }}
              </text>
              <text class="picker-arrow">›</text>
            </view>

            <view v-else-if="field.fieldType === 'radio'" class="ctrl-tags">
              <view
                v-for="option in field.parsedOptions || []"
                :key="option.value"
                class="tag-item"
                :class="{ active: formData[field.fieldKey] === option.value }"
                @click="setValue(field.fieldKey, option.value)"
              >
                <text>{{ option.label }}</text>
              </view>
            </view>

            <view v-else-if="field.fieldType === 'checkbox'" class="ctrl-tags">
              <view
                v-for="option in field.parsedOptions || []"
                :key="option.value"
                class="tag-item"
                :class="{ active: (formData[field.fieldKey] || []).includes(option.value) }"
                @click="toggleCheckbox(field.fieldKey, option.value)"
              >
                <text>{{ option.label }}</text>
              </view>
            </view>

            <view v-else-if="field.fieldType === 'image'" class="ctrl-images">
              <view
                v-for="(img, index) in formData[field.fieldKey] || []"
                :key="index"
                class="img-item"
                @click="previewImages(formData[field.fieldKey], index)"
              >
                <image :src="img" mode="aspectFill" />
                <view class="img-delete" @click.stop="removeImage(field.fieldKey, index)">×</view>
              </view>
              <view
                v-if="(formData[field.fieldKey] || []).length < getMaxImages(field)"
                class="img-add"
                @click="uploadImage(field)"
              >
                <text class="img-add-icon">＋</text>
                <text class="img-add-text">添加图片</text>
              </view>
            </view>

            <input
              v-else
              v-model="formData[field.fieldKey]"
              :placeholder="field.placeholder || `请输入${field.label}`"
              placeholder-class="placeholder"
              class="ctrl-input"
            />
          </view>
        </view>

        <view class="field-card support-card">
          <view class="field-head">
            <view class="field-number field-number--soft">图</view>
            <view class="field-title-wrap">
              <view class="field-title-row">
                <text class="field-title">参考图片</text>
              </view>
              <text class="field-subtitle">上传灵感图、尺寸图或想参考的风格</text>
            </view>
          </view>
          <view class="ctrl-images">
            <view
              v-for="(img, index) in refImages"
              :key="index"
              class="img-item"
              @click="previewImages(refImages, index)"
            >
              <image :src="img" mode="aspectFill" />
              <view class="img-delete" @click.stop="removeRefImage(index)">×</view>
            </view>
            <view v-if="refImages.length < 9" class="img-add" @click="chooseRefImages">
              <text class="img-add-icon">＋</text>
              <text class="img-add-text">灵感图片</text>
            </view>
          </view>
        </view>

        <view class="field-card support-card">
          <view class="field-head">
            <view class="field-number field-number--soft">补</view>
            <view class="field-title-wrap">
              <view class="field-title-row">
                <text class="field-title">其他需求</text>
              </view>
              <text class="field-subtitle">比如预算、交付时间、偏好的沟通方式</text>
            </view>
          </view>
          <textarea
            v-model="description"
            placeholder="可以写下特殊需求、交付时间、忌讳元素或想让设计师重点关注的细节..."
            placeholder-class="placeholder"
            class="ctrl-textarea"
            maxlength="500"
            auto-height
          />
        </view>

        <view v-if="!loading && schema.length === 0" class="empty-state">
          <text class="empty-state__title">暂未配置表单字段</text>
          <text class="empty-state__desc">你仍然可以通过参考图片和其他需求提交定制意向。</text>
        </view>
      </view>
    </scroll-view>

    <view class="submit-bar">
      <view class="submit-copy">
        <text class="submit-title">提交后设计师将在 24 小时内联系你</text>
        <text class="submit-desc">{{ missingRequiredCount > 0 ? `还有 ${missingRequiredCount} 个必填项待完善` : '资料已准备好，可以提交' }}</text>
      </view>
      <button class="submit-btn" :class="{ ready: canSubmit }" :disabled="submitting" @click="handleSubmit">
        {{ submitting ? '提交中...' : '提交定制意向' }}
      </button>
    </view>
  </view>
</template>

<script setup>
import { computed, reactive, ref } from 'vue'
import { onLoad } from '@dcloudio/uni-app'
import { getFormSchema, submitRequest } from '@/api/custom'

const categoryId = ref(0)
const categoryName = ref('定制服务')
const schema = ref([])
const formData = reactive({})
const description = ref('')
const refImages = ref([])
const loading = ref(false)
const submitting = ref(false)

const requiredFields = computed(() => schema.value.filter(field => field.isRequired))

const isFilled = (value) => {
  if (Array.isArray(value)) return value.length > 0
  return value !== undefined && value !== null && String(value).trim() !== ''
}

const requiredFilled = computed(() => requiredFields.value.filter(field => isFilled(formData[field.fieldKey])).length)
const requiredCount = computed(() => requiredFields.value.length)
const missingRequiredCount = computed(() => Math.max(requiredCount.value - requiredFilled.value, 0))
const canSubmit = computed(() => missingRequiredCount.value === 0 && !submitting.value)

const progressPercent = computed(() => {
  const weightedTotal = schema.value.length + 2
  const dynamicFilled = schema.value.filter(field => isFilled(formData[field.fieldKey])).length
  const extraFilled = (refImages.value.length > 0 ? 1 : 0) + (description.value.trim() ? 1 : 0)
  return Math.min(100, Math.round(((dynamicFilled + extraFilled) / weightedTotal) * 100))
})

const parseOptions = (field) => {
  let options = []
  if (typeof field.options === 'string' && field.options) {
    try {
      options = JSON.parse(field.options)
    } catch {
      options = []
    }
  } else if (Array.isArray(field.options)) {
    options = field.options
  }
  return normalizeOptions(options)
}

const normalizeOptions = (options) => {
  if (!Array.isArray(options)) return []
  return options
    .map((option) => {
      if (option && typeof option === 'object') {
        const label = option.label ?? option.name ?? option.text ?? option.title ?? option.value
        const value = option.value ?? option.key ?? option.id ?? label
        return {
          ...option,
          label: String(label ?? ''),
          value: value ?? '',
        }
      }
      return {
        label: String(option ?? ''),
        value: option ?? '',
      }
    })
    .filter(option => option.label !== '')
}

const normalizeField = (field) => {
  const parsedOptions = parseOptions(field)
  return {
    ...field,
    parsedOptions,
    optionLabels: parsedOptions.map(option => option.label),
  }
}

const fetchSchema = async () => {
  loading.value = true
  try {
    const data = await getFormSchema(categoryId.value)
    const list = Array.isArray(data) ? data : (data?.records || data?.list || [])
    schema.value = list.map(normalizeField)
  } catch (err) {
    console.error('获取表单配置失败', err)
    uni.showToast({ title: '获取表单失败', icon: 'none' })
  } finally {
    loading.value = false
  }
}

const setValue = (fieldKey, value) => {
  formData[fieldKey] = value
}

const getSelectLabel = (field) => {
  const value = formData[field.fieldKey]
  const option = (field.parsedOptions || []).find(option => option.value === value)
  return option?.label
}

const getOptionLabels = (field) => {
  const labels = field.optionLabels || (field.parsedOptions || []).map(option => option.label)
  return labels.map(label => String(label ?? ''))
}

const openSelectSheet = (field) => {
  const options = field.parsedOptions || []
  const itemList = getOptionLabels(field)
  if (!itemList.length) {
    uni.showToast({ title: '暂无可选项', icon: 'none' })
    return
  }
  uni.showActionSheet({
    itemList,
    success: ({ tapIndex }) => {
      const option = options[tapIndex]
      if (option) setValue(field.fieldKey, option.value)
    }
  })
}

const toggleCheckbox = (fieldKey, value) => {
  const current = Array.isArray(formData[fieldKey]) ? formData[fieldKey] : []
  formData[fieldKey] = current.includes(value)
    ? current.filter(item => item !== value)
    : [...current, value]
}

const getMaxImages = (field) => Number(field.maxImages) || 9

const chooseImages = (count, onSuccess) => {
  uni.chooseImage({
    count,
    sizeType: ['compressed'],
    sourceType: ['album', 'camera'],
    success: (res) => onSuccess(res.tempFilePaths || []),
  })
}

const uploadImage = (field) => {
  const fieldKey = field.fieldKey
  const images = formData[fieldKey] || []
  chooseImages(getMaxImages(field) - images.length, (paths) => {
    formData[fieldKey] = [...images, ...paths]
  })
}

const removeImage = (fieldKey, index) => {
  const images = formData[fieldKey] || []
  formData[fieldKey] = images.filter((_, imgIndex) => imgIndex !== index)
}

const chooseRefImages = () => {
  chooseImages(9 - refImages.value.length, (paths) => {
    refImages.value = [...refImages.value, ...paths]
  })
}

const removeRefImage = (index) => {
  refImages.value = refImages.value.filter((_, imgIndex) => imgIndex !== index)
}

const previewImages = (images, current = 0) => {
  if (!images?.length) return
  uni.previewImage({
    urls: images,
    current: images[current],
  })
}

const getFirstMissingField = () => requiredFields.value.find(field => !isFilled(formData[field.fieldKey]))

const handleSubmit = async () => {
  const missing = getFirstMissingField()
  if (missing) {
    uni.showToast({ title: `请填写${missing.label}`, icon: 'none' })
    return
  }

  submitting.value = true
  try {
    await submitRequest({
      categoryId: categoryId.value,
      customData: JSON.stringify({ ...formData }),
      imageUrls: JSON.stringify(refImages.value),
      description: description.value,
    })

    uni.showToast({ title: '提交成功', icon: 'success' })
    setTimeout(() => {
      uni.switchTab({ url: '/pages/order/list/index' })
    }, 900)
  } catch (err) {
    uni.showToast({ title: err.message || '提交失败', icon: 'none' })
  } finally {
    submitting.value = false
  }
}

onLoad((options) => {
  categoryId.value = Number(options.categoryId) || 0
  categoryName.value = decodeURIComponent(options.categoryName || '定制服务')
  uni.setNavigationBarTitle({ title: categoryName.value })
  fetchSchema()
})
</script>

<style lang="scss" scoped>
.form-page {
  height: 100vh;
  display: flex;
  flex-direction: column;
  background:
    radial-gradient(circle at 84% 4%, rgba(210, 228, 251, 0.72), transparent 34%),
    linear-gradient(180deg, #fbf9fa 0%, #f5f3f4 100%);
  color: #1b1c1d;
}

.progress-bar {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  height: 5rpx;
  background: rgba(26, 43, 60, 0.08);
  z-index: 20;
}

.progress-fill {
  height: 100%;
  background: linear-gradient(90deg, #1a2b3c, #2d4b41);
  transition: width 0.35s ease;
}

.form-scroll {
  flex: 1;
  min-height: 0;
}

.hero {
  padding: 70rpx 44rpx 30rpx;
  display: flex;
  flex-direction: column;
  align-items: center;
  text-align: center;
}

.hero-kicker {
  font-family: 'Times New Roman', serif;
  font-size: 22rpx;
  letter-spacing: 10rpx;
  color: #2d4b41;
  margin-bottom: 20rpx;
}

.hero-title {
  font-family: 'Times New Roman', serif;
  font-size: 54rpx;
  line-height: 1.18;
  letter-spacing: 4rpx;
  color: #1a2b3c;
  margin-bottom: 18rpx;
}

.hero-desc {
  max-width: 590rpx;
  font-size: 25rpx;
  line-height: 1.68;
  color: #6b6b6b;
}

.brief-panel {
  margin: 0 32rpx 34rpx;
  padding: 28rpx 18rpx;
  display: flex;
  align-items: center;
  justify-content: space-between;
  border: 1rpx solid rgba(229, 226, 218, 0.9);
  border-radius: 18rpx;
  background: rgba(255, 255, 255, 0.9);
  box-shadow: 0 14rpx 38rpx rgba(26, 43, 60, 0.05);
}

.brief-item {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
}

.brief-value {
  font-size: 34rpx;
  line-height: 1.2;
  color: #1a2b3c;
  font-weight: 700;
}

.brief-label {
  margin-top: 8rpx;
  font-size: 20rpx;
  color: #74777d;
}

.brief-divider {
  width: 1rpx;
  height: 56rpx;
  background: #e5e2da;
}

.section-label {
  padding: 0 34rpx 18rpx;
  display: flex;
  align-items: flex-end;
  justify-content: space-between;
  gap: 20rpx;
  font-size: 30rpx;
  color: #1a2b3c;
  font-weight: 700;
}

.section-label__hint {
  font-size: 21rpx;
  color: #74777d;
  font-weight: 400;
}

.form-body {
  padding: 0 32rpx 230rpx;
}

.field-card {
  margin-bottom: 22rpx;
  padding: 32rpx;
  border: 1rpx solid rgba(229, 226, 218, 0.92);
  border-radius: 18rpx;
  background: rgba(255, 255, 255, 0.94);
  box-shadow: 0 10rpx 30rpx rgba(26, 43, 60, 0.04);
}

.field-head {
  display: flex;
  align-items: flex-start;
  margin-bottom: 26rpx;
}

.field-number {
  width: 52rpx;
  height: 52rpx;
  margin-right: 20rpx;
  flex-shrink: 0;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 12rpx;
  background: #1a2b3c;
  color: #ffffff;
  font-family: 'Times New Roman', serif;
  font-size: 22rpx;
}

.field-number--soft {
  background: #2d4b41;
}

.field-title-wrap {
  flex: 1;
  min-width: 0;
}

.field-title-row {
  display: flex;
  align-items: center;
  flex-wrap: wrap;
  gap: 12rpx;
}

.field-title {
  font-size: 30rpx;
  line-height: 1.35;
  font-weight: 700;
  color: #1a2b3c;
}

.field-required {
  padding: 5rpx 14rpx;
  border-radius: 999rpx;
  background: #feddb5;
  color: #584326;
  font-size: 19rpx;
}

.field-subtitle {
  display: block;
  margin-top: 8rpx;
  font-size: 22rpx;
  color: #74777d;
}

.ctrl-input,
.ctrl-picker {
  width: 100%;
  min-height: 82rpx;
  box-sizing: border-box;
  padding: 0 24rpx;
  display: flex;
  align-items: center;
  border: 1rpx solid #e5e2da;
  border-radius: 12rpx;
  background: #fbf9fa;
  color: #1b1c1d;
  font-size: 28rpx;
}

.ctrl-number-wrap {
  display: flex;
  align-items: center;
  gap: 16rpx;
}

.ctrl-number-wrap .ctrl-input {
  flex: 1;
}

.ctrl-unit {
  min-width: 64rpx;
  color: #74777d;
  font-size: 24rpx;
}

.ctrl-textarea {
  width: 100%;
  min-height: 180rpx;
  box-sizing: border-box;
  padding: 22rpx 24rpx;
  border: 1rpx solid #e5e2da;
  border-radius: 12rpx;
  background: #fbf9fa;
  color: #1b1c1d;
  font-size: 27rpx;
  line-height: 1.62;
}

.placeholder,
.is-placeholder {
  color: #a6a3a0;
}

.ctrl-picker {
  justify-content: space-between;
}

.picker-arrow {
  color: #74777d;
  font-size: 40rpx;
  line-height: 1;
  transform: rotate(90deg);
}

.ctrl-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 16rpx;
}

.tag-item {
  padding: 15rpx 26rpx;
  border: 1rpx solid #e5e2da;
  border-radius: 999rpx;
  background: #fbf9fa;
  color: #6b6b6b;
  font-size: 24rpx;
}

.tag-item.active {
  border-color: #1a2b3c;
  background: #1a2b3c;
  color: #ffffff;
}

.ctrl-images {
  display: flex;
  flex-wrap: wrap;
  gap: 18rpx;
}

.img-item,
.img-add {
  width: 154rpx;
  height: 154rpx;
  border-radius: 14rpx;
}

.img-item {
  position: relative;
  overflow: visible;
}

.img-item image {
  width: 100%;
  height: 100%;
  border-radius: 14rpx;
  background: #e9e7e9;
}

.img-delete {
  position: absolute;
  top: -12rpx;
  right: -12rpx;
  width: 40rpx;
  height: 40rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 50%;
  background: #1a2b3c;
  color: #ffffff;
  font-size: 28rpx;
  box-shadow: 0 6rpx 16rpx rgba(26, 43, 60, 0.2);
}

.img-add {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  border: 2rpx dashed #c4c6cd;
  background: #fbf9fa;
}

.img-add-icon {
  font-size: 42rpx;
  line-height: 1;
  color: #1a2b3c;
}

.img-add-text {
  margin-top: 8rpx;
  font-size: 21rpx;
  color: #74777d;
}

.support-card {
  background: rgba(255, 255, 255, 0.9);
}

.empty-state {
  padding: 62rpx 30rpx;
  display: flex;
  flex-direction: column;
  align-items: center;
  border: 1rpx dashed #c4c6cd;
  border-radius: 18rpx;
  color: #74777d;
}

.empty-state__title {
  font-size: 28rpx;
  color: #1a2b3c;
  font-weight: 700;
  margin-bottom: 10rpx;
}

.empty-state__desc {
  font-size: 23rpx;
}

.submit-bar {
  position: fixed;
  left: 0;
  right: 0;
  bottom: 0;
  padding: 22rpx 32rpx;
  padding-bottom: calc(22rpx + env(safe-area-inset-bottom));
  display: flex;
  align-items: center;
  gap: 22rpx;
  border-top: 1rpx solid rgba(229, 226, 218, 0.9);
  background: rgba(255, 255, 255, 0.94);
  backdrop-filter: blur(18px);
  box-shadow: 0 -10rpx 32rpx rgba(26, 43, 60, 0.06);
  z-index: 10;
}

.submit-copy {
  flex: 1;
  min-width: 0;
  display: flex;
  flex-direction: column;
}

.submit-title {
  font-size: 23rpx;
  color: #1a2b3c;
  font-weight: 700;
}

.submit-desc {
  margin-top: 6rpx;
  font-size: 20rpx;
  color: #74777d;
}

.submit-btn {
  width: 260rpx;
  height: 86rpx;
  margin: 0;
  border-radius: 14rpx;
  border: none;
  background: #1a2b3c;
  color: #ffffff;
  font-size: 26rpx;
  line-height: 86rpx;
  box-shadow: 0 12rpx 28rpx rgba(26, 43, 60, 0.18);
}

.submit-btn::after {
  border: none;
}

.submit-btn[disabled] {
  opacity: 0.68;
}
</style>
