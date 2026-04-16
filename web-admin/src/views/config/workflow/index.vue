<template>
  <n-card title="工作流配置" :bordered="false">
    <template #header-extra>
      <n-space align="center">
        <span>所属品类：</span>
        <n-select
          v-model:value="selectedCategoryId"
          :options="categoryOptions"
          placeholder="请选择品类"
          style="width: 220px"
          @update:value="handleCategoryChange"
        />
        <n-button type="primary" :disabled="!selectedCategoryId" @click="handleAddStep">
          新增节点
        </n-button>
        <n-button :disabled="!selectedCategoryId" @click="goWorkbench">
          打开工作台
        </n-button>
        <n-button type="success" :disabled="!selectedCategoryId" :loading="saving" @click="handleSaveAll">
          保存流程
        </n-button>
      </n-space>
    </template>

    <n-spin :show="loading">
      <div v-if="!selectedCategoryId" class="empty-hint">请先选择一个品类再配置工作流。</div>
      <div v-else>
        <n-form inline label-placement="left" style="margin-bottom: 20px">
          <n-form-item label="工作流名称">
            <n-input
              v-model:value="workflowName"
              placeholder="例如：服装定制流程"
              style="width: 320px"
            />
          </n-form-item>
        </n-form>

        <div v-if="stepsList.length === 0" class="empty-hint">当前品类还没有工作流节点。</div>
        <div v-else class="step-table">
          <div class="step-header">
            <div class="col-drag"></div>
            <div class="col-order">顺序</div>
            <div class="col-name">节点名称</div>
            <div class="col-fields">节点字段</div>
            <div class="col-meta">客户可见</div>
            <div class="col-meta">需传图</div>
            <div class="col-meta">预计天数</div>
            <div class="col-action">操作</div>
          </div>
          <draggable v-model="stepsList" item-key="stepName" handle=".drag-handle" animation="200">
            <template #item="{ element, index }">
              <div class="step-item">
                <div class="col-drag">
                  <n-icon class="drag-handle" size="18" color="#999"><MenuOutlined /></n-icon>
                </div>
                <div class="col-order">
                  <n-tag size="small" round>{{ index + 1 }}</n-tag>
                </div>
                <div class="col-name">
                  <div class="step-name">{{ element.stepName }}</div>
                  <div class="step-desc">{{ element.nodeDescription || '未配置节点说明' }}</div>
                </div>
                <div class="col-fields">
                  {{ getNodeFieldSummary(element.nodeFormFields) }}
                </div>
                <div class="col-meta">
                  <n-tag size="small" :type="element.visibleToClient === 0 ? 'default' : 'success'">
                    {{ element.visibleToClient === 0 ? '否' : '是' }}
                  </n-tag>
                </div>
                <div class="col-meta">
                  <n-tag size="small" :type="element.needImageUpload === 1 ? 'warning' : 'default'">
                    {{ element.needImageUpload === 1 ? '是' : '否' }}
                  </n-tag>
                </div>
                <div class="col-meta">{{ element.expectedDurationDays || '-' }}</div>
                <div class="col-action">
                  <n-button text type="primary" size="small" @click="handleEditStep(element, index)">编辑</n-button>
                  <n-button text type="error" size="small" @click="handleDeleteStep(index)">删除</n-button>
                </div>
              </div>
            </template>
          </draggable>
        </div>
      </div>
    </n-spin>

    <n-modal
      v-model:show="showModal"
      preset="dialog"
      :title="isEdit ? '编辑节点' : '新增节点'"
      positive-text="确定"
      negative-text="取消"
      style="width: 560px"
      @positive-click="handleSubmitStep"
    >
      <n-form ref="formRef" :model="formData" :rules="rules" label-placement="left" label-width="100">
        <n-form-item label="节点名称" path="stepName">
          <n-input v-model:value="formData.stepName" placeholder="例如：草图确认" />
        </n-form-item>
        <n-form-item label="节点说明">
          <n-input
            v-model:value="formData.nodeDescription"
            type="textarea"
            :autosize="{ minRows: 2, maxRows: 4 }"
            placeholder="用于工作台提示和客户端说明"
          />
        </n-form-item>
        <n-form-item label="允许动作">
          <n-checkbox-group v-model:value="selectedActions">
            <n-space>
              <n-checkbox value="save">保存记录</n-checkbox>
              <n-checkbox value="advance">推进下一步</n-checkbox>
              <n-checkbox value="rollback">退回上一步</n-checkbox>
              <n-checkbox value="block">标记阻塞</n-checkbox>
              <n-checkbox value="unblock">解除阻塞</n-checkbox>
            </n-space>
          </n-checkbox-group>
        </n-form-item>
        <n-form-item label="节点字段">
          <n-select
            v-model:value="selectedNodeFields"
            :options="fieldOptions"
            multiple
            clearable
            placeholder="选择该节点需要填写的动态字段"
          />
        </n-form-item>
        <n-form-item label="客户可见">
          <n-switch v-model:value="visibleToClientBool" />
        </n-form-item>
        <n-form-item label="要求上传图片">
          <n-switch v-model:value="needImageUploadBool" />
        </n-form-item>
        <n-form-item label="预计耗时(天)">
          <n-input-number v-model:value="formData.expectedDurationDays" :min="0" style="width: 160px" />
        </n-form-item>
      </n-form>
    </n-modal>
  </n-card>
