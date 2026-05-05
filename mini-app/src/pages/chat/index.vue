<template>
  <view class="chat-page">
    <view v-if="!isConnected" class="connection-bar">
      <text class="connection-bar__text">{{ reconnecting ? '正在重连沟通通道...' : '当前连接已断开，请稍候重试' }}</text>
    </view>

    <view class="context-bar">
      <view class="context-main">
        <view class="context-cover">
          <image v-if="contextCover" :src="contextCover" mode="aspectFill" class="context-cover__image" />
          <view v-else class="context-cover__fallback">{{ contextInitial }}</view>
        </view>
        <view class="context-copy">
          <text class="context-title">{{ contextTitle }}</text>
          <text class="context-subtitle">{{ contextSubtitle }}</text>
        </view>
      </view>
      <view class="context-side">
        <text class="context-side__badge">{{ isOrderChat ? '订单沟通' : '专属客服' }}</text>
      </view>
    </view>

    <scroll-view
      class="message-area"
      scroll-y
      :scroll-into-view="scrollToId"
      :scroll-top="scrollTop"
      scroll-with-animation
    >
      <view class="message-canvas">
        <view
          v-for="(msg, index) in messages"
          :key="msg.messageId || index"
          :id="'msg-' + index"
          class="message-block"
        >
          <view v-if="shouldShowTimeDivider(index)" class="time-divider">
            <text class="time-divider__text">{{ formatDivider(msg.createTime) }}</text>
          </view>

          <view :class="['msg-row', isMyMsg(msg) ? 'is-mine' : 'is-other']">
            <view class="msg-avatar" :class="avatarClass(msg)">
              <image
                v-if="avatarImage(msg)"
                :src="avatarImage(msg)"
                mode="aspectFill"
                class="msg-avatar__image"
              />
              <text v-else class="msg-avatar__text">{{ avatarText(msg) }}</text>
            </view>

            <view class="msg-content">
              <view v-if="isAssistantMsg(msg)" class="assistant-tag">
                <text class="assistant-tag__icon">✦</text>
                <text class="assistant-tag__text">工作室助手</text>
              </view>

              <view class="msg-bubble" :class="bubbleClass(msg)">
                <view
                  v-if="isProgressCardMsg(msg)"
                  class="progress-card"
                  @click="openProgressCard(msg)"
                >
                  <view class="progress-card__head">
                    <view>
                      <text class="progress-card__kicker">订单进度</text>
                      <text class="progress-card__title">{{ progressCardData(msg).orderSn || '定制订单' }}</text>
                    </view>
                    <text class="progress-card__status">{{ progressCardData(msg).statusText || '处理中' }}</text>
                  </view>
                  <view class="progress-card__body">
                    <view class="progress-card__metric">
                      <text class="progress-card__label">当前节点</text>
                      <text class="progress-card__value">{{ progressCardData(msg).currentStepName || '-' }}</text>
                    </view>
                    <view class="progress-card__metric">
                      <text class="progress-card__label">预计交付</text>
                      <text class="progress-card__value">{{ progressCardData(msg).expectedDateText || progressCardData(msg).expectedDate || '-' }}</text>
                    </view>
                  </view>
                  <view class="progress-card__track">
                    <view
                      v-for="(step, stepIndex) in progressCardSteps(msg)"
                      :key="step.stepId || stepIndex"
                      class="progress-card__dot"
                      :class="{ active: stepIndex <= progressCardCurrentIndex(msg) }"
                    ></view>
                  </view>
                  <text v-if="progressCardData(msg).latestProgress" class="progress-card__latest">
                    {{ progressCardData(msg).latestProgress }}
                  </text>
                  <view class="progress-card__action">
                    <text>{{ progressCardData(msg).actionText || '查看订单详情' }}</text>
                    <text>→</text>
                  </view>
                </view>
                <view v-else-if="isHandoffRequestMsg(msg)" class="handoff-card">
                  <view class="handoff-card__icon">!</view>
                  <view class="handoff-card__main">
                    <text class="handoff-card__title">已请求人工客服</text>
                    <text class="handoff-card__desc">我们已经通知后台客服接入，请稍等片刻。</text>
                  </view>
                </view>
                <view v-else-if="isHandoffResolvedMsg(msg)" class="handoff-card handoff-card--resolved">
                  <view class="handoff-card__icon">✓</view>
                  <view class="handoff-card__main">
                    <text class="handoff-card__title">AI客服已恢复</text>
                    <text class="handoff-card__desc">人工服务已处理，后续可继续由小Z协助解答。</text>
                  </view>
                </view>
                <view
                  v-else-if="isActionCardMsg(msg)"
                  class="action-card"
                  @click="openActionCard(msg)"
                >
                  <view class="action-card__icon">{{ actionCardIcon(msg) }}</view>
                  <view class="action-card__main">
                    <text class="action-card__title">{{ actionCardData(msg).title || msg.content }}</text>
                    <text class="action-card__desc">{{ actionCardData(msg).description || '点击查看相关内容' }}</text>
                    <view class="action-card__button">
                      <text>{{ actionCardData(msg).actionText || '立即查看' }}</text>
                      <text>→</text>
                    </view>
                  </view>
                </view>
                <image
                  v-else-if="isImageMsg(msg)"
                  class="msg-image"
                  :src="imageMsgUrl(msg)"
                  mode="widthFix"
                  @click="previewImage(imageMsgUrl(msg))"
                />
                <view
                  v-else-if="isFileMsg(msg)"
                  class="file-card"
                  @click="openFile(msg)"
                >
                  <view class="file-card__icon">FILE</view>
                  <view class="file-card__main">
                    <text class="file-card__name">{{ fileMsgData(msg).fileName || getFileName(msg.content) }}</text>
                    <text class="file-card__meta">{{ formatFileSize(fileMsgData(msg).fileSize) || '点击打开文件' }}</text>
                  </view>
                  <view class="file-card__button" @click.stop="openFile(msg)">下载</view>
                </view>
                <text v-else class="msg-text">{{ msg.content }}</text>
              </view>

              <text class="msg-time">{{ formatTime(msg.createTime) }}</text>
            </view>
          </view>
        </view>
        <view id="message-bottom" class="message-bottom-space"></view>
      </view>
    </scroll-view>

    <view class="input-area">
      <view class="handoff-row">
        <view class="handoff-btn" :class="{ disabled: handoffLoading }" @click="requestHumanHandoff">
          <text class="handoff-btn__dot"></text>
          <text>{{ handoffLoading ? '正在通知人工...' : '转人工客服' }}</text>
        </view>
        <text class="handoff-hint">紧急修改、退款、催交付建议转人工</text>
      </view>
      <view class="input-shell">
        <view class="media-btn" :class="{ 'media-btn--disabled': mediaUploading }" @click="chooseMedia">
          <text class="media-btn__icon">＋</text>
        </view>
        <textarea
          v-model="inputText"
          class="chat-input"
          placeholder="输入消息..."
          auto-height
          maxlength="1000"
          confirm-type="send"
          @confirm="sendTextMsg"
        />
        <view
          class="send-btn"
          :class="{ 'send-btn--disabled': !canSend }"
          @click="sendTextMsg"
        >
          <text class="send-btn__icon">➤</text>
        </view>
      </view>
    </view>
  </view>
