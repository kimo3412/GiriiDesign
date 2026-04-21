<template>
  <div class="bom-page">
    <!-- 顶部统计 -->
    <div class="stat-cards">
      <BusinessMetricCard label="BOM模板" :value="stats.total" icon="📋" variant="primary" />
      <BusinessMetricCard label="使用中" :value="stats.active" icon="✅" variant="success" />
      <BusinessMetricCard label="关联品类" :value="stats.categories" icon="🏷️" variant="info" />
    </div>

    <n-card :bordered="false" class="directory-card">
      <div class="directory-layout">
        <!-- 左侧：品类维度树 -->
        <div class="directory-tree">
          <div class="tree-header">品类筛选</div>
          <div class="tree-items">
            <div
              class="tree-item"
              :class="{ 'tree-item--active': selectedCategory === null }"
              @click="selectCategory(null)"
            >
              全部 <span class="tree-item__count">{{ stats.total }}</span>
            </div>
            <div
              v-for="cat in categoryStats"
              :key="cat.id"
              class="tree-item"
              :class="{ 'tree-item--active': selectedCategory === cat.id }"
              @click="selectCategory(cat.id)"
            >
              {{ cat.name }} <span class="tree-item__count">{{ cat.count }}</span>
            </div>
          </div>
        </div>

        <!-- 右侧：紧凑筛选 + 表格 -->
        <div class="directory-main">
          <div class="compact-filter">
            <n-input
              v-model:value="keyword"
              placeholder="搜索模板名称..."
              size="small"
              clearable
              @keyup.enter="loadData"
              style="width: 200px"
            >
              <template #prefix><n-icon><Search /></n-icon></template>
            </n-input>
            <n-button size="small" type="primary" @click="loadData">搜索</n-button>
            <n-divider vertical />
            <n-button :disabled="!checkedKeys.length" size="small" type="error" ghost @click="handleBatchDelete">
              批量删除{{ checkedKeys.length ? `(${checkedKeys.length})` : '' }}
            </n-button>
            <n-button size="small" type="primary" @click="handleAdd">新增模板</n-button>
          </div>

          <n-data-table
            v-model:checked-row-keys="checkedKeys"
            :columns="columns"
            :data="displayData"
            :loading="loading"
            :row-key="row => row.templateId"
            size="small"
            :bordered="false"
          />

          <div class="compact-pagination">
            <n-pagination
              v-model:page="pageNum"
              :page-size="pageSize"
              :page-sizes="[10, 20, 50]"
              :total="total"
              show-size-picker
              size="small"
              @update:page="loadData"
              @update:page-size="loadData"
            />
          </div>
        </div>
      </div>
    </n-card>

    <!-- 新增/编辑弹窗 -->
    <n-modal v-model:show="showModal" :title="isEdit ? '编辑 BOM 模板' : '新增 BOM 模板'" preset="dialog"
      positive-text="保存" negative-text="取消" @positive-click="handleSubmit" style="width: 600px">
      <n-form :model="formData" label-placement="left" label-width="90">
        <n-form-item label="模板名称">
          <n-input v-model:value="formData.name" placeholder="如：旗袍标准BOM" />
        </n-form-item>
        <n-form-item label="关联品类">
          <n-select v-model:value="formData.categoryId" :options="categoryOptions" placeholder="选择品类" />
        </n-form-item>
        <n-form-item label="备注">
          <n-input v-model:value="formData.remark" type="textarea" placeholder="模板备注（选填）" />
        </n-form-item>

        <n-divider>物料明细</n-divider>

        <div v-for="(item, idx) in formData.items" :key="idx" style="display: flex; gap: 8px; margin-bottom: 8px; align-items: center;">
          <n-select v-model:value="item.materialId" :options="materialOptions" placeholder="选择物料" style="flex: 1" filterable />
          <n-input-number v-model:value="item.quantity" :min="0.01" :precision="2" placeholder="数量" style="width: 120px" />
          <n-button type="error" size="small" @click="formData.items.splice(idx, 1)">删除</n-button>
        </div>
        <n-button dashed block @click="formData.items.push({ materialId: null, quantity: 1 })">+ 添加物料</n-button>
      </n-form>
    </n-modal>
  </div>
