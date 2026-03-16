<template>
  <div v-if="!detailLoaded" style="text-align: center; padding: 80px 0; color: #999;">
    加载中...
  </div>
  <div v-else-if="!detail" style="text-align: center; padding: 80px 0; color: #999;">
    订单不存在
  </div>
  <div v-else>
    <!-- 顶部信息卡 -->
    <n-card :bordered="false" style="margin-bottom: 16px;">
      <n-space justify="space-between" align="center">
        <n-space align="center" :size="16">
          <n-text strong style="font-size: 18px;">{{ detail.order.orderSn }}</n-text>
          <n-tag :type="statusMap[detail.order.status]?.type" size="medium">
            {{ statusMap[detail.order.status]?.label }}
          </n-tag>
          <n-tag v-if="detail.order.isBlocked === 1" type="error">已阻塞：{{ detail.order.blockReason }}</n-tag>
        </n-space>
        <n-space>
          <n-button v-if="detail.order.status === 1 && detail.order.isBlocked !== 1" type="primary" @click="showAdvanceModal = true">
            推进节点
          </n-button>
          <n-button v-if="detail.order.status === 1 && detail.order.isBlocked !== 1" type="warning" @click="showBlockModal = true">
            标记阻塞
          </n-button>
          <n-button v-if="detail.order.isBlocked === 1" type="success" @click="handleUnblock">
            解除阻塞
          </n-button>
          <n-button @click="showProgressModal = true">添加进度</n-button>
        </n-space>
      </n-space>
    </n-card>

    <!-- 主体 Tabs -->
    <n-card :bordered="false">
      <n-tabs type="line">
        <!-- Tab: 基本信息 -->
        <n-tab-pane name="info" tab="基本信息">
          <n-descriptions bordered :column="2">
            <n-descriptions-item label="订单编号">{{ detail.order.orderSn }}</n-descriptions-item>
            <n-descriptions-item label="品类ID">{{ detail.order.categoryId }}</n-descriptions-item>
            <n-descriptions-item label="客户ID">{{ detail.order.userId }}</n-descriptions-item>
            <n-descriptions-item label="设计师ID">{{ detail.order.designerId || '未指派' }}</n-descriptions-item>
            <n-descriptions-item label="总金额">{{ detail.order.totalAmount ? `¥${detail.order.totalAmount}` : '-' }}</n-descriptions-item>
            <n-descriptions-item label="预付款">{{ detail.order.prepayAmount ? `¥${detail.order.prepayAmount}` : '-' }}</n-descriptions-item>
            <n-descriptions-item label="已付款">{{ detail.order.paidAmount ? `¥${detail.order.paidAmount}` : '¥0' }}</n-descriptions-item>
            <n-descriptions-item label="预计交付">{{ detail.order.expectedDate || '-' }}</n-descriptions-item>
            <n-descriptions-item label="创建时间">{{ detail.order.createTime }}</n-descriptions-item>
            <n-descriptions-item label="完成时间">{{ detail.order.finishTime || '-' }}</n-descriptions-item>
            <n-descriptions-item label="备注" :span="2">{{ detail.order.remark || '无' }}</n-descriptions-item>
          </n-descriptions>

          <n-divider>定制参数快照</n-divider>
          <pre style="background: #f5f5f5; padding: 12px; border-radius: 4px; font-size: 12px; white-space: pre-wrap;">{{ formatJson(detail.order.customDataSnapshot) }}</pre>
        </n-tab-pane>

        <!-- Tab: 工作流进度 -->
        <n-tab-pane name="workflow" tab="工作流进度">
          <n-steps :current="currentStepIndex" style="margin-bottom: 24px;">
            <n-step v-for="step in detail.workflowSteps" :key="step.stepId" :title="step.stepName" />
          </n-steps>
        </n-tab-pane>

        <!-- Tab: 进度时间轴 -->
        <n-tab-pane name="timeline" tab="进度时间轴">
          <div v-if="detail.progressList.length === 0" style="text-align: center; color: #999; padding: 40px;">
            暂无进度记录
          </div>
          <n-timeline v-else>
            <n-timeline-item
              v-for="p in detail.progressList"
              :key="p.progressId"
              :time="p.createTime"
              :title="getStepName(p.stepId)"
              :content="p.description"
              type="success"
            />
          </n-timeline>
        </n-tab-pane>
      </n-tabs>
    </n-card>

    <!-- 推进节点弹窗 -->
    <n-modal v-model:show="showAdvanceModal" title="推进到下一节点" preset="dialog" positive-text="确认推进" negative-text="取消" @positive-click="handleAdvance" style="width: 450px">
      <n-form-item label="进度说明">
        <n-input v-model:value="advanceDesc" type="textarea" placeholder="可输入当前节点的完成说明（选填）" />
      </n-form-item>
    </n-modal>

    <!-- 阻塞弹窗 -->
    <n-modal v-model:show="showBlockModal" title="标记阻塞" preset="dialog" positive-text="确认阻塞" negative-text="取消" @positive-click="handleBlock" style="width: 400px">
      <n-form-item label="阻塞原因">
        <n-input v-model:value="blockReason" type="textarea" placeholder="请描述阻塞原因" />
      </n-form-item>
    </n-modal>

    <!-- 添加进度弹窗 -->
    <n-modal v-model:show="showProgressModal" title="添加进度记录" preset="dialog" positive-text="提交" negative-text="取消" @positive-click="handleAddProgress" style="width: 450px">
      <n-form-item label="进度描述">
        <n-input v-model:value="progressDesc" type="textarea" placeholder="描述当前进度..." />
      </n-form-item>
    </n-modal>
  </div>