</template>

<script setup>
import { computed, nextTick, onUnmounted, ref } from 'vue'
import { onLoad } from '@dcloudio/uni-app'
import { getOrderDetail } from '@/api/order'
import { uploadChatFile } from '@/api/upload'
import request from '@/utils/request'
import storage from '@/utils/storage'

const messages = ref([])
const inputText = ref('')
const scrollToId = ref('')
const scrollTop = ref(0)
const chatOrderId = ref(null)
const isConnected = ref(false)
const reconnecting = ref(false)
const orderInfo = ref({})
const handoffLoading = ref(false)
const mediaUploading = ref(false)

let socketTask = null
let reconnectTimer = null
let reconnectAttempts = 0
const MAX_RECONNECT = 5
const RECONNECT_DELAY = 3000

const isOrderChat = computed(() => !!chatOrderId.value)

const canSend = computed(() => isConnected.value && inputText.value.trim().length > 0)

const contextTitle = computed(() => {
  if (isOrderChat.value) {
    return orderInfo.value.orderSn ? `订单 #${orderInfo.value.orderSn}` : `订单咨询 #${chatOrderId.value}`
  }
  return '专属沟通空间'
})

const contextSubtitle = computed(() => {
  if (isOrderChat.value) {
    const category = orderInfo.value.categoryName || '专属定制'
    const status = getStatusText(orderInfo.value.status)
    return `${category} · ${status || '沟通中'}`
  }
  return '与设计师、客服和智能助手保持单线程沟通'
})

