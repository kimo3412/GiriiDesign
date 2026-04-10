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
          <n-tag v-if="selectedStep?.needImageUpload === 1" type="error" size="medium">
            需上传图片
          </n-tag>
          <n-tag v-if="selectedStep?.visibleToClient === 1" type="success" size="medium">
            客户端可见
          </n-tag>
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
            <n-empty v-else-if="workflowSteps.length === 0" description="当前品类还没有配置工作流" />
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
                :class="{ active: order.orderId === activeOrderId, blocked: order.isBlocked === 1 }"
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
                  <span>{{ getCustomerLabel(order) }}</span>
                  <span>{{ getDesignerLabel(order) }}</span>
                </div>
                <div v-if="order.blockReason" class="order-card__reason">{{ order.blockReason }}</div>
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
                <div>
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
                  <n-tag v-if="rollbackTargetLabel" type="default">
                    默认退回：{{ rollbackTargetLabel }}
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
                  <div class="summary-value">{{ getCustomerLabel(activeOrder) }}</div>
                </n-gi>
                <n-gi>
                  <div class="summary-label">设计师</div>
                  <div class="summary-value">{{ getDesignerLabel(activeOrder) }}</div>
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

              <n-form ref="formRef" :model="nodeFieldValues" label-placement="top" class="action-form">
                <n-form-item label="节点记录">
                  <n-input
                    v-model:value="actionForm.description"
                    type="textarea"
                    :autosize="{ minRows: 3, maxRows: 5 }"
                    placeholder="填写当前节点产出、沟通结果或处理说明"
                  />
                </n-form-item>

                <template v-if="currentStepFields.length">
                  <n-divider>节点字段</n-divider>
                  <n-grid :cols="2" :x-gap="12">
                    <n-gi v-for="field in currentStepFields" :key="field.fieldKey">
                      <n-form-item :label="getFieldFormLabel(field)" :rule="getFieldRule(field)" :path="field.fieldKey">
                        <n-input
                          v-if="field.fieldType === 'text' || field.fieldType === 'image'"
                          v-model:value="nodeFieldValues[field.fieldKey]"
                          :placeholder="field.placeholder || `请输入${field.label}`"
                        />
                        <n-input
                          v-else-if="field.fieldType === 'textarea'"
                          v-model:value="nodeFieldValues[field.fieldKey]"
                          type="textarea"
                          :autosize="{ minRows: 2, maxRows: 4 }"
                          :placeholder="field.placeholder || `请输入${field.label}`"
                        />
                        <n-input-number
                          v-else-if="field.fieldType === 'number'"
                          v-model:value="nodeFieldValues[field.fieldKey]"
                          clearable
                          style="width: 100%"
                          :placeholder="field.placeholder || `请输入${field.label}`"
                        />
                        <n-select
                          v-else-if="field.fieldType === 'select'"
                          v-model:value="nodeFieldValues[field.fieldKey]"
                          :options="getSelectOptions(field)"
                          clearable
                          :placeholder="field.placeholder || `请选择${field.label}`"
                        />
                        <n-date-picker
                          v-else-if="field.fieldType === 'date'"
                          v-model:formatted-value="nodeFieldValues[field.fieldKey]"
                          type="date"
                          value-format="yyyy-MM-dd"
                          clearable
                          style="width: 100%"
                        />
                        <n-input
                          v-else
                          v-model:value="nodeFieldValues[field.fieldKey]"
                          :placeholder="field.placeholder || `请输入${field.label}`"
                        />
                        <div v-if="getFieldHelperText(field)" class="field-helper">
                          {{ getFieldHelperText(field) }}
                        </div>
                      </n-form-item>
                    </n-gi>
                  </n-grid>
                </template>

                <n-alert
                  v-if="canRenderAction('rollback')"
                  type="info"
                  :show-icon="false"
                  class="panel-alert"
                >
                  <template v-if="rollbackOptions.length">
                    当前位于「{{ currentOrderStepName }}」，可退回到：{{ rollbackOptionText }}。
                    当前将退回到「{{ rollbackTargetLabel }}」。
                  </template>
                  <template v-else>
                    当前订单已经在流程第一步，不能继续退回。
                  </template>
                </n-alert>

                <n-form-item v-if="canRenderAction('rollback')" label="退回目标节点">
                  <n-select
                    v-model:value="actionForm.rollbackTargetStepId"
                    :options="rollbackOptions"
                    :disabled="!rollbackOptions.length"
                    placeholder="默认退回上一步，也可选择更早的前序节点"
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
                    v-if="canRenderAction('rollback')"
                    type="error"
                    ghost
                    :disabled="!rollbackOptions.length || activeOrder.isBlocked === 1"
                    :loading="submittingAction === 'rollback'"
                    @click="submitAction('rollback')"
                  >
                    {{ rollbackActionText }}
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

              <n-empty v-if="!detail?.progressList?.length" description="当前订单暂无进度记录" />
              <n-timeline v-else>
                <n-timeline-item
                  v-for="progress in detail.progressList"
                  :key="progress.progressId"
                  type="info"
                  :time="progress.createTime"
                  :title="getStepName(progress.stepId)"
                >
                  <div class="timeline-desc">{{ progress.description || '无说明' }}</div>
                  <div v-if="getProgressFormEntries(progress).length" class="timeline-form">
                    <div v-for="entry in getProgressFormEntries(progress)" :key="entry.key" class="timeline-form__item">
                      <span class="timeline-form__label">{{ entry.label }}：</span>
                      <span>{{ entry.value }}</span>
                    </div>
                  </div>
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
import { useDialog, useMessage } from 'naive-ui';
import { useRoute } from 'vue-router';
import { getCategoryList } from '@/api/config/category';
import { getFieldList, type CustomField } from '@/api/config/field';
import { getOrderDetail, getWorkbenchData, submitWorkbenchAction } from '@/api/order/index';
import { useGlobSetting } from '@/hooks/setting';
import { ACCESS_TOKEN } from '@/store/mutation-types';
import { storage } from '@/utils/Storage';