</template>

<script lang="ts" setup>
import { ref, computed, onMounted, h } from 'vue';
import { NButton, NSpace, NIcon, NDivider } from 'naive-ui';
import { Search } from '@vicons/ionicons5';
import { getBomTemplateList, getBomTemplateDetail, addBomTemplate, updateBomTemplate, deleteBomTemplate, batchDeleteBomTemplates } from '@/api/supply/index';
import { getMaterialList } from '@/api/supply/index';
import { getCategoryList } from '@/api/config/category';
import { useMessage, useDialog } from 'naive-ui';
import { BusinessMetricCard } from '@/components/Business';

const message = useMessage();
const dialog = useDialog();
const loading = ref(false);
const tableData = ref<any[]>([]);
const total = ref(0);
const pageNum = ref(1);
const pageSize = ref(10);

const keyword = ref('');
const selectedCategory = ref<number | null>(null);
const categoryOptions = ref<any[]>([]);
const categoryMap = ref<Record<number, string>>({});
const materialOptions = ref<any[]>([]);

const showModal = ref(false);
const isEdit = ref(false);
const formData = ref<any>({ name: '', categoryId: null, remark: '', items: [] });
const checkedKeys = ref<number[]>([]);

// 统计
const stats = computed(() => {
  const all = tableData.value;
  return {
    total: all.length,
    active: all.filter((r: any) => r.categoryId).length,
    categories: new Set(all.map((r: any) => r.categoryId).filter(Boolean)).size,
  };
});

// 品类统计
const categoryStats = computed(() => {
  const map: Record<number, number> = {};
  tableData.value.forEach((r: any) => {
    if (r.categoryId) map[r.categoryId] = (map[r.categoryId] || 0) + 1;
  });
  return Object.entries(map).map(([id, count]) => ({
    id: Number(id),
    name: categoryMap.value[Number(id)] || `ID#${id}`,
    count,
  }));
});

// 筛选后数据
const displayData = computed(() => {
  let list = [...tableData.value];
  if (selectedCategory.value !== null) {
    list = list.filter((r: any) => r.categoryId === selectedCategory.value);
  }
  if (keyword.value) {
    const kw = keyword.value.toLowerCase();
    list = list.filter((r: any) => (r.name || '').toLowerCase().includes(kw));
  }
  return list;
});

const selectCategory = (id: number | null) => {
  selectedCategory.value = id;
  pageNum.value = 1;
};

const columns = [
  { type: 'selection', width: 40 },
  { title: 'ID', key: 'templateId', width: 60 },
  { title: '模板名称', key: 'name', ellipsis: { tooltip: true } },
  {
    title: '品类',
    key: 'categoryId',
    width: 90,
    render(row: any) { return categoryMap.value[row.categoryId] || '-'; }
  },
  { title: '备注', key: 'remark', ellipsis: { tooltip: true }, render: (r: any) => r.remark || '-' },
  { title: '创建时间', key: 'createTime', width: 150, render: (r: any) => r.createTime ? r.createTime.slice(0, 16) : '-' },
  {
    title: '操作',
    key: 'actions',
    width: 120,
    render(row: any) {
      return h(NSpace, { size: 4 }, {
        default: () => [
          h(NButton, { size: 'tiny', type: 'primary', onClick: () => handleEdit(row) }, { default: () => '编辑' }),
          h(NButton, { size: 'tiny', type: 'error', onClick: () => handleDelete(row) }, { default: () => '删除' }),
        ]
      });
    }
  }
];

