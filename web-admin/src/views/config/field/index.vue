<template>
  <n-card title="动态字段配置" :bordered="false">
    <template #header-extra>
      <n-space align="center">
        <span>所属品类：</span>
        <n-select
          v-model:value="selectedCategoryId"
          :options="categoryOptions"
          placeholder="请选择品类"
          style="width: 200px"
          @update:value="loadFields"
        />
        <n-input
          v-model:value="keyword"
          placeholder="搜索字段名称/key"
          clearable
          style="width: 180px"
        />
        <n-button type="primary" :disabled="!selectedCategoryId" @click="handleAdd">
          新增字段
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
      <div v-else-if="displayFieldList.length === 0" class="empty-hint">
        当前品类暂无字段，请点击「新增字段」
      </div>
      <div v-else class="drag-container">
        <div class="field-header">
          <div class="col-drag"></div>
          <div class="col-label">字段名称</div>
          <div class="col-key">字段键名</div>
          <div class="col-type">控件类型</div>
          <div class="col-req">是否必填</div>
          <div class="col-action">操作</div>
        </div>
        <draggable
          v-model="displayFieldList"
          item-key="fieldKey"
          handle=".drag-handle"
          animation="200"
          :disabled="!!keyword.trim()"
        >
          <template #item="{ element, index }">
            <div class="field-item">
              <div class="col-drag">
                <n-icon size="18" class="drag-handle" color="#999"><MenuOutlined /></n-icon>
              </div>
              <div class="col-label">{{ element.label }}</div>
              <div class="col-key">{{ element.fieldKey }}</div>
              <div class="col-type">
                <n-tag size="small" type="info">{{ getTypeName(element.fieldType) }}</n-tag>
              </div>
              <div class="col-req">
                <n-tag size="small" :type="element.isRequired === 1 ? 'error' : 'default'">
                  {{ element.isRequired === 1 ? '必填' : '选填' }}
                </n-tag>
              </div>
              <div class="col-action">
                <n-button size="small" text type="primary" @click="handleEdit(element, getFieldIndex(element))">编辑</n-button>
                <n-button size="small" text type="error" style="margin-left: 12px;" @click="handleDelete(getFieldIndex(element))">删除</n-button>
              </div>
            </div>
          </template>
        </draggable>
        <div style="margin-top: 10px; color: #999; font-size: 12px;">
          * 提示：按住左侧图标可拖拽排序。排序或修改后，请点击右上角「保存所有修改」生效。
        </div>
      </div>
    </n-spin>

    <n-modal
      v-model:show="showModal"
      :title="isEdit ? '编辑字段' : '新增字段'"
      preset="dialog"
      positive-text="确定"
      negative-text="取消"
      @positive-click="handleSubmit"
      style="width: 500px"
    >
      <n-form :model="formData" :rules="rules" ref="formRef" label-placement="left" label-width="80">
        <n-form-item label="字段名称" path="label">
          <n-input v-model:value="formData.label" placeholder="如：胸围、颜色" />
        </n-form-item>
        <n-form-item label="字段键名" path="fieldKey">
          <n-input v-model:value="formData.fieldKey" placeholder="如：chest、color (英文字符)" :disabled="isEdit" />
        </n-form-item>
        <n-form-item label="控件类型" path="fieldType">
          <n-select v-model:value="formData.fieldType" :options="typeOptions" />
        </n-form-item>
        
        <!-- 仅 select 类型时显示选项配置 -->
        <n-form-item v-if="formData.fieldType === 'select'" label="选项列表">
          <n-dynamic-tags v-model:value="optionsList" />
        </n-form-item>

        <n-form-item label="占位提示" path="placeholder">
          <n-input v-model:value="formData.placeholder" placeholder="输入框内的提示文案（可选）" />
        </n-form-item>
        <n-form-item label="单位" path="unit">
          <n-input v-model:value="formData.unit" placeholder="如：cm、kg（可选）" />
        </n-form-item>
        <n-form-item label="是否必填" path="isRequired">
          <n-switch v-model:value="formData.isRequired" :checked-value="1" :unchecked-value="0" />
        </n-form-item>
      </n-form>
    </n-modal>
  </n-card>
</template>