type WorkbenchAction = 'save' | 'advance' | 'rollback' | 'block' | 'unblock';

const route = useRoute();
const message = useMessage();
const dialog = useDialog();
const { uploadUrl, fileUrl } = useGlobSetting();

const categoryOptions = ref<{ label: string; value: number }[]>([]);
const selectedCategoryId = ref<number | null>(null);
const selectedStepId = ref<number | null>(null);
const workflowSteps = ref<any[]>([]);
const categoryFields = ref<CustomField[]>([]);
const orders = ref<any[]>([]);
const activeOrderId = ref<number | null>(null);
const detail = ref<any>(null);
const loadingWorkbench = ref(false);
const loadingDetail = ref(false);
const submittingAction = ref<WorkbenchAction | ''>('');
const uploadFiles = ref<UploadFileInfo[]>([]);
const nodeFieldValues = ref<Record<string, any>>({});
const formRef = ref<any>(null);

const actionForm = ref<{
  description: string;
  blockReason: string;
  rollbackTargetStepId: number | null;
}>({
  description: '',
  blockReason: '',
  rollbackTargetStepId: null,
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
    return ['save', 'advance', 'rollback', 'block', 'unblock'];
  }
  try {
    const parsed = JSON.parse(raw);
    return Array.isArray(parsed) ? parsed : ['save', 'advance', 'rollback', 'block', 'unblock'];
  } catch {
    return ['save', 'advance', 'rollback', 'block', 'unblock'];
  }
});

const rollbackOptions = computed(() => {
  if (!activeOrder.value) {
    return [];
  }
  const steps = detail.value?.workflowSteps || workflowSteps.value;
  const currentIndex = steps.findIndex((item: any) => item.stepId === activeOrder.value.currentStepId);
  if (currentIndex <= 0) {
    return [];
  }
  return steps
    .slice(0, currentIndex)
    .reverse()
    .map((step: any) => ({
      label: `${step.stepOrder}. ${step.stepName}`,
      value: step.stepId,
    }));
});

const rollbackTargetLabel = computed(() => {
  if (!rollbackOptions.value.length) {
    return '';
  }
  const target = rollbackOptions.value.find((item) => item.value === actionForm.value.rollbackTargetStepId);
  return target?.label || rollbackOptions.value[0].label;
});

const rollbackOptionText = computed(() => rollbackOptions.value.map((item) => item.label).join('、'));

const currentOrderStepName = computed(() => {
  if (!activeOrder.value?.currentStepId) {
    return '未绑定节点';
  }
  return getStepName(activeOrder.value.currentStepId);
});