const contextInitial = computed(() => {
  if (isOrderChat.value) return '单'
  return 'Z'
})

const contextCover = computed(() => orderInfo.value.coverUrl || orderInfo.value.coverImage || '')

onLoad((options) => {
  if (options && options.orderId) {
    chatOrderId.value = Number(options.orderId)
    uni.setNavigationBarTitle({ title: '订单咨询' })
    fetchOrderContext()
  } else {
    uni.setNavigationBarTitle({ title: '在线沟通' })
  }
  fetchHistory()
  connectWS()
})

onUnmounted(() => {
  clearReconnect()
  if (socketTask) {
    socketTask.close({ code: 1000, reason: '页面关闭' })
    socketTask = null
  }
})

const clearReconnect = () => {
  if (reconnectTimer) {
    clearTimeout(reconnectTimer)
    reconnectTimer = null
  }
}

const scheduleReconnect = () => {
  if (reconnectAttempts >= MAX_RECONNECT) {
    reconnecting.value = false
    return
  }
  reconnecting.value = true
  reconnectTimer = setTimeout(() => {
    reconnectAttempts += 1
    connectWS()
  }, RECONNECT_DELAY)
}

const fetchOrderContext = async () => {
  if (!chatOrderId.value) return
  try {
    const data = await getOrderDetail(chatOrderId.value)
    orderInfo.value = data || {}
  } catch (err) {
    console.error('获取订单上下文失败', err)
  }
}

const fetchHistory = async () => {
  try {
    const params = {}
    if (chatOrderId.value) params.orderId = chatOrderId.value
    const data = await request({
      url: '/v1/app/chat',
      method: 'GET',
      data: params
    })
    messages.value = data || []
    scrollToBottom()
  } catch (err) {
    console.error('获取聊天记录失败', err)
  }
}

const connectWS = () => {
  const token = storage.getToken()
  if (!token) return

  const wsUrl = `ws://localhost:8081/ws/chat?token=${token}`

  socketTask = uni.connectSocket({
    url: wsUrl,
    fail: () => {
      isConnected.value = false
      reconnecting.value = false
    }
  })

  socketTask.onOpen(() => {
    isConnected.value = true
    reconnecting.value = false
    reconnectAttempts = 0
  })

  socketTask.onMessage((res) => {
    try {
      const msg = JSON.parse(res.data)
      if (msg.type === 'NEW_MSG') {
        if (!chatOrderId.value || msg.orderId == chatOrderId.value) {
          messages.value.push(msg)
          scrollToBottom()
        }
      }
    } catch (e) {
      console.error('解析消息失败', e)
    }
  })

  socketTask.onClose(() => {
    isConnected.value = false
    if (!reconnectTimer && reconnectAttempts < MAX_RECONNECT) {
      scheduleReconnect()
    }
  })

  socketTask.onError(() => {
    isConnected.value = false
  })
}

const sendTextMsg = () => {
  const text = inputText.value.trim()
  if (!text || !canSend.value) return
  sendMessage(text, 'text')
  inputText.value = ''
}

const ensureConnected = () => {
  if (socketTask && isConnected.value) return true
  uni.showToast({ title: '连接已断开', icon: 'none' })
  return false
}

const chooseMedia = () => {
  if (!ensureConnected() || mediaUploading.value) return
  uni.showActionSheet({
    itemList: ['发送图片', '发送文件'],
    success: ({ tapIndex }) => {
      if (tapIndex === 0) chooseImage()
      if (tapIndex === 1) chooseFile()
    }
  })
}

const chooseImage = () => {
  if (!isConnected.value) {
    uni.showToast({ title: '连接已断开', icon: 'none' })
    return
  }
  uni.chooseImage({
    count: 1,
    sizeType: ['original', 'compressed'],
    success: async (res) => {
      const tempPath = res.tempFilePaths[0]
      const file = res.tempFiles?.[0] || {}
      await uploadAndSend(tempPath, 'image', {
        fileName: file.name || getFileName(tempPath),
        fileSize: file.size || 0,
        mimeType: file.type || 'image/*'
      })
    }
  })
}

