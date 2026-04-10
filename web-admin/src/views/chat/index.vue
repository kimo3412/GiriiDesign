<template>
  <div class="chat-page">
    <div class="chat-layout">
      <!-- 左侧：会话列表 -->
      <div class="panel-left">
        <div class="panel-header">
          <span class="panel-title">消息</span>
          <n-badge :value="totalUnread" :max="99" v-if="totalUnread > 0" />
        </div>
        <n-input
          v-model:value="searchText"
          placeholder="搜索订单号..."
          clearable
          size="small"
          style="margin: 0 12px 12px"
        />
        <div class="conv-scroll">
          <div
            v-for="conv in filteredConversations"
            :key="(conv.userId) + '_' + (conv.orderId || 'general')"
            class="conv-item"
            :class="{ active: activeUserId === conv.userId && activeOrderId == conv.orderId }"
            @click="selectConversation(conv)"
          >
            <div class="conv-avatar">
              <n-avatar round size="medium" :src="conv.avatar" v-if="conv.avatar" />
              <div v-else class="text-avatar">{{ String(conv.nickname || conv.username || conv.userId).slice(0, 1) }}</div>
            </div>
            <div class="conv-info">
              <div class="conv-top">
                <span class="conv-name">
                  {{ conv.nickname || conv.username || `用户#${conv.userId}` }}
                  <span v-if="conv.orderSn" class="conv-order-tag">{{ conv.orderSn }}</span>
                  <span v-else class="conv-order-tag conv-order-general">一般咨询</span>
                </span>
                <span class="conv-time-text">{{ formatTime(conv.lastTime) }}</span>
              </div>
              <div class="conv-bottom">
                <span class="conv-last">{{ conv.lastContent || '暂无消息' }}</span>
                <n-badge :value="conv.unreadCount" :max="99" v-if="conv.unreadCount > 0" />
              </div>
            </div>
          </div>
          <div v-if="filteredConversations.length === 0" class="conv-empty">
            暂无会话
          </div>
        </div>
      </div>

      <!-- 中间：聊天区 -->
      <div class="panel-center" v-if="activeUserId">
        <div class="chat-header">
          <div class="chat-header-left">
            <span class="chat-title">{{ activeUserName }}</span>
            <n-tag v-if="activeOrderSn" size="small" type="info" round>{{ activeOrderSn }}</n-tag>
            <n-tag v-else size="small" round>一般咨询</n-tag>
            <n-tag size="tiny" :type="wsConnected ? 'success' : 'default'" round>
              {{ wsConnected ? '在线' : '离线' }}
            </n-tag>
          </div>
          <n-button size="small" text @click="showOrderPanel = !showOrderPanel">
            {{ showOrderPanel ? '收起档案' : '客户档案 →' }}
          </n-button>
        </div>

        <div class="chat-messages" ref="messagesRef">
          <div v-if="messages.length === 0" class="msg-empty">
            <span>📨</span>
            <span>暂无消息，开始沟通吧</span>
          </div>
          <div
            v-for="(msg, idx) in messages"
            :key="msg.messageId || idx"
            :class="['msg-row', isAdminMsg(msg) ? 'is-admin' : 'is-client']"
          >
            <div class="msg-avatar">
              {{ isAdminMsg(msg) ? '管' : '客' }}
            </div>
            <div class="msg-body">
              <div class="msg-bubble">
                <n-image
                  v-if="isImageMsg(msg)"
                  :src="msg.content"
                  width="200"
                  style="border-radius: 6px"
                  preview-disabled
                />
                <span v-else class="msg-content">{{ msg.content }}</span>
              </div>
              <span class="msg-time">{{ formatMsgTime(msg.createTime) }}</span>
            </div>
          </div>
        </div>

        <div class="chat-input">
          <n-input
            v-model:value="inputText"
            type="textarea"
            :autosize="{ minRows: 1, maxRows: 4 }"
            placeholder="输入消息，Enter 发送..."
            @keydown.enter.exact.prevent="sendText"
          />
          <n-button type="primary" @click="sendText" :disabled="!inputText.trim()">
            发送
          </n-button>
        </div>
      </div>

      <!-- 未选择 -->
      <div class="panel-center panel-placeholder" v-else>
        <div class="placeholder-content">
          <span class="placeholder-icon">💬</span>
          <span class="placeholder-text">选择一个会话开始沟通</span>
        </div>
      </div>

      <!-- 右侧：客户档案面板 -->
      <transition name="slide-right">
        <div class="panel-right" v-if="activeUserId && showOrderPanel">
          <div class="panel-header">
            <span class="panel-title">客户档案</span>
            <n-button size="tiny" text @click="showOrderPanel = false">✕</n-button>
          </div>
          <div class="order-detail-scroll" v-if="userSummary">
            
            <div class="summary-block" v-if="userSummary.requests?.length > 0">
              <div class="summary-title">近期意向</div>
              <div class="summary-card" v-for="req in userSummary.requests" :key="req.requestId">
                <div class="summary-row">
                  <n-tag type="info" size="small">{{ req.status === 0 ? '待处理' : (req.status === 1 ? '已转单' : '已关闭') }}</n-tag>
                  <span class="summary-date">{{ formatMsgTime(req.createTime) }}</span>
                </div>
                <div class="summary-row">
                  品类: {{ getCategoryName(req.categoryId) }}
                </div>
              </div>
            </div>

            <div class="summary-block" v-if="userSummary.orders?.length > 0">
              <div class="summary-title">历史订单</div>
              <div class="summary-card" v-for="ord in userSummary.orders" :key="ord.orderId" @click="router.push(`/order/detail/${ord.orderId}`)" style="cursor: pointer;">
                <div class="summary-row">
                  <n-tag :type="statusMap[ord.status]?.type" size="small">{{ statusMap[ord.status]?.label }}</n-tag>
                  <span class="summary-sn">{{ ord.orderSn }}</span>
                </div>
                <div class="summary-row">
                  金额: ¥{{ ord.totalAmount || '0.00' }}
                </div>
              </div>
            </div>

            <div v-if="!userSummary.requests?.length && !userSummary.orders?.length" class="order-loading">
              该客户暂无业务记录
            </div>
          </div>
          <div v-else class="order-loading">加载中...</div>
        </div>
      </transition>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, nextTick, onMounted, onUnmounted } from 'vue';