</template>

<script lang="ts" setup>
import { computed, onMounted, ref } from 'vue';
import { useDialog, useMessage } from 'naive-ui';
import { useRoute, useRouter } from 'vue-router';
import draggable from 'vuedraggable';
import { MenuOutlined } from '@vicons/antd';
import { getCategoryList } from '@/api/config/category';
import { getWorkflow, saveWorkflow, type WorkflowStep } from '@/api/config/workflow';
import { getFieldList, type CustomField } from '@/api/config/field';

const message = useMessage();
const dialog = useDialog();
const route = useRoute();
const router = useRouter();

const loading = ref(false);
const saving = ref(false);
const categoryOptions = ref<{ label: string; value: number }[]>([]);
const fieldOptions = ref<{ label: string; value: string }[]>([]);
const categoryFields = ref<CustomField[]>([]);
const selectedCategoryId = ref<number | null>(null);
const workflowName = ref('');
const stepsList = ref<WorkflowStep[]>([]);

const showModal = ref(false);
const isEdit = ref(false);
const editIndex = ref(-1);
const formRef = ref();
const formData = ref<WorkflowStep>({
  stepName: '',
  nodeDescription: '',
  allowedActions: '["save","advance","rollback","block","unblock"]',
  needImageUpload: 0,
  visibleToClient: 1,
  expectedDurationDays: null,
  nodeFormFields: '[]',
});

const rules = {
  stepName: { required: true, message: '请输入节点名称', trigger: 'blur' },
};

const selectedActions = computed({
  get: () => {
    try {
      const raw = formData.value.allowedActions;
      return raw ? JSON.parse(raw) : [];
    } catch {
      return [];
    }
  },
  set: (value: string[]) => {
    formData.value.allowedActions = JSON.stringify(value);
  },
});

const visibleToClientBool = computed({
  get: () => formData.value.visibleToClient !== 0,
  set: (value: boolean) => {
    formData.value.visibleToClient = value ? 1 : 0;
  },
});

const needImageUploadBool = computed({
  get: () => formData.value.needImageUpload === 1,
  set: (value: boolean) => {
    formData.value.needImageUpload = value ? 1 : 0;
  },
});

const selectedNodeFields = computed({
  get: () => {
    try {
      return formData.value.nodeFormFields ? JSON.parse(formData.value.nodeFormFields) : [];
    } catch {
      return [];
    }
  },
  set: (value: string[]) => {
    formData.value.nodeFormFields = JSON.stringify(value);
  },
});

onMounted(async () => {
  const categories = await getCategoryList();
  categoryOptions.value = categories.map((item: any) => ({
    label: item.name,
    value: item.categoryId,
  }));

  const queryCategoryId = Number(route.query.categoryId);
  if (queryCategoryId) {
    selectedCategoryId.value = queryCategoryId;
    await loadCategoryFields();
    await loadWorkflow();
  }
});

async function loadWorkflow() {
  if (!selectedCategoryId.value) return;
  loading.value = true;
  try {
    const res = await getWorkflow(selectedCategoryId.value);
    workflowName.value = res?.workflow?.workflowName || '';
    stepsList.value = (res?.steps || []).map((step: WorkflowStep) => ({
      ...step,
      allowedActions: step.allowedActions || '["save","advance","rollback","block","unblock"]',
      needImageUpload: step.needImageUpload ?? 0,
      visibleToClient: step.visibleToClient ?? 1,
      nodeFormFields: step.nodeFormFields || '[]',
    }));
  } finally {
    loading.value = false;
  }
}

async function loadCategoryFields() {
  if (!selectedCategoryId.value) return;
  const fields = await getFieldList(selectedCategoryId.value);
  categoryFields.value = fields || [];
  fieldOptions.value = categoryFields.value.map((field) => ({
    label: `${field.label} (${field.fieldKey})`,
    value: field.fieldKey,
  }));
}