const loadData = async () => {
  loading.value = true;
  try {
    const params: any = { pageNum: pageNum.value, pageSize: pageSize.value };
    const res: any = await getBomTemplateList(params);
    tableData.value = res.records || [];
    total.value = res.total || 0;
  } catch (e) { console.error(e); }
  finally { loading.value = false; }
};

onMounted(async () => {
  loadData();
  try {
    const cats = await getCategoryList();
    categoryOptions.value = cats.map((c: any) => ({ label: c.name, value: c.categoryId }));
    categoryMap.value = Object.fromEntries(cats.map((c: any) => [c.categoryId, c.name]));
  } catch (e) { /* ignore */ }
  try {
    const mats: any = await getMaterialList({ pageNum: 1, pageSize: 1000 });
    materialOptions.value = (mats.records || mats || []).map((m: any) => ({ label: `${m.name} (${m.sku})`, value: m.materialId }));
  } catch (e) { /* ignore */ }
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
    if (!formData.value.items.length) formData.value.items.push({ materialId: null, quantity: 1 });
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
    if (isEdit.value) { await updateBomTemplate(formData.value.templateId, data); message.success('修改成功'); }
    else { await addBomTemplate(data); message.success('新增成功'); }
    showModal.value = false;
    loadData();
  } catch (e) { console.error(e); }
};

const handleDelete = (row: any) => {
  dialog.warning({
    title: '确认删除', content: `确认删除模板 ${row.name}？`,
    positiveText: '确认', negativeText: '取消',
    onPositiveClick: async () => { await deleteBomTemplate(row.templateId); message.success('已删除'); loadData(); },
  });
};

const handleBatchDelete = () => {
  dialog.warning({
    title: '确认批量删除', content: `确定要删除选中的 ${checkedKeys.value.length} 个模板吗？`,
    positiveText: '确认', negativeText: '取消',
    onPositiveClick: async () => {
      try { await batchDeleteBomTemplates(checkedKeys.value); message.success('批量删除成功'); checkedKeys.value = []; loadData(); }
      catch (e) { console.error(e); }
    },
  });
};
</script>

<style scoped>
.bom-page {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.stat-cards {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
}

.stat-cards :deep(.metric-card) {
  flex: 0 1 180px;
}

.directory-card :deep(.n-card__content) { padding: 0; }

.directory-layout {
  display: flex;
  height: calc(100vh - 260px);
  min-height: 400px;
}

.directory-tree {
  width: 160px;
  flex-shrink: 0;
  border-right: 1px solid var(--border-light);
  background: var(--page-bg);
}

.tree-header {
  font-size: 12px;
  font-weight: 600;
  color: var(--text-tertiary);
  text-transform: uppercase;
  letter-spacing: 0.5px;
  padding: 12px 16px 8px;
  border-bottom: 1px solid var(--border-light);
}

.tree-items { padding: 8px 0; }

.tree-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 8px 16px;
  font-size: 13px;
  color: var(--text-secondary);
  cursor: pointer;
  transition: background 0.15s;
}
.tree-item:hover { background: var(--row-selected-bg); }
.tree-item--active {
  background: var(--row-selected-bg);
  color: var(--primary-color);
  font-weight: 600;
  border-left: 3px solid var(--primary-color);
}
.tree-item__count {
  font-size: 11px;
  color: var(--text-placeholder);
  background: var(--border-light);
  padding: 1px 6px;
  border-radius: 8px;
}
.tree-item--active .tree-item__count { background: var(--primary-bg); color: var(--primary-color); }

.directory-main {
  flex: 1;
  display: flex;
  flex-direction: column;
  overflow: hidden;
  padding: 14px 16px;
  gap: 12px;
}

.compact-filter {
  display: flex;
  align-items: center;
  gap: 8px;
}

.compact-pagination {
  display: flex;
  justify-content: flex-end;
  padding-top: 8px;
  border-top: 1px solid var(--border-light);
}
</style>
