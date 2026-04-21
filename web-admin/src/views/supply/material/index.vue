<template>
  <div class="material-page">
    <!-- 顶部统计 -->
    <div class="stat-cards">
      <BusinessMetricCard
        label="物料种类"
        :value="stats.total"
        icon="📦"
        variant="primary"
      />
      <BusinessMetricCard
        label="预警物料"
        :value="stats.lowStock"
        icon="⚠️"
        variant="warning"
        :clickable="true"
        @click="showLowStockOnly = !showLowStockOnly"
      />
      <BusinessMetricCard
        label="库存总额"
        :value="stats.totalValue"
        icon="💰"
        variant="success"
        prefix="¥"
      />
    </div>

    <n-card :bordered="false" class="directory-card">
      <div class="directory-layout">
        <!-- 左侧：分类维度树 -->
        <div class="directory-tree">
          <div class="tree-header">品类筛选</div>
          <div class="tree-items">
            <div
              class="tree-item"
              :class="{ 'tree-item--active': selectedCategory === null }"
              @click="selectCategory(null)"
            >
              全部 <span class="tree-item__count">{{ tableData.length }}</span>
            </div>
            <div
              v-for="cat in categoryStats"
              :key="cat.name"
              class="tree-item"
              :class="{ 'tree-item--active': selectedCategory === cat.name }"
              @click="selectCategory(cat.name)"
            >
              {{ cat.name }} <span class="tree-item__count">{{ cat.count }}</span>
            </div>
          </div>
        </div>

        <!-- 右侧：紧凑筛选 + 表格 -->
        <div class="directory-main">
          <!-- 紧凑筛选栏 -->
          <div class="compact-filter">
            <n-input
              v-model:value="keyword"
              placeholder="搜索名称/编码..."
              size="small"
              clearable
              @keyup.enter="loadData"
              style="width: 200px"
            >
              <template #prefix>
                <n-icon><Search /></n-icon>
              </template>
            </n-input>
            <n-button size="small" type="primary" @click="loadData">搜索</n-button>
            <n-divider vertical />
            <n-tag v-if="showLowStockOnly" closable size="small" type="warning" round @close="showLowStockOnly = false">
              仅预警
            </n-tag>
            <n-space :size="6">
              <n-button :disabled="!checkedKeys.length" size="small" type="error" ghost @click="handleBatchDelete">
                批量删除{{ checkedKeys.length ? `(${checkedKeys.length})` : '' }}
              </n-button>
              <n-button size="small" type="primary" @click="handleAdd">新增物料</n-button>
            </n-space>
          </div>

          <!-- 表格 -->
          <n-data-table
            v-model:checked-row-keys="checkedKeys"
            :columns="columns"
            :data="displayData"
            :loading="loading"
            :row-key="row => row.materialId"
            size="small"
            :bordered="false"
          />

          <!-- 分页 -->
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
    <n-modal v-model:show="showModal" :title="isEdit ? '编辑物料' : '新增物料'" preset="dialog"
      positive-text="确定" negative-text="取消" @positive-click="handleSubmit" style="width: 520px">
      <n-form :model="formData" ref="formRef" label-placement="left" label-width="80">
        <n-form-item label="物料名称" path="name"><n-input v-model:value="formData.name" placeholder="物料名称" /></n-form-item>
        <n-form-item label="编码SKU" path="sku"><n-input v-model:value="formData.sku" placeholder="如：FAB-SILK-001" /></n-form-item>
        <n-form-item label="品类" path="category">
          <n-select v-model:value="formData.category" :options="categoryOptions" placeholder="选择品类" />
        </n-form-item>
        <n-form-item label="单位" path="unit"><n-input v-model:value="formData.unit" placeholder="米/个/kg" /></n-form-item>
        <n-form-item label="单价" path="unitPrice"><n-input-number v-model:value="formData.unitPrice" :min="0" :precision="2" style="width: 100%" /></n-form-item>
        <n-form-item label="预警阈值" path="warningStock"><n-input-number v-model:value="formData.warningStock" :min="0" :precision="2" style="width: 100%" /></n-form-item>
        <n-form-item label="备注" path="remark"><n-input v-model:value="formData.remark" type="textarea" /></n-form-item>
      </n-form>
    </n-modal>

    <!-- 入库/出库弹窗 -->
    <n-modal v-model:show="showStockModal" :title="stockType === 'in' ? '物料入库' : '物料出库'" preset="dialog"
      positive-text="确定" negative-text="取消" @positive-click="handleStock" style="width: 380px">
      <n-alert v-if="stockType === 'out'" type="warning" :bordered="false" style="margin-bottom: 12px;">
        出库将从库存中扣减对应数量
      </n-alert>
      <n-form label-placement="left" label-width="70">
        <n-form-item label="物料">{{ stockMaterial?.name }}</n-form-item>
        <n-form-item label="当前库存">
          <span :style="{ color: isLowStock ? 'var(--status-warning-text)' : 'inherit', fontWeight: 'bold' }">
            {{ stockMaterial?.stock }} {{ stockMaterial?.unit }}
          </span>
          <n-tag v-if="isLowStock" type="warning" size="tiny" style="margin-left: 8px">库存预警</n-tag>
        </n-form-item>
        <n-form-item label="数量"><n-input-number v-model:value="stockQty" :min="0.01" :precision="2" style="width: 100%" /></n-form-item>
      </n-form>
    </n-modal>
  </div>
</template>

