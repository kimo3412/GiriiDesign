<template>
  <n-space vertical :size="16">
    <n-card :bordered="false">
      <n-space justify="space-between" align="center" wrap>
        <n-space align="center" wrap>
          <n-text depth="3">品类</n-text>
          <n-select
            v-model:value="selectedCategoryId"
            :options="categoryOptions"
            placeholder="请选择品类"
            style="width: 240px"
            @update:value="handleCategoryChange"
          />
        </n-space>
        <n-space align="center" wrap>
          <n-tag v-if="selectedStep" type="info" size="medium">{{ selectedStep.stepName }}</n-tag>
          <n-tag v-if="selectedStep?.expectedDurationDays" type="warning" size="medium">
            预计 {{ selectedStep.expectedDurationDays }} 天
          </n-tag>
          <n-tag v-if="selectedStep?.needImageUpload === 1" type="error" size="medium">需上传图片</n-tag>
          <n-tag v-if="selectedStep?.visibleToClient === 1" type="success" size="medium">客户端可见</n-tag>
        </n-space>
      </n-space>

      <div v-if="selectedCategoryId && workflowSteps.length" class="step-switcher">
        <button
          v-for="step in workflowSteps"
          :key="step.stepId"
          type="button"
          class="step-chip"
          :class="{ active: step.stepId === selectedStepId }"
          @click="handleStepChange(step.stepId)"
        >
          <span class="step-chip__title">{{ step.stepName }}</span>
          <span class="step-chip__meta">第 {{ step.stepOrder }} 步</span>
        </button>
      </div>
    </n-card>

    <n-grid :cols="24" :x-gap="16" :y-gap="16" responsive="screen">
      <n-gi :span="24" :lg="9">
        <n-card :bordered="false" title="节点订单">
          <template #header-extra>
            <n-text depth="3">{{ orders.length }} 条</n-text>
          </template>

          <n-spin :show="loadingWorkbench">
            <n-empty v-if="!selectedCategoryId" description="请先选择一个品类" />
            <n-empty
              v-else-if="workflowSteps.length === 0"
              description="当前品类还没有配置工作流"
            />
            <n-empty
              v-else-if="orders.length === 0"
              :description="`${selectedStep?.stepName || '当前节点'} 暂无订单`"
            />
            <div v-else class="order-list">
              <button
                v-for="order in orders"
                :key="order.orderId"
                type="button"
                class="order-card"
                :class="{
                  active: order.orderId === activeOrderId,
                  blocked: order.isBlocked === 1,
                }"
                @click="selectOrder(order.orderId)"
              >
                <div class="order-card__head">
                  <div>
                    <div class="order-card__sn">{{ order.orderSn }}</div>
                    <div class="order-card__time">{{ order.createTime }}</div>
                  </div>
                  <n-tag v-if="order.isBlocked === 1" type="error" size="small">已阻塞</n-tag>
                </div>
                <div class="order-card__meta">
                  <span>用户 #{{ order.userId }}</span>
                  <span>设计师 #{{ order.designerId || '-' }}</span>
                </div>
                <div v-if="order.blockReason" class="order-card__reason">
                  {{ order.blockReason }}
                </div>
              </button>
            </div>
          </n-spin>
        </n-card>
      </n-gi>

      <n-gi :span="24" :lg="15">
        <n-card :bordered="false" :title="activeOrder ? `订单 ${activeOrder.orderSn}` : '节点执行面板'">
          <n-spin :show="loadingDetail">
            <n-empty v-if="!activeOrder" description="选择左侧订单后即可处理当前节点" />
            <div v-else class="workbench-panel">
              <div class="workbench-summary">
                <div class="summary-main">
                  <div class="summary-title">{{ selectedStep?.stepName || '当前节点' }}</div>
                  <div class="summary-desc">
                    {{ selectedStep?.nodeDescription || '该节点暂无额外说明。' }}
                  </div>
                </div>
                <n-space wrap>
                  <n-tag :type="activeOrder.isBlocked === 1 ? 'error' : 'info'">
                    {{ activeOrder.isBlocked === 1 ? '阻塞中' : '进行中' }}
                  </n-tag>
                  <n-tag v-if="activeOrder.expectedDate" type="warning">
                    预计交付 {{ activeOrder.expectedDate }}
                  </n-tag>
                </n-space>
              </div>

              <n-alert
                v-if="activeOrder.isBlocked === 1 && activeOrder.blockReason"
                type="error"
                :show-icon="false"
                class="panel-alert"
              >
                当前订单阻塞原因：{{ activeOrder.blockReason }}
              </n-alert>
              <n-alert
                v-if="selectedStep?.needImageUpload === 1"
                type="warning"
                :show-icon="false"
                class="panel-alert"
              >
                当前节点要求上传图片后才能保存记录或推进下一步。
              </n-alert>

              <n-grid :cols="2" :x-gap="12" class="summary-grid">
                <n-gi>
                  <div class="summary-label">客户</div>
                  <div class="summary-value">#{{ activeOrder.userId }}</div>
                </n-gi>
                <n-gi>
                  <div class="summary-label">设计师</div>
                  <div class="summary-value">#{{ activeOrder.designerId || '-' }}</div>
                </n-gi>
                <n-gi>
                  <div class="summary-label">总金额</div>
                  <div class="summary-value">{{ formatAmount(activeOrder.totalAmount) }}</div>
                </n-gi>
                <n-gi>
                  <div class="summary-label">预付款</div>
                  <div class="summary-value">{{ formatAmount(activeOrder.prepayAmount) }}</div>
                </n-gi>
              </n-grid>

              <n-form label-placement="top" class="action-form">
                <n-form-item label="节点记录">
                  <n-input
                    v-model:value="actionForm.description"
                    type="textarea"
                    :autosize="{ minRows: 3, maxRows: 5 }"
                    placeholder="填写当前节点产出、沟通结果或处理说明"
                  />
                </n-form-item>

                <n-form-item
                  v-if="canRenderAction('block') || activeOrder.isBlocked === 1"
                  label="阻塞原因"
                >
                  <n-input
                    v-model:value="actionForm.blockReason"
                    type="textarea"
                    :autosize="{ minRows: 2, maxRows: 4 }"
                    placeholder="仅在阻塞时必填"
                  />
                </n-form-item>

                <n-form-item label="节点图片">
                  <n-upload
                    v-model:file-list="uploadFiles"
                    list-type="image-card"
                    :custom-request="handleUpload"
                    :default-upload="false"
                    :max="6"
                    multiple
                  >
                    上传图片
                  </n-upload>
                </n-form-item>

                <div class="action-buttons">
                  <n-button
                    v-if="canRenderAction('save')"
                    type="default"
                    :loading="submittingAction === 'save'"
                    @click="submitAction('save')"
                  >
                    保存记录
                  </n-button>
                  <n-button
                    v-if="canRenderAction('advance')"
                    type="primary"
                    :disabled="activeOrder.isBlocked === 1"
                    :loading="submittingAction === 'advance'"
                    @click="submitAction('advance')"
                  >
                    推进下一步
                  </n-button>
                  <n-button
                    v-if="canRenderAction('block')"
                    type="warning"
                    :disabled="activeOrder.isBlocked === 1"
                    :loading="submittingAction === 'block'"
                    @click="submitAction('block')"
                  >
                    标记阻塞
                  </n-button>
                  <n-button
                    v-if="canRenderAction('unblock')"
                    type="success"
                    :disabled="activeOrder.isBlocked !== 1"
                    :loading="submittingAction === 'unblock'"
                    @click="submitAction('unblock')"
                  >
                    解除阻塞
                  </n-button>
                </div>
              </n-form>

              <n-divider>历史进度</n-divider>

              <n-empty
                v-if="!detail?.progressList?.length"
                description="当前订单暂无进度记录"
              />
              <n-timeline v-else>
                <n-timeline-item
                  v-for="progress in detail.progressList"
                  :key="progress.progressId"
                  type="info"
                  :time="progress.createTime"
                  :title="getStepName(progress.stepId)"
                >
                  <div class="timeline-desc">{{ progress.description || '无说明' }}</div>
                  <div v-if="parseImageUrls(progress.imageUrls).length" class="timeline-images">
                    <n-image
                      v-for="image in parseImageUrls(progress.imageUrls)"
                      :key="image"
                      width="88"
                      height="88"
                      object-fit="cover"
                      :src="toFileUrl(image)"
                    />
                  </div>
                </n-timeline-item>
              </n-timeline>
            </div>
          </n-spin>
        </n-card>
      </n-gi>
    </n-grid>
  </n-space>
