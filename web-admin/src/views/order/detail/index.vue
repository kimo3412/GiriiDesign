<template>
  <div v-if="!detailLoaded" class="page-state">加载中...</div>
  <div v-else-if="!detail" class="page-state">订单不存在</div>
  <n-space v-else vertical :size="16">
    <n-card :bordered="false">
      <n-space justify="space-between" align="center" wrap>
        <n-space align="center" :size="12" wrap>
          <n-text strong style="font-size: 18px">{{ detail.order.orderSn }}</n-text>
          <n-tag :type="statusMap[detail.order.status]?.type || 'default'">
            {{ statusMap[detail.order.status]?.label || '未知状态' }}
          </n-tag>
          <n-tag v-if="detail.order.isBlocked === 1" type="error">
            已阻塞：{{ detail.order.blockReason || '-' }}
          </n-tag>
        </n-space>
        <n-space wrap>
          <n-button
            v-if="detail.order.status === 1 && detail.order.isBlocked !== 1"
            type="primary"
            @click="showAdvanceModal = true"
          >
            推进节点
          </n-button>
          <n-button v-if="detail.order.status === 2" type="info" @click="showShipModal = true">
            标记发货
          </n-button>
          <n-button
            v-if="detail.order.status === 1 && detail.order.isBlocked !== 1"
            type="warning"
            @click="showBlockModal = true"
          >
            标记阻塞
          </n-button>
          <n-button
            v-if="detail.order.isBlocked === 1"
            type="success"
            @click="handleUnblock"
          >
            解除阻塞
          </n-button>
          <n-button
            v-if="detail.order.status !== 4 && detail.order.status !== 5"
            type="warning"
            ghost
            @click="showDelayModal = true"
          >
            登记延期
          </n-button>
          <n-button
            v-if="detail.order.status !== 4 && detail.order.status !== 5"
            type="error"
            ghost
            @click="showCancelModal = true"
          >
            取消订单
          </n-button>
          <n-button @click="showProgressModal = true">添加进度</n-button>
        </n-space>
      </n-space>
    </n-card>

    <n-card :bordered="false">
      <n-tabs type="line">
        <n-tab-pane name="info" tab="基本信息">
          <n-descriptions bordered :column="2">
            <n-descriptions-item label="订单编号">{{ detail.order.orderSn }}</n-descriptions-item>
            <n-descriptions-item label="品类 ID">{{ detail.order.categoryId }}</n-descriptions-item>
            <n-descriptions-item label="客户">{{ detail.order.customerName || detail.order.userId || '-' }}</n-descriptions-item>
            <n-descriptions-item label="设计师">{{ detail.order.designerName || detail.order.designerId || '-' }}</n-descriptions-item>
            <n-descriptions-item label="总金额">{{ formatAmount(detail.order.totalAmount) }}</n-descriptions-item>
            <n-descriptions-item label="预付款">{{ formatAmount(detail.order.prepayAmount) }}</n-descriptions-item>
            <n-descriptions-item label="已付款">{{ formatAmount(detail.order.paidAmount) }}</n-descriptions-item>
            <n-descriptions-item label="预计交付">{{ detail.order.expectedDate || '-' }}</n-descriptions-item>
            <n-descriptions-item label="延期原因">{{ detail.order.delayReason || '-' }}</n-descriptions-item>
            <n-descriptions-item label="取消原因">{{ detail.order.cancelReason || '-' }}</n-descriptions-item>
            <n-descriptions-item label="创建时间">{{ detail.order.createTime || '-' }}</n-descriptions-item>
            <n-descriptions-item label="完成时间">{{ detail.order.finishTime || '-' }}</n-descriptions-item>
            <n-descriptions-item label="发货时间">{{ detail.order.deliveryTime || '-' }}</n-descriptions-item>
            <n-descriptions-item label="确认完成">{{ detail.order.confirmTime || '-' }}</n-descriptions-item>
            <n-descriptions-item label="备注" :span="2">{{ detail.order.remark || '-' }}</n-descriptions-item>
          </n-descriptions>

          <n-divider>定制参数快照</n-divider>
          <pre class="json-box">{{ formatJson(detail.order.customDataSnapshot) }}</pre>
        </n-tab-pane>

        <n-tab-pane name="workflow" tab="工作流进度">
          <n-steps :current="currentStepIndex" style="margin-bottom: 24px">
            <n-step
              v-for="step in detail.workflowSteps || []"
              :key="step.stepId"
              :title="step.stepName"
            />
          </n-steps>
        </n-tab-pane>

        <n-tab-pane name="timeline" tab="进度时间线">
          <n-empty v-if="!detail.progressList?.length" description="暂无进度记录" />
          <n-timeline v-else>
            <n-timeline-item
              v-for="progress in detail.progressList"
              :key="progress.progressId"
              :time="progress.createTime"
              :title="getStepName(progress.stepId)"
              type="success"
            >
              {{ progress.description || '无说明' }}
            </n-timeline-item>
          </n-timeline>
        </n-tab-pane>
      </n-tabs>
    </n-card>

    <n-modal
      v-model:show="showAdvanceModal"
      title="推进到下一节点"
      preset="dialog"
      positive-text="确认推进"
      negative-text="取消"
      @positive-click="handleAdvance"
    >
      <n-form-item label="进度说明">
        <n-input v-model:value="advanceDesc" type="textarea" placeholder="可选填写本次推进说明" />
      </n-form-item>
    </n-modal>

    <n-modal
      v-model:show="showBlockModal"
      title="标记阻塞"
      preset="dialog"
      positive-text="确认阻塞"
      negative-text="取消"
      @positive-click="handleBlock"
    >
      <n-form-item label="阻塞原因">
        <n-input v-model:value="blockReason" type="textarea" placeholder="请输入阻塞原因" />
      </n-form-item>
    </n-modal>

    <n-modal
      v-model:show="showDelayModal"
      title="登记延期"
      preset="dialog"
      positive-text="保存"
      negative-text="取消"
      @positive-click="handleDelay"
    >
      <n-form-item label="新的预计日期">
        <n-date-picker
          v-model:formatted-value="delayExpectedDate"
          type="date"
          value-format="yyyy-MM-dd"
          style="width: 100%"
        />
      </n-form-item>
      <n-form-item label="延期原因">
        <n-input v-model:value="delayReason" type="textarea" placeholder="请输入延期原因" />
      </n-form-item>
    </n-modal>

    <n-modal
      v-model:show="showShipModal"
      title="标记发货"
      preset="dialog"
      positive-text="确认发货"
      negative-text="取消"
      @positive-click="handleShip"
    >
      <n-form-item label="发货说明">
        <n-input v-model:value="shipDesc" type="textarea" placeholder="可选填写物流或发货说明" />
      </n-form-item>
    </n-modal>

    <n-modal
      v-model:show="showCancelModal"
      title="取消订单"
      preset="dialog"
      positive-text="确认取消"
      negative-text="返回"
      @positive-click="handleCancel"
    >
      <n-form-item label="取消原因">
        <n-input v-model:value="cancelReason" type="textarea" placeholder="请输入取消原因" />
      </n-form-item>
    </n-modal>

    <n-modal
      v-model:show="showProgressModal"
      title="添加进度记录"
      preset="dialog"
      positive-text="提交"
      negative-text="取消"
      @positive-click="handleAddProgress"
    >
      <n-form-item label="进度描述">
        <n-input v-model:value="progressDesc" type="textarea" placeholder="描述当前进度" />
      </n-form-item>
    </n-modal>
  </n-space>