<script lang="ts" setup>
import { ref, computed, onMounted, h } from 'vue';
import { NButton, NTag, NSpace, NInput, NInputNumber, NIcon, NDivider, NForm, NFormItem, NSelect, NModal, NAlert, NPagination, useMessage, useDialog } from 'naive-ui';
import { Search } from '@vicons/ionicons5';
import { getMaterialList, addMaterial, updateMaterial, deleteMaterial, batchDeleteMaterials, stockIn, stockOut } from '@/api/supply/index';
import { BusinessMetricCard } from '@/components/Business';

const message = useMessage();
const dialog = useDialog();
const loading = ref(false);
const tableData = ref<any[]>([]);
const total = ref(0);
const pageNum = ref(1);
const pageSize = ref(10);

const keyword = ref('');
const selectedCategory = ref<string | null>(null);
const showLowStockOnly = ref(false);

const categoryOptions = [
  { label: '面料', value: '面料' },
  { label: '辅料', value: '辅料' },
  { label: '五金件', value: '五金件' },
];

// 统计
const stats = computed(() => {
  const all = tableData.value;
  const lowStock = all.filter((r: any) => r.warningStock && Number(r.stock) <= Number(r.warningStock)).length;
  const totalValue = all.reduce((sum: number, r: any) => sum + (Number(r.stock) || 0) * (Number(r.unitPrice) || 0), 0);
  return { total: all.length, lowStock, totalValue: totalValue.toFixed(2) };
});

// 分类统计
const categoryStats = computed(() => {
  const map: Record<string, number> = {};
  tableData.value.forEach((r: any) => {
    if (r.category) map[r.category] = (map[r.category] || 0) + 1;
  });
  return Object.entries(map).map(([name, count]) => ({ name, count }));
});

// 筛选后数据
const displayData = computed(() => {
  let list = [...tableData.value];
  if (selectedCategory.value) {
    list = list.filter((r: any) => r.category === selectedCategory.value);
  }
  if (showLowStockOnly.value) {
    list = list.filter((r: any) => r.warningStock && Number(r.stock) <= Number(r.warningStock));
  }
  if (keyword.value) {
    const kw = keyword.value.toLowerCase();
    list = list.filter((r: any) =>
      (r.name || '').toLowerCase().includes(kw) ||
      (r.sku || '').toLowerCase().includes(kw)
    );
  }
  return list;
});

const selectCategory = (cat: string | null) => {
  selectedCategory.value = cat;
  pageNum.value = 1;
};

const showModal = ref(false);
const isEdit = ref(false);
const formRef = ref();
const formData = ref<any>({});

const showStockModal = ref(false);
const stockType = ref<'in' | 'out'>('in');
const stockMaterial = ref<any>(null);
const stockQty = ref(1);

const checkedKeys = ref<number[]>([]);

const isLowStock = computed(() =>
  stockMaterial.value?.warningStock &&
  Number(stockMaterial.value?.stock) <= Number(stockMaterial.value?.warningStock)
);

const columns = [
  { type: 'selection', width: 40 },
  { title: 'SKU编码', key: 'sku', width: 130 },
  { title: '名称', key: 'name', ellipsis: { tooltip: true } },
  { title: '品类', key: 'category', width: 80 },
  { title: '单位', key: 'unit', width: 60 },
  {
    title: '单价',
    key: 'unitPrice',
    width: 80,
    align: 'right' as const,
    render: (r: any) => r.unitPrice ? `¥${r.unitPrice}` : '-'
  },
  {
    title: '库存',
    key: 'stock',
    width: 100,
    render(row: any) {
      const isLow = row.warningStock && Number(row.stock) <= Number(row.warningStock);
      return h('span', {
        style: isLow ? 'color: var(--status-warning-text); font-weight: 700' : 'color: var(--text-primary)'
      }, `${row.stock} ${row.unit || ''}`);
    }
  },
  { title: '预警值', key: 'warningStock', width: 70, render: (r: any) => r.warningStock || '-' },
  {
    title: '操作',
    key: 'actions',
    width: 180,
    render(row: any) {
      return h(NSpace, { size: 4 }, {
        default: () => [
          h(NButton, { size: 'tiny', type: 'success', onClick: () => openStock(row, 'in') }, { default: () => '入库' }),
          h(NButton, { size: 'tiny', type: 'warning', onClick: () => openStock(row, 'out') }, { default: () => '出库' }),
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
    if (keyword.value) params.keyword = keyword.value;
    const res: any = await getMaterialList(params);
    tableData.value = res.records || [];
    total.value = res.total || 0;
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
    title: '确认删除', content: `确认删除 ${row.name}？`,
    positiveText: '确认', negativeText: '取消',
    onPositiveClick: async () => {
      await deleteMaterial(row.materialId);
      message.success('已删除');
      loadData();
    }
  });
};

const handleBatchDelete = () => {
  dialog.warning({
    title: '确认批量删除', content: `确定要删除选中的 ${checkedKeys.value.length} 条物料吗？`,
    positiveText: '确认', negativeText: '取消',
    onPositiveClick: async () => {
      try {
        await batchDeleteMaterials(checkedKeys.value);
        message.success('批量删除成功');
        checkedKeys.value = [];
        loadData();
      } catch (e) { console.error(e); }
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

<style scoped>
.material-page {
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

.directory-card :deep(.n-card__content) {
  padding: 0;
}

.directory-layout {
  display: flex;
  height: calc(100vh - 260px);
  min-height: 400px;
}

/* 左侧分类树 */
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

.tree-items {
  padding: 8px 0;
}

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

.tree-item:hover {
  background: var(--row-selected-bg);
}

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

.tree-item--active .tree-item__count {
  background: var(--primary-bg);
  color: var(--primary-color);
}

/* 右侧主区 */
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
  flex-wrap: wrap;
}

.compact-pagination {
  display: flex;
  justify-content: flex-end;
  padding-top: 8px;
  border-top: 1px solid var(--border-light);
}
</style>
