<template>
  <n-card title="物料管理" :bordered="false">
    <template #header-extra>
      <n-space>
        <n-select v-model:value="filterCategory" :options="categoryOptions" placeholder="分类" style="width: 120px" clearable @update:value="loadData" />
        <n-input v-model:value="keyword" placeholder="搜索名称/编码" clearable @keyup.enter="loadData" style="width: 180px" />
        <n-button type="primary" @click="handleAdd">新增物料</n-button>
      </n-space>
    </template>

    <n-data-table :columns="columns" :data="tableData" :loading="loading" :row-key="row => row.materialId" />

    <!-- 新增/编辑弹窗 -->
    <n-modal v-model:show="showModal" :title="isEdit ? '编辑物料' : '新增物料'" preset="dialog" positive-text="确定" negative-text="取消" @positive-click="handleSubmit" style="width: 520px">
      <n-form :model="formData" ref="formRef" label-placement="left" label-width="80">
        <n-form-item label="物料名称" path="name"><n-input v-model:value="formData.name" placeholder="物料名称" /></n-form-item>
        <n-form-item label="编码SKU" path="sku"><n-input v-model:value="formData.sku" placeholder="如：FAB-SILK-001" /></n-form-item>
        <n-form-item label="分类" path="category">
          <n-select v-model:value="formData.category" :options="categoryOptions" placeholder="选择分类" />
        </n-form-item>
        <n-form-item label="单位" path="unit"><n-input v-model:value="formData.unit" placeholder="米/个/kg" /></n-form-item>
        <n-form-item label="单价" path="unitPrice"><n-input-number v-model:value="formData.unitPrice" :min="0" :precision="2" style="width: 100%" /></n-form-item>
        <n-form-item label="预警阈值" path="warningStock"><n-input-number v-model:value="formData.warningStock" :min="0" :precision="2" style="width: 100%" /></n-form-item>
        <n-form-item label="备注" path="remark"><n-input v-model:value="formData.remark" type="textarea" /></n-form-item>
      </n-form>
    </n-modal>

    <!-- 入库/出库弹窗 -->
    <n-modal v-model:show="showStockModal" :title="stockType === 'in' ? '物料入库' : '物料出库'" preset="dialog" positive-text="确定" negative-text="取消" @positive-click="handleStock" style="width: 380px">
      <n-form label-placement="left" label-width="60">
        <n-form-item label="物料">{{ stockMaterial?.name }}</n-form-item>
        <n-form-item label="当前库存">{{ stockMaterial?.stock }} {{ stockMaterial?.unit }}</n-form-item>
        <n-form-item label="数量"><n-input-number v-model:value="stockQty" :min="0.01" :precision="2" style="width: 100%" /></n-form-item>
      </n-form>
    </n-modal>
  </n-card>
</template>

<script lang="ts" setup>
import { ref, onMounted, h } from 'vue';
import { NButton, NTag, NSpace, useMessage, useDialog } from 'naive-ui';
import { getMaterialList, addMaterial, updateMaterial, deleteMaterial, stockIn, stockOut } from '@/api/supply/index';

const message = useMessage();
const dialog = useDialog();
const loading = ref(false);
const tableData = ref([]);

const filterCategory = ref(null);
const keyword = ref('');

const categoryOptions = [
  { label: '面料', value: '面料' },
  { label: '辅料', value: '辅料' },
  { label: '五金件', value: '五金件' },
];

const showModal = ref(false);
const isEdit = ref(false);
const formRef = ref();
const formData = ref<any>({});

const showStockModal = ref(false);
const stockType = ref<'in' | 'out'>('in');
const stockMaterial = ref<any>(null);
const stockQty = ref(1);

const columns = [
  { title: '编码', key: 'sku', width: 140 },
  { title: '名称', key: 'name', ellipsis: { tooltip: true } },
  { title: '分类', key: 'category', width: 80 },
  { title: '单位', key: 'unit', width: 60 },
  { title: '单价', key: 'unitPrice', width: 80, render: (r: any) => r.unitPrice ? `¥${r.unitPrice}` : '-' },
  {
    title: '库存',
    key: 'stock',
    width: 100,
    render(row: any) {
      const isLow = row.warningStock && Number(row.stock) <= Number(row.warningStock);
      return h('span', { style: isLow ? 'color: red; font-weight: bold' : '' }, `${row.stock} ${row.unit || ''}`);
    }
  },
  { title: '预警值', key: 'warningStock', width: 80 },
  {
    title: '操作',
    key: 'actions',
    width: 250,
    render(row: any) {
      return h(NSpace, {}, {
        default: () => [
          h(NButton, { size: 'small', type: 'success', onClick: () => openStock(row, 'in') }, { default: () => '入库' }),
          h(NButton, { size: 'small', type: 'warning', onClick: () => openStock(row, 'out') }, { default: () => '出库' }),
          h(NButton, { size: 'small', type: 'primary', onClick: () => handleEdit(row) }, { default: () => '编辑' }),
          h(NButton, { size: 'small', type: 'error', onClick: () => handleDelete(row) }, { default: () => '删除' }),
        ]
      });
    }
  }
];

const loadData = async () => {
  loading.value = true;
  try {
    const params: any = {};
    if (filterCategory.value) params.category = filterCategory.value;
    if (keyword.value) params.keyword = keyword.value;
    tableData.value = await getMaterialList(params);
  } catch (e) { console.error(e); }
  finally { loading.value = false; }
};

onMounted(loadData);

const handleAdd = () => {
  isEdit.value = false;
  formData.value = { name: '', sku: '', category: '面料', unit: '米', unitPrice: null, warningStock: null, remark: '' };
  showModal.value = true;
};

const handleEdit = (row: any) => {
  isEdit.value = true;
  formData.value = { ...row };
  showModal.value = true;
};

const handleSubmit = async () => {
  try {
    if (isEdit.value) {
      await updateMaterial(formData.value.materialId, formData.value);
      message.success('修改成功');
    } else {
      await addMaterial(formData.value);
      message.success('新增成功');
    }
    showModal.value = false;
    loadData();
  } catch (e) { console.error(e); }
};

const handleDelete = (row: any) => {
  dialog.warning({
    title: '确认删除',
    content: `确认删除 ${row.name}？`,
    positiveText: '确认',
    negativeText: '取消',
    onPositiveClick: async () => {
      await deleteMaterial(row.materialId);
      message.success('已删除');
      loadData();
    }
  });
};

const openStock = (row: any, type: 'in' | 'out') => {
  stockMaterial.value = row;
  stockType.value = type;
  stockQty.value = 1;
  showStockModal.value = true;
};

const handleStock = async () => {
  try {
    const fn = stockType.value === 'in' ? stockIn : stockOut;
    await fn(stockMaterial.value.materialId, { quantity: stockQty.value });
    message.success(stockType.value === 'in' ? '入库成功' : '出库成功');
    showStockModal.value = false;
    loadData();
  } catch (e) { console.error(e); }
};
</script>
