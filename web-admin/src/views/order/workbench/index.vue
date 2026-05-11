<template>
  <div class="workbench-page">
    <section class="hero-stage">
      <div class="hero-head">
        <div class="hero-main">
          <div class="hero-kicker">生产节点工作台</div>
          <h1 class="hero-title">节点工作台</h1>
          <div class="hero-meta">
            <span>当前订单</span>
            <span class="hero-order">{{ activeOrder?.orderSn || '待选择' }}</span>
            <span v-if="selectedStep">· 当前节点 {{ selectedStep.stepName }}</span>
          </div>
        </div>
        <div class="hero-actions">
          <div class="hero-filter">
            <span class="hero-filter__label">品类</span>
            <n-select
              v-model:value="selectedCategoryId"
              :options="categoryOptions"
              placeholder="请选择品类"
              style="width: 220px"
              @update:value="handleCategoryChange"
            />
          </div>
          <div class="hero-tags">
            <n-tag v-if="selectedStep?.expectedDurationDays" type="warning" size="medium">预计 {{ selectedStep.expectedDurationDays }} 天</n-tag>
            <n-tag v-if="selectedStep?.needImageUpload === 1" type="error" size="medium">需上传图片</n-tag>
            <n-tag v-if="selectedStep?.visibleToClient === 1" type="success" size="medium">客户端可见</n-tag>
          </div>
        </div>
      </div>

      <div v-if="selectedCategoryId && workflowSteps.length" class="process-track">
        <button
          v-for="step in workflowSteps"
          :key="step.stepId"
          type="button"
          class="track-step"
          :class="{ active: step.stepId === selectedStepId, current: step.stepId === activeOrder?.currentStepId }"
          @click="handleStepChange(step.stepId)"
        >
          <span class="track-step__dot">{{ step.stepOrder }}</span>
          <span class="track-step__name">{{ step.stepName }}</span>
        </button>
      </div>

      <div v-if="activeOrder" class="hero-overview">
        <div class="hero-overview__item">
          <span class="hero-overview__label">客户</span>
          <span class="hero-overview__value">{{ getCustomerLabel(activeOrder) }}</span>
        </div>
        <div class="hero-overview__item">
          <span class="hero-overview__label">设计师</span>
          <span class="hero-overview__value">{{ getDesignerLabel(activeOrder) }}</span>
        </div>
        <div class="hero-overview__item">
          <span class="hero-overview__label">总金额</span>
          <span class="hero-overview__value hero-overview__value--money">{{ formatAmount(activeOrder.totalAmount) }}</span>
        </div>
        <div class="hero-overview__item">
          <span class="hero-overview__label">预付款</span>
          <span class="hero-overview__value hero-overview__value--money">{{ formatAmount(activeOrder.prepayAmount) }}</span>
        </div>
        <div class="hero-overview__item">
          <span class="hero-overview__label">预计交付</span>
          <span class="hero-overview__value">{{ activeOrder.expectedDate || '未设置' }}</span>
        </div>
      </div>
    </section>

    <section class="order-switch-section">
      <div class="order-switch-section__head">
        <div>
          <div class="order-switch-section__title">当前节点订单</div>
          <div class="order-switch-section__caption">
            {{ selectedStep?.stepName || '当前节点' }} · {{ orders.length }} 条
            <span v-if="orders.length > orderPageSize"> · 当前第 {{ orderPage }} 页</span>
          </div>
        </div>
      </div>
      <n-spin :show="loadingWorkbench">
        <n-empty v-if="!selectedCategoryId" description="请先选择一个品类" />
        <n-empty v-else-if="workflowSteps.length === 0" description="当前品类还没有配置工作流" />
        <n-empty v-else-if="orders.length === 0" :description="`${selectedStep?.stepName || '当前节点'} 暂无订单`" />

        <div v-else class="order-switcher-shell">
          <div class="order-switcher">
          <button
            v-for="order in pagedOrders"
            :key="order.orderId"
            type="button"
            class="compact-order"
            :class="{ active: order.orderId === activeOrderId, blocked: order.isBlocked === 1 }"
            @click="selectOrder(order.orderId)"
          >
            <div class="compact-order__top">
              <span class="compact-order__sn">{{ order.orderSn }}</span>
              <n-tag v-if="order.isBlocked === 1" type="error" size="small" round>阻塞</n-tag>
            </div>
            <div class="compact-order__title">{{ getCustomerLabel(order) }}</div>
            <div class="compact-order__meta">
              <span>{{ getDesignerLabel(order) }}</span>
              <span>{{ getStepName(order.currentStepId) }}</span>
            </div>
          </button>
          </div>

          <div v-if="orders.length > orderPageSize" class="order-switcher-pagination">
            <span class="order-switcher-pagination__text">
              显示 {{ pageStartIndex + 1 }}-{{ pageEndIndex }} / {{ orders.length }}
            </span>
            <n-pagination
              v-model:page="orderPage"
              :page-size="orderPageSize"
              :item-count="orders.length"
              :page-slot="5"
              size="small"
            />
          </div>
        </div>
      </n-spin>
    </section>

    <div class="workspace-grid">
        <n-card :bordered="false" class="panel-card execution-panel">
          <n-spin :show="loadingDetail">
            <n-empty v-if="!activeOrder" description="选择左侧订单后即可处理当前节点" />

            <div v-else class="execution-content">
              <div class="execution-topline"></div>

              <div class="execution-header">
                <div>
                  <div class="step-badge">当前执行节点</div>
                  <div class="execution-title">{{ selectedStep?.stepName || '当前节点' }}</div>
                  <div class="execution-desc">{{ selectedStep?.nodeDescription || '该节点暂无额外说明。' }}</div>
                </div>
                <div class="execution-status">
                  <n-tag :type="activeOrder.isBlocked === 1 ? 'error' : 'success'" round>{{ activeOrder.isBlocked === 1 ? '阻塞中' : '执行中' }}</n-tag>
                </div>
              </div>

              <n-alert v-if="activeOrder.isBlocked === 1 && activeOrder.blockReason" type="error" :show-icon="false" class="panel-alert">
                当前订单阻塞原因：{{ activeOrder.blockReason }}
              </n-alert>

              <n-alert v-if="selectedStep?.needImageUpload === 1" type="warning" :show-icon="false" class="panel-alert">
                当前节点要求上传图片后才能保存记录或推进下一步。
              </n-alert>

              <n-form ref="formRef" :model="nodeFieldValues" label-placement="top" class="action-form">
                <template v-if="currentStepFields.length">
                  <div class="section-title">节点字段</div>
                  <div class="field-card-grid">
                    <div v-for="field in currentStepFields" :key="field.fieldKey" class="field-card">
                      <div class="field-card__label">{{ getFieldFormLabel(field) }}</div>
                      <n-form-item :show-label="false" :rule="getFieldRule(field)" :path="field.fieldKey">
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
                        <n-input v-else v-model:value="nodeFieldValues[field.fieldKey]" :placeholder="field.placeholder || `请输入${field.label}`" />
                      </n-form-item>
                      <div v-if="getFieldHelperText(field)" class="field-helper">{{ getFieldHelperText(field) }}</div>
                    </div>
                  </div>
                </template>

                <div class="section-title">节点记录 / 备注</div>
                <n-form-item label="节点记录">
                  <n-input
                    v-model:value="actionForm.description"
                    type="textarea"
                    :autosize="{ minRows: 4, maxRows: 6 }"
                    placeholder="填写当前节点产出、客户沟通结果、尺寸确认、工艺说明或需同步的信息"
                  />
                </n-form-item>

                <template v-if="selectedStep?.needImageUpload === 1">
                  <div class="section-title">节点图片</div>
                  <n-form-item label="节点图片">
                    <n-upload v-model:file-list="uploadFiles" list-type="image-card" :custom-request="handleUpload" :max="6" multiple accept="image/*">
                      上传图片
                    </n-upload>
                  </n-form-item>
                </template>

                <div class="action-bar">
                  <n-button v-if="canRenderAction('save')" quaternary :loading="submittingAction === 'save'" @click="submitAction('save')">保存记录</n-button>
                  <n-button v-if="canRenderAction('unblock')" quaternary type="success" :disabled="activeOrder.isBlocked !== 1" :loading="submittingAction === 'unblock'" @click="submitAction('unblock')">解除阻塞</n-button>
                  <n-button quaternary @click="lowFrequencyExpanded = !lowFrequencyExpanded">
                    {{ lowFrequencyExpanded ? '收起低频操作' : '展开低频操作' }}
                  </n-button>
                  <n-button v-if="canRenderAction('advance')" type="primary" class="action-bar__primary" :disabled="activeOrder.isBlocked === 1" :loading="submittingAction === 'advance'" @click="submitAction('advance')">推进到下一步</n-button>
                </div>

                <div v-if="lowFrequencyExpanded" class="low-frequency-panel">
                  <n-alert v-if="canRenderAction('rollback')" type="info" :show-icon="false" class="panel-alert">
                    <template v-if="rollbackOptions.length">
                      当前位于「{{ currentOrderStepName }}」，可退回到：{{ rollbackOptionText }}。当前将退回到「{{ rollbackTargetLabel }}」。
                    </template>
                    <template v-else>当前订单已经在流程第一步，不能继续退回。</template>
                  </n-alert>

                  <div class="compact-actions">
                    <n-form-item v-if="canRenderAction('rollback')" label="退回目标节点">
                      <n-select v-model:value="actionForm.rollbackTargetStepId" :options="rollbackOptions" :disabled="!rollbackOptions.length" placeholder="默认退回上一步，也可选择更早的前序节点" />
                    </n-form-item>

                    <n-form-item v-if="canRenderAction('block') || activeOrder.isBlocked === 1" label="阻塞原因">
                      <n-input v-model:value="actionForm.blockReason" type="textarea" :autosize="{ minRows: 2, maxRows: 4 }" placeholder="仅在阻塞时必填" />
                    </n-form-item>
                  </div>

                  <div v-if="selectedStep?.needImageUpload !== 1" class="section-title">参考图片</div>
                  <n-form-item v-if="selectedStep?.needImageUpload !== 1" label="节点图片">
                    <n-upload v-model:file-list="uploadFiles" list-type="image-card" :custom-request="handleUpload" :max="6" multiple accept="image/*">
                      上传图片
                    </n-upload>
                  </n-form-item>

                  <div class="secondary-actions">
                    <n-button v-if="canRenderAction('block')" type="warning" ghost :disabled="activeOrder.isBlocked === 1" :loading="submittingAction === 'block'" @click="submitAction('block')">标记阻塞</n-button>
                    <n-button v-if="canRenderAction('rollback')" ghost :disabled="!rollbackOptions.length || activeOrder.isBlocked === 1" :loading="submittingAction === 'rollback'" @click="submitAction('rollback')">{{ rollbackActionText }}</n-button>
                  </div>
                </div>
              </n-form>
            </div>
          </n-spin>
        </n-card>

      <div class="side-stack">
        <n-card v-if="activeOrder" :bordered="false" class="panel-card side-card">
          <template #header>
            <div class="panel-card__header panel-card__header--tight">
              <div class="panel-card__title">订单摘要</div>
            </div>
          </template>

          <div class="summary-panel">
            <div class="summary-row">
              <span class="summary-label">客户</span>
              <span class="summary-value">{{ getCustomerLabel(activeOrder) }}</span>
            </div>
            <div class="summary-row">
              <span class="summary-label">设计师</span>
              <span class="summary-value">{{ getDesignerLabel(activeOrder) }}</span>
            </div>
            <div class="summary-row">
              <span class="summary-label">下单时间</span>
              <span class="summary-value">{{ activeOrder.createTime || '-' }}</span>
            </div>
            <div class="summary-row">
              <span class="summary-label">预计交付</span>
              <span class="summary-value summary-value--highlight">{{ activeOrder.expectedDate || '未设置' }}</span>
            </div>
            <div class="summary-finance">
              <div>
                <div class="summary-finance__label">总金额</div>
                <div class="summary-finance__value">{{ formatAmount(activeOrder.totalAmount) }}</div>
              </div>
              <div>
                <div class="summary-finance__label">预付款</div>
                <div class="summary-finance__value">{{ formatAmount(activeOrder.prepayAmount) }}</div>
              </div>
            </div>
          </div>
        </n-card>

          <n-card :bordered="false" class="panel-card side-card">
            <template #header>
              <div class="panel-card__header panel-card__header--tight">
                <div class="panel-card__title">最近动态</div>
                <n-button text type="primary" @click="historyDrawerVisible = true">查看完整历史</n-button>
              </div>
            </template>

            <n-empty v-if="!detail?.progressList?.length" description="当前订单暂无进度记录" />
            <div v-else class="mini-timeline">
              <div v-for="progress in recentProgressList" :key="progress.progressId" class="mini-timeline__item">
                <div class="mini-timeline__dot"></div>
                <div class="mini-timeline__content">
                  <div class="mini-timeline__time">{{ progress.createTime }}</div>
                  <div class="mini-timeline__title">{{ getStepName(progress.stepId) }}</div>
                  <div class="mini-timeline__desc">{{ progress.description || '无说明' }}</div>
                </div>
              </div>
            </div>
          </n-card>
      </div>
    </div>

    <n-drawer v-model:show="historyDrawerVisible" :width="520" placement="right">
      <n-drawer-content title="完整历史进度" closable>
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
              <n-image v-for="image in parseImageUrls(progress.imageUrls)" :key="image" width="88" height="88" object-fit="cover" :src="toFileUrl(image)" />
            </div>
          </n-timeline-item>
        </n-timeline>
      </n-drawer-content>
    </n-drawer>

  </div>