</template>

<script lang="ts" setup>
import { computed, onMounted, ref } from 'vue';
import type { UploadCustomRequestOptions, UploadFileInfo } from 'naive-ui';
import { useMessage } from 'naive-ui';
import { useRoute } from 'vue-router';
import { getCategoryList } from '@/api/config/category';
import { getOrderDetail, getWorkbenchData, submitWorkbenchAction } from '@/api/order/index';
import { useGlobSetting } from '@/hooks/setting';
import { ACCESS_TOKEN } from '@/store/mutation-types';
import { storage } from '@/utils/Storage';

type WorkbenchAction = 'save' | 'advance' | 'block' | 'unblock';

const route = useRoute();
const message = useMessage();
const { uploadUrl, fileUrl } = useGlobSetting();

const categoryOptions = ref<{ label: string; value: number }[]>([]);
const selectedCategoryId = ref<number | null>(null);
const selectedStepId = ref<number | null>(null);
const workflowSteps = ref<any[]>([]);
const orders = ref<any[]>([]);
const activeOrderId = ref<number | null>(null);
const detail = ref<any>(null);
const loadingWorkbench = ref(false);
const loadingDetail = ref(false);
const submittingAction = ref<WorkbenchAction | ''>('');
const uploadFiles = ref<UploadFileInfo[]>([]);

