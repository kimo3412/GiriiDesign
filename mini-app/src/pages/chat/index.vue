<template>
  <view class="chat-page">
    <!-- 连接状态栏 -->
    <view v-if="!isConnected" class="connection-bar">
      <text class="connection-bar__text">{{ reconnecting ? '正在重连...' : '连接已断开' }}</text>
    </view>

    <!-- 消息列表 -->
    <scroll-view
      class="message-area"
      scroll-y
      :scroll-into-view="scrollToId"
      scroll-with-animation
    >
      <view class="msg-list">
        <view
          v-for="(msg, index) in messages"
          :key="msg.messageId || index"
          :id="'msg-' + index"
          :class="['msg-row', isMyMsg(msg) ? 'is-mine' : 'is-other']"
        >
          <!-- 头像 -->
          <view class="msg-avatar">
            <text class="avatar-text">{{ isMyMsg(msg) ? '我' : '师' }}</text>
          </view>

          <!-- 消息体 -->
          <view class="msg-body">
            <view class="msg-bubble" :class="isMyMsg(msg) ? 'bubble--mine' : 'bubble--other'">
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
      <view style="height: 20rpx;"></view>
    </scroll-view>

    <!-- 输入区 -->
    <view class="input-area">
      <view class="input-row">
        <input
          v-model="inputText"
          class="chat-input"
          placeholder="输入消息..."
          confirm-type="send"
          @confirm="sendTextMsg"
        />
        <view class="btn-group">
          <view class="icon-btn" @click="chooseImage">
            <text>📷</text>
          </view>
          <view
            class="send-btn"
            :class="{ 'send-btn--disabled': !canSend }"
            @click="sendTextMsg"
          >
            <text class="send-text">发送</text>
          </view>
        </view>
      </view>
    </view>
  </view>
</template>

<script setup>
import { ref, computed, onUnmounted, nextTick } from 'vue'
import { onLoad } from '@dcloudio/uni-app'
import request from '@/utils/request'
import storage from '@/utils/storage'

const messages = ref([])
const inputText = ref('')
const scrollToId = ref('')
const chatOrderId = ref(null)
const isConnected = ref(false)
const reconnecting = ref(false)

let socketTask = null
let reconnectTimer = null
let reconnectAttempts = 0
const MAX_RECONNECT = 5
const RECONNECT_DELAY = 3000

const canSend = computed(() => {
  return isConnected.value && inputText.value.trim().length > 0
})

onLoad((options) => {
  if (options && options.orderId) {
    chatOrderId.value = Number(options.orderId)
    uni.setNavigationBarTitle({ title: '订单咨询' })
  } else {
    uni.setNavigationBarTitle({ title: '专属客服' })
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
    reconnectAttempts++
    connectWS()
  }, RECONNECT_DELAY)
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

  const wsUrl = 'ws://localhost:8081/ws/chat?token=' + token

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
        if (msg.orderId == chatOrderId.value) {
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
      content: content,
      msgType: msgType,
      orderId: chatOrderId.value
    })
  })

  messages.value.push({
    senderType: 'client',
    content: content,
    msgType: msgType,
    orderId: chatOrderId.value,
    createTime: new Date().toISOString().replace('T', ' ').substring(0, 19)
  })
  scrollToBottom()
}

const scrollToBottom = () => {
  nextTick(() => {
    if (messages.value.length > 0) {
      scrollToId.value = ''
      setTimeout(() => {
        scrollToId.value = 'msg-' + (messages.value.length - 1)
      }, 50)
    }
  })
}

const previewImage = (url) => {
  uni.previewImage({ urls: [url], current: url })
}

const formatTime = (timeStr) => {
  if (!timeStr) return ''
  return String(timeStr).substring(11, 16)
}

const isMyMsg = (msg) => {
  return msg.senderType === 'client' || msg.senderType === 0
}

const isImageMsg = (msg) => {
  return msg.msgType === 'image' || msg.contentType === 1
}
</script>

<style lang="scss" scoped>
.chat-page {
  display: flex;
  flex-direction: column;
  height: 100vh;
  background: #F5F2EE;
}

.connection-bar {
  background: rgba(211, 60, 60, 0.1);
  padding: 10rpx 24rpx;
  text-align: center;
}

.connection-bar__text {
  font-size: 22rpx;
  color: #d35d6e;
}

.message-area {
  flex: 1;
  overflow: hidden;
}

.msg-list {
  padding: 20rpx 24rpx;
}

.msg-row {
  display: flex;
  margin-bottom: 28rpx;
  align-items: flex-start;
  animation: fadeInUp 0.2s ease;
}

@keyframes fadeInUp {
  from { opacity: 0; transform: translateY(10rpx); }
  to { opacity: 1; transform: translateY(0); }
}

.msg-row.is-mine {
  flex-direction: row-reverse;
}

.msg-avatar {
  width: 68rpx;
  height: 68rpx;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.is-other .msg-avatar {
  background: #4A5D4E;
  margin-right: 16rpx;
}

.is-mine .msg-avatar {
  background: #2C2C2C;
  margin-left: 16rpx;
}

.avatar-text {
  color: #fff;
  font-size: 22rpx;
  font-weight: 500;
}

.msg-body {
  max-width: 70%;
  display: flex;
  flex-direction: column;
}

.is-mine .msg-body { align-items: flex-end; }
.is-other .msg-body { align-items: flex-start; }

.msg-bubble {
  padding: 20rpx 28rpx;
  word-break: break-all;
  line-height: 1.6;
}

.bubble--other {
  background: #fff;
  border-radius: 4rpx 20rpx 20rpx 20rpx;
  box-shadow: 0 2rpx 10rpx rgba(0, 0, 0, 0.06);
}

.bubble--mine {
  background: #4A5D4E;
  border-radius: 20rpx 4rpx 20rpx 20rpx;
}

.msg-text {
  font-size: 28rpx;
  letter-spacing: 0.5px;
}

.bubble--mine .msg-text { color: #fff; }
.bubble--other .msg-text { color: #2c2c2c; }

.msg-image {
  max-width: 100%;
  border-radius: 14rpx;
}

.msg-time {
  font-size: 20rpx;
  color: #bbb;
  margin-top: 8rpx;
}

.input-area {
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(8rpx);
  -webkit-backdrop-filter: blur(8rpx);
  border-top: 1rpx solid #e8e4e0;
  padding: 16rpx 24rpx;
  padding-bottom: calc(16rpx + env(safe-area-inset-bottom));
}

.input-row {
  display: flex;
  align-items: center;
  gap: 16rpx;
}

.chat-input {
  flex: 1;
  height: 72rpx;
  background: #F5F2EE;
  padding: 0 24rpx;
  font-size: 28rpx;
  border-radius: 36rpx;
  border: none;
}

.btn-group {
  display: flex;
  align-items: center;
  gap: 12rpx;
  flex-shrink: 0;
}

.icon-btn {
  width: 72rpx;
  height: 72rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 36rpx;
}

.send-btn {
  height: 72rpx;
  padding: 0 32rpx;
  background: #4A5D4E;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 36rpx;
  transition: opacity 0.15s;

  &:active { opacity: 0.8; }
  &--disabled { background: #bbb; opacity: 0.6; }
}

.send-text {
  color: #fff;
  font-size: 26rpx;
  letter-spacing: 2rpx;
}
</style>