</template>

<script lang="ts" setup>
import { computed, onMounted, ref, watch } from 'vue';
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
const orderPage = ref(1);
const orderPageSize = 6;
const activeOrderId = ref<number | null>(null);
const detail = ref<any>(null);
const loadingWorkbench = ref(false);
const loadingDetail = ref(false);
const submittingAction = ref<WorkbenchAction | ''>('');
const lowFrequencyExpanded = ref(false);
const historyDrawerVisible = ref(false);
const uploadFiles = ref<UploadFileInfo[]>([]);
const nodeFieldValues = ref<Record<string, any>>({});
const formRef = ref<any>(null);

const actionForm = ref<{ description: string; blockReason: string; rollbackTargetStepId: number | null }>({
  description: '',
  blockReason: '',
  rollbackTargetStepId: null,
});

const selectedStep = computed(() => workflowSteps.value.find((step) => step.stepId === selectedStepId.value) || null);

const activeOrder = computed(() => {
  return orders.value.find((item) => item.orderId === activeOrderId.value) || detail.value?.order || null;
});

const allowedActions = computed<WorkbenchAction[]>(() => {
  const raw = selectedStep.value?.allowedActions;
  if (!raw) return ['save', 'advance', 'rollback', 'block', 'unblock'];
  try {
    const parsed = JSON.parse(raw);
    return Array.isArray(parsed) ? parsed : ['save', 'advance', 'rollback', 'block', 'unblock'];
  } catch {
    return ['save', 'advance', 'rollback', 'block', 'unblock'];
  }
});