const actionForm = ref({
  description: '',
  blockReason: '',
});

const selectedStep = computed(
  () => workflowSteps.value.find((step) => step.stepId === selectedStepId.value) || null
);

const activeOrder = computed(() => {
  return orders.value.find((item) => item.orderId === activeOrderId.value) || detail.value?.order || null;
});

const allowedActions = computed<WorkbenchAction[]>(() => {
  const raw = selectedStep.value?.allowedActions;
  if (!raw) {
    return ['save', 'advance', 'block', 'unblock'];
  }
  try {
    const parsed = JSON.parse(raw);
    return Array.isArray(parsed) ? parsed : ['save', 'advance', 'block', 'unblock'];
  } catch {
    return ['save', 'advance', 'block', 'unblock'];
  }
});

onMounted(async () => {
  await loadCategories();
  const queryCategoryId = Number(route.query.categoryId);
  if (queryCategoryId) {
    selectedCategoryId.value = queryCategoryId;
  } else if (categoryOptions.value.length) {
    selectedCategoryId.value = categoryOptions.value[0].value;
  }
  if (selectedCategoryId.value) {
    await loadWorkbench();
  }
});

async function loadCategories() {
  const list = await getCategoryList();
  categoryOptions.value = list.map((item: any) => ({
    label: item.name,
    value: item.categoryId,
  }));
}

async function handleCategoryChange() {
  selectedStepId.value = null;
  await loadWorkbench();
}

async function handleStepChange(stepId: number) {
  if (selectedStepId.value === stepId) return;
  selectedStepId.value = stepId;
  await loadWorkbench();
}

async function loadWorkbench() {
  if (!selectedCategoryId.value) return;
  loadingWorkbench.value = true;
  try {
    const res = await getWorkbenchData(selectedCategoryId.value, selectedStepId.value ? { stepId: selectedStepId.value } : undefined);
    workflowSteps.value = res?.workflowSteps || [];
    selectedStepId.value = res?.selectedStepId || workflowSteps.value[0]?.stepId || null;
    orders.value = res?.orders || [];

    if (orders.value.some((item: any) => item.orderId === activeOrderId.value)) {
      await loadOrderDetail(activeOrderId.value as number);
      return;
    }

    if (orders.value.length > 0) {
      await selectOrder(orders.value[0].orderId);
      return;
    }

    activeOrderId.value = null;
    detail.value = null;
    resetEditor();
  } finally {
    loadingWorkbench.value = false;
  }
}

async function selectOrder(orderId: number) {
  activeOrderId.value = orderId;
  resetEditor();
  await loadOrderDetail(orderId);
}

async function loadOrderDetail(orderId: number) {
  loadingDetail.value = true;
  try {
    detail.value = await getOrderDetail(orderId);
  } finally {
    loadingDetail.value = false;
  }
}

function resetEditor() {
  actionForm.value = {
    description: '',
    blockReason: '',
  };
  uploadFiles.value = [];
}

function canRenderAction(action: WorkbenchAction) {
  return allowedActions.value.includes(action);
}

function formatAmount(value?: number | string | null) {
  if (value === null || value === undefined || value === '') {
    return '-';
  }
  return `¥${value}`;
}

function parseImageUrls(value?: string | null) {
  if (!value) return [];
  try {
    const parsed = JSON.parse(value);
    if (Array.isArray(parsed)) {
      return parsed.filter(Boolean);
    }
    if (typeof parsed === 'string' && parsed) {
      return [parsed];
    }
  } catch {
    if (value) {
      return [value];
    }
  }
  return [];
}

function getStepName(stepId?: number | null) {
  if (!stepId) return '未绑定节点';
  const steps = detail.value?.workflowSteps || workflowSteps.value;
  const step = steps.find((item: any) => item.stepId === stepId);
  return step?.stepName || `节点 #${stepId}`;
}

function toFileUrl(url?: string | null) {
  if (!url) return '';
  if (/^https?:\/\//i.test(url)) {
    return url;
  }
  if (!fileUrl) {
    return url;
  }
  return `${fileUrl}${url}`;
}