const rollbackActionText = computed(() => {
  if (!rollbackOptions.value.length) {
    return '退回前序节点';
  }
  return rollbackTargetLabel.value ? `退回到 ${rollbackTargetLabel.value}` : '退回前序节点';
});

const currentStepFields = computed(() => {
  const raw = selectedStep.value?.nodeFormFields;
  if (!raw) {
    return [];
  }
  try {
    const keys = JSON.parse(raw);
    if (!Array.isArray(keys)) {
      return [];
    }
    return keys
      .map((key) => categoryFields.value.find((field) => field.fieldKey === key))
      .filter(Boolean) as CustomField[];
  } catch {
    return [];
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
    await loadCategoryFields();
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
  await loadCategoryFields();
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
    const res = await getWorkbenchData(
      selectedCategoryId.value,
      selectedStepId.value ? { stepId: selectedStepId.value } : undefined
    );
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

async function loadCategoryFields() {
  if (!selectedCategoryId.value) return;
  categoryFields.value = await getFieldList(selectedCategoryId.value);
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
    syncRollbackTarget();
  } finally {
    loadingDetail.value = false;
  }
}

function resetEditor() {
  actionForm.value = {
    description: '',
    blockReason: '',
    rollbackTargetStepId: null,
  };
  uploadFiles.value = [];
  nodeFieldValues.value = {};
}

function syncRollbackTarget() {
  actionForm.value.rollbackTargetStepId = rollbackOptions.value[0]?.value || null;
  syncNodeFieldValues();
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

function getCustomerLabel(order?: any) {
  if (!order) return '-';
  return order.customerName || (order.userId ? `客户 #${order.userId}` : '-');
}

function getDesignerLabel(order?: any) {
  if (!order) return '-';
  return order.designerName || (order.designerId ? `设计师 #${order.designerId}` : '-');
}

function getFieldFormLabel(field: CustomField) {
  const unitText = field.unit ? `（${field.unit}）` : '';
  const requiredText = field.isRequired === 1 ? ' *' : '';
  return `${field.label}${unitText}${requiredText}`;
}

function getFieldHelperText(field: CustomField) {
  const tips: string[] = [];
  if (field.placeholder) {
    tips.push(field.placeholder);
  }
  if (field.unit) {
    tips.push(`单位：${field.unit}`);
  }
  return tips.join(' · ');
}

function getFieldRule(field: CustomField) {
  if (field.isRequired !== 1) return undefined;
  return {
    required: true,
    message: `请填写${field.label}`,
    trigger: ['blur', 'change'],
  };
}

/** 前端验证必填字段 */
function validateRequiredFields(): boolean {
  const requiredFields = currentStepFields.value.filter((f) => f.isRequired === 1);
  for (const field of requiredFields) {
    const val = nodeFieldValues.value[field.fieldKey];
    if (val === null || val === undefined || val === '') {
      message.warning(`请填写必填字段：${field.label}`);
      return false;
    }
  }
  if (selectedStep.value?.needImageUpload === 1 && !getUploadedImageUrls().length) {
    message.warning('当前节点要求上传图片');
    return false;
  }
  return true;
}

function syncNodeFieldValues() {
  const baseValues = parseObjectValue(activeOrder.value?.customDataSnapshot);
  const latestProgressValues = getLatestProgressFormData();
  const merged = {
    ...baseValues,
    ...latestProgressValues,
  };
  nodeFieldValues.value = currentStepFields.value.reduce((result, field) => {
    result[field.fieldKey] = merged[field.fieldKey] ?? null;
    return result;
  }, {} as Record<string, any>);
}

function getLatestProgressFormData() {
  const list = detail.value?.progressList || [];
  for (let index = list.length - 1; index >= 0; index -= 1) {
    const values = parseObjectValue(list[index]?.formData);
    if (Object.keys(values).length) {
      return values;
    }
  }
  return {};
}

function parseObjectValue(value?: string | null) {
  if (!value) return {};
  try {
    const parsed = JSON.parse(value);
    return parsed && typeof parsed === 'object' ? parsed : {};
  } catch {
    return {};
  }
}

function getSelectOptions(field: CustomField) {
  const parsed = parseFieldOptions(field.options);
  return parsed.map((item) => ({
    label: item,
    value: item,
  }));
}

function parseFieldOptions(options?: any) {
  if (!options) return [];
  if (Array.isArray(options)) return options;
  if (typeof options === 'string') {
    try {
      const parsed = JSON.parse(options);
      return Array.isArray(parsed) ? parsed : [];
    } catch {
      return [];
    }
  }
  return [];
}

function getProgressFormEntries(progress: any) {
  const values = parseObjectValue(progress?.formData);
  return Object.entries(values)
    .filter(([, value]) => value !== null && value !== undefined && value !== '')
    .map(([key, value]) => ({
      key,
      label: categoryFields.value.find((field) => field.fieldKey === key)?.label || key,
      value: formatFieldDisplayValue(categoryFields.value.find((field) => field.fieldKey === key), value),
    }));
}

function formatFieldDisplayValue(field: CustomField | undefined, value: any) {
  if (Array.isArray(value)) {
    const joined = value.filter((item) => item !== null && item !== undefined && item !== '').join('、');
    return appendFieldUnit(field, joined);
  }
  if (value && typeof value === 'object') {
    return appendFieldUnit(field, JSON.stringify(value));
  }
  return appendFieldUnit(field, value);
}

function appendFieldUnit(field: CustomField | undefined, value: any) {
  if (value === null || value === undefined || value === '') {
    return '-';
  }
  return field?.unit ? `${value} ${field.unit}` : String(value);
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
  return fileUrl ? `${fileUrl}${url}` : url;
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

  // 前置校验
  if (action === 'block' && !actionForm.value.blockReason.trim()) {
    message.warning('请先填写阻塞原因');
    return;
  }
  if (action === 'rollback' && !rollbackOptions.value.length) {
    message.warning('当前节点没有可退回的前序节点');
    return;
  }

  // save/advance 需要验证必填字段
  if (action === 'save' || action === 'advance') {
    if (!validateRequiredFields()) return;
  }

  // 确认弹窗（save 不需要确认）
  if (action !== 'save') {
    const confirmed = await confirmAction(action);
    if (!confirmed) return;
  }

  const imageUrls = getUploadedImageUrls();
  const formData =
    currentStepFields.value.length > 0 ? JSON.stringify(nodeFieldValues.value || {}) : null;
  submittingAction.value = action;
  try {
    await submitWorkbenchAction(activeOrder.value.orderId, {
      action,
      description: actionForm.value.description.trim() || null,
      blockReason: actionForm.value.blockReason.trim() || null,
      rollbackTargetStepId: action === 'rollback' ? actionForm.value.rollbackTargetStepId : null,
      formData,
      imageUrls: imageUrls.length ? JSON.stringify(imageUrls) : null,
    });
    message.success(actionSuccessText[action]);
    resetEditor();
    await loadWorkbench();
  } finally {
    submittingAction.value = '';
  }
}

function confirmAction(action: WorkbenchAction): Promise<boolean> {
  const configMap: Record<string, { title: string; content: string; type: 'warning' | 'error' | 'info' | 'success' }> = {
    advance: {
      title: '确认推进',
      content: '确认推进到下一节点？推进后客户将看到最新进度。',
      type: 'info',
    },
    rollback: {
      title: '确认退回',
      content: `确认退回到「${rollbackTargetLabel.value || '前序节点'}」？退回操作会通知客户。`,
      type: 'warning',
    },
    block: {
      title: '确认阻塞',
      content: `确认标记订单为阻塞？原因：${actionForm.value.blockReason.trim()}`,
      type: 'error',
    },
    unblock: {
      title: '确认解除阻塞',
      content: '确认解除阻塞？订单将恢复正常流转。',
      type: 'success',
    },
  };
  const config = configMap[action];
  if (!config) return Promise.resolve(true);

  return new Promise((resolve) => {
    dialog.warning({
      title: config.title,
      content: config.content,
      positiveText: '确认',
      negativeText: '取消',
      onPositiveClick: () => resolve(true),
      onNegativeClick: () => resolve(false),
      onClose: () => resolve(false),
      onMaskClick: () => resolve(false),
    });
  });
}

const actionSuccessText: Record<WorkbenchAction, string> = {
  save: '节点记录已保存',
  advance: '订单已推进到下一步',
  rollback: '订单已退回到指定前序节点',
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

.field-helper {
  margin-top: 8px;
  color: #9ca3af;
  font-size: 12px;
  line-height: 1.5;
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

.timeline-form {
  margin-top: 8px;
}

.timeline-form__item {
  color: #4b5563;
  font-size: 12px;
  line-height: 1.8;
}

.timeline-form__label {
  color: #6b7280;
}
</style>
