<template>
  <div v-if="!detailLoaded" class="page-state">加载中...</div>
  <div v-else-if="!detail" class="page-state">订单不存在</div>
  <div v-else class="order-detail-page">

    <!-- ===================== 顶部锚点栏 ===================== -->
    <div class="bento-header">
      <div class="bento-header__left">
        <span class="order-sn">{{ detail.order.orderSn }}</span>
        <StatusBadge :status="detail.order.status" round show-dot />
        <n-tag v-if="detail.order.isBlocked === 1" type="error" round size="small">
          已阻塞：{{ detail.order.blockReason || '-' }}
        </n-tag>
        <n-tag v-if="detail.order.delayReason" type="warning" round size="small">
          延期：{{ detail.order.delayReason }}
        </n-tag>
      </div>
      <div class="bento-header__right">
        <!-- 高频操作 -->
        <n-space :size="8" wrap>
          <n-button
            v-if="detail.order.status === 1 && detail.order.isBlocked !== 1"
            type="primary"
            size="small"
            @click="showAdvanceModal = true"
          >
            推进节点
          </n-button>
          <n-button
            v-if="detail.order.status === 2"
            type="info"
            size="small"
            @click="showShipModal = true"
          >
            标记发货
          </n-button>
          <n-button
            v-if="detail.order.status === 1 && detail.order.isBlocked !== 1"
            type="warning"
            size="small"
            ghost
            @click="showBlockModal = true"
          >
            标记阻塞
          </n-button>
          <n-button
            v-if="detail.order.isBlocked === 1"
            type="success"
            size="small"
            @click="handleUnblock"
          >
            解除阻塞
          </n-button>
          <n-button
            v-if="detail.order.status !== 4 && detail.order.status !== 5"
            type="default"
            size="small"
            ghost
            @click="showDelayModal = true"
          >
            登记延期
          </n-button>
          <n-button
            v-if="detail.order.status !== 4 && detail.order.status !== 5"
            type="error"
            size="small"
            ghost
            @click="showCancelModal = true"
          >
            取消订单
          </n-button>
          <n-button size="small" @click="showProgressModal = true">添加进度</n-button>
        </n-space>
      </div>
    </div>

    <!-- ===================== 四象限主体 ===================== -->
    <div class="bento-grid">

      <!-- 左上：核心锚点 -->
      <div class="bento-card bento-card--anchor">
        <div class="bento-card__title">订单概况</div>
        <div class="anchor-stats">
          <div class="anchor-stat">
            <span class="anchor-stat__label">总金额</span>
            <span class="anchor-stat__value anchor-stat__value--money">{{ formatAmount(detail.order.totalAmount) }}</span>
          </div>
          <div class="anchor-stat">
            <span class="anchor-stat__label">预付款</span>
            <span class="anchor-stat__value">{{ formatAmount(detail.order.prepayAmount) }}</span>
          </div>
          <div class="anchor-stat">
            <span class="anchor-stat__label">已付款</span>
            <span class="anchor-stat__value anchor-stat__value--success">{{ formatAmount(detail.order.paidAmount) }}</span>
          </div>
          <div class="anchor-stat">
            <span class="anchor-stat__label">尾款</span>
            <span class="anchor-stat__value anchor-stat__value--warning">{{ formatAmount(remainingAmount) }}</span>
          </div>
        </div>

        <n-divider />

        <div class="anchor-fields">
          <div class="anchor-field">
            <span class="anchor-field__label">客户</span>
            <span class="anchor-field__value">{{ detail.order.customerName || `用户#${detail.order.userId}` }}</span>
          </div>
          <div class="anchor-field">
            <span class="anchor-field__label">设计师</span>
            <span class="anchor-field__value">{{ detail.order.designerName || `设计师#${detail.order.designerId}` }}</span>
          </div>
          <div class="anchor-field">
            <span class="anchor-field__label">品类</span>
            <span class="anchor-field__value">{{ categoryName || `ID#${detail.order.categoryId}` }}</span>
          </div>
          <div class="anchor-field">
            <span class="anchor-field__label">交付日期</span>
            <span class="anchor-field__value">{{ detail.order.expectedDate || '-' }}</span>
          </div>
          <div class="anchor-field">
            <span class="anchor-field__label">当前节点</span>
            <span class="anchor-field__value anchor-field__value--highlight">{{ currentStepName }}</span>
          </div>
        </div>
      </div>

      <!-- 右上：工作流进度 -->
      <div class="bento-card bento-card--workflow">
        <div class="bento-card__title">工作流进度</div>
        <div class="workflow-steps">
          <div
            v-for="(step, index) in detail.workflowSteps || []"
            :key="step.stepId"
            class="workflow-step"
            :class="{
              'workflow-step--done': index < currentStepIndex - 1,
              'workflow-step--current': index === currentStepIndex - 1,
              'workflow-step--future': index > currentStepIndex - 1,
            }"
          >
            <div class="workflow-step__dot"></div>
            <div class="workflow-step__info">
              <span class="workflow-step__name">{{ step.stepName }}</span>
              <span v-if="step.expectedDurationDays" class="workflow-step__duration">预计{{ step.expectedDurationDays }}天</span>
            </div>
          </div>
        </div>
      </div>

      <!-- 左下：最新动态 -->
      <div class="bento-card bento-card--timeline">
        <div class="bento-card__title">
          流转追踪
          <span class="bento-card__subtitle">最近{{ recentProgress.length }}条</span>
        </div>
        <EmptyStateGuide
          v-if="!recentProgress.length"
          icon="📭"
          title="暂无进度记录"
        />
        <div v-else class="timeline-mini">
          <div
            v-for="item in recentProgress"
            :key="item.progressId"
            class="timeline-item"
          >
            <div class="timeline-item__dot"></div>
            <div class="timeline-item__body">
              <div class="timeline-item__title">{{ getStepName(item.stepId) }}</div>
              <div class="timeline-item__desc">{{ item.description || '无说明' }}</div>
              <div class="timeline-item__time">{{ formatTime(item.createTime) }}</div>
            </div>
          </div>
        </div>
      </div>

      <!-- 右下：业务实体 Tab -->
      <div class="bento-card bento-card--entity">
        <n-tabs type="line" size="small">
          <n-tab-pane name="custom" tab="定制参数">
            <pre class="json-box">{{ formatJson(detail.order.customDataSnapshot) }}</pre>
          </n-tab-pane>
          <n-tab-pane name="bom" tab="BOM物料">
            <div v-if="detail.order.materialCost" class="bom-cost-banner">
              物料成本合计：<span class="bom-cost-amount">¥{{ detail.order.materialCost }}</span>
            </div>
            <EmptyStateGuide
              v-if="!bomItems.length"
              icon="📦"
              title="暂无BOM物料"
            />
            <n-data-table
              v-else
              :columns="bomColumns"
              :data="bomItems"
              :bordered="false"
              size="small"
              style="margin-top: 8px"
            />
          </n-tab-pane>
          <n-tab-pane name="basic" tab="基本信息">
            <n-descriptions :column="1" size="small">
              <n-descriptions-item label="订单编号">{{ detail.order.orderSn }}</n-descriptions-item>
              <n-descriptions-item label="创建时间">{{ detail.order.createTime || '-' }}</n-descriptions-item>
              <n-descriptions-item label="发货时间">{{ detail.order.deliveryTime || '-' }}</n-descriptions-item>
              <n-descriptions-item label="完成时间">{{ detail.order.finishTime || '-' }}</n-descriptions-item>
              <n-descriptions-item label="确认完成">{{ detail.order.confirmTime || '-' }}</n-descriptions-item>
              <n-descriptions-item label="备注">{{ detail.order.remark || '-' }}</n-descriptions-item>
            </n-descriptions>
          </n-tab-pane>
        </n-tabs>
      </div>
    </div>

    <!-- ===================== 弹窗们 ===================== -->
    <n-modal