const chooseFile = () => {
  if (!ensureConnected()) return
  if (typeof uni.chooseMessageFile !== 'function') {
    uni.showToast({ title: '当前环境不支持选择文件', icon: 'none' })
    return
  }
  uni.chooseMessageFile({
    count: 1,
    type: 'file',
    success: async (res) => {
      const file = res.tempFiles?.[0]
      if (!file?.path) return
      await uploadAndSend(file.path, 'file', {
        fileName: file.name || getFileName(file.path),
        fileSize: file.size || 0,
        mimeType: file.type || 'application/octet-stream'
      })
    }
  })
}

const uploadAndSend = async (filePath, msgType, meta = {}) => {
  mediaUploading.value = true
  uni.showLoading({ title: '上传中...' })
  try {
    const fileName = meta.fileName || getFileName(filePath)
    const url = await uploadChatFile(filePath, { fileName, msgType })
    sendMessage(url, msgType, {
      ...meta,
      fileName,
      fileUrl: url
    })
  } catch (err) {
    uni.showToast({ title: err.message || '上传失败', icon: 'none' })
  } finally {
    uni.hideLoading()
    mediaUploading.value = false
  }
}

const sendMessage = (content, msgType, extraJson = null) => {
  if (!socketTask || !isConnected.value) {
    uni.showToast({ title: '连接已断开', icon: 'none' })
    return
  }

  socketTask.send({
    data: JSON.stringify({
      type: 'SEND',
      content,
      msgType,
      extraJson,
      orderId: chatOrderId.value
    })
  })

  messages.value.push({
    senderType: 'client',
    content,
    msgType,
    extraJson,
    orderId: chatOrderId.value,
    createTime: new Date().toISOString().replace('T', ' ').substring(0, 19)
  })
  scrollToBottom()
}

const requestHumanHandoff = async () => {
  if (handoffLoading.value) return
  handoffLoading.value = true
  try {
    const msg = await request({
      url: '/v1/app/chat/handoff',
      method: 'POST',
      data: { orderId: chatOrderId.value }
    })
    messages.value.push({
      ...msg,
      messageId: msg.msgId || msg.messageId,
      senderType: 'client',
      msgType: 'handoff_request',
      contentType: 4,
      orderId: chatOrderId.value,
      createTime: msg.createTime || new Date().toISOString().replace('T', ' ').substring(0, 19)
    })
    uni.showToast({ title: '已通知人工客服', icon: 'success' })
    scrollToBottom()
  } catch (err) {
    uni.showToast({ title: err.message || '转人工失败', icon: 'none' })
  } finally {
    handoffLoading.value = false
  }
}

const scrollToBottom = () => {
  nextTick(() => {
    if (!messages.value.length) return
    const scroll = () => {
      scrollToId.value = ''
      scrollTop.value += 100000
      setTimeout(() => {
        scrollToId.value = 'message-bottom'
        scrollTop.value += 100000
      }, 30)
    }
    scroll()
    setTimeout(scroll, 180)
    setTimeout(scroll, 360)
  })
}

const previewImage = (url) => {
  const imageUrl = toAbsoluteFileUrl(url)
  if (!imageUrl) return
  uni.previewImage({ urls: [imageUrl], current: imageUrl })
}

const openFile = (msg) => {
  const url = toAbsoluteFileUrl(msg.content || fileMsgData(msg).fileUrl)
  if (!url) return
  uni.downloadFile({
    url,
    success: (res) => {
      if (res.statusCode !== 200) {
        uni.showToast({ title: '文件下载失败', icon: 'none' })
        return
      }
      uni.openDocument({
        filePath: res.tempFilePath,
        showMenu: true,
        fail: () => uni.showToast({ title: '无法打开该文件', icon: 'none' })
      })
    },
    fail: () => uni.showToast({ title: '文件下载失败', icon: 'none' })
  })
}

const isMyMsg = (msg) => msg.senderType === 'client' || msg.senderType === 0
const isAssistantMsg = (msg) => msg.senderType === 2 || msg.senderType === 'ai'
const isImageMsg = (msg) => msg.msgType === 'image' || msg.contentType === 1
const isFileMsg = (msg) => msg.msgType === 'file' || msg.contentType === 2
const isProgressCardMsg = (msg) => msg.msgType === 'progress_card' || msg.contentType === 3
const isHandoffRequestMsg = (msg) =>
  msg.msgType === 'handoff_request' || parseExtraJson(msg).cardType === 'handoff_request'
