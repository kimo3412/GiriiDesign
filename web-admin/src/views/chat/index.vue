<template>
  <n-card title="消息中心" :bordered="false">
    <div class="chat-layout">
      <!-- 左侧：会话列表 -->
      <div class="conversation-list">
        <n-input
          v-model:value="searchText"
          placeholder="搜索订单号..."
          clearable
          style="margin-bottom: 12px"
        />
        <n-list hoverable clickable>
          <n-list-item
            v-for="conv in filteredConversations"
            :key="conv.order_id"
            @click="selectConversation(conv)"
            :class="{ 'active-conv': activeOrderId === conv.order_id }"
          >
            <n-thing>
              <template #header>
                <div class="conv-header">
                  <span>订单 #{{ conv.order_no || conv.order_id }}</span>
                  <n-badge
                    v-if="conv.unread_count > 0"
                    :value="conv.unread_count"
                    type="error"
                  />
                </div>
              </template>
              <template #description>
                <div class="conv-desc">
                  <span class="conv-last-msg">{{ conv.last_content || '暂无消息' }}</span>
                  <span class="conv-time">{{ formatTime(conv.last_time) }}</span>
                </div>
              </template>
            </n-thing>
          </n-list-item>
          <n-empty v-if="filteredConversations.length === 0" description="暂无消息" />
        </n-list>
      </div>

      <!-- 右侧：聊天窗口 -->
      <div class="chat-window" v-if="activeOrderId">
        <div class="chat-header">
          <span>订单 #{{ activeOrderNo }} 沟通</span>
          <n-tag size="small" :type="wsConnected ? 'success' : 'error'">
            {{ wsConnected ? '已连接' : '未连接' }}
          </n-tag>
        </div>

        <div class="chat-messages" ref="messagesRef">
          <div
            v-for="(msg, idx) in messages"
            :key="msg.messageId || idx"
            :class="['msg-row', msg.senderType === 'admin' ? 'msg-right' : 'msg-left']"
          >
            <div class="msg-bubble">
              <n-image
                v-if="msg.msgType === 'image'"
                :src="msg.content"
                width="200"
                style="border-radius: 4px"
              />
              <span v-else>{{ msg.content }}</span>
            </div>
            <span class="msg-time">{{ formatMsgTime(msg.createTime) }}</span>
          </div>
          <n-empty v-if="messages.length === 0" description="开始聊天吧" />
        </div>

        <div class="chat-input">
          <n-input
            v-model:value="inputText"
            type="textarea"
            :autosize="{ minRows: 1, maxRows: 3 }"
            placeholder="输入消息，Enter 发送..."
            @keydown.enter.prevent="sendText"
          />
          <n-button type="primary" @click="sendText">发送</n-button>
        </div>
      </div>

      <!-- 未选择会话 -->
      <div class="chat-empty" v-else>
        <n-empty description="请从左侧选择一个会话">
          <template #icon>
            <n-icon size="60">
              <ChatboxEllipsesOutline />
            </n-icon>
          </template>
        </n-empty>
      </div>
    </div>
  </n-card>
</template>

<script setup lang="ts">
import { ref, computed, nextTick, onMounted, onUnmounted } from 'vue';
import { ChatboxEllipsesOutline } from '@vicons/ionicons5';
import { useUser } from '@/store/modules/user';
import { getConversations as fetchConvApi, getChatMessages, markChatRead } from '@/api/chat/index';

const userStore = useUser();

const searchText = ref('');
const conversations = ref<any[]>([]);
const activeOrderId = ref<number | null>(null);
const activeOrderNo = ref('');
const messages = ref<any[]>([]);
const inputText = ref('');
const messagesRef = ref<HTMLElement | null>(null);
const wsConnected = ref(false);

let ws: WebSocket | null = null;

const filteredConversations = computed(() => {
  if (!searchText.value) return conversations.value;
  return conversations.value.filter(
    (c: any) =>
      String(c.order_no || c.order_id).includes(searchText.value) ||
      (c.last_content || '').includes(searchText.value)
  );
});