v-model:show="showAdvanceModal" title="推进到下一节点" preset="dialog"
      positive-text="确认推进" negative-text="取消" @positive-click="handleAdvance">
      <n-form-item label="进度说明">
        <n-input v-model:value="advanceDesc" type="textarea" placeholder="可选填写本次推进说明" />
      </n-form-item>
    </n-modal>

    <n-modal
v-model:show="showBlockModal" title="标记阻塞" preset="dialog"
      positive-text="确认阻塞" negative-text="取消" @positive-click="handleBlock">
      <n-alert type="warning" :bordered="false" style="margin-bottom: 12px;">阻塞后需解除才可继续推进</n-alert>
      <n-form-item label="阻塞原因">
        <n-input v-model:value="blockReason" type="textarea" placeholder="请输入阻塞原因" />
      </n-form-item>
    </n-modal>

    <n-modal
v-model:show="showDelayModal" title="登记延期" preset="dialog"
      positive-text="保存" negative-text="取消" @positive-click="handleDelay">
      <n-form-item label="新的预计日期">
        <n-date-picker v-model:formatted-value="delayExpectedDate" type="date" value-format="yyyy-MM-dd" style="width: 100%" />
      </n-form-item>
      <n-form-item label="延期原因">
        <n-input v-model:value="delayReason" type="textarea" placeholder="请输入延期原因" />
      </n-form-item>
    </n-modal>

    <n-modal