const isHandoffResolvedMsg = (msg) =>
  msg.msgType === 'handoff_resolved' || parseExtraJson(msg).cardType === 'handoff_resolved'
const isActionCardMsg = (msg) =>
  (msg.msgType === 'action_card' || msg.contentType === 4) &&
  !isHandoffRequestMsg(msg) &&
  !isHandoffResolvedMsg(msg)

const parseExtraJson = (msg) => {
  const raw = msg.extraJson
  if (!raw) return {}
  if (typeof raw === 'object') return raw || {}
  try {
    const parsed = JSON.parse(raw)
    return parsed && typeof parsed === 'object' ? parsed : {}
  } catch (err) {
    return {}
  }
}

const progressCardData = (msg) => parseExtraJson(msg)
const actionCardData = (msg) => parseExtraJson(msg)
const fileMsgData = (msg) => parseExtraJson(msg)
const imageMsgUrl = (msg) => toAbsoluteFileUrl(msg.content || fileMsgData(msg).fileUrl)

const getFileName = (path = '') => {
  const normalized = String(path).split('?')[0]
  return normalized.substring(normalized.lastIndexOf('/') + 1) || '附件'
}

const formatFileSize = (size) => {
  const bytes = Number(size || 0)
  if (!bytes) return ''
  if (bytes < 1024) return `${bytes}B`
  if (bytes < 1024 * 1024) return `${(bytes / 1024).toFixed(1)}KB`
  return `${(bytes / 1024 / 1024).toFixed(1)}MB`
}

const toAbsoluteFileUrl = (url) => {
  if (!url) return ''
  if (/^https?:\/\//i.test(url)) return url
  return `http://localhost:8081${url.startsWith('/') ? url : `/${url}`}`
}

const progressCardSteps = (msg) => {
  const steps = progressCardData(msg).steps
  return Array.isArray(steps) ? steps : []
}

const progressCardCurrentIndex = (msg) => {
  const index = Number(progressCardData(msg).currentStepIndex)
  return Number.isNaN(index) ? -1 : index
}

const openProgressCard = (msg) => {
  const card = progressCardData(msg)
  const url = card.actionUrl || (card.orderId ? `/pages/order/detail/index?id=${card.orderId}` : '')
  if (!url) return
  uni.navigateTo({ url })
}

const actionCardIcon = (msg) => {
  const type = actionCardData(msg).iconType
  const icons = {
    service: '客',
    portfolio: '作',
    custom: '定',
    notification: '铃',
    payment: '¥'
  }
  return icons[type] || 'Z'
}

const openActionCard = (msg) => {
  const url = actionCardData(msg).actionUrl
  if (!url) return
  const tabPages = ['/pages/index/index', '/pages/order/list/index', '/pages/user/index']
  if (tabPages.includes(url)) {
    uni.switchTab({ url })
    return
  }
  uni.navigateTo({ url })
}

const avatarText = (msg) => {
  if (isMyMsg(msg)) return '我'
  if (isAssistantMsg(msg)) return 'AI'
  return '师'
}

const avatarImage = () => ''

const avatarClass = (msg) => {
  if (isMyMsg(msg)) return 'msg-avatar--mine'
  if (isAssistantMsg(msg)) return 'msg-avatar--assistant'
  return 'msg-avatar--other'
}

const bubbleClass = (msg) => {
  if (isMyMsg(msg)) return 'msg-bubble--mine'
  if (isAssistantMsg(msg)) return 'msg-bubble--assistant'
  return 'msg-bubble--other'
}

const formatTime = (timeStr) => {
  if (!timeStr) return ''
  return String(timeStr).substring(11, 16)
}

const formatDivider = (timeStr) => {
  if (!timeStr) return ''
  const date = new Date(timeStr.replace(/-/g, '/'))
  if (Number.isNaN(date.getTime())) return String(timeStr).slice(0, 16)
  const now = new Date()
  const sameDay = date.toDateString() === now.toDateString()
  const time = `${String(date.getHours()).padStart(2, '0')}:${String(date.getMinutes()).padStart(2, '0')}`
  if (sameDay) return `今天 ${time}`
  return `${date.getMonth() + 1}月${date.getDate()}日 ${time}`
}

const shouldShowTimeDivider = (index) => {
  if (index === 0) return true
  const prev = messages.value[index - 1]
  const current = messages.value[index]
  if (!prev?.createTime || !current?.createTime) return false
  const prevTime = new Date(String(prev.createTime).replace(/-/g, '/')).getTime()
  const currentTime = new Date(String(current.createTime).replace(/-/g, '/')).getTime()
  return currentTime - prevTime > 10 * 60 * 1000
}

const getStatusText = (status) => {
  const map = {
    0: '待支付',
    1: '生产中',
    2: '待发货',
    3: '待收货',
    4: '已完成',
    5: '已取消',
    6: '待付尾款'
  }
  return map[status] || ''
}
</script>

<style lang="scss" scoped>
.chat-page {
  min-height: 100vh;
  display: flex;
  flex-direction: column;
  background: #f5f1eb;
}

:global(page) {
  background: #f5f1eb;
}

.connection-bar {
  padding: 12rpx 24rpx;
  background: rgba(230, 89, 89, 0.1);
  text-align: center;
}

.connection-bar__text {
  font-size: 22rpx;
  color: #cb5454;
}

.context-bar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 20rpx;
  padding: 22rpx 24rpx;
  background: rgba(255, 255, 255, 0.88);
  border-bottom: 1rpx solid rgba(201, 198, 192, 0.6);
  box-shadow: 0 6rpx 18rpx rgba(26, 43, 60, 0.04);
}

