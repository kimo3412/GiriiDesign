<template>
  <view class="chat-container">
    <!-- 消息列表 -->
    <scroll-view
      class="message-list"
      scroll-y
      :scroll-into-view="scrollToId"
      scroll-with-animation
    >
      <view class="msg-padding"></view>
      <view
        v-for="(msg, index) in messages"
        :key="msg.messageId || index"
        :id="'msg-' + index"
        :class="['msg-row', msg.senderType === 'client' ? 'msg-right' : 'msg-left']"
      >
        <view class="msg-bubble">
          <!-- 图片消息 -->
          <image
            v-if="msg.msgType === 'image'"
            class="msg-image"
            :src="msg.content"
            mode="widthFix"
            @click="previewImage(msg.content)"
          />
          <!-- 文字消息 -->
          <text v-else class="msg-text">{{ msg.content }}</text>
        </view>
        <text class="msg-time">{{ formatTime(msg.createTime) }}</text>
      </view>
      <view class="msg-padding-bottom"></view>
    </scroll-view>

    <!-- 输入区域 -->
    <view class="input-bar">
      <view class="input-wrap">
        <input
          v-model="inputText"
          class="input"
          placeholder="输入消息..."
          confirm-type="send"
          @confirm="sendTextMsg"
        />
      </view>
      <view class="action-btns">
        <view class="icon-btn" @click="chooseImage">
          <text class="icon-text">📷</text>
        </view>
        <view class="send-btn" @click="sendTextMsg">
          <text class="send-text">发送</text>
        </view>
      </view>
    </view>
  </view>
</template>

<script setup>
import { ref, onUnmounted, nextTick } from 'vue'
import { onLoad } from '@dcloudio/uni-app'
import { uploadFile } from '@/api/upload'
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

  // 1. 先拉取历史消息
  fetchHistory()

  // 2. 建立 WebSocket
  connectWS()
})

onUnmounted(() => {
  if (socketTask) {
    socketTask.close({ code: 1000, reason: '页面关闭' })
    socketTask = null
  }
})

/**
 * 获取历史消息
 */
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

/**
 * 建立 WebSocket 连接
 */
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
      } else if (msg.type === 'SEND_ACK') {
        // 发送确认，可以做消息状态更新
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

/**
 * 发送文字消息
 */
const sendTextMsg = () => {
  const text = inputText.value.trim()
  if (!text) return

  sendMessage(text, 'text')
  inputText.value = ''
}

/**
 * 选择并发送图片
 */
const chooseImage = () => {
  uni.chooseImage({
    count: 1,
    sizeType: ['compressed'],
    success: async (res) => {
      uni.showLoading({ title: '发送中...' })
      try {
        const url = await uploadFile(res.tempFilePaths[0])
        sendMessage(url, 'image')
        uni.hideLoading()
      } catch (err) {
        uni.hideLoading()
        uni.showToast({ title: '图片发送失败', icon: 'none' })
      }
    }
  })
}

/**
 * 通过 WebSocket 发送消息
 */
const sendMessage = (content, msgType) => {
  if (!socketTask) {
    uni.showToast({ title: '连接已断开', icon: 'none' })
    return
  }

  const payload = JSON.stringify({
    type: 'SEND',
    orderId: orderId.value,
    content: content,
    msgType: msgType
  })

  socketTask.send({ data: payload })

  // 本地先展示（乐观更新）
  messages.value.push({
    orderId: orderId.value,
    senderType: 'client',
    content: content,
    msgType: msgType,
    createTime: new Date().toLocaleString()
  })
  scrollToBottom()
}

/**
 * 滚动到底部
 */
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

/**
 * 预览大图
 */
const previewImage = (url) => {
  uni.previewImage({ urls: [url], current: url })
}

/**
 * 格式化时间
 */
const formatTime = (timeStr) => {
  if (!timeStr) return ''
  return timeStr.substring(11, 16) // HH:mm
}
</script>

<style lang="scss" scoped>
.chat-container {
  display: flex;
  flex-direction: column;
  height: 100vh;
  background: #f5f5f5;
}

.message-list {
  flex: 1;
  padding: 0 24rpx;
}

.msg-padding {
  height: 20rpx;
}

.msg-padding-bottom {
  height: 20rpx;
}

.msg-row {
  display: flex;
  flex-direction: column;
  margin-bottom: 24rpx;
}

.msg-left {
  align-items: flex-start;
}

.msg-right {
  align-items: flex-end;
}

.msg-bubble {
  max-width: 70%;
  padding: 20rpx 28rpx;
  border-radius: 4rpx;
  word-break: break-all;
}

.msg-left .msg-bubble {
  background: #ffffff;
  border: 1px solid #e8e8e8;
}

.msg-right .msg-bubble {
  background: #1a1a1a;
  color: #ffffff;
}

.msg-text {
  font-size: 26rpx;
  line-height: 1.6;
  letter-spacing: 1rpx;
}

.msg-image {
  max-width: 400rpx;
  border-radius: 4rpx;
}

.msg-time {
  font-size: 18rpx;
  color: #999;
  margin-top: 8rpx;
  letter-spacing: 1rpx;
}

.input-bar {
  display: flex;
  align-items: center;
  padding: 16rpx 24rpx;
  padding-bottom: calc(16rpx + env(safe-area-inset-bottom));
  background: #ffffff;
  border-top: 1px solid #e8e8e8;
  gap: 16rpx;
}

.input-wrap {
  flex: 1;
}

.input {
  height: 72rpx;
  background: #f5f5f5;
  padding: 0 24rpx;
  font-size: 26rpx;
  border: 1px solid #e8e8e8;
  border-radius: 0;
}

.action-btns {
  display: flex;
  align-items: center;
  gap: 12rpx;
}

.icon-btn {
  width: 72rpx;
  height: 72rpx;
  display: flex;
  align-items: center;
  justify-content: center;
}

.icon-text {
  font-size: 36rpx;
}

.send-btn {
  height: 72rpx;
  padding: 0 32rpx;
  background: #1a1a1a;
  display: flex;
  align-items: center;
  justify-content: center;
}

.send-text {
  color: #ffffff;
  font-size: 24rpx;
  letter-spacing: 2rpx;
}
</style>
