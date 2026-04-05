<template>
  <view class="chat-page">
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
            <view class="msg-bubble">
              <!-- 图片 -->
              <image
                v-if="isImageMsg(msg)"
                class="msg-image"
                :src="msg.content"
                mode="widthFix"
                @click="previewImage(msg.content)"
              />
              <!-- 文字 -->
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
          <view class="send-btn" @click="sendTextMsg">
            <text class="send-text">发送</text>
          </view>
        </view>
      </view>
    </view>
  </view>
</template>

<script setup>
import { ref, onUnmounted, nextTick } from 'vue'
import { onLoad } from '@dcloudio/uni-app'
import request from '@/utils/request'
import storage from '@/utils/storage'

const orderId = ref(0)
const messages = ref([])
const inputText = ref('')
const scrollToId = ref('')

let socketTask = null

onLoad((options) => {
  orderId.value = Number(options.orderId || 0)
  uni.setNavigationBarTitle({ title: `订单 #${orderId.value} 沟通` })
  fetchHistory()
  connectWS()
})

onUnmounted(() => {
  if (socketTask) {
    socketTask.close({ code: 1000, reason: '页面关闭' })
    socketTask = null
  }
})

const fetchHistory = async () => {
  try {
    const data = await request({
      url: `/v1/app/chat/${orderId.value}`,
      method: 'GET'
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
    complete: () => {}
  })

  socketTask.onOpen(() => {
    console.log('WebSocket 已连接')
  })

  socketTask.onMessage((res) => {
    try {
      const msg = JSON.parse(res.data)
      if (msg.type === 'NEW_MSG' && msg.orderId === orderId.value) {
        messages.value.push(msg)
        scrollToBottom()
      }
    } catch (e) {
      console.error('解析消息失败', e)
    }
  })

  socketTask.onClose(() => {
    console.log('WebSocket 已断开')
  })

  socketTask.onError((err) => {
    console.error('WebSocket 错误', err)
  })
}

const sendTextMsg = () => {
  const text = inputText.value.trim()
  if (!text) return
  sendMessage(text, 'text')
  inputText.value = ''
}

const chooseImage = () => {
  uni.chooseImage({
    count: 1,
    sizeType: ['compressed'],
    success: (res) => {
      // 暂时用本地路径发送
      sendMessage(res.tempFilePaths[0], 'image')
    }
  })
}

const sendMessage = (content, msgType) => {
  if (!socketTask) {
    uni.showToast({ title: '连接已断开', icon: 'none' })
    return
  }

  socketTask.send({
    data: JSON.stringify({
      type: 'SEND',
      orderId: orderId.value,
      content: content,
      msgType: msgType
    })
  })

  messages.value.push({
    orderId: orderId.value,
    senderType: 'client',
    content: content,
    msgType: msgType,
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

/* 消息区 */
.message-area {
  flex: 1;
  overflow: hidden;
}

.msg-list {
  padding: 20rpx 24rpx;
}

/* 消息行 */
.msg-row {
  display: flex;
  margin-bottom: 28rpx;
  align-items: flex-start;
}

.msg-row.is-mine {
  flex-direction: row-reverse;
}

/* 头像 */
.msg-avatar {
  width: 64rpx;
  height: 64rpx;
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

/* 消息体 */
.msg-body {
  max-width: 65%;
  display: flex;
  flex-direction: column;
}

.is-mine .msg-body {
  align-items: flex-end;
}

.is-other .msg-body {
  align-items: flex-start;
}

/* 气泡 */
.msg-bubble {
  padding: 20rpx 28rpx;
  border-radius: 20rpx;
  word-break: break-all;
  line-height: 1.5;
}

.is-other .msg-bubble {
  background: #FFFFFF;
  border-top-left-radius: 4rpx;
  box-shadow: 0 2rpx 8rpx rgba(0,0,0,0.04);
}

.is-mine .msg-bubble {
  background: #4A5D4E;
  border-top-right-radius: 4rpx;
}

.is-mine .msg-text {
  color: #fff;
}

.is-other .msg-text {
  color: #333;
}

.msg-text {
  font-size: 28rpx;
  letter-spacing: 1rpx;
}

.msg-image {
  max-width: 400rpx;
  border-radius: 12rpx;
}

.msg-time {
  font-size: 20rpx;
  color: #aaa;
  margin-top: 8rpx;
  letter-spacing: 1rpx;
}

/* 输入区 */
.input-area {
  background: #fff;
  border-top: 1rpx solid #E8E4E0;
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
}

.send-text {
  color: #fff;
  font-size: 26rpx;
  letter-spacing: 2rpx;
}
</style>
