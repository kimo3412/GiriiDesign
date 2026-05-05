<template>
  <div class="chat-page">
    <div class="chat-layout">
      <aside class="panel-left">
        <div class="panel-left__head">
          <div>
            <div class="panel-eyebrow">在线沟通</div>
            <div class="panel-title">会话列表</div>
          </div>
          <n-badge v-if="totalUnread > 0" :value="totalUnread" :max="99" />
        </div>

        <div class="panel-left__stats">
          <div class="summary-pill">
            <span class="summary-pill__label">会话</span>
            <strong>{{ conversations.length }}</strong>
          </div>
          <div class="summary-pill">
            <span class="summary-pill__label">未读</span>
            <strong>{{ totalUnread }}</strong>
          </div>
        </div>

        <div class="panel-left__search">
          <n-input
            v-model:value="searchText"
            placeholder="搜索订单号 / 客户"
            clearable
            size="small"
          >
            <template #prefix>🔍</template>
          </n-input>
        </div>

        <div class="conv-scroll">
          <button
            v-for="conv in filteredConversations"
            :key="`${conv.userId}_${conv.orderId || 'general'}`"
            class="conv-item"
            :class="{ active: activeUserId === conv.userId && activeOrderId == conv.orderId }"
            type="button"
            @click="selectConversation(conv)"
          >
            <div class="conv-avatar">
              <n-avatar v-if="conv.avatar" round size="medium" :src="conv.avatar" />
              <div v-else class="text-avatar">
                {{ String(conv.nickname || conv.username || conv.userId).slice(0, 1) }}
              </div>
            </div>

            <div class="conv-info">
              <div class="conv-top">
                <span class="conv-name">{{
                  conv.nickname || conv.username || `用户#${conv.userId}`
                }}</span>
                <span class="conv-time">{{ formatTime(conv.lastTime) }}</span>
              </div>
              <div class="conv-middle">
                <span v-if="conv.orderSn" class="conv-tag">{{ conv.orderSn }}</span>
                <span v-else class="conv-tag conv-tag--general">普通咨询</span>
                <div class="conv-alerts">
                  <span v-if="conv.handoffActive" class="conv-handoff-dot">转人工</span>
                  <n-badge v-if="conv.unreadCount > 0" :value="conv.unreadCount" :max="99" />
                </div>
              </div>
              <div class="conv-last">{{ conv.lastContent || '暂无消息' }}</div>
            </div>
          </button>

          <div v-if="filteredConversations.length === 0" class="conv-empty">暂无会话</div>
        </div>
      </aside>

      <main class="panel-center" v-if="activeUserId">
        <div class="chat-header">
          <div class="chat-header__main">
            <div class="chat-header__title">
              <strong>{{ activeUserName }}</strong>
              <span class="chat-header__status" :class="{ online: wsConnected }">
                {{ wsConnected ? '在线' : '离线' }}
              </span>
            </div>
            <div class="chat-header__meta">
              <span v-if="activeOrderSn" class="header-pill">{{ activeOrderSn }}</span>
              <span v-if="activeHandoff" class="header-pill header-pill--handoff">人工接入中</span>
              <span v-if="!activeOrderSn" class="header-pill header-pill--muted">普通咨询</span>
            </div>
          </div>

          <n-button
            v-if="activeHandoff"
            size="small"
            type="warning"
            ghost
            :loading="resolvingHandoff"
            @click="restoreAiService"
          >
            恢复AI客服
          </n-button>
          <n-button size="small" quaternary @click="showOrderPanel = !showOrderPanel">
            {{ showOrderPanel ? '收起档案' : '展开档案' }}
          </n-button>
        </div>

        <div class="chat-messages" ref="messagesRef">
          <div v-if="messages.length === 0" class="msg-empty">
            <div class="msg-empty__icon">💬</div>
            <div class="msg-empty__text">暂无消息，开始沟通吧</div>
          </div>

          <div
            v-for="(msg, idx) in messages"
            :key="msg.messageId || idx"
            class="msg-row"
            :class="isAdminMsg(msg) ? 'is-admin' : 'is-client'"
          >
            <div class="msg-avatar">
              {{ isAdminMsg(msg) ? '管' : '客' }}
            </div>
            <div class="msg-body">
              <div class="msg-bubble" :class="{ 'msg-bubble--card': isCardMsg(msg) }">
                <n-image
                  v-if="isImageMsg(msg)"
                  :src="imageMsgUrl(msg)"
                  width="200"
                  style="border-radius: 10px"
                />
                <div v-else-if="isFileMsg(msg)" class="chat-file" @click="openFileMsg(msg)">
                  <div class="chat-file__icon">FILE</div>
                  <div class="chat-file__main">
                    <div class="chat-file__name">{{ parseExtraJson(msg).fileName || getFileName(msg.content) }}</div>
                    <div class="chat-file__meta">{{ formatFileSize(parseExtraJson(msg).fileSize) || '点击打开文件' }}</div>
                  </div>
                  <button class="chat-file__button" type="button" @click.stop="openFileMsg(msg)">下载</button>
                </div>
                <div v-else-if="isProgressCardMsg(msg)" class="chat-card chat-card--progress">
                  <div class="chat-card__title">{{ parseExtraJson(msg).title || '订单进度' }}</div>
                  <div class="chat-card__desc">
                    {{ parseExtraJson(msg).orderSn || '定制订单' }} ·
                    {{ parseExtraJson(msg).statusText || parseExtraJson(msg).currentStepName || '处理中' }}
                  </div>
                  <div class="chat-card__meta">
                    当前节点：{{ parseExtraJson(msg).currentStepName || '-' }}
                  </div>
                </div>
                <div v-else-if="isHandoffRequestMsg(msg)" class="chat-card chat-card--handoff">
                  <div class="chat-card__title">{{ parseExtraJson(msg).title || '转人工请求' }}</div>
                  <div class="chat-card__desc">
                    {{ parseExtraJson(msg).description || msg.content }}
                  </div>
                </div>
                <div v-else-if="isHandoffResolvedMsg(msg)" class="chat-card chat-card--resolved">
                  <div class="chat-card__title">{{ parseExtraJson(msg).title || 'AI客服已恢复' }}</div>
                  <div class="chat-card__desc">
                    {{ parseExtraJson(msg).description || msg.content }}
                  </div>
                </div>
                <div v-else-if="isActionCardMsg(msg)" class="chat-card">
                  <div class="chat-card__title">{{ parseExtraJson(msg).title || msg.content }}</div>
                  <div class="chat-card__desc">
                    {{ parseExtraJson(msg).description || '动作卡片' }}
                  </div>
                  <div v-if="parseExtraJson(msg).actionText" class="chat-card__meta">
                    {{ parseExtraJson(msg).actionText }}
                  </div>
                </div>
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
            placeholder="输入消息，Enter 发送"
            @keydown.enter.exact.prevent="sendText"
          />
          <n-button type="primary" @click="sendText" :disabled="!inputText.trim()">发送</n-button>
        </div>
      </main>

      <main v-else class="panel-center panel-placeholder">
        <div class="placeholder-content">
          <div class="placeholder-icon">💬</div>
          <div class="placeholder-title">选择一个会话开始沟通</div>
          <div class="placeholder-desc">左侧会话支持按订单号和客户名搜索</div>
        </div>
      </main>

      <transition name="slide-right">
        <aside class="panel-right" v-if="activeUserId && showOrderPanel">
          <div class="panel-right__head">
            <div>
              <div class="panel-eyebrow">客户档案</div>
              <div class="panel-title">业务摘要</div>
            </div>
            <n-button size="tiny" text @click="showOrderPanel = false">✕</n-button>
          </div>

          <div v-if="userSummary" class="order-detail-scroll">
            <div class="summary-overview">
              <div class="summary-pill">
                <span class="summary-pill__label">历史订单</span>
                <strong>{{ orderCount }}</strong>
              </div>
              <div class="summary-pill">
                <span class="summary-pill__label">近期意向</span>
                <strong>{{ requestCount }}</strong>
              </div>
            </div>

            <div v-if="requestCount || orderCount" class="summary-tabs">
              <button
                type="button"
                class="summary-tab"
                :class="{ active: archiveTab === 'orders' }"
                @click="archiveTab = 'orders'"
              >
                历史订单
              </button>
              <button
                type="button"
                class="summary-tab"
                :class="{ active: archiveTab === 'requests' }"
                @click="archiveTab = 'requests'"
              >
                近期意向
              </button>
            </div>

            <div v-if="archiveTab === 'requests' && requestCount" class="summary-section">
              <div class="summary-section__title">
                <span>近期意向</span>
                <button
                  v-if="requestCount > summaryPreviewCount"
                  type="button"
                  class="summary-link"
                  @click="showAllRequests = !showAllRequests"
                >
                  {{ showAllRequests ? '收起' : '展开全部' }}
                </button>
              </div>
              <div v-for="req in visibleRequests" :key="req.requestId" class="summary-card">
                <div class="summary-row">
                  <n-tag type="info" size="small">
                    {{ req.status === 0 ? '待处理' : req.status === 1 ? '已转单' : '已关闭' }}
                  </n-tag>
                  <span class="summary-date">{{ formatMsgTime(req.createTime) }}</span>
                </div>
                <div class="summary-line">品类：{{ getCategoryName(req.categoryId) }}</div>
              </div>
              <button
                v-if="hiddenRequestCount > 0 && !showAllRequests"
                type="button"
                class="summary-more"
                @click="showAllRequests = true"
              >
                <span>还有 {{ hiddenRequestCount }} 条意向未展开</span>
                <span class="summary-more__action">展开全部</span>
              </button>
            </div>
            <div v-else-if="archiveTab === 'requests'" class="summary-empty">暂无近期意向</div>

            <div v-if="archiveTab === 'orders' && orderCount" class="summary-section">
              <div class="summary-section__title">
                <span>历史订单</span>
                <button
                  v-if="orderCount > summaryPreviewCount"
                  type="button"
                  class="summary-link"
                  @click="showAllOrders = !showAllOrders"
                >
                  {{ showAllOrders ? '收起' : '展开全部' }}
                </button>
              </div>
              <div
                v-for="ord in visibleOrders"
                :key="ord.orderId"
                class="summary-card summary-card--clickable"
                @click="router.push(`/order/detail/${ord.orderId}`)"
              >
                <div class="summary-row">
                  <n-tag :type="statusMap[ord.status]?.type" size="small">{{
                    statusMap[ord.status]?.label
                  }}</n-tag>
                  <span class="summary-sn">{{ ord.orderSn }}</span>
                </div>
                <div class="summary-line">金额：¥{{ ord.totalAmount || '0.00' }}</div>
              </div>
              <button
                v-if="hiddenOrderCount > 0 && !showAllOrders"
                type="button"
                class="summary-more"
                @click="showAllOrders = true"
              >
                <span>还有 {{ hiddenOrderCount }} 条订单未展开</span>
                <span class="summary-more__action">展开全部</span>
              </button>
            </div>
            <div v-else-if="archiveTab === 'orders'" class="summary-empty">暂无历史订单</div>
          </div>

          <div v-else class="summary-loading">加载中...</div>
        </aside>
      </transition>
    </div>
  </div>