.context-main {
  display: flex;
  align-items: center;
  gap: 16rpx;
  flex: 1;
  min-width: 0;
}

.context-cover {
  width: 76rpx;
  height: 76rpx;
  border-radius: 18rpx;
  overflow: hidden;
  background: #eef1f5;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.context-cover__image {
  width: 100%;
  height: 100%;
}

.context-cover__fallback {
  color: #1a2b3c;
  font-size: 28rpx;
  font-weight: 700;
}

.context-copy {
  min-width: 0;
}

.context-title {
  display: block;
  font-size: 28rpx;
  color: #1a2b3c;
  font-weight: 700;
}

.context-subtitle {
  display: block;
  margin-top: 6rpx;
  font-size: 22rpx;
  color: #6d7385;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.context-side__badge {
  display: inline-flex;
  padding: 10rpx 16rpx;
  border-radius: 999rpx;
  background: #edf2fb;
  color: #42557b;
  font-size: 20rpx;
  font-weight: 600;
}

.message-area {
  flex: 1;
  background: #f5f1eb;
}

.message-canvas {
  padding: 28rpx 24rpx 12rpx;
  min-height: 100%;
  background: #f5f1eb;
}

.time-divider {
  display: flex;
  justify-content: center;
  margin: 12rpx 0 18rpx;
}

.time-divider__text {
  padding: 8rpx 18rpx;
  border-radius: 999rpx;
  background: rgba(255, 255, 255, 0.66);
  color: #888d9b;
  font-size: 20rpx;
}

.msg-row {
  display: flex;
  align-items: flex-end;
  gap: 14rpx;
  margin-bottom: 22rpx;
}

.msg-row.is-mine {
  flex-direction: row-reverse;
}

.msg-avatar {
  width: 64rpx;
  height: 64rpx;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  overflow: hidden;
  flex-shrink: 0;
}

.msg-avatar--other {
  background: #dce4ec;
  color: #1a2b3c;
}

.msg-avatar--assistant {
  background: #ebe7ee;
  color: #5f4f73;
}

.msg-avatar--mine {
  background: #24364d;
  color: #fff;
}

.msg-avatar__text {
  font-size: 22rpx;
  font-weight: 700;
}

.msg-content {
  max-width: 78%;
  display: flex;
  flex-direction: column;
}

.is-mine .msg-content {
  align-items: flex-end;
}

.assistant-tag {
  display: inline-flex;
  align-items: center;
  gap: 8rpx;
  margin-bottom: 8rpx;
  padding: 6rpx 12rpx;
  border-radius: 999rpx;
  background: rgba(255, 255, 255, 0.76);
}

.assistant-tag__icon,
.assistant-tag__text {
  color: #41557d;
}

.assistant-tag__text {
  font-size: 18rpx;
  font-weight: 600;
  letter-spacing: 1rpx;
}