onMounted(() => {
  fetchConversations();
  connectWS();
});

onUnmounted(() => {
  if (ws) {
    ws.close();
    ws = null;
  }
});

const fetchConversations = async () => {
  try {
    const res = await fetchConvApi();
    conversations.value = res || [];
  } catch (e) {
    console.error('获取会话列表失败', e);
  }
};

const selectConversation = async (conv: any) => {
  activeOrderId.value = conv.order_id;
  activeOrderNo.value = conv.order_no || conv.order_id;
  try {
    const res = await getChatMessages(conv.order_id);
    messages.value = res || [];
    scrollToBottom();
    await markChatRead(conv.order_id);
    conv.unread_count = 0;
  } catch (e) {
    console.error('获取聊天记录失败', e);
  }
};

const connectWS = () => {
  const token = userStore.getToken;
  if (!token) return;

  ws = new WebSocket(`ws://localhost:8081/ws/chat?token=${token}`);

  ws.onopen = () => {
    wsConnected.value = true;
  };

  ws.onmessage = (event) => {
    try {
      const msg = JSON.parse(event.data);
      if (msg.type === 'NEW_MSG') {
        if (msg.orderId === activeOrderId.value) {
          messages.value.push(msg);
          scrollToBottom();
        }
        fetchConversations();
      }
    } catch (e) {
      console.error('解析消息失败', e);
    }
  };

  ws.onclose = () => {
    wsConnected.value = false;
    setTimeout(connectWS, 5000);
  };

  ws.onerror = (err) => {
    console.error('WebSocket 错误', err);
  };
};

const sendText = () => {
  const text = inputText.value.trim();
  if (!text || !activeOrderId.value || !ws) return;

  ws.send(JSON.stringify({
    type: 'SEND',
    orderId: activeOrderId.value,
    content: text,
    msgType: 'text',
  }));

  messages.value.push({
    orderId: activeOrderId.value,
    senderType: 'admin',
    content: text,
    msgType: 'text',
    createTime: new Date().toLocaleString(),
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
  return timeStr.substring(5, 16);
};

const formatMsgTime = (timeStr: string) => {
  if (!timeStr) return '';
  return timeStr.substring(11, 16);
};
</script>

<style scoped>
.chat-layout {
  display: flex;
  height: calc(100vh - 200px);
  min-height: 500px;
  gap: 16px;
}

.conversation-list {
  width: 320px;
  flex-shrink: 0;
  border-right: 1px solid #e8e8e8;
  padding-right: 16px;
  overflow-y: auto;
}

.active-conv {
  background-color: #f0f9f4 !important;
}

.conv-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.conv-desc {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 8px;
}

.conv-last-msg {
  flex: 1;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  color: #999;
  font-size: 12px;
}

.conv-time {
  font-size: 11px;
  color: #bbb;
  white-space: nowrap;
}

.chat-window {
  flex: 1;
  display: flex;
  flex-direction: column;
}

.chat-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding-bottom: 12px;
  border-bottom: 1px solid #e8e8e8;
  font-weight: 500;
}

.chat-messages {
  flex: 1;
  overflow-y: auto;
  padding: 16px 0;
}

.msg-row {
  display: flex;
  flex-direction: column;
  margin-bottom: 16px;
}

.msg-left { align-items: flex-start; }
.msg-right { align-items: flex-end; }

.msg-bubble {
  max-width: 60%;
  padding: 10px 16px;
  border-radius: 8px;
  font-size: 14px;
  line-height: 1.5;
  word-break: break-all;
}

.msg-left .msg-bubble { background: #f5f5f5; color: #333; }
.msg-right .msg-bubble { background: #18a058; color: #fff; }

.msg-time {
  font-size: 11px;
  color: #bbb;
  margin-top: 4px;
}

.chat-input {
  display: flex;
  gap: 8px;
  padding-top: 12px;
  border-top: 1px solid #e8e8e8;
  align-items: flex-end;
}

.chat-empty {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
}
</style>