import { useRouter } from 'vue-router';
import { useUser } from '@/store/modules/user';
import { getConversations as fetchConvApi, getChatMessages, markChatRead, getUserSummary as fetchUserSummaryApi } from '@/api/chat/index';
import { getCategoryList } from '@/api/config/category';

const router = useRouter();
const userStore = useUser();

const searchText = ref('');
const conversations = ref<any[]>([]);
const activeUserId = ref<number | null>(null);
const activeOrderId = ref<number | null>(null);
const activeUserName = ref('');
const activeOrderSn = ref('');
const messages = ref<any[]>([]);
const inputText = ref('');
const messagesRef = ref<HTMLElement | null>(null);
const wsConnected = ref(false);
const showOrderPanel = ref(true);
const userSummary = ref<any>(null);
const categoryMap = ref<Record<number, string>>({});

let ws: WebSocket | null = null;

const statusMap: any = {
  0: { label: '待支付', type: 'default' },
  1: { label: '生产中', type: 'info' },
  2: { label: '待发货', type: 'warning' },
  3: { label: '待收货', type: 'success' },
  4: { label: '已完成', type: 'success' },
  5: { label: '已取消', type: 'error' },
  6: { label: '待付尾款', type: 'warning' },
};

const getCategoryName = (id: number) => categoryMap.value[id] || `品类#${id}`;

const totalUnread = computed(() =>
  conversations.value.reduce((sum, c) => sum + (c.unread_count || 0), 0)
);

const filteredConversations = computed(() => {
  if (!searchText.value) return conversations.value;
  const kw = searchText.value.toLowerCase();
  return conversations.value.filter(
    (c: any) =>
      (c.orderSn || '').toLowerCase().includes(kw) ||
      (c.nickname || '').toLowerCase().includes(kw) ||
      (c.lastContent || '').toLowerCase().includes(kw)
  );
});



onMounted(async () => {
  fetchConversations();
  connectWS();
  try {
    const cats = await getCategoryList();
    categoryMap.value = Object.fromEntries(cats.map((c: any) => [c.categoryId, c.name]));
  } catch (e) { console.error(e); }
});

onUnmounted(() => {
  if (ws) { ws.close(); ws = null; }
});

const fetchConversations = async () => {
  try {
    const res = await fetchConvApi();
    conversations.value = res || [];
  } catch (e) { console.error('获取会话列表失败', e); }
};

const selectConversation = async (conv: any) => {
  activeUserId.value = conv.userId;
  activeOrderId.value = conv.orderId || null;
  activeUserName.value = conv.nickname || conv.username || `用户#${conv.userId}`;
  activeOrderSn.value = conv.orderSn || '';
  userSummary.value = null;

  try {
    const res = await getChatMessages(conv.userId, activeOrderId.value);
    messages.value = res || [];
    scrollToBottom();
    await markChatRead(conv.userId, activeOrderId.value);
    conv.unreadCount = 0;
  } catch (e) { console.error('获取聊天记录失败', e); }

  // 加载客户全纪录档案
  try {
    const detail = await fetchUserSummaryApi(conv.userId);
    userSummary.value = detail || null;
  } catch (e) { console.error('获取档案详情失败', e); }
};