.msg-bubble {
  padding: 22rpx 24rpx;
  border-radius: 26rpx;
  border: 1rpx solid rgba(209, 206, 200, 0.66);
  word-break: break-word;
  box-shadow: 0 8rpx 20rpx rgba(26, 43, 60, 0.04);
}

.msg-bubble--other {
  background: #ffffff;
  border-bottom-left-radius: 10rpx;
}

.msg-bubble--assistant {
  background: #f5f4f7;
  border-bottom-left-radius: 10rpx;
}

.msg-bubble--mine {
  background: #1a2b3c;
  border-color: transparent;
  border-bottom-right-radius: 10rpx;
}

.msg-text {
  font-size: 28rpx;
  line-height: 1.72;
  color: #1f222c;
}

.msg-bubble--mine .msg-text {
  color: #fff;
}

.msg-image {
  display: block;
  width: 360rpx;
  max-width: 100%;
  min-height: 180rpx;
  border-radius: 18rpx;
}

.progress-card {
  width: 480rpx;
  padding: 6rpx 2rpx 2rpx;
}

.progress-card__head {
  display: flex;
  justify-content: space-between;
  gap: 20rpx;
  margin-bottom: 22rpx;
}

.progress-card__kicker,
.progress-card__label {
  display: block;
  font-size: 20rpx;
  color: #74777d;
}

.progress-card__title {
  display: block;
  margin-top: 6rpx;
  font-size: 30rpx;
  font-weight: 700;
  color: #1a2b3c;
}

.progress-card__status {
  height: 42rpx;
  padding: 0 16rpx;
  border-radius: 999rpx;
  background: #c8eadc;
  color: #2d4b41;
  font-size: 21rpx;
  line-height: 42rpx;
  flex-shrink: 0;
}

.progress-card__body {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 16rpx;
}

.progress-card__metric {
  padding: 18rpx;
  border-radius: 16rpx;
  background: #ffffff;
  border: 1rpx solid rgba(229, 226, 218, 0.8);
}

.progress-card__value {
  display: block;
  margin-top: 8rpx;
  font-size: 25rpx;
  color: #1a2b3c;
  font-weight: 700;
}

.progress-card__track {
  margin: 24rpx 0 16rpx;
  display: flex;
  align-items: center;
  gap: 10rpx;
}

.progress-card__dot {
  flex: 1;
  height: 8rpx;
  border-radius: 999rpx;
  background: #e4e2e3;
}

.progress-card__dot.active {
  background: #1a2b3c;
}

.progress-card__latest {
  display: block;
  padding: 14rpx 16rpx;
  border-radius: 14rpx;
  background: rgba(210, 228, 251, 0.5);
  color: #38485a;
  font-size: 22rpx;
  line-height: 1.5;
}

.progress-card__action {
  margin-top: 18rpx;
  padding-top: 18rpx;
  border-top: 1rpx solid rgba(229, 226, 218, 0.9);
  display: flex;
  justify-content: space-between;
  color: #1a2b3c;
  font-size: 24rpx;
  font-weight: 700;
}

.action-card {
  width: 480rpx;
  display: flex;
  gap: 22rpx;
}

.action-card__icon {
  width: 72rpx;
  height: 72rpx;
  flex-shrink: 0;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 18rpx;
  background: #1a2b3c;
  color: #ffffff;
  font-size: 28rpx;
  font-weight: 700;
}

.action-card__main {
  flex: 1;
  min-width: 0;
}

.action-card__title {
  display: block;
  font-size: 29rpx;
  color: #1a2b3c;
  font-weight: 700;
  line-height: 1.35;
}

.action-card__desc {
  display: block;
  margin-top: 10rpx;
  font-size: 23rpx;
  color: #6b6b6b;
  line-height: 1.55;
}

.action-card__button {
  margin-top: 18rpx;
  padding: 16rpx 18rpx;
  border-radius: 14rpx;
  background: #c8eadc;
  color: #2d4b41;
  display: flex;
  align-items: center;
  justify-content: space-between;
  font-size: 23rpx;
  font-weight: 700;
}

.file-card {
  width: 480rpx;
  display: flex;
  align-items: center;
  gap: 18rpx;
}

.file-card__icon {
  width: 84rpx;
  height: 84rpx;
  border-radius: 18rpx;
  background: #edf2fb;
  color: #42557b;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 20rpx;
  font-weight: 800;
  flex-shrink: 0;
}