v-model:show="showShipModal" title="标记发货" preset="dialog"
      positive-text="确认发货" negative-text="取消" @positive-click="handleShip">
      <n-form-item label="发货说明">
        <n-input v-model:value="shipDesc" type="textarea" placeholder="可选填写物流或发货说明" />
      </n-form-item>
    </n-modal>

    <n-modal
v-model:show="showCancelModal" title="取消订单" preset="dialog"
      positive-text="确认取消" negative-text="返回" @positive-click="handleCancel">
      <n-alert type="error" :bordered="false" style="margin-bottom: 12px;">取消后不可恢复</n-alert>
      <n-form-item label="取消原因">
        <n-input v-model:value="cancelReason" type="textarea" placeholder="请输入取消原因" />
      </n-form-item>
    </n-modal>

    <n-modal
v-model:show="showProgressModal" title="添加进度记录" preset="dialog"
      positive-text="提交" negative-text="取消" @positive-click="handleAddProgress">
      <n-form-item label="进度描述">
        <n-input v-model:value="progressDesc" type="textarea" placeholder="描述当前进度" />
      </n-form-item>
    </n-modal>
  </div>
</template>

<script lang="ts" setup>
import { computed, onMounted, ref } from 'vue';
import { useRoute } from 'vue-router';
import { useMessage, NDivider, NTabs, NTabPane, NDescriptions, NDescriptionsItem, NAlert } from 'naive-ui';
import {
  addProgress, advanceOrder, blockOrder, cancelOrder, delayOrder,
  getOrderDetail, getOrderBom, shipOrder, unblockOrder,
} from '@/api/order/index';
import { getCategoryList } from '@/api/config/category';
import { StatusBadge, EmptyStateGuide } from '@/components/Business';

const route = useRoute();
const message = useMessage();

const detailLoaded = ref(false);
const detail = ref<any>(null);
const categoryName = ref('');

const showAdvanceModal = ref(false);
const showBlockModal = ref(false);
const showDelayModal = ref(false);
const showShipModal = ref(false);
const showCancelModal = ref(false);
const showProgressModal = ref(false);

const advanceDesc = ref('');
const blockReason = ref('');
const delayReason = ref('');
const delayExpectedDate = ref('');
const shipDesc = ref('');
const cancelReason = ref('');
const progressDesc = ref('');

const currentStepIndex = computed(() => {
  if (!detail.value?.workflowSteps?.length) return 0;
  const currentId = detail.value.order?.currentStepId;
  const index = detail.value.workflowSteps.findIndex((step: any) => step.stepId === currentId);
  return index >= 0 ? index + 1 : 0;
});

const currentStepName = computed(() => {
  if (!detail.value?.workflowSteps?.length) return '-';
  const currentId = detail.value.order?.currentStepId;
  const step = detail.value.workflowSteps.find((s: any) => s.stepId === currentId);
  return step?.stepName || '-';
});

const remainingAmount = computed(() => {
  const total = Number(detail.value?.order?.totalAmount) || 0;
  const paid = Number(detail.value?.order?.paidAmount) || 0;
  const remaining = total - paid;
  return remaining > 0 ? remaining.toFixed(2) : '0.00';
});

const recentProgress = computed(() => {
  const list = detail.value?.progressList || [];
  return [...list].slice(0, 3);
});

// BOM
const bomItems = ref<any[]>([]);
const bomColumns = [
  { title: '物料', key: 'name', width: 130 },
  { title: 'SKU', key: 'sku', width: 90 },
  { title: '用量', key: 'quantity', width: 60, align: 'center' as const },
  { title: '单价', key: 'unitPrice', width: 80, align: 'right' as const, render: (row: any) => row.unitPrice ? `¥${row.unitPrice}` : '-' },
  { title: '小计', key: 'subtotal', width: 80, align: 'right' as const, render: (row: any) => row.unitPrice && row.quantity ? `¥${(row.unitPrice * row.quantity).toFixed(2)}` : '-' },
  { title: '已扣库', key: 'isAllocated', width: 70, align: 'center' as const, render: (row: any) => row.isAllocated === 1 ? '是' : '否' },
];

async function loadDetail() {
  const id = Number(route.params.id);
  if (!id) { detailLoaded.value = true; return; }
  try {
    detail.value = await getOrderDetail(id);
    delayExpectedDate.value = detail.value?.order?.expectedDate || '';
    loadBomItems(id);
    await loadCategoryName();
  } finally {
    detailLoaded.value = true;
  }
}