const connectWS = () => {
  const token = userStore.getToken;
  if (!token) return;

  ws = new WebSocket(`ws://localhost:8081/ws/chat?token=${token}`);

  ws.onopen = () => { wsConnected.value = true; };

  ws.onmessage = (event) => {
    try {
      const msg = JSON.parse(event.data);
      if (msg.type === 'NEW_MSG') {
        if (msg.userId === activeUserId.value && (msg.orderId == activeOrderId.value)) {
          messages.value.push(msg);
          scrollToBottom();
        }
        fetchConversations();
      }
    } catch (e) { console.error('解析消息失败', e); }
  };

  ws.onclose = () => {
    wsConnected.value = false;
    setTimeout(connectWS, 5000);
  };

  ws.onerror = () => {};
};

const sendText = () => {
  const text = inputText.value.trim();
  if (!text || !activeUserId.value || !ws) return;

  ws.send(JSON.stringify({
    type: 'SEND',
    userId: activeUserId.value,
    orderId: activeOrderId.value,
    content: text,
    msgType: 'text',
  }));

  messages.value.push({
    userId: activeUserId.value,
    orderId: activeOrderId.value,
    senderType: 'admin',
    content: text,
    msgType: 'text',
    createTime: new Date().toISOString().replace('T', ' ').substring(0, 19),
  });

  inputText.value = '';
  scrollToBottom();
};

const scrollToBottom = () => {
  nextTick(() => {
    if (messagesRef.value) {
      messagesRef.value.scrollTop = messagesRef.value.scrollHeight;
    }
  });
};



const formatTime = (timeStr: string) => {
  if (!timeStr) return '';
  return String(timeStr).substring(5, 16);
};

const formatMsgTime = (timeStr: string) => {
  if (!timeStr) return '';
  return String(timeStr).substring(11, 16);
};

const isAdminMsg = (msg: any) => {
  return msg.senderType === 'admin' || msg.senderType === 1;
};

const isImageMsg = (msg: any) => {
  return msg.msgType === 'image' || msg.contentType === 1;
};
</script>

<style scoped>
.chat-page {
  height: calc(100vh - 100px);
  background: #f5f5f5;
  border-radius: 8px;
  overflow: hidden;
}

.chat-layout {
  display: flex;
  height: 100%;
  background: #fff;
  border-radius: 8px;
  overflow: hidden;
  box-shadow: 0 1px 4px rgba(0,0,0,0.06);
}

/* ========== 左侧会话面板 ========== */
.panel-left {
  width: 280px;
  flex-shrink: 0;
  border-right: 1px solid #f0f0f0;
  display: flex;
  flex-direction: column;
  background: #fafafa;
}

.panel-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 16px;
  font-weight: 600;
}

.panel-title {
  font-size: 15px;
  color: #1a1a2e;
}

.conv-scroll {
  flex: 1;
  overflow-y: auto;
}

.conv-item {
  display: flex;
  align-items: center;
  padding: 12px 16px;
  gap: 12px;
  cursor: pointer;
  transition: background 0.15s;
  border-left: 3px solid transparent;
}