.file-card__main {
  min-width: 0;
  flex: 1;
}

.file-card__button {
  flex-shrink: 0;
  padding: 12rpx 20rpx;
  border-radius: 999rpx;
  background: rgba(75, 123, 236, 0.12);
  color: #2f6fed;
  font-size: 23rpx;
  font-weight: 700;
}

.file-card__name {
  display: block;
  font-size: 27rpx;
  color: #1a2b3c;
  font-weight: 700;
  line-height: 1.4;
  word-break: break-all;
}

.file-card__meta {
  display: block;
  margin-top: 8rpx;
  font-size: 22rpx;
  color: #6d7385;
}

.handoff-card {
  display: flex;
  align-items: center;
  gap: 18rpx;
  padding: 18rpx;
  border-radius: 18rpx;
  background: #fff7ed;
  border: 1rpx solid rgba(249, 115, 22, 0.28);
}

.handoff-card__icon {
  width: 48rpx;
  height: 48rpx;
  border-radius: 999rpx;
  background: #f97316;
  color: #ffffff;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 28rpx;
  font-weight: 800;
  flex-shrink: 0;
}

.handoff-card__main {
  min-width: 0;
}

.handoff-card__title {
  display: block;
  color: #9a3412;
  font-size: 27rpx;
  font-weight: 800;
}

.handoff-card__desc {
  display: block;
  margin-top: 6rpx;
  color: #7c2d12;
  font-size: 22rpx;
  line-height: 1.45;
}

.handoff-card--resolved {
  background: #f0fdf4;
  border-color: rgba(34, 197, 94, 0.26);
}

.handoff-card--resolved .handoff-card__icon {
  background: #22c55e;
}

.handoff-card--resolved .handoff-card__title {
  color: #166534;
}

.handoff-card--resolved .handoff-card__desc {
  color: #15803d;
}

.msg-time {
  margin-top: 10rpx;
  font-size: 20rpx;
  color: #9a9eaa;
}

.message-bottom-space {
  height: 24rpx;
}

.input-area {
  padding: 16rpx 24rpx calc(16rpx + env(safe-area-inset-bottom));
  background: rgba(255, 255, 255, 0.9);
  backdrop-filter: blur(10rpx);
  border-top: 1rpx solid rgba(206, 202, 195, 0.5);
  box-shadow: 0 -6rpx 24rpx rgba(26, 43, 60, 0.03);
}

.handoff-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 16rpx;
  margin-bottom: 14rpx;
}

.handoff-btn {
  display: inline-flex;
  align-items: center;
  gap: 10rpx;
  padding: 12rpx 18rpx;
  border-radius: 999rpx;
  background: #fff4ed;
  color: #b45309;
  font-size: 23rpx;
  font-weight: 700;
  border: 1rpx solid rgba(245, 158, 11, 0.28);
}

.handoff-btn.disabled {
  opacity: 0.58;
}

.handoff-btn__dot {
  width: 12rpx;
  height: 12rpx;
  border-radius: 999rpx;
  background: #f97316;
  box-shadow: 0 0 0 6rpx rgba(249, 115, 22, 0.12);
}

.handoff-hint {
  flex: 1;
  text-align: right;
  font-size: 21rpx;
  color: #8b8f9a;
}

.input-shell {
  display: flex;
  align-items: flex-end;
  gap: 14rpx;
  padding: 10rpx;
  border-radius: 24rpx;
  background: #f3f1ed;
  border: 1rpx solid rgba(206, 202, 195, 0.72);
}

.media-btn,
.send-btn {
  width: 72rpx;
  height: 72rpx;
  border-radius: 20rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.media-btn {
  background: rgba(255, 255, 255, 0.84);
}

.media-btn__icon {
  font-size: 34rpx;
  color: #6f7587;
}

.chat-input {
  flex: 1;
  min-height: 40rpx;
  max-height: 160rpx;
  padding: 12rpx 0;
  font-size: 28rpx;
  line-height: 1.6;
  color: #1f222c;
  background: transparent;
}

.send-btn {
  background: #1a2b3c;
}

.send-btn--disabled {
  background: #a3a8b5;
}

.send-btn__icon {
  font-size: 26rpx;
  color: #fff;
}
</style>