async function loadCategoryName() {
  try {
    const cats = await getCategoryList();
    const list = Array.isArray(cats) ? cats : (cats?.records || []);
    const cat = list.find((c: any) => c.categoryId === detail.value?.order?.categoryId);
    categoryName.value = cat?.name || '';
  } catch { categoryName.value = ''; }
}

async function loadBomItems(orderId: number) {
  try {
    const items = await getOrderBom(orderId);
    bomItems.value = (items || []).map((item: any) => {
      let snapshot: any = {};
      try { snapshot = JSON.parse(item.materialSnapshot || '{}'); } catch {}
      return {
        ...item,
        name: snapshot.name || `物料#${item.materialId}`,
        sku: snapshot.sku || '-',
        unit: snapshot.unit || '-',
        unitPrice: snapshot.unitPrice || null,
      };
    });
  } catch { bomItems.value = []; }
}

function getStepName(stepId: number) {
  const step = detail.value?.workflowSteps?.find((item: any) => item.stepId === stepId);
  return step?.stepName || `节点 #${stepId}`;
}

function formatJson(value?: string) {
  if (!value) return '-';
  try { return JSON.stringify(JSON.parse(value), null, 2); } catch { return value; }
}

function formatAmount(value?: string | number | null) {
  if (value === null || value === undefined || value === '') return '-';
  return `¥${Number(value).toFixed(2)}`;
}

function formatTime(time?: string) {
  if (!time) return '-';
  return time.slice(0, 16).replace('T', ' ');
}

async function handleAdvance() {
  await advanceOrder(detail.value.order.orderId, {
    expectedCurrentStepId: detail.value.order.currentStepId || null,
    description: advanceDesc.value || null,
  });
  message.success('订单已推进');
  showAdvanceModal.value = false;
  advanceDesc.value = '';
  await loadDetail();
}

async function handleBlock() {
  if (!blockReason.value.trim()) { message.warning('请输入阻塞原因'); return; }
  await blockOrder(detail.value.order.orderId, { blockReason: blockReason.value });
  message.success('订单已阻塞');
  showBlockModal.value = false;
  blockReason.value = '';
  await loadDetail();
}

async function handleUnblock() {
  await unblockOrder(detail.value.order.orderId);
  message.success('订单已解除阻塞');
  await loadDetail();
}

async function handleDelay() {
  if (!delayReason.value.trim() || !delayExpectedDate.value) {
    message.warning('请填写延期原因和新的预计日期'); return;
  }
  await delayOrder(detail.value.order.orderId, { delayReason: delayReason.value, expectedDate: delayExpectedDate.value });
  message.success('延期信息已保存');
  showDelayModal.value = false;
  await loadDetail();
}

async function handleShip() {
  await shipOrder(detail.value.order.orderId, { description: shipDesc.value || null });
  message.success('订单已标记发货');
  showShipModal.value = false;
  shipDesc.value = '';
  await loadDetail();
}

async function handleCancel() {
  if (!cancelReason.value.trim()) { message.warning('请输入取消原因'); return; }
  await cancelOrder(detail.value.order.orderId, { cancelReason: cancelReason.value });
  message.success('订单已取消');
  showCancelModal.value = false;
  cancelReason.value = '';
  await loadDetail();
}

async function handleAddProgress() {
  if (!progressDesc.value.trim()) { message.warning('请输入进度描述'); return; }
  await addProgress(detail.value.order.orderId, { description: progressDesc.value });
  message.success('进度已添加');
  showProgressModal.value = false;
  progressDesc.value = '';
  await loadDetail();
}

onMounted(loadDetail);
</script>

<style scoped>
.order-detail-page {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

/* ===== 顶部锚点栏 ===== */
.bento-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  background: var(--panel-bg);
  border-radius: var(--panel-radius);
  padding: 14px 20px;
  box-shadow: var(--panel-shadow);
  flex-wrap: wrap;
  gap: 12px;
}

.bento-header__left {
  display: flex;
  align-items: center;
  gap: 10px;
  flex-wrap: wrap;
}

.order-sn {
  font-size: 17px;
  font-weight: 700;
  color: var(--text-primary);
}

.bento-header__right {
  display: flex;
  align-items: center;
}

/* ===== 四象限网格 ===== */
.bento-grid {
  display: grid;
  grid-template-columns: 5fr 4fr;
  grid-template-rows: auto auto;
  gap: 12px;
}

.bento-card {
  background: var(--panel-bg);
  border-radius: var(--panel-radius);
  padding: 18px 20px;
  box-shadow: var(--panel-shadow);
}