function getUploadedImageUrls() {
  return uploadFiles.value
    .map((file) => file.url)
    .filter((url): url is string => typeof url === 'string' && !!url);
}

async function handleUpload(options: UploadCustomRequestOptions) {
  const file = options.file.file;
  if (!file) {
    options.onError();
    return;
  }

  try {
    const formData = new FormData();
    formData.append('file', file);

    const token = storage.get(ACCESS_TOKEN);
    const response = await fetch(uploadUrl || '/api/v1/oss/upload', {
      method: 'POST',
      headers: token ? { Authorization: `Bearer ${token}` } : undefined,
      body: formData,
    });

    const result = await response.json();
    if (!response.ok || result.code !== 200 || !result.data) {
      message.error(result.msg || '图片上传失败');
      options.onError();
      return;
    }

    options.file.url = result.data;
    options.onFinish();
  } catch (error) {
    console.error(error);
    message.error('图片上传失败');
    options.onError();
  }
}

async function submitAction(action: WorkbenchAction) {
  if (!activeOrder.value) return;
  if (action === 'block' && !actionForm.value.blockReason.trim()) {
    message.warning('请先填写阻塞原因');
    return;
  }

  const imageUrls = getUploadedImageUrls();
  submittingAction.value = action;
  try {
    await submitWorkbenchAction(activeOrder.value.orderId, {
      action,
      description: actionForm.value.description.trim() || null,
      blockReason: actionForm.value.blockReason.trim() || null,
      imageUrls: imageUrls.length ? JSON.stringify(imageUrls) : null,
    });
    message.success(actionSuccessText[action]);
    resetEditor();
    await loadWorkbench();
  } finally {
    submittingAction.value = '';
  }
}

const actionSuccessText: Record<WorkbenchAction, string> = {
  save: '节点记录已保存',
  advance: '订单已推进到下一步',
  block: '订单已标记为阻塞',
  unblock: '订单已解除阻塞',
};
</script>

<style scoped>
.step-switcher {
  display: flex;
  gap: 12px;
  margin-top: 16px;
  padding-top: 16px;
  border-top: 1px solid #f1f3f5;
  overflow-x: auto;
}

.step-chip {
  min-width: 132px;
  padding: 12px 14px;
  border: 1px solid #e5e7eb;
  border-radius: 14px;
  background: #fff;
  text-align: left;
  cursor: pointer;
  transition: all 0.2s ease;
}

.step-chip:hover,
.step-chip.active {
  border-color: #18a058;
  background: #f3fbf7;
}

.step-chip__title {
  display: block;
  color: #111827;
  font-weight: 600;
}

.step-chip__meta {
  display: block;
  margin-top: 4px;
  color: #6b7280;
  font-size: 12px;
}

.order-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.order-card {
  width: 100%;
  padding: 14px;
  border: 1px solid #e5e7eb;
  border-radius: 14px;
  background: #fff;
  text-align: left;
  cursor: pointer;
  transition: all 0.2s ease;
}

.order-card:hover,
.order-card.active {
  border-color: #18a058;
  box-shadow: 0 8px 24px rgba(24, 160, 88, 0.08);
}

.order-card.blocked {
  border-color: #d03050;
  background: #fff7f7;
}

.order-card__head,
.order-card__meta {
  display: flex;
  justify-content: space-between;
  gap: 12px;
}

.order-card__sn {
  color: #111827;
  font-weight: 700;
}

.order-card__time,
.order-card__meta,
.order-card__reason,
.summary-desc,
.summary-label,
.timeline-desc {
  color: #6b7280;
}

.order-card__time,
.summary-label {
  font-size: 12px;
}

.order-card__meta {
  margin-top: 10px;
  font-size: 12px;
}

.order-card__reason {
  margin-top: 10px;
  line-height: 1.5;
}

.workbench-panel {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.workbench-summary {
  display: flex;
  justify-content: space-between;
  gap: 16px;
  padding: 16px 18px;
  border-radius: 16px;
  background: linear-gradient(135deg, #f6fbf8 0%, #eef7ff 100%);
}

.summary-title {
  color: #111827;
  font-size: 18px;
  font-weight: 700;
}

.summary-desc {
  margin-top: 8px;
  line-height: 1.7;
}

.panel-alert,
.summary-grid,
.action-form {
  margin-top: 4px;
}

.summary-value {
  margin-top: 4px;
  color: #111827;
  font-weight: 600;
}

.action-buttons {
  display: flex;
  flex-wrap: wrap;
  gap: 12px;
}

.timeline-images {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  margin-top: 10px;
}
</style>