<script lang="ts" setup>
  import { computed, ref, onMounted } from 'vue';
  import { useRoute } from 'vue-router';
  import { useMessage, useDialog } from 'naive-ui';
  import { MenuOutlined } from '@vicons/antd';
  import draggable from 'vuedraggable';
  import { getCategoryList } from '@/api/config/category';
  import { getFieldList, saveFieldList, type CustomField } from '@/api/config/field';

  const message = useMessage();
  const dialog = useDialog();
  const route = useRoute();

  const loading = ref(false);
  const saving = ref(false);

  // 品类下拉
  const categoryOptions = ref<{label: string, value: number}[]>([]);
  const selectedCategoryId = ref<number | null>(null);
  const keyword = ref('');

  // 字段列表数据
  const fieldList = ref<CustomField[]>([]);
  const displayFieldList = computed({
    get() {
      const kw = keyword.value.trim().toLowerCase();
      if (!kw) return fieldList.value;
      return fieldList.value.filter((field) =>
        [field.label, field.fieldKey, field.fieldType].some((value) =>
          String(value || '').toLowerCase().includes(kw)
        )
      );
    },
    set(value: CustomField[]) {
      if (!keyword.value.trim()) fieldList.value = value;
    },
  });

  // 表单状态
  const showModal = ref(false);
  const isEdit = ref(false);
  const editIndex = ref(-1);
  const formRef = ref();
  const optionsList = ref<string[]>([]);
  const formData = ref<CustomField>({
    categoryId: 0,
    label: '',
    fieldKey: '',
    fieldType: 'text',
    unit: '',
    placeholder: '',
    isRequired: 0,
  });

  const rules = {
    label: { required: true, message: '请输入字段名称', trigger: 'blur' },
    fieldKey: { required: true, message: '请输入字段键名', trigger: 'blur' },
    fieldType: { required: true, message: '请选择控件类型', trigger: 'change' },
  };

  const typeOptions = [
    { label: '单文本框 (text)', value: 'text' },
    { label: '数字输入 (number)', value: 'number' },
    { label: '下拉选择 (select)', value: 'select' },
    { label: '日期选择 (date)', value: 'date' },
    { label: '图片上传 (image)', value: 'image' },
  ];

  const getTypeName = (val: string) => typeOptions.find(t => t.value === val)?.label || val;
  const getFieldIndex = (field: CustomField) =>
    fieldList.value.findIndex((item) => item.fieldKey === field.fieldKey);

  // 初始化加载品类，并支持从品类管理跳转预选
  onMounted(async () => {
    try {
      const res = await getCategoryList();
      categoryOptions.value = res.map((item: any) => ({
        label: item.name,
        value: item.categoryId,
      }));
      // 如果从品类管理跳转过来，自动选中并加载
      const qCategoryId = Number(route.query.categoryId);
      if (qCategoryId) {
        selectedCategoryId.value = qCategoryId;
        loadFields();
      }
    } catch (e) {
      console.error(e);
    }
  });

  // 加载所选品类的字段
  const loadFields = async () => {
    if (!selectedCategoryId.value) return;
    loading.value = true;
    try {
      fieldList.value = await getFieldList(selectedCategoryId.value);
    } catch (e) {
      console.error(e);
    } finally {
      loading.value = false;
    }
  };

  // 新增
  const handleAdd = () => {
    isEdit.value = false;
    optionsList.value = [];
    formData.value = {
      categoryId: selectedCategoryId.value as number,
      label: '',
      fieldKey: '',
      fieldType: 'text',
      unit: '',
      placeholder: '',
      isRequired: 0,
    };
    showModal.value = true;
  };

  // 编辑
  const handleEdit = (row: CustomField, index: number) => {
    isEdit.value = true;
    editIndex.value = index;
    formData.value = { ...row };
    // 处理 options
    if (row.options && typeof row.options === 'string') {
      try {
        optionsList.value = JSON.parse(row.options);
      } catch (e) {
        optionsList.value = [];
      }
    } else {
      optionsList.value = [];
    }
    showModal.value = true;
  };

  // 弹窗提交（本地列表更新，暂不发服务端）
  const handleSubmit = async () => {
    try {
      await formRef.value?.validate();
    } catch {
      return false;
    }

    const normalizedField: CustomField = {
      ...formData.value,
      categoryId: selectedCategoryId.value as number,
      label: formData.value.label?.trim(),
      fieldKey: formData.value.fieldKey?.trim(),
      unit: formData.value.unit?.trim(),
      placeholder: formData.value.placeholder?.trim(),
      options: formData.value.fieldType === 'select' ? JSON.stringify(optionsList.value) : null,
    };

    if (isEdit.value) {
      // 检查重复 key
      const exists = fieldList.value.find((f, i) => f.fieldKey === normalizedField.fieldKey && i !== editIndex.value);
      if (exists) {
        message.error('字段键名不能重复');
        return false;
      }
      fieldList.value[editIndex.value] = normalizedField;
    } else {
      const exists = fieldList.value.find((f) => f.fieldKey === normalizedField.fieldKey);
      if (exists) {
        message.error('字段键名已存在');
        return false;
      }
      fieldList.value.push(normalizedField);
    }

    showModal.value = false;
    return false; // 阻止默认关闭，由我们自己控制
  };

  // 删除
  const handleDelete = (index: number) => {
    dialog.warning({
      title: '确认删除',
      content: '删除后不影响历史订单，但新订单此字段会被移除。确认删除？',
      positiveText: '确认',
      negativeText: '取消',
      onPositiveClick: () => {
        fieldList.value.splice(index, 1);
      },
    });
  };

  // 批量保存到服务端
  const handleSaveAll = async () => {
    if (!selectedCategoryId.value) return;
    saving.value = true;
    try {
      await saveFieldList(selectedCategoryId.value, fieldList.value);
      message.success('保存成功');
      await loadFields();
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
    color: var(--text-placeholder);
    font-size: 14px;
    background: var(--page-bg);
    border-radius: var(--panel-radius);
  }

  .drag-container {
    border: 1px solid var(--border-light);
    border-radius: var(--panel-radius);
  }

  .field-header {
    display: flex;
    background: var(--page-bg);
    padding: 12px;
    font-weight: 600;
    font-size: 12px;
    color: var(--text-secondary);
    text-transform: uppercase;
    letter-spacing: 0.5px;
    border-bottom: 1px solid var(--border-light);
  }

  .field-item {
    display: flex;
    align-items: center;
    padding: 12px;
    border-bottom: 1px solid var(--border-light);
    background: var(--panel-bg);
    transition: background 0.2s;
  }

  .field-item:hover {
    background: var(--row-hover-bg);
  }

  .col-drag { width: 40px; text-align: center; }
  .drag-handle { cursor: grab; }
  .drag-handle:active { cursor: grabbing; }

  .col-label { flex: 1; color: var(--text-primary); }
  .col-key { flex: 1; font-family: monospace; color: var(--text-secondary); font-size: 12px; }
  .col-type { width: 150px; }
  .col-req { width: 100px; }
  .col-action { width: 120px; text-align: right; }
</style>
