<template>
  <n-card title="品类管理" :bordered="false">
    <template #header-extra>
      <n-button type="primary" @click="handleAdd">
        <template #icon><n-icon><PlusOutlined /></n-icon></template>
        新增品类
      </n-button>
    </template>

    <n-data-table
      :columns="columns"
      :data="tableData"
      :loading="loading"
      :row-key="(row) => row.categoryId"
      striped
    />

    <!-- 新增/编辑弹窗 -->
    <n-modal
      v-model:show="showModal"
      :title="isEdit ? '编辑品类' : '新增品类'"
      preset="dialog"
      positive-text="确定"
      negative-text="取消"
      @positive-click="handleSubmit"
      @negative-click="showModal = false"
      style="width: 500px"
    >
      <n-form
        ref="formRef"
        :model="formData"
        :rules="rules"
        label-placement="left"
        label-width="80"
      >
        <n-form-item label="品类名称" path="name">
          <n-input v-model:value="formData.name" placeholder="请输入品类名称" />
        </n-form-item>
        <n-form-item label="图标URL" path="iconUrl">
          <n-input v-model:value="formData.iconUrl" placeholder="图标地址（可选）" />
        </n-form-item>
        <n-form-item label="排序" path="sortOrder">
          <n-input-number v-model:value="formData.sortOrder" :min="0" style="width: 100%" />
        </n-form-item>
        <n-form-item label="需要BOM">
          <n-switch v-model:value="formData.hasBom" :checked-value="1" :unchecked-value="0" />
        </n-form-item>
        <n-form-item label="实体产品">
          <n-switch v-model:value="formData.isPhysical" :checked-value="1" :unchecked-value="0" />
        </n-form-item>
        <n-form-item label="是否启用">
          <n-switch v-model:value="formData.isActive" :checked-value="1" :unchecked-value="0" />
        </n-form-item>
      </n-form>
    </n-modal>
  </n-card>
</template>

<script lang="ts" setup>
  import { ref, h, onMounted } from 'vue';
  import { useMessage, useDialog, NTag, NButton, NSpace } from 'naive-ui';
  import { PlusOutlined } from '@vicons/antd';
  import {
    getCategoryList,
    addCategory,
    updateCategory,
    deleteCategory,
  } from '@/api/config/category';

  const message = useMessage();
  const dialog = useDialog();
  const loading = ref(false);
  const showModal = ref(false);
  const isEdit = ref(false);
  const formRef = ref();
  const tableData = ref<any[]>([]);

  const formData = ref({
    categoryId: null as number | null,
    name: '',
    iconUrl: '',
    sortOrder: 0,
    hasBom: 0,
    isPhysical: 1,
    isActive: 1,
  });

  const rules = {
    name: { required: true, message: '请输入品类名称', trigger: 'blur' },
  };

  const columns = [
    { title: 'ID', key: 'categoryId', width: 60 },
    { title: '品类名称', key: 'name', width: 150 },
    {
      title: '状态',
      key: 'isActive',
      width: 80,
      render(row: any) {
        return h(NTag, { type: row.isActive === 1 ? 'success' : 'default', size: 'small' }, {
          default: () => (row.isActive === 1 ? '启用' : '停用'),
        });
      },
    },
    {
      title: '需要BOM',
      key: 'hasBom',
      width: 90,
      render(row: any) {
        return h(NTag, { type: row.hasBom === 1 ? 'info' : 'default', size: 'small' }, {
          default: () => (row.hasBom === 1 ? '是' : '否'),
        });
      },
    },
    {
      title: '实体产品',
      key: 'isPhysical',
      width: 90,
      render(row: any) {
        return h(NTag, { type: row.isPhysical === 1 ? 'info' : 'default', size: 'small' }, {
          default: () => (row.isPhysical === 1 ? '是' : '否'),
        });
      },
    },
    { title: '排序', key: 'sortOrder', width: 60 },
    {
      title: '操作',
      key: 'actions',
      width: 200,
      render(row: any) {
        return h(NSpace, null, {
          default: () => [
            h(NButton, { text: true, type: 'primary', onClick: () => handleEdit(row) }, { default: () => '编辑' }),
            h(NButton, { text: true, type: 'info', onClick: () => handleFields(row) }, { default: () => '字段配置' }),
            h(NButton, { text: true, type: 'info', onClick: () => handleWorkflow(row) }, { default: () => '工作流' }),
            h(
              NButton,
              { text: true, type: 'error', onClick: () => handleDelete(row) },
              { default: () => '删除' }
            ),
          ],
        });
      },
    },
  ];

  // 加载列表
  const loadData = async () => {
    loading.value = true;
    try {
      tableData.value = await getCategoryList();
    } finally {
      loading.value = false;
    }
  };

  // 新增
  const handleAdd = () => {
    isEdit.value = false;
    formData.value = { categoryId: null, name: '', iconUrl: '', sortOrder: 0, hasBom: 0, isPhysical: 1, isActive: 1 };
    showModal.value = true;
  };

  // 编辑
  const handleEdit = (row: any) => {
    isEdit.value = true;
    formData.value = { ...row };
    showModal.value = true;
  };

  // 提交
  const handleSubmit = async () => {
    try {
      if (isEdit.value && formData.value.categoryId) {
        await updateCategory(formData.value.categoryId, formData.value);
        message.success('修改成功');
      } else {
        await addCategory(formData.value);
        message.success('新增成功');
      }
      showModal.value = false;
      await loadData();
    } catch (e) {
      return false; // 阻止弹窗关闭
    }
  };

  // 删除
  const handleDelete = (row: any) => {
    dialog.warning({
      title: '确认删除',
      content: `确定要删除品类「${row.name}」吗？`,
      positiveText: '删除',
      negativeText: '取消',
      onPositiveClick: async () => {
        await deleteCategory(row.categoryId);
        message.success('删除成功');
        await loadData();
      },
    });
  };

  // 字段配置（跳转）
  const handleFields = (row: any) => {
    message.info(`字段配置 - ${row.name}（功能开发中）`);
  };

  // 工作流（跳转）
  const handleWorkflow = (row: any) => {
    message.info(`工作流管理 - ${row.name}（功能开发中）`);
  };

  onMounted(() => {
    loadData();
  });
</script>