const rollbackOptions = computed(() => {
  if (!activeOrder.value) return [];
  const steps = detail.value?.workflowSteps || workflowSteps.value;
  const currentIndex = steps.findIndex((item: any) => item.stepId === activeOrder.value.currentStepId);
  if (currentIndex <= 0) return [];
  return steps.slice(0, currentIndex).reverse().map((step: any) => ({ label: `${step.stepOrder}. ${step.stepName}`, value: step.stepId }));
});

const rollbackTargetLabel = computed(() => {
  if (!rollbackOptions.value.length) return '';
  const target = rollbackOptions.value.find((item) => item.value === actionForm.value.rollbackTargetStepId);
  return target?.label || rollbackOptions.value[0].label;
});

const rollbackOptionText = computed(() => rollbackOptions.value.map((item) => item.label).join('、'));
const currentOrderStepName = computed(() => (!activeOrder.value?.currentStepId ? '未绑定节点' : getStepName(activeOrder.value.currentStepId)));
const rollbackActionText = computed(() => (!rollbackOptions.value.length ? '退回前序节点' : rollbackTargetLabel.value ? `退回到 ${rollbackTargetLabel.value}` : '退回前序节点'));
const recentProgressList = computed(() => (detail.value?.progressList || []).slice(0, 2));

const pageStartIndex = computed(() => (orderPage.value - 1) * orderPageSize);
const pageEndIndex = computed(() => Math.min(pageStartIndex.value + orderPageSize, orders.value.length));
const pagedOrders = computed(() => orders.value.slice(pageStartIndex.value, pageEndIndex.value));

