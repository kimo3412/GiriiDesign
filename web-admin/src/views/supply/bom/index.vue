<template>
  <n-card title="BOM 模板" :bordered="false">
    <template #header-extra>
      <n-space>
        <n-select v-model:value="filterCategory" :options="categoryOptions" placeholder="品类" style="width: 140px" clearable @update:value="loadData" />
        <n-button type="primary" @click="handleAdd">新增模板</n-button>
      </n-space>
    </template>

    <n-data-table :columns="columns" :data="tableData" :loading="loading" :row-key="row => row.templateId" />

    <!-- 新增/编辑弹窗 -->
    <n-modal v-model:show="showModal" :title="isEdit ? '编辑 BOM 模板' : '新增 BOM 模板'" preset="dialog" positive-text="保存" negative-text="取消" @positive-click="handleSubmit" style="width: 600px">
      <n-form :model="formData" label-placement="left" label-width="80">
        <n-form-item label="模板名称"><n-input v-model:value="formData.name" placeholder="如：旗袍标准BOM" /></n-form-item>
        <n-form-item label="关联品类">
          <n-select v-model:value="formData.categoryId" :options="categoryOptions" placeholder="选择品类" />
        </n-form-item>
        <n-form-item label="备注"><n-input v-model:value="formData.remark" type="textarea" /></n-form-item>

        <n-divider>物料明细</n-divider>

        <div v-for="(item, idx) in formData.items" :key="idx" style="display: flex; gap: 8px; margin-bottom: 8px; align-items: center;">
          <n-select v-model:value="item.materialId" :options="materialOptions" placeholder="选择物料" style="flex: 1" filterable />
          <n-input-number v-model:value="item.quantity" :min="0.01" :precision="2" placeholder="数量" style="width: 120px" />
          <n-button type="error" size="small" @click="formData.items.splice(idx, 1)">删除</n-button>
        </div>
        <n-button dashed block @click="formData.items.push({ materialId: null, quantity: 1 })">+ 添加物料</n-button>
      </n-form>
    </n-modal>
  </n-card>
</template>

<script lang="ts" setup>
import { ref, onMounted, h } from 'vue';
import { NButton, NSpace, useMessage, useDialog } from 'naive-ui';
import { getBomTemplateList, getBomTemplateDetail, addBomTemplate, updateBomTemplate, deleteBomTemplate } from '@/api/supply/index';
import { getMaterialList } from '@/api/supply/index';
import { getCategoryList } from '@/api/config/category';

const message = useMessage();
const dialog = useDialog();
const loading = ref(false);
const tableData = ref([]);

const filterCategory = ref(null);
const categoryOptions = ref<any[]>([]);
const categoryMap = ref<Record<number, string>>({});
const materialOptions = ref<any[]>([]);

const showModal = ref(false);
const isEdit = ref(false);
const formData = ref<any>({ name: '', categoryId: null, remark: '', items: [] });

const columns = [
  { title: 'ID', key: 'templateId', width: 60 },
  { title: '模板名称', key: 'name' },
  { title: '品类', key: 'categoryId', width: 100, render(row: any) { return categoryMap.value[row.categoryId] || '-'; } },
  { title: '备注', key: 'remark', ellipsis: { tooltip: true } },
  { title: '创建时间', key: 'createTime', width: 170 },
  {
    title: '操作',
    key: 'actions',
    width: 150,
    render(row: any) {
      return h(NSpace, {}, {
        default: () => [
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
    if (filterCategory.value != null) params.categoryId = filterCategory.value;
    tableData.value = await getBomTemplateList(params);
  } catch (e) { console.error(e); }
  finally { loading.value = false; }
};

onMounted(async () => {
  loadData();
  try {
    const cats = await getCategoryList();
    categoryOptions.value = cats.map((c: any) => ({ label: c.name, value: c.categoryId }));
    const cMap: any = {};
    cats.forEach((c: any) => { cMap[c.categoryId] = c.name; });
    categoryMap.value = cMap;
  } catch (e) { console.error(e); }
  try {
    const mats = await getMaterialList({});
    materialOptions.value = mats.map((m: any) => ({ label: `${m.name} (${m.sku})`, value: m.materialId }));
  } catch (e) { console.error(e); }
});

const handleAdd = () => {
  isEdit.value = false;
  formData.value = { name: '', categoryId: null, remark: '', items: [{ materialId: null, quantity: 1 }] };
  showModal.value = true;
};

const handleEdit = async (row: any) => {
  try {
    const res = await getBomTemplateDetail(row.templateId);
    isEdit.value = true;
    formData.value = {
      ...res.template,
      items: (res.items || []).map((i: any) => ({ materialId: i.materialId, quantity: i.quantity }))
    };
    if (formData.value.items.length === 0) {
      formData.value.items.push({ materialId: null, quantity: 1 });
    }
    showModal.value = true;
  } catch (e) { console.error(e); }
};

const handleSubmit = async () => {
  try {
    const data = {
      name: formData.value.name,
      categoryId: formData.value.categoryId,
      remark: formData.value.remark,
      items: formData.value.items.filter((i: any) => i.materialId),
    };
    if (isEdit.value) {
      await updateBomTemplate(formData.value.templateId, data);
      message.success('修改成功');
    } else {
      await addBomTemplate(data);
      message.success('新增成功');
    }
    showModal.value = false;
    loadData();
  } catch (e) { console.error(e); }
};

const handleDelete = (row: any) => {
  dialog.warning({
    title: '确认删除',
    content: `确认删除模板 ${row.name}？`,
    positiveText: '确认',
    negativeText: '取消',
    onPositiveClick: async () => {
      await deleteBomTemplate(row.templateId);
      message.success('已删除');
      loadData();
    }
  });
};
</script>