</template>

<script lang="ts" setup>
import { computed, onMounted, ref } from 'vue';
import { useRoute } from 'vue-router';
import { useMessage } from 'naive-ui';
import {
  addProgress,
  advanceOrder,
  blockOrder,
  cancelOrder,
  delayOrder,
  getOrderDetail,
  shipOrder,
  unblockOrder,
} from '@/api/order/index';

const route = useRoute();
const message = useMessage();

const detailLoaded = ref(false);
const detail = ref<any>(null);

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

const statusMap: Record<number, { label: string; type: string }> = {
  0: { label: '待支付', type: 'default' },
  1: { label: '生产中', type: 'info' },
  2: { label: '待发货', type: 'warning' },
  3: { label: '待收货', type: 'warning' },
  4: { label: '已完成', type: 'success' },
  5: { label: '已取消', type: 'error' },
  6: { label: '待付尾款', type: 'warning' },
};

const currentStepIndex = computed(() => {
  if (!detail.value?.workflowSteps?.length) {
    return 0;
  }
  const currentId = detail.value.order?.currentStepId;
  const index = detail.value.workflowSteps.findIndex((step: any) => step.stepId === currentId);
  return index >= 0 ? index + 1 : 0;
});

async function loadDetail() {
  const id = Number(route.params.id);
  if (!id) {
    detailLoaded.value = true;
    return;
  }
  try {
    detail.value = await getOrderDetail(id);
    delayExpectedDate.value = detail.value?.order?.expectedDate || '';
  } finally {
    detailLoaded.value = true;
  }
}

function getStepName(stepId: number) {
  const step = detail.value?.workflowSteps?.find((item: any) => item.stepId === stepId);
  return step?.stepName || `节点 #${stepId}`;
}

function formatJson(value?: string) {
  if (!value) {
    return '-';
  }
  try {
    return JSON.stringify(JSON.parse(value), null, 2);
  } catch {
    return value;
  }
}

function formatAmount(value?: string | number | null) {
  if (value === null || value === undefined || value === '') {
    return '-';
  }
  return `¥${value}`;
}

async function handleAdvance() {
  await advanceOrder(detail.value.order.orderId, { description: advanceDesc.value || null });
  message.success('订单已推进');
  showAdvanceModal.value = false;
  advanceDesc.value = '';
  await loadDetail();
}

async function handleBlock() {
  if (!blockReason.value.trim()) {
    message.warning('请输入阻塞原因');
    return false;
  }
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
    message.warning('请填写延期原因和新的预计日期');
    return false;
  }
  await delayOrder(detail.value.order.orderId, {
    delayReason: delayReason.value,
    expectedDate: delayExpectedDate.value,
  });
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
  if (!cancelReason.value.trim()) {
    message.warning('请输入取消原因');
    return false;
  }
  await cancelOrder(detail.value.order.orderId, { cancelReason: cancelReason.value });
  message.success('订单已取消');
  showCancelModal.value = false;
  cancelReason.value = '';
  await loadDetail();
}

async function handleAddProgress() {
  if (!progressDesc.value.trim()) {
    message.warning('请输入进度描述');
    return false;
  }
  await addProgress(detail.value.order.orderId, { description: progressDesc.value });
  message.success('进度已添加');
  showProgressModal.value = false;
  progressDesc.value = '';
  await loadDetail();
}

onMounted(loadDetail);
</script>

<style scoped>
.page-state {
  padding: 80px 0;
  text-align: center;
  color: #999;
}

.json-box {
  background: #f5f5f5;
  padding: 12px;
  border-radius: 4px;
  font-size: 12px;
  white-space: pre-wrap;
}
</style>
