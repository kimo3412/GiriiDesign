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
                <image
                  v-if="isImageMsg(msg)"
                  class="msg-image"
                  :src="msg.content"
                  mode="widthFix"
                  @click="previewImage(msg.content)"
                />
                <text v-else class="msg-text">{{ msg.content }}</text>
              </view>

              <text class="msg-time">{{ formatTime(msg.createTime) }}</text>
            </view>
          </view>
        </view>
        <view class="message-bottom-space"></view>
      </view>
    </scroll-view>

    <view class="input-area">
      <view class="input-shell">
        <view class="media-btn" @click="chooseImage">
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
import request from '@/utils/request'
import storage from '@/utils/storage'

const messages = ref([])
const inputText = ref('')
const scrollToId = ref('')
const chatOrderId = ref(null)
const isConnected = ref(false)
const reconnecting = ref(false)
const orderInfo = ref({})

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

const chooseImage = () => {
  if (!isConnected.value) {
    uni.showToast({ title: '连接已断开', icon: 'none' })
    return
  }
  uni.chooseImage({
    count: 1,
    sizeType: ['compressed'],
    success: (res) => {
      sendMessage(res.tempFilePaths[0], 'image')
    }
  })
}

const sendMessage = (content, msgType) => {
  if (!socketTask || !isConnected.value) {
    uni.showToast({ title: '连接已断开', icon: 'none' })
    return
  }

  socketTask.send({
    data: JSON.stringify({
      type: 'SEND',
      content,
      msgType,
      orderId: chatOrderId.value
    })
  })

  messages.value.push({
    senderType: 'client',
    content,
    msgType,
    orderId: chatOrderId.value,
    createTime: new Date().toISOString().replace('T', ' ').substring(0, 19)
  })
  scrollToBottom()
}

const scrollToBottom = () => {
  nextTick(() => {
    if (!messages.value.length) return
    scrollToId.value = ''
    setTimeout(() => {
      scrollToId.value = `msg-${messages.value.length - 1}`
    }, 50)
  })
}

const previewImage = (url) => {
  uni.previewImage({ urls: [url], current: url })
}

const isMyMsg = (msg) => msg.senderType === 'client' || msg.senderType === 0
const isAssistantMsg = (msg) => msg.senderType === 2 || msg.senderType === 'ai'
const isImageMsg = (msg) => msg.msgType === 'image' || msg.contentType === 1

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
  height: 100vh;
  display: flex;
  flex-direction: column;
  background:
    radial-gradient(circle at top right, rgba(146, 170, 218, 0.14), transparent 28%),
    linear-gradient(180deg, #faf8f5 0%, #f5f1eb 100%);
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
}

.message-canvas {
  padding: 28rpx 24rpx 12rpx;
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
  width: 100%;
  max-width: 360rpx;
  border-radius: 18rpx;
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