</template>

<script lang="ts" setup>
import { ref, onMounted, computed } from 'vue';
import { useRoute } from 'vue-router';
import { useMessage } from 'naive-ui';
import { getOrderDetail, advanceOrder, blockOrder, unblockOrder, addProgress } from '@/api/order/index';

const route = useRoute();
const message = useMessage();

const detailLoaded = ref(false);
const detail = ref<any>(null);

const statusMap: any = {
  0: { label: '待支付', type: 'default' },
  1: { label: '生产中', type: 'info' },
  2: { label: '待发货', type: 'warning' },
  3: { label: '待收货', type: 'success' },
  4: { label: '已完成', type: 'success' },
  5: { label: '已取消', type: 'error' },
};

const showAdvanceModal = ref(false);
const advanceDesc = ref('');
const showBlockModal = ref(false);
const blockReason = ref('');
const showProgressModal = ref(false);
const progressDesc = ref('');

const currentStepIndex = computed(() => {
  if (!detail.value) return 0;
  const steps = detail.value.workflowSteps || [];
  const currentId = detail.value.order.currentStepId;
  if (!currentId) return 0;
  const idx = steps.findIndex((s: any) => s.stepId === currentId);
  return idx >= 0 ? idx + 1 : 0;
});

const getStepName = (stepId: number) => {
  if (!detail.value) return '';
  const step = (detail.value.workflowSteps || []).find((s: any) => s.stepId === stepId);
  return step ? step.stepName : `节点#${stepId}`;
};

const formatJson = (str: string) => {
  if (!str) return '无';
  try { return JSON.stringify(JSON.parse(str), null, 2); }
  catch { return str; }
};

const loadDetail = async () => {
  const id = Number(route.params.id);
  if (!id) return;
  try {
    detail.value = await getOrderDetail(id);
  } catch (e) { console.error(e); }
  finally { detailLoaded.value = true; }
};

onMounted(loadDetail);

const handleAdvance = async () => {
  try {
    await advanceOrder(detail.value.order.orderId, { description: advanceDesc.value });
    message.success('推进成功');
    showAdvanceModal.value = false;
    advanceDesc.value = '';
    loadDetail();
  } catch (e) { console.error(e); }
};

const handleBlock = async () => {
  try {
    await blockOrder(detail.value.order.orderId, { blockReason: blockReason.value });
    message.success('已标记阻塞');
    showBlockModal.value = false;
    blockReason.value = '';
    loadDetail();
  } catch (e) { console.error(e); }
};

const handleUnblock = async () => {
  try {
    await unblockOrder(detail.value.order.orderId);
    message.success('已解除阻塞');
    loadDetail();
  } catch (e) { console.error(e); }
};

const handleAddProgress = async () => {
  try {
    await addProgress(detail.value.order.orderId, { description: progressDesc.value });
    message.success('进度已添加');
    showProgressModal.value = false;
    progressDesc.value = '';
    loadDetail();
  } catch (e) { console.error(e); }
};
</script>