const currentStepFields = computed(() => {
  const raw = selectedStep.value?.nodeFormFields;
  if (!raw) return [];
  try {
    const keys = JSON.parse(raw);
    if (!Array.isArray(keys)) return [];
    return keys.map((key) => categoryFields.value.find((field) => field.fieldKey === key)).filter(Boolean) as CustomField[];
  } catch {
    return [];
  }
});
onMounted(async () => {
  await loadCategories();
  const queryCategoryId = Number(route.query.categoryId);
  if (queryCategoryId) selectedCategoryId.value = queryCategoryId;
  else if (categoryOptions.value.length) selectedCategoryId.value = categoryOptions.value[0].value;
  if (selectedCategoryId.value) {
    await loadCategoryFields();
    await loadWorkbench();
  }
});

watch(
  () => [selectedCategoryId.value, selectedStepId.value],
  () => {
    orderPage.value = 1;
  }
);

watch(
  () => orders.value.length,
  (len) => {
    const maxPage = Math.max(1, Math.ceil(len / orderPageSize));
    if (orderPage.value > maxPage) orderPage.value = maxPage;
  }
);

async function loadCategories() {
  const list = await getCategoryList();
  categoryOptions.value = list.map((item: any) => ({ label: item.name, value: item.categoryId }));
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
    const res = await getWorkbenchData(selectedCategoryId.value, selectedStepId.value ? { stepId: selectedStepId.value } : undefined);
    workflowSteps.value = res?.workflowSteps || [];
    selectedStepId.value = res?.selectedStepId || workflowSteps.value[0]?.stepId || null;
    orders.value = res?.orders || [];
    orderPage.value = 1;

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
  actionForm.value = { description: '', blockReason: '', rollbackTargetStepId: null };
  lowFrequencyExpanded.value = false;
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
  if (value === null || value === undefined || value === '') return '-';
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
  if (field.placeholder) tips.push(field.placeholder);
  if (field.unit) tips.push(`单位：${field.unit}`);
  return tips.join(' · ');
}