</template>

<script setup lang="ts">
  import { computed, nextTick, onMounted, onUnmounted, ref } from 'vue';
  import { useRouter } from 'vue-router';
  import { useUser } from '@/store/modules/user';
  import {
    getConversations as fetchConvApi,
    getChatMessages,
    getUserSummary as fetchUserSummaryApi,
    markChatRead,
    resolveHumanHandoff,
  } from '@/api/chat/index';
  import { getCategoryList } from '@/api/config/category';

  const router = useRouter();
  const userStore = useUser();

  const searchText = ref('');
  const conversations = ref<any[]>([]);
  const activeUserId = ref<number | null>(null);
  const activeOrderId = ref<number | null>(null);
  const activeUserName = ref('');
  const activeOrderSn = ref('');
  const activeHandoff = ref(false);
  const resolvingHandoff = ref(false);
  const messages = ref<any[]>([]);
  const inputText = ref('');
  const messagesRef = ref<HTMLElement | null>(null);
  const wsConnected = ref(false);
  const showOrderPanel = ref(true);
  const userSummary = ref<any>(null);
  const categoryMap = ref<Record<number, string>>({});
  const archiveTab = ref<'orders' | 'requests'>('orders');
  const showAllOrders = ref(false);
  const showAllRequests = ref(false);
  const summaryPreviewCount = 3;

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
    conversations.value.reduce((sum, item) => sum + Number(item.unreadCount || 0), 0)
  );

  const filteredConversations = computed(() => {
    if (!searchText.value) return conversations.value;
    const kw = searchText.value.toLowerCase();
    return conversations.value.filter(
      (item: any) =>
        (item.orderSn || '').toLowerCase().includes(kw) ||
        (item.nickname || item.username || '').toLowerCase().includes(kw) ||
        (item.lastContent || '').toLowerCase().includes(kw)
    );
  });

  const orderCount = computed(() => userSummary.value?.orders?.length || 0);

  const requestCount = computed(() => userSummary.value?.requests?.length || 0);

  const visibleOrders = computed(() => {
    const list = userSummary.value?.orders || [];
    return showAllOrders.value ? list : list.slice(0, summaryPreviewCount);
  });

  const visibleRequests = computed(() => {
    const list = userSummary.value?.requests || [];
    return showAllRequests.value ? list : list.slice(0, summaryPreviewCount);
  });

  const hiddenOrderCount = computed(() =>
    Math.max(orderCount.value - visibleOrders.value.length, 0)
  );

  const hiddenRequestCount = computed(() =>
    Math.max(requestCount.value - visibleRequests.value.length, 0)
  );

  onMounted(async () => {
    fetchConversations();
    connectWS();
    try {
      const categories = await getCategoryList();
      categoryMap.value = Object.fromEntries(
        categories.map((item: any) => [item.categoryId, item.name])
      );
    } catch (error) {
      console.error(error);
    }
  });

  onUnmounted(() => {
    if (ws) {
      ws.close();
      ws = null;
    }
  });

  const fetchConversations = async () => {
    try {
      const result = await fetchConvApi();
      conversations.value = (result || []).map((item: any) => ({
        ...item,
        unreadCount: Number(item.unreadCount ?? item.unread_count ?? 0),
        handoffCount: Number(item.handoffCount ?? item.handoff_count ?? 0),
        handoffActive: Boolean(item.handoffActive ?? item.handoff_active ?? false),
      }));
    } catch (error) {
      console.error('获取会话列表失败', error);
    }
  };

  const selectConversation = async (conv: any) => {
    activeUserId.value = conv.userId;
    activeOrderId.value = conv.orderId || null;
    activeUserName.value = conv.nickname || conv.username || `用户#${conv.userId}`;
    activeOrderSn.value = conv.orderSn || '';
    activeHandoff.value = Boolean(conv.handoffActive);
    userSummary.value = null;
    archiveTab.value = conv.orderSn ? 'orders' : 'requests';
    showAllOrders.value = false;
    showAllRequests.value = false;

    try {
      const result = await getChatMessages(conv.userId, activeOrderId.value);
      messages.value = result || [];
      scrollToBottom();
      await markChatRead(conv.userId, activeOrderId.value);
      conv.unreadCount = 0;
      conv.handoffCount = 0;
    } catch (error) {
      console.error('获取聊天记录失败', error);
    }

    try {
      const summary = await fetchUserSummaryApi(conv.userId);
      userSummary.value = summary || null;
    } catch (error) {
      console.error('获取客户档案失败', error);
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
          if (msg.userId === activeUserId.value && msg.orderId == activeOrderId.value) {
            messages.value.push(msg);
            if (msg.msgType === 'handoff_request') {
              activeHandoff.value = true;
            }
            if (msg.msgType === 'handoff_resolved') {
              activeHandoff.value = false;
            }
            scrollToBottom();
          }
          fetchConversations();
        }
      } catch (error) {
        console.error('解析消息失败', error);
      }
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

    ws.send(
      JSON.stringify({
        type: 'SEND',
        userId: activeUserId.value,
        orderId: activeOrderId.value,
        content: text,
        msgType: 'text',
      })
    );

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

  const restoreAiService = async () => {
    if (!activeUserId.value || resolvingHandoff.value) return;
    resolvingHandoff.value = true;
    try {
      const msg = await resolveHumanHandoff(activeUserId.value, activeOrderId.value);
      activeHandoff.value = false;
      const current = conversations.value.find(
        (item) => item.userId === activeUserId.value && (item.orderId || null) === activeOrderId.value
      );
      if (current) {
        current.handoffActive = false;
        current.handoffCount = 0;
      }
      if (msg) {
        messages.value.push({
          ...msg,
          senderType: 'admin',
          msgType: 'handoff_resolved',
          contentType: 4,
          createTime: msg.createTime || new Date().toISOString().replace('T', ' ').substring(0, 19),
        });
        scrollToBottom();
      }
      fetchConversations();
    } finally {
      resolvingHandoff.value = false;
    }
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

  const isAdminMsg = (msg: any) =>
    msg.senderType === 'admin' || msg.senderType === 'ai' || msg.senderType === 1 || msg.senderType === 2;

  const isImageMsg = (msg: any) => msg.msgType === 'image' || msg.contentType === 1;
  const isFileMsg = (msg: any) => msg.msgType === 'file' || msg.contentType === 2;

  const parseExtraJson = (msg: any) => {
    const raw = msg?.extraJson;
    if (!raw) return {};
    if (typeof raw === 'object') return raw ?? {};
    try {
      const parsed = JSON.parse(raw);
      return parsed && typeof parsed === 'object' ? parsed : {};
    } catch (error) {
      return {};
    }
  };

  const isProgressCardMsg = (msg: any) => msg.msgType === 'progress_card' || msg.contentType === 3;
  const isHandoffRequestMsg = (msg: any) =>
    msg.msgType === 'handoff_request' || parseExtraJson(msg).cardType === 'handoff_request';
  const isHandoffResolvedMsg = (msg: any) =>
    msg.msgType === 'handoff_resolved' || parseExtraJson(msg).cardType === 'handoff_resolved';
  const isActionCardMsg = (msg: any) =>
    (msg.msgType === 'action_card' || msg.contentType === 4) &&
    !isHandoffRequestMsg(msg) &&
    !isHandoffResolvedMsg(msg);
  const isCardMsg = (msg: any) =>
    isProgressCardMsg(msg) || isHandoffRequestMsg(msg) || isHandoffResolvedMsg(msg) || isActionCardMsg(msg);

  const imageMsgUrl = (msg: any) => toFileUrl(msg.content || parseExtraJson(msg).fileUrl);

  const getFileName = (path = '') => {
    const normalized = String(path).split('?')[0];
    return normalized.substring(normalized.lastIndexOf('/') + 1) || '附件';
  };

  const formatFileSize = (size: any) => {
    const bytes = Number(size || 0);
    if (!bytes) return '';
    if (bytes < 1024) return `${bytes}B`;
    if (bytes < 1024 * 1024) return `${(bytes / 1024).toFixed(1)}KB`;
    return `${(bytes / 1024 / 1024).toFixed(1)}MB`;
  };

  const toFileUrl = (url = '') => {
    if (!url) return '';
    if (/^https?:\/\//i.test(url)) return url;
    return `http://localhost:8081${url.startsWith('/') ? url : `/${url}`}`;
  };

  const openFileMsg = (msg: any) => {
    const url = toFileUrl(msg.content || parseExtraJson(msg).fileUrl);
    if (url) window.open(url, '_blank');
  };
</script>

<style scoped>
  .chat-page {
    height: calc(100vh - 100px);
    border-radius: 18px;
    overflow: hidden;
  }

  .chat-layout {
    display: flex;
    height: 100%;
    border: 1px solid var(--border-light);
    border-radius: 18px;
    background: rgba(255, 255, 255, 0.92);
    overflow: hidden;
  }

  .panel-left {
    width: 308px;
    flex-shrink: 0;
    display: flex;
    flex-direction: column;
    border-right: 1px solid var(--border-light);
    background: rgba(248, 250, 252, 0.92);
  }

  .panel-left__head,
  .panel-right__head {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 16px 16px 12px;
  }

  .panel-eyebrow {
    font-size: 12px;
    color: var(--text-tertiary);
  }

  .panel-title {
    font-size: 18px;
    font-weight: 700;
    color: var(--text-primary);
  }

  .panel-left__stats {
    display: flex;
    gap: 8px;
    padding: 0 16px 12px;
  }

  .summary-pill {
    flex: 1;
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 8px 10px;
    border-radius: 14px;
    background: rgba(255, 255, 255, 0.92);
    border: 1px solid var(--border-light);
  }

  .summary-pill__label {
    font-size: 12px;
    color: var(--text-tertiary);
  }

  .panel-left__search {
    padding: 0 16px 12px;
  }

  .conv-scroll {
    flex: 1;
    overflow-y: auto;
    padding: 0 10px 10px;
  }

  .conv-item {
    width: 100%;
    display: flex;
    align-items: flex-start;
    gap: 12px;
    padding: 12px;
    border: 0;
    border-radius: 16px;
    background: transparent;
    cursor: pointer;
    text-align: left;
    transition: background 0.18s ease, box-shadow 0.18s ease;
  }

  .conv-item:hover {
    background: rgba(255, 255, 255, 0.78);
  }

  .conv-item.active {
    background: rgba(255, 255, 255, 0.98);
    box-shadow: inset 0 0 0 1px rgba(75, 123, 236, 0.18);
  }

  .conv-avatar {
    flex-shrink: 0;
  }

  .text-avatar {
    width: 40px;
    height: 40px;
    display: flex;
    align-items: center;
    justify-content: center;
    border-radius: 14px;
    background: #4b7bec;
    color: #fff;
    font-size: 13px;
    font-weight: 700;
  }

  .conv-info {
    flex: 1;
    min-width: 0;
  }

  .conv-top,
  .conv-middle {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 8px;
  }

  .conv-top {
    margin-bottom: 6px;
  }

  .conv-name {
    font-size: 13px;
    font-weight: 700;
    color: #16213e;
  }

  .conv-time {
    font-size: 11px;
    color: #98a2b3;
    flex-shrink: 0;
  }

  .conv-middle {
    margin-bottom: 6px;
  }

  .conv-tag {
    display: inline-flex;
    align-items: center;
    padding: 2px 8px;
    border-radius: 999px;
    background: rgba(75, 123, 236, 0.12);
    color: #4b7bec;
    font-size: 11px;
    font-weight: 600;
  }

  .conv-tag--general {
    background: rgba(148, 163, 184, 0.14);
    color: #64748b;
  }

  .conv-alerts {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    flex-shrink: 0;
  }

  .conv-handoff-dot {
    display: inline-flex;
    align-items: center;
    gap: 4px;
    padding: 2px 8px;
    border-radius: 999px;
    background: #fff1f2;
    color: #e11d48;
    border: 1px solid rgba(225, 29, 72, 0.24);
    font-size: 11px;
    font-weight: 700;
  }

  .conv-handoff-dot::before {
    content: '';
    width: 6px;
    height: 6px;
    border-radius: 999px;
    background: #e11d48;
    box-shadow: 0 0 0 4px rgba(225, 29, 72, 0.12);
  }

  .conv-last {
    font-size: 12px;
    color: #667085;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
  }

  .conv-empty,
  .summary-empty,
  .summary-loading {
    padding: 40px 20px;
    text-align: center;
    color: #98a2b3;
    font-size: 13px;
  }

  .panel-center {
    flex: 1;
    min-width: 0;
    display: flex;
    flex-direction: column;
  }

  .panel-placeholder {
    align-items: center;
    justify-content: center;
    background: linear-gradient(180deg, rgba(248, 250, 252, 0.72), rgba(255, 255, 255, 0.96));
  }

  .placeholder-content {
    text-align: center;
  }

  .placeholder-icon {
    font-size: 52px;
    margin-bottom: 14px;
  }

  .placeholder-title {
    font-size: 18px;
    font-weight: 700;
    color: var(--text-primary);
    margin-bottom: 6px;
  }

  .placeholder-desc {
    font-size: 13px;
    color: var(--text-tertiary);
  }

  .chat-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 12px;
    padding: 14px 18px;
    border-bottom: 1px solid var(--border-light);
    background: rgba(255, 255, 255, 0.96);
  }

  .chat-header__title {
    display: flex;
    align-items: center;
    gap: 10px;
    margin-bottom: 6px;
  }

  .chat-header__status {
    display: inline-flex;
    align-items: center;
    padding: 2px 8px;
    border-radius: 999px;
    background: rgba(148, 163, 184, 0.16);
    color: #64748b;
    font-size: 11px;
    font-weight: 600;
  }

  .chat-header__status.online {
    background: rgba(34, 197, 94, 0.12);
    color: #15803d;
  }

  .chat-header__meta {
    display: flex;
    gap: 8px;
    flex-wrap: wrap;
  }

  .header-pill {
    padding: 4px 8px;
    border-radius: 999px;
    background: rgba(75, 123, 236, 0.12);
    color: #4b7bec;
    font-size: 11px;
    font-weight: 600;
  }

  .header-pill--muted {
    background: rgba(148, 163, 184, 0.14);
    color: #64748b;
  }

  .header-pill--handoff {
    background: #fff7ed;
    color: #c2410c;
    border: 1px solid rgba(249, 115, 22, 0.24);
  }

  .chat-messages {
    flex: 1;
    overflow-y: auto;
    padding: 18px;
    background: linear-gradient(180deg, rgba(248, 250, 252, 0.9), rgba(255, 255, 255, 0.98));
  }

  .msg-empty {
    height: 100%;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    gap: 10px;
    color: #98a2b3;
  }

  .msg-empty__icon {
    font-size: 36px;
  }

  .msg-row {
    display: flex;
    align-items: flex-start;
    gap: 10px;
    margin-bottom: 18px;
  }

  .msg-row.is-admin {
    flex-direction: row-reverse;
  }

  .msg-avatar {
    width: 36px;
    height: 36px;
    display: flex;
    align-items: center;
    justify-content: center;
    border-radius: 14px;
    color: #fff;
    font-size: 12px;
    font-weight: 700;
    flex-shrink: 0;
  }

  .is-client .msg-avatar {
    background: #e5a84b;
  }

  .is-admin .msg-avatar {
    background: #4b7bec;
  }

  .msg-body {
    max-width: 58%;
    display: flex;
    flex-direction: column;
  }

  .is-admin .msg-body {
    align-items: flex-end;
  }

  .msg-bubble {
    padding: 11px 14px;
    border-radius: 16px;
    font-size: 14px;
    line-height: 1.6;
    word-break: break-word;
  }

  .msg-bubble--card {
    padding: 0;
    overflow: hidden;
  }

  .chat-card {
    min-width: 240px;
    max-width: 340px;
    padding: 12px 14px;
    background: #fff;
    color: #1f2937;
    border: 1px solid rgba(148, 163, 184, 0.24);
    border-radius: 14px;
  }

  .chat-card--progress {
    border-color: rgba(75, 123, 236, 0.28);
  }

  .chat-card--handoff {
    border-color: rgba(249, 115, 22, 0.32);
    background: #fff7ed;
  }

  .chat-card--resolved {
    border-color: rgba(34, 197, 94, 0.28);
    background: #f0fdf4;
  }

  .chat-card__title {
    font-size: 14px;
    font-weight: 700;
    line-height: 1.45;
  }

  .chat-card__desc {
    margin-top: 6px;
    font-size: 12px;
    line-height: 1.55;
    color: #667085;
  }

  .chat-card__meta {
    margin-top: 8px;
    font-size: 12px;
    font-weight: 600;
    color: #4b7bec;
  }

  .chat-file {
    min-width: 240px;
    max-width: 340px;
    display: flex;
    align-items: center;
    gap: 12px;
    padding: 12px;
    border-radius: 14px;
    background: #fff;
    color: #1f2937;
    border: 1px solid rgba(148, 163, 184, 0.24);
    cursor: pointer;
  }

  .chat-file__icon {
    width: 46px;
    height: 46px;
    border-radius: 12px;
    background: rgba(75, 123, 236, 0.12);
    color: #4b7bec;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 11px;
    font-weight: 800;
    flex-shrink: 0;
  }

  .chat-file__main {
    min-width: 0;
    flex: 1;
  }

  .chat-file__button {
    flex-shrink: 0;
    border: 0;
    border-radius: 999px;
    padding: 6px 12px;
    background: rgba(75, 123, 236, 0.12);
    color: #2f6fed;
    font-size: 12px;
    font-weight: 700;
    cursor: pointer;
  }

  .chat-file__name {
    font-size: 13px;
    line-height: 1.45;
    font-weight: 700;
    word-break: break-all;
  }

  .chat-file__meta {
    margin-top: 4px;
    font-size: 12px;
    color: #667085;
  }

  .is-client .msg-bubble {
    background: #fff;
    color: #1f2937;
    border-top-left-radius: 6px;
    box-shadow: 0 4px 12px rgba(15, 23, 42, 0.05);
  }

  .is-admin .msg-bubble {
    background: #4b7bec;
    color: #fff;
    border-top-right-radius: 6px;
  }

  .msg-content {
    white-space: pre-wrap;
  }

  .msg-time {
    margin-top: 5px;
    font-size: 11px;
    color: #98a2b3;
  }

  .chat-input {
    display: flex;
    gap: 10px;
    align-items: flex-end;
    padding: 14px 18px;
    border-top: 1px solid var(--border-light);
    background: rgba(255, 255, 255, 0.96);
  }

  .panel-right {
    width: 300px;
    flex-shrink: 0;
    display: flex;
    flex-direction: column;
    border-left: 1px solid var(--border-light);
    background: rgba(248, 250, 252, 0.92);
  }

  .order-detail-scroll {
    flex: 1;
    overflow-y: auto;
    padding: 0 14px 14px;
  }

  .summary-overview {
    display: grid;
    grid-template-columns: repeat(2, minmax(0, 1fr));
    gap: 8px;
    margin-bottom: 12px;
  }

  .summary-tabs {
    display: inline-flex;
    padding: 4px;
    margin-bottom: 12px;
    border-radius: 12px;
    background: rgba(255, 255, 255, 0.92);
    border: 1px solid var(--border-light);
  }

  .summary-tab {
    border: 0;
    background: transparent;
    color: var(--text-secondary);
    padding: 7px 12px;
    border-radius: 10px;
    font-size: 12px;
    font-weight: 700;
    cursor: pointer;
    transition: all 0.18s ease;
  }

  .summary-tab.active {
    background: rgba(75, 123, 236, 0.12);
    color: #4b7bec;
  }

  .summary-section {
    margin-bottom: 16px;
  }

  .summary-section__title {
    display: flex;
    align-items: center;
    justify-content: space-between;
    margin-bottom: 8px;
    font-size: 12px;
    color: var(--text-tertiary);
    font-weight: 700;
  }

  .summary-link {
    border: 0;
    background: transparent;
    color: #4b7bec;
    font-size: 12px;
    font-weight: 600;
    cursor: pointer;
    padding: 0;
  }

  .summary-more {
    width: 100%;
    margin-top: 8px;
    border: 1px dashed rgba(75, 123, 236, 0.28);
    background: rgba(75, 123, 236, 0.05);
    color: #4b7bec;
    border-radius: 14px;
    padding: 10px 12px;
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 10px;
    font-size: 12px;
    font-weight: 600;
    cursor: pointer;
    transition: all 0.18s ease;
  }

  .summary-more:hover {
    background: rgba(75, 123, 236, 0.08);
    border-color: rgba(75, 123, 236, 0.4);
  }

  .summary-more__action {
    flex-shrink: 0;
  }

  .summary-card {
    padding: 12px;
    border: 1px solid var(--border-light);
    border-radius: 14px;
    background: rgba(255, 255, 255, 0.94);
  }

  .summary-card + .summary-card {
    margin-top: 8px;
  }

  .summary-card--clickable {
    cursor: pointer;
    transition: border-color 0.18s ease, transform 0.18s ease;
  }

  .summary-card--clickable:hover {
    border-color: rgba(75, 123, 236, 0.18);
    transform: translateY(-1px);
  }

  .summary-row {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 10px;
    margin-bottom: 6px;
  }

  .summary-line {
    font-size: 12px;
    color: #475467;
  }

  .summary-date,
  .summary-sn {
    font-size: 11px;
    color: #98a2b3;
  }

  .slide-right-enter-active,
  .slide-right-leave-active {
    transition: all 0.24s ease;
  }

  .slide-right-enter-from,
  .slide-right-leave-to {
    width: 0;
    opacity: 0;
    overflow: hidden;
  }

  @media (max-width: 1360px) {
    .panel-right {
      width: 268px;
    }
  }

  @media (max-width: 1100px) {
    .panel-left {
      width: 280px;
    }

    .msg-body {
      max-width: 72%;
    }
  }
</style>