.bento-card__title {
  font-size: 13px;
  font-weight: 600;
  color: var(--text-tertiary);
  letter-spacing: 0.5px;
  text-transform: uppercase;
  margin-bottom: 16px;
  display: flex;
  align-items: center;
  gap: 8px;
}

.bento-card__subtitle {
  font-size: 11px;
  font-weight: 400;
  color: var(--text-placeholder);
  text-transform: none;
  letter-spacing: 0;
}

/* 左上：核心锚点 */
.bento-card--anchor {}

.anchor-stats {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 12px;
  margin-bottom: 4px;
}

.anchor-stat {
  display: flex;
  flex-direction: column;
  gap: 2px;
}

.anchor-stat__label {
  font-size: 12px;
  color: var(--text-tertiary);
}

.anchor-stat__value {
  font-size: 18px;
  font-weight: 700;
  color: var(--text-primary);
}

.anchor-stat__value--money { color: var(--money-color); }
.anchor-stat__value--success { color: var(--status-success-text); }
.anchor-stat__value--warning { color: var(--money-color); }

.anchor-fields {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.anchor-field {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 6px 0;
  border-bottom: 1px solid var(--border-light);
}

.anchor-field:last-child { border-bottom: none; }

.anchor-field__label {
  font-size: 13px;
  color: var(--text-tertiary);
}

.anchor-field__value {
  font-size: 13px;
  color: var(--text-primary);
  font-weight: 500;
}

.anchor-field__value--highlight {
  color: var(--primary-color);
  font-weight: 600;
}

/* 右上：工作流进度 */
.workflow-steps {
  display: flex;
  flex-direction: column;
  gap: 0;
}

.workflow-step {
  display: flex;
  align-items: flex-start;
  gap: 10px;
  padding: 8px 0;
  position: relative;
}

.workflow-step:not(:last-child)::after {
  content: '';
  position: absolute;
  left: 5px;
  top: 22px;
  bottom: -8px;
  width: 2px;
  background: var(--border-light);
}

.workflow-step--done::after { background: var(--status-success-text); }

.workflow-step__dot {
  width: 12px;
  height: 12px;
  border-radius: 50%;
  flex-shrink: 0;
  margin-top: 3px;
  border: 2px solid;
}

.workflow-step--done .workflow-step__dot {
  background: var(--status-success-text);
  border-color: var(--status-success-text);
}

.workflow-step--current .workflow-step__dot {
  background: var(--panel-bg);
  border-color: var(--primary-color);
  box-shadow: 0 0 0 3px var(--primary-bg);
}

.workflow-step--future .workflow-step__dot {
  background: var(--panel-bg);
  border-color: var(--border-light);
}

.workflow-step__info {
  display: flex;
  flex-direction: column;
  gap: 1px;
}

.workflow-step__name {
  font-size: 13px;
  color: var(--text-primary);
  font-weight: 500;
}

.workflow-step--future .workflow-step__name { color: var(--text-tertiary); }

.workflow-step__duration {
  font-size: 11px;
  color: var(--text-placeholder);
}

/* 左下：流转追踪 */
.timeline-mini {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.timeline-item {
  display: flex;
  gap: 10px;
}

.timeline-item__dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background: var(--status-success-text);
  flex-shrink: 0;
  margin-top: 5px;
}

.timeline-item__body {
  flex: 1;
}

.timeline-item__title {
  font-size: 13px;
  font-weight: 600;
  color: var(--text-primary);
  margin-bottom: 2px;
}

.timeline-item__desc {
  font-size: 12px;
  color: var(--text-secondary);
  line-height: 1.5;
}

.timeline-item__time {
  font-size: 11px;
  color: var(--text-tertiary);
  margin-top: 3px;
}

/* 右下：业务实体 */
.bento-card--entity {}

/* JSON */
.json-box {
  background: var(--page-bg);
  padding: 12px;
  border-radius: 6px;
  font-size: 12px;
  color: var(--text-secondary);
  white-space: pre-wrap;
  max-height: 300px;
  overflow-y: auto;
}

/* BOM */
.bom-cost-banner {
  background: var(--status-info-bg);
  border: 1px solid var(--status-info-border);
  border-radius: 6px;
  padding: 8px 14px;
  font-size: 13px;
  color: var(--text-secondary);
  margin-bottom: 8px;
}

.bom-cost-amount {
  font-weight: 700;
  font-size: 15px;
  color: var(--money-color);
}

.page-state {
  padding: 80px 0;
  text-align: center;
  color: var(--text-tertiary);
}
</style>