function getFieldRule(field: CustomField) {
  if (field.isRequired !== 1) return undefined;
  return { required: true, message: `请填写${field.label}`, trigger: ['blur', 'change'] };
}

function validateRequiredFields(): boolean {
  const requiredFields = currentStepFields.value.filter((f) => f.isRequired === 1);
  for (const field of requiredFields) {
    const val = nodeFieldValues.value[field.fieldKey];
    if (val === null || val === undefined || val === '') {
      message.warning(`请填写必填字段：${field.label}`);
      return false;
    }
  }
  if (selectedStep.value?.needImageUpload === 1 && !hasFinishedUploadedImages()) {
    if (hasPendingUploadImages()) {
      message.warning('图片还在上传中，请稍候再推进');
      return false;
    }
    message.warning('当前节点要求上传图片');
    return false;
  }
  return true;
}

function syncNodeFieldValues() {
  const baseValues = parseObjectValue(activeOrder.value?.customDataSnapshot);
  const latestProgressValues = getLatestProgressFormData();
  const merged = { ...baseValues, ...latestProgressValues };
  nodeFieldValues.value = currentStepFields.value.reduce((result, field) => {
    result[field.fieldKey] = normalizeNodeFieldValue(field, merged[field.fieldKey]);
    return result;
  }, {} as Record<string, any>);
}

function normalizeNodeFieldValue(field: CustomField, value: any) {
  if (value === null || value === undefined || value === '') return null;
  if (field.fieldType === 'number') {
    const numericValue = Number(value);
    return Number.isFinite(numericValue) ? numericValue : null;
  }
  return value;
}

