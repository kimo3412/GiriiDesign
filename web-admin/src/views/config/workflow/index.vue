<template>
  <n-card title="工作流管理" :bordered="false">
    <template #header-extra>
      <n-space align="center">
        <span>所属品类：</span>
        <n-select
          v-model:value="selectedCategoryId"
          :options="categoryOptions"
          placeholder="请选择品类"
          style="width: 200px"
          @update:value="loadWorkflow"
        />
        <n-button type="primary" :disabled="!selectedCategoryId" @click="handleAddStep">
          新增节点
        </n-button>
        <n-button type="success" :disabled="!selectedCategoryId" @click="handleSaveAll" :loading="saving">
          保存所有修改
        </n-button>
      </n-space>
    </template>

    <n-spin :show="loading">
      <div v-if="!selectedCategoryId" class="empty-hint">
        请先在右上角选择需要配置的品类
      </div>
      <div v-else class="workflow-container">
        <n-form inline label-placement="left" style="margin-bottom: 20px;">
          <n-form-item label="工作流名称">
            <n-input v-model:value="workflowName" placeholder="请输入工作流名称（如：服装定制流程）" style="width: 300px" />
          </n-form-item>
        </n-form>

        <div v-if="stepsList.length === 0" class="empty-hint" style="padding: 30px 0;">
          暂无工作流节点，请点击「新增节点」
        </div>
        <div v-else class="drag-container">
          <div class="step-header">
            <div class="col-drag"></div>
            <div class="col-order">顺序</div>
            <div class="col-name">节点名称</div>
            <div class="col-role">预设属性</div>
            <div class="col-action">操作</div>
          </div>
          <draggable
            v-model="stepsList"
            item-key="stepName"
            handle=".drag-handle"
            animation="200"
          >
            <template #item="{ element, index }">
              <div class="step-item">
                <div class="col-drag">
                  <n-icon size="18" class="drag-handle" color="#999"><MenuOutlined /></n-icon>
                </div>
                <!-- 实时显示拖拽后的顺序 -->
                <div class="col-order">
                  <n-tag round size="small" type="info">{{ index + 1 }}</n-tag>
                </div>
                <div class="col-name">{{ element.stepName }}</div>
                <div class="col-role">
                  <n-tag v-if="index === 0" size="small" type="success">起始节点</n-tag>
                  <n-tag v-else-if="index === stepsList.length - 1" size="small" type="error">结束节点</n-tag>
                  <n-tag v-else size="small" type="default">中间节点</n-tag>
                </div>
                <div class="col-action">
                  <n-button size="small" text type="primary" @click="handleEditStep(element, index)">编辑</n-button>
                  <n-button size="small" text type="error" style="margin-left: 12px;" @click="handleDeleteStep(index)">删除</n-button>
                </div>
              </div>
            </template>
          </draggable>
          <div style="margin-top: 10px; color: #999; font-size: 12px;">
            * 提示：按住左侧图标可拖拽排序。首个节点强制为起始节点，最后一个强制为结束节点。修改后请点击右上角「保存所有修改」。
          </div>
        </div>
      </div>
    </n-spin>

    <n-modal
      v-model:show="showModal"
      :title="isEdit ? '编辑节点' : '新增节点'"
      preset="dialog"
      positive-text="确定"
      negative-text="取消"
      @positive-click="handleSubmitStep"
      style="width: 400px"
    >
      <n-form :model="formData" :rules="rules" ref="formRef" label-placement="left" label-width="80">
        <n-form-item label="节点名称" path="stepName">
          <n-input v-model:value="formData.stepName" placeholder="如：需求确认、裁剪、质检等" />
        </n-form-item>
      </n-form>
    </n-modal>
  </n-card>
</template>