async function handleCategoryChange() {
  await loadCategoryFields();
  await loadWorkflow();
}

function resetForm() {
  formData.value = {
    stepName: '',
    nodeDescription: '',
    allowedActions: '["save","advance","rollback","block","unblock"]',
    needImageUpload: 0,
    visibleToClient: 1,
    expectedDurationDays: null,
    nodeFormFields: '[]',
  };
}

function handleAddStep() {
  isEdit.value = false;
  editIndex.value = -1;
  resetForm();
  showModal.value = true;
}

function handleEditStep(row: WorkflowStep, index: number) {
  isEdit.value = true;
  editIndex.value = index;
  formData.value = {
    ...row,
    allowedActions: row.allowedActions || '["save","advance","rollback","block","unblock"]',
    needImageUpload: row.needImageUpload ?? 0,
    visibleToClient: row.visibleToClient ?? 1,
    nodeFormFields: row.nodeFormFields || '[]',
  };
  showModal.value = true;
}

function handleSubmitStep(e: MouseEvent) {
  e.preventDefault();
  formRef.value?.validate((errors: any) => {
    if (errors) return;
    const payload = { ...formData.value };
    if (isEdit.value) {
      stepsList.value.splice(editIndex.value, 1, payload);
    } else {
      stepsList.value.push(payload);
    }
    showModal.value = false;
  });
  return false;
}

function handleDeleteStep(index: number) {
  dialog.warning({
    title: '确认删除',
    content: '删除后会影响该品类的流程渲染，确定继续吗？',
    positiveText: '删除',
    negativeText: '取消',
    onPositiveClick: () => {
      stepsList.value.splice(index, 1);
    },
  });
}

async function handleSaveAll() {
  if (!selectedCategoryId.value) return;
  if (!workflowName.value.trim()) {
    message.error('请输入工作流名称');
    return;
  }
  if (stepsList.value.length === 0) {
    message.warning('请至少保留一个节点');
    return;
  }

  saving.value = true;
  try {
    await saveWorkflow(selectedCategoryId.value, {
      workflowName: workflowName.value,
      steps: stepsList.value,
    });
    message.success('工作流已保存');
    await loadWorkflow();
  } finally {
    saving.value = false;
  }
}

function goWorkbench() {
  if (!selectedCategoryId.value) return;
  router.push(`/workbench/nodes?categoryId=${selectedCategoryId.value}`);
}

function getNodeFieldSummary(nodeFormFields?: string) {
  if (!nodeFormFields) return '未绑定字段';
  try {
    const keys = JSON.parse(nodeFormFields);
    if (!Array.isArray(keys) || !keys.length) {
      return '未绑定字段';
    }
    const labels = keys
      .map((key) => categoryFields.value.find((field) => field.fieldKey === key)?.label || key)
      .slice(0, 3);
    return keys.length > 3 ? `${labels.join('、')} 等 ${keys.length} 个字段` : labels.join('、');
  } catch {
    return '未绑定字段';
  }
}
</script>

<style scoped>
.empty-hint {
  padding: 56px 0;
  text-align: center;
  color: var(--text-placeholder);
  background: var(--page-bg);
  border-radius: var(--panel-radius);
}

.step-table {
  border: 1px solid var(--border-light);
  border-radius: var(--panel-radius);
  overflow: hidden;
}

.step-header,
.step-item {
  display: flex;
  align-items: center;
  padding: 14px 16px;
}

.step-header {
  background: var(--page-bg);
  font-weight: 600;
  font-size: 12px;
  color: var(--text-secondary);
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.step-item {
  border-top: 1px solid var(--border-light);
  background: var(--panel-bg);
}

.step-item:hover {
  background: var(--row-hover-bg);
}

.col-drag {
  width: 36px;
  text-align: center;
}

.col-order {
  width: 70px;
}

.col-name {
  flex: 1;
  min-width: 0;
}

.col-fields {
  width: 220px;
  color: var(--text-secondary);
  font-size: 12px;
}

.col-meta {
  width: 90px;
  text-align: center;
  color: var(--text-secondary);
  font-size: 13px;
}

.col-action {
  width: 120px;
  display: flex;
  justify-content: flex-end;
  gap: 8px;
}

.drag-handle {
  cursor: grab;
}

.step-name {
  font-weight: 600;
  color: var(--text-primary);
}

.step-desc {
  margin-top: 4px;
  color: var(--text-tertiary);
  font-size: 12px;
}
</style>