function getLatestProgressFormData() {
  const list = detail.value?.progressList || [];
  for (let index = list.length - 1; index >= 0; index -= 1) {
    const values = parseObjectValue(list[index]?.formData);
    if (Object.keys(values).length) return values;
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
  return parsed.map((item) => ({ label: item, value: item }));
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
  if (value && typeof value === 'object') return appendFieldUnit(field, JSON.stringify(value));
  return appendFieldUnit(field, value);
}

function appendFieldUnit(field: CustomField | undefined, value: any) {
  if (value === null || value === undefined || value === '') return '-';
  return field?.unit ? `${value} ${field.unit}` : String(value);
}

function parseImageUrls(value?: string | null) {
  if (!value) return [];
  try {
    const parsed = JSON.parse(value);
    if (Array.isArray(parsed)) return parsed.filter(Boolean);
    if (typeof parsed === 'string' && parsed) return [parsed];
  } catch {
    if (value) return [value];
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
  if (/^https?:\/\//i.test(url)) return url;
  return fileUrl ? `${fileUrl}${url}` : url;
}

function getUploadedImageUrls() {
  return uploadFiles.value.map((file) => file.url).filter((url): url is string => typeof url === 'string' && !!url);
}

function hasFinishedUploadedImages() {
  return uploadFiles.value.some((file) => file.status === 'finished' && typeof file.url === 'string' && !!file.url);
}

function hasPendingUploadImages() {
  return uploadFiles.value.some((file) => file.status === 'pending' || file.status === 'uploading');
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
  if (action === 'rollback' && !rollbackOptions.value.length) {
    message.warning('当前节点没有可退回的前序节点');
    return;
  }
  if ((action === 'save' || action === 'advance') && !validateRequiredFields()) return;
  if (action !== 'save') {
    const confirmed = await confirmAction(action);
    if (!confirmed) return;
  }

  const imageUrls = getUploadedImageUrls();
  const formData = currentStepFields.value.length > 0 ? JSON.stringify(nodeFieldValues.value || {}) : null;
  submittingAction.value = action;
  try {
    await submitWorkbenchAction(activeOrder.value.orderId, {
      action,
      expectedCurrentStepId: activeOrder.value.currentStepId || null,
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
    advance: { title: '确认推进', content: '确认推进到下一节点？推进后客户将看到最新进度。', type: 'info' },
    rollback: { title: '确认退回', content: `确认退回到「${rollbackTargetLabel.value || '前序节点'}」？退回操作会通知客户。`, type: 'warning' },
    block: { title: '确认阻塞', content: `确认标记订单为阻塞？原因：${actionForm.value.blockReason.trim()}`, type: 'error' },
    unblock: { title: '确认解除阻塞', content: '确认解除阻塞？订单将恢复正常流转。', type: 'success' },
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
.workbench-page {
  display: flex;
  flex-direction: column;
  gap: 18px;
}

.panel-card {
  border-radius: 24px;
  box-shadow: 0 18px 48px rgba(29, 45, 96, 0.08);
}

.hero-stage {
  padding: 6px 4px 0;
  background: radial-gradient(circle at top right, rgba(79, 70, 229, 0.08), transparent 34%);
}

.hero-head {
  display: flex;
  justify-content: space-between;
  gap: 20px;
  align-items: flex-start;
}

.hero-kicker {
  color: #5b6b8c;
  font-size: 13px;
  font-weight: 600;
  letter-spacing: 0.04em;
}

.hero-title {
  margin: 8px 0 0;
  color: #1d2d60;
  font-size: 34px;
  line-height: 1.15;
  font-weight: 800;
}

.hero-meta {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  margin-top: 10px;
  color: #6b7280;
  font-size: 15px;
}

.hero-order {
  padding: 2px 10px;
  border-radius: 10px;
  background: #eef2ff;
  color: #3344a9;
  font-weight: 700;
}
.hero-actions {
  display: flex;
  flex-direction: column;
  gap: 12px;
  align-items: flex-end;
}

.hero-filter {
  display: flex;
  align-items: center;
  gap: 10px;
}

.hero-filter__label,
.summary-label,
.panel-card__caption,
.order-card__time,
.order-card__meta,
.order-card__reason,
.execution-desc,
.timeline-desc,
.mini-timeline__time,
.mini-timeline__desc {
  color: #7c879d;
}

.hero-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
  justify-content: flex-end;
}

.process-track {
  display: flex;
  gap: 16px;
  margin-top: 26px;
  padding-top: 8px;
  overflow-x: auto;
}

.hero-overview {
  display: flex;
  flex-wrap: wrap;
  gap: 12px 18px;
  margin-top: 18px;
  padding-top: 18px;
  border-top: 1px solid rgba(221, 227, 241, 0.9);
}

.hero-overview__item {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  min-height: 36px;
  padding: 8px 12px;
  border-radius: 999px;
  background: rgba(255, 255, 255, 0.78);
  border: 1px solid #e8ecf5;
}

.hero-overview__label {
  color: #7c879d;
  font-size: 12px;
  font-weight: 700;
}

.hero-overview__value {
  color: #1f2c4a;
  font-size: 14px;
  font-weight: 700;
}

.hero-overview__value--money {
  color: #253893;
}

.track-step {
  position: relative;
  min-width: 126px;
  padding: 0;
  border: none;
  background: transparent;
  text-align: center;
  cursor: pointer;
}

.track-step::after {
  content: '';
  position: absolute;
  top: 24px;
  left: calc(50% + 28px);
  width: calc(100% - 56px);
  height: 2px;
  background: #dde3f1;
}

.track-step:last-child::after {
  display: none;
}

.track-step__dot {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 48px;
  height: 48px;
  border-radius: 999px;
  background: #e9edf5;
  color: #7b8192;
  font-weight: 700;
  transition: all 0.25s ease;
}

.track-step__name {
  display: block;
  margin-top: 12px;
  color: #7b8192;
  font-size: 14px;
  font-weight: 600;
}

.track-step.active .track-step__dot,
.track-step.current .track-step__dot {
  background: #2338a6;
  color: #fff;
  box-shadow: 0 10px 24px rgba(35, 56, 166, 0.28);
}

.track-step.active .track-step__name,
.track-step.current .track-step__name {
  color: #2338a6;
}

.panel-card__header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 16px;
}

.panel-card__header--tight {
  width: 100%;
}

.panel-card__title {
  color: #26324f;
  font-size: 20px;
  font-weight: 800;
}

.panel-card__caption {
  margin-top: 4px;
  font-size: 13px;
}

.order-switch-section {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.order-switch-section__head {
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.order-switch-section__title {
  color: #26324f;
  font-size: 18px;
  font-weight: 800;
}

.order-switch-section__caption {
  margin-top: 4px;
  color: #7c879d;
  font-size: 13px;
}

.order-switcher-shell {
  padding: 18px;
  border: 1px solid #e8ecf5;
  border-radius: 24px;
  background: linear-gradient(180deg, #ffffff 0%, #fbfcff 100%);
  box-shadow: 0 12px 30px rgba(29, 45, 96, 0.06);
}

.order-switch-card,
.side-card {
  background: linear-gradient(180deg, #ffffff 0%, #fbfcff 100%);
}

.order-switcher {
  display: flex;
  flex-wrap: wrap;
  gap: 14px;
}

.order-switcher-pagination {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
  margin-top: 16px;
  padding-top: 14px;
  border-top: 1px solid #eef1f7;
}

.order-switcher-pagination__text {
  flex-shrink: 0;
  color: #7c879d;
  font-size: 12px;
  font-weight: 600;
}

.compact-order {
  width: 264px;
  min-height: 88px;
  padding: 14px 16px;
  border: 1px solid #e8ecf5;
  border-radius: 18px;
  background: linear-gradient(180deg, #ffffff 0%, #fbfcff 100%);
  text-align: left;
  cursor: pointer;
  transition: all 0.22s ease;
}

.compact-order:hover,
.compact-order.active {
  border-color: #7c8de7;
  background: linear-gradient(180deg, #ffffff 0%, #f5f7ff 100%);
  box-shadow: 0 12px 28px rgba(64, 84, 197, 0.14);
}

.compact-order.blocked {
  border-color: #f1b2bf;
  background: #fff7f8;
}

.compact-order__top,
.compact-order__meta {
  display: flex;
  justify-content: space-between;
  gap: 10px;
  align-items: flex-start;
}

.compact-order__sn,
.execution-title,
.mini-timeline__title {
  color: #1f2c4a;
  font-weight: 800;
}

.compact-order__sn {
  color: #6c7895;
  font-size: 13px;
}

.compact-order__title {
  margin-top: 10px;
  color: #1f2c4a;
  font-size: 16px;
  font-weight: 800;
  line-height: 1.3;
}

.compact-order__meta {
  margin-top: 8px;
  font-size: 12px;
  color: #7c879d;
}

.compact-order__meta span:last-child {
  text-align: right;
}

.workspace-grid {
  display: grid;
  grid-template-columns: minmax(0, 1.7fr) 320px;
  gap: 18px;
  align-items: start;
}

.execution-panel {
  overflow: hidden;
}

.execution-content {
  display: flex;
  flex-direction: column;
  gap: 18px;
}

.execution-topline {
  height: 5px;
  border-radius: 999px;
  background: linear-gradient(90deg, #2338a6 0%, #5568d8 100%);
}

.execution-header {
  display: flex;
  justify-content: space-between;
  gap: 16px;
  align-items: flex-start;
}

.step-badge {
  display: inline-flex;
  align-items: center;
  padding: 6px 12px;
  border-radius: 999px;
  background: #dff6ea;
  color: #257552;
  font-size: 12px;
  font-weight: 700;
}

.execution-title {
  margin-top: 14px;
  font-size: 34px;
  line-height: 1.15;
}
.execution-desc {
  margin-top: 8px;
  line-height: 1.8;
}

.section-title {
  margin: 4px 0 10px;
  color: #2a3552;
  font-size: 16px;
  font-weight: 700;
}

.field-card-grid {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 14px;
}

.field-card {
  padding: 16px;
  border: 1px solid #eef1f7;
  border-radius: 18px;
  background: #f8faff;
}

.field-card__label {
  margin-bottom: 10px;
  color: #5f6b84;
  font-size: 12px;
  font-weight: 700;
  letter-spacing: 0.03em;
}

.field-helper {
  margin-top: 8px;
  color: #99a3b8;
  font-size: 12px;
  line-height: 1.5;
}

.panel-alert {
  border-radius: 16px;
}

.compact-actions {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 14px;
}

.low-frequency-panel {
  margin-top: 18px;
  padding: 18px;
  border: 1px dashed #d9dfef;
  border-radius: 18px;
  background: #fbfcff;
}

.secondary-actions {
  display: flex;
  flex-wrap: wrap;
  gap: 12px;
  padding-top: 4px;
}

.action-bar {
  display: flex;
  flex-wrap: wrap;
  gap: 12px;
  align-items: center;
  padding: 18px 0 0;
}

.action-bar__primary {
  margin-left: auto;
  min-width: 164px;
}

.side-stack {
  display: flex;
  flex-direction: column;
  gap: 18px;
  position: sticky;
  top: 16px;
}

.summary-panel {
  display: flex;
  flex-direction: column;
  gap: 14px;
}

.summary-row {
  display: flex;
  justify-content: space-between;
  gap: 16px;
  padding-bottom: 12px;
  border-bottom: 1px solid #eef1f7;
}

.summary-row:last-of-type {
  padding-bottom: 0;
}

.summary-value {
  color: #26324f;
  font-size: 14px;
  font-weight: 700;
  text-align: right;
}

.summary-value--highlight {
  color: #b88b1f;
}

.summary-finance {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 12px;
  padding: 14px;
  border-radius: 16px;
  background: #f7f9ff;
}

.summary-finance__label {
  color: #7c879d;
  font-size: 12px;
  font-weight: 700;
}

.summary-finance__value {
  margin-top: 6px;
  color: #253893;
  font-size: 20px;
  font-weight: 800;
}

.mini-timeline {
  display: flex;
  flex-direction: column;
  gap: 18px;
}

.mini-timeline__item {
  display: flex;
  gap: 12px;
}

.mini-timeline__dot {
  flex: 0 0 10px;
  width: 10px;
  height: 10px;
  margin-top: 6px;
  border-radius: 999px;
  background: #2940aa;
  box-shadow: 0 0 0 5px rgba(41, 64, 170, 0.08);
}

.mini-timeline__content {
  min-width: 0;
}

.mini-timeline__time,
.timeline-form__item {
  font-size: 12px;
}

.mini-timeline__title {
  margin-top: 2px;
  font-size: 15px;
}

.mini-timeline__desc {
  margin-top: 4px;
  line-height: 1.6;
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
  line-height: 1.8;
}

.timeline-form__label {
  color: #6b7280;
}

@media (max-width: 1200px) {
  .hero-head,
  .execution-header {
    flex-direction: column;
  }

  .hero-actions {
    align-items: flex-start;
  }

  .workspace-grid {
    grid-template-columns: 1fr;
  }

  .side-stack {
    position: static;
  }
}

@media (max-width: 768px) {
  .hero-title,
  .execution-title {
    font-size: 28px;
  }

  .hero-stage {
    padding-inline: 0;
  }

  .compact-actions,
  .field-card-grid {
    grid-template-columns: 1fr;
  }

  .compact-order {
    width: 100%;
  }

  .summary-finance {
    grid-template-columns: 1fr;
  }

  .action-bar__primary {
    margin-left: 0;
    width: 100%;
  }
}
</style>