<script lang="ts" setup>
  import { ref, onMounted } from 'vue';
  import { useMessage, useDialog } from 'naive-ui';
  import { MenuOutlined } from '@vicons/antd';
  import draggable from 'vuedraggable';
  import { getCategoryList } from '@/api/config/category';
  import { getWorkflow, saveWorkflow, type WorkflowStep } from '@/api/config/workflow';

  const message = useMessage();
  const dialog = useDialog();

  const loading = ref(false);
  const saving = ref(false);

  // 品类下拉
  const categoryOptions = ref<{label: string, value: number}[]>([]);
  const selectedCategoryId = ref<number | null>(null);

  // 工作流数据
  const workflowName = ref('');
  const stepsList = ref<WorkflowStep[]>([]);

  // 弹窗表单
  const showModal = ref(false);
  const isEdit = ref(false);
  const editIndex = ref(-1);
  const formRef = ref();
  const formData = ref<WorkflowStep>({ stepName: '' });

  const rules = {
    stepName: { required: true, message: '请输入节点名称', trigger: 'blur' },
  };

  onMounted(async () => {
    try {
      const res = await getCategoryList();
      categoryOptions.value = res.map((item: any) => ({
        label: item.name,
        value: item.categoryId,
      }));
    } catch (e) {
      console.error(e);
    }
  });

  const loadWorkflow = async () => {
    if (!selectedCategoryId.value) return;
    loading.value = true;
    try {
      const res = await getWorkflow(selectedCategoryId.value);
      if (res) {
        workflowName.value = res.workflow?.workflowName || '';
        stepsList.value = res.steps || [];
      } else {
        workflowName.value = '';
        stepsList.value = [];
      }
    } catch (e) {
      console.error(e);
    } finally {
      loading.value = false;
    }
  };

  const handleAddStep = () => {
    isEdit.value = false;
    formData.value = { stepName: '' };
    showModal.value = true;
  };

  const handleEditStep = (row: WorkflowStep, index: number) => {
    isEdit.value = true;
    editIndex.value = index;
    formData.value = { ...row };
    showModal.value = true;
  };

  const handleSubmitStep = (e: MouseEvent) => {
    e.preventDefault();
    formRef.value?.validate((errors: any) => {
      if (!errors) {
        if (isEdit.value) {
          stepsList.value[editIndex.value] = { ...formData.value };
        } else {
          stepsList.value.push({ ...formData.value });
        }
        showModal.value = false;
      }
    });
    return false;
  };

  const handleDeleteStep = (index: number) => {
    dialog.warning({
      title: '确认删除',
      content: '删除节点后，若有处于该节点的旧订单可能会受到影响。确认删除？',
      positiveText: '确认',
      negativeText: '取消',
      onPositiveClick: () => {
        stepsList.value.splice(index, 1);
      },
    });
  };

  const handleSaveAll = async () => {
    if (!selectedCategoryId.value) return;
    if (!workflowName.value.trim()) {
      message.error('请输入工作流名称');
      return;
    }
    if (stepsList.value.length === 0) {
      message.warning('请至少添加一个工作流节点');
      return;
    }

    saving.value = true;
    try {
      await saveWorkflow(selectedCategoryId.value, {
        workflowName: workflowName.value,
        steps: stepsList.value,
      });
      message.success('保存成功');
      await loadWorkflow();
    } catch (e) {
      console.error(e);
    } finally {
      saving.value = false;
    }
  };
</script>

<style scoped>
  .empty-hint {
    text-align: center;
    padding: 60px 0;
    color: #999;
    font-size: 14px;
    background: #f9f9f9;
    border-radius: 4px;
  }
  
  .drag-container {
    border: 1px solid #eee;
    border-radius: 4px;
  }

  .step-header {
    display: flex;
    background: #fafafa;
    padding: 12px;
    font-weight: bold;
    border-bottom: 1px solid #eee;
  }

  .step-item {
    display: flex;
    align-items: center;
    padding: 12px;
    border-bottom: 1px solid #eee;
    background: #fff;
    transition: background 0.2s;
  }
  
  .step-item:hover {
    background: #fafafa;
  }

  .col-drag { width: 40px; text-align: center; }
  .drag-handle { cursor: grab; }
  .drag-handle:active { cursor: grabbing; }

  .col-order { width: 60px; text-align: center; }
  .col-name { flex: 1; }
  .col-role { width: 100px; }
  .col-action { width: 120px; text-align: right; }
</style>