.conv-item:hover { background: #f0f0f0; }

.conv-item.active {
  background: #EDF5EE;
  border-left-color: #5B8C5A;
}

.conv-avatar {
  width: 40px;
  height: 40px;
  border-radius: 8px;
  background: #5B8C5A;
  color: #fff;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 13px;
  font-weight: 600;
  flex-shrink: 0;
}

.conv-info {
  flex: 1;
  min-width: 0;
}

.conv-top {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 4px;
}

.conv-name {
  font-size: 13px;
  font-weight: 500;
  color: #333;
  display: flex;
  align-items: center;
  gap: 4px;
}

.conv-order-tag {
  font-size: 10px;
  padding: 1px 6px;
  border-radius: 3px;
  background: #e8f4fd;
  color: #1890ff;
  font-weight: normal;
}

.conv-order-general {
  background: #f0f0f0;
  color: #999;
}

.conv-time-text {
  font-size: 11px;
  color: #bbb;
}

.conv-bottom {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.conv-last {
  font-size: 12px;
  color: #999;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  flex: 1;
  margin-right: 8px;
}

.conv-empty {
  text-align: center;
  padding: 40px 0;
  color: #ccc;
  font-size: 13px;
}

/* ========== 中间聊天区 ========== */
.panel-center {
  flex: 1;
  display: flex;
  flex-direction: column;
  min-width: 0;
}

.panel-placeholder {
  align-items: center;
  justify-content: center;
}

.placeholder-content {
  text-align: center;
}

.placeholder-icon {
  display: block;
  font-size: 48px;
  margin-bottom: 12px;
}

.placeholder-text {
  font-size: 14px;
  color: #999;
}

.chat-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 12px 20px;
  border-bottom: 1px solid #f0f0f0;
  background: #fff;
}

.chat-header-left {
  display: flex;
  align-items: center;
  gap: 8px;
}

.chat-title {
  font-weight: 600;
  font-size: 14px;
  color: #1a1a2e;
}

.chat-messages {
  flex: 1;
  overflow-y: auto;
  padding: 16px 20px;
  background: #f9f9f9;
}

.msg-empty {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  height: 100%;
  gap: 8px;
  color: #ccc;
  font-size: 14px;
}

.msg-empty span:first-child { font-size: 32px; }

.msg-row {
  display: flex;
  margin-bottom: 20px;
  align-items: flex-start;
  gap: 10px;
}

.msg-row.is-admin {
  flex-direction: row-reverse;
}

.msg-avatar {
  width: 36px;
  height: 36px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 12px;
  font-weight: 600;
  color: #fff;
  flex-shrink: 0;
}

.is-client .msg-avatar { background: #E5A84B; }
.is-admin .msg-avatar { background: #5B8C5A; }

.msg-body {
  max-width: 55%;
  display: flex;
  flex-direction: column;
}

.is-admin .msg-body { align-items: flex-end; }
.is-client .msg-body { align-items: flex-start; }

.msg-bubble {
  padding: 10px 16px;
  border-radius: 12px;
  font-size: 14px;
  line-height: 1.6;
  word-break: break-all;
}

.is-client .msg-bubble {
  background: #fff;
  color: #333;
  border-top-left-radius: 4px;
  box-shadow: 0 1px 4px rgba(0,0,0,0.04);
}

.is-admin .msg-bubble {
  background: #5B8C5A;
  color: #fff;
  border-top-right-radius: 4px;
}

.msg-content {
  white-space: pre-wrap;
}

.msg-time {
  font-size: 11px;
  color: #bbb;
  margin-top: 4px;
}

.chat-input {
  display: flex;
  gap: 8px;
  padding: 12px 20px;
  border-top: 1px solid #f0f0f0;
  background: #fff;
  align-items: flex-end;
}

/* ========== 右侧订单面板 ========== */
.panel-right {
  width: 300px;
  flex-shrink: 0;
  border-left: 1px solid #f0f0f0;
  display: flex;
  flex-direction: column;
  background: #fafafa;
}

.order-detail-scroll {
  flex: 1;
  overflow-y: auto;
  padding: 16px;
}

.order-loading {
  padding: 40px;
  text-align: center;
  color: #ccc;
}

.order-status-card {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-bottom: 20px;
  padding: 12px;
  background: #fff;
  border-radius: 8px;
  box-shadow: 0 1px 4px rgba(0,0,0,0.04);
}

.order-sn {
  font-size: 12px;
  color: #888;
  font-family: 'Monaco', 'Consolas', monospace;
}

.detail-section {
  display: flex;
  justify-content: space-between;
  padding: 8px 0;
  border-bottom: 1px solid #f5f5f5;
}

.detail-label {
  font-size: 12px;
  color: #999;
}

.detail-value {
  font-size: 13px;
  color: #333;
  font-weight: 500;
  text-align: right;
}

.detail-value.amount {
  color: #e74c3c;
  font-weight: 600;
}

.custom-section {
  margin-top: 16px;
  padding: 12px;
  background: #fff;
  border-radius: 8px;
}

.custom-title {
  font-size: 12px;
  color: #999;
  margin-bottom: 8px;
  font-weight: 600;
}

.custom-row {
  display: flex;
  justify-content: space-between;
  padding: 4px 0;
  font-size: 12px;
}

.custom-key { color: #888; }
.custom-val { color: #333; font-weight: 500; }

.detail-actions {
  margin-top: 16px;
}

/* 动画 */
.slide-right-enter-active,
.slide-right-leave-active {
  transition: all 0.25s ease;
}

.slide-right-enter-from,
.slide-right-leave-to {
  width: 0;
  opacity: 0;
  overflow: hidden;
}
</style>
