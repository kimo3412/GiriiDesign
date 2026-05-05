<template>
  <div class="inventory-page">
    <!-- 顶部统计 -->
    <div class="stat-cards">
      <BusinessMetricCard label="物料种类" :value="stats.total" icon="📦" variant="primary" />
      <BusinessMetricCard
        label="低库存预警"
        :value="lowStockList.length"
        icon="⚠️"
        variant="warning"
        :clickable="true"
        @click="showLowStockOnly = !showLowStockOnly"
      />
      <BusinessMetricCard label="当前页库存总量" :value="stats.currentPageStock" icon="🏭" variant="success" prefix="¥" />
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
              全部 <span class="tree-item__count">{{ categoryTotals['all'] || 0 }}</span>
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

          <!-- 低库存预警区 -->
          <div v-if="lowStockList.length" class="lowstock-alert">
            <div class="lowstock-alert__title">⚠️ 预警物料</div>
            <div
              v-for="item in lowStockList.slice(0, 5)"
              :key="item.materialId"
              class="lowstock-item"
            >
              <span class="lowstock-item__name">{{ item.name }}</span>
              <span class="lowstock-item__stock">{{ item.stock || 0 }}/{{ item.warningStock || 0 }}</span>
            </div>
            <div v-if="lowStockList.length > 5" class="lowstock-alert__more">
              还有 {{ lowStockList.length - 5 }} 条预警
            </div>
          </div>
        </div>

        <!-- 右侧：紧凑筛选 + 表格 -->
        <div class="directory-main">
          <div class="compact-filter">
            <n-input
              v-model:value="keyword"
              placeholder="搜索名称/编码..."
              size="small"
              clearable
              @keyup.enter="handleSearch"
              style="width: 200px"
            >
              <template #prefix><n-icon><Search /></n-icon></template>
            </n-input>
            <n-button size="small" type="primary" @click="handleSearch">搜索</n-button>
            <n-tag v-if="showLowStockOnly" closable size="small" type="warning" round @close="showLowStockOnly = false">
              仅预警
            </n-tag>
          </div>

          <n-data-table
            :columns="columns"
            :data="displayData"
            :loading="loading"
            :row-key="row => row.materialId"
            size="small"
            :bordered="false"
          />

          <div class="compact-pagination">
            <n-pagination
              v-model:page="pageNum"
              v-model:page-size="pageSize"
              :page-sizes="[10, 20, 50]"
              :item-count="total"
              show-size-picker
              size="small"
              @update:page="handlePageChange"
              @update:page-size="handlePageSizeChange"
            />
          </div>
        </div>
      </div>
    </n-card>

    <!-- 入库/出库弹窗 -->
    <n-modal
      v-model:show="showStockModal"
      :title="stockAction === 'in' ? '物料入库' : '物料出库'"
      preset="dialog"
      positive-text="确认" negative-text="取消"
      @positive-click="handleSubmitStock"
    >
      <n-alert v-if="stockAction === 'out'" type="warning" :bordered="false" style="margin-bottom: 12px;">
        出库将从库存中扣减对应数量
      </n-alert>
      <n-form label-placement="left" label-width="70">
        <n-form-item label="物料">{{ currentMaterialLabel }}</n-form-item>
        <n-form-item label="当前库存">
          <span :style="{ color: isLowStock ? 'var(--status-warning-text)' : 'inherit', fontWeight: 'bold' }">
            {{ currentMaterial?.stock }} {{ currentMaterial?.unit }}
          </span>
          <n-tag v-if="isLowStock" type="warning" size="tiny" style="margin-left: 8px">预警</n-tag>
        </n-form-item>
        <n-form-item label="数量">
          <n-input-number v-model:value="stockQuantity" :min="0.01" :precision="2" style="width: 100%" />
        </n-form-item>
      </n-form>
    </n-modal>
  </div>
</template>

<script lang="ts" setup>
import { ref, computed, onMounted, h } from 'vue';
import { NTag, NButton, NSpace, NIcon, NAlert, NForm, NFormItem, NInputNumber, NModal, NPagination, useMessage } from 'naive-ui';
import { Search } from '@vicons/ionicons5';
import { getLowStock, getMaterialList, stockIn, stockOut } from '@/api/supply';
import { BusinessMetricCard } from '@/components/Business';

const message = useMessage();
const loading = ref(false);
const tableData = ref<any[]>([]);
const lowStockList = ref<any[]>([]);
const total = ref(0);
const pageNum = ref(1);
const pageSize = ref(10);
const keyword = ref('');
const selectedCategory = ref<string | null>(null);
const showLowStockOnly = ref(false);

const showStockModal = ref(false);
const stockAction = ref<'in' | 'out'>('in');
const stockQuantity = ref<number | null>(null);
const currentMaterial = ref<any>(null);

const categoryOptions = [
  { label: '面料', value: '面料' },
  { label: '辅料', value: '辅料' },
  { label: '五金件', value: '五金件' },
];

// 统计
const stats = computed(() => {
  const all = tableData.value;
  return {
    total: total.value,
    currentPageStock: all.reduce((sum: number, r: any) => sum + Number(r.stock || 0), 0).toFixed(2),
  };
});

// 品类统计
const categoryStats = computed(() => {
  const map: Record<string, number> = {};
  tableData.value.forEach((r: any) => {
    if (r.category) map[r.category] = (map[r.category] || 0) + 1;
  });
  return Object.entries(map).map(([name, count]) => ({ name, count }));
});

const categoryTotals = computed(() => {
  const map: Record<string, number> = { all: tableData.value.length };
  tableData.value.forEach((r: any) => {
    if (r.category) map[r.category] = (map[r.category] || 0) + 1;
  });
  return map;
});

// 筛选后数据
const displayData = computed(() => {
  let list = [...tableData.value];
  if (showLowStockOnly.value) {
    list = list.filter((r: any) => r.warningStock && Number(r.stock) <= Number(r.warningStock));
  }
  return list;
});

const selectCategory = (cat: string | null) => {
  selectedCategory.value = cat;
  pageNum.value = 1;
  loadData();
};

const isLowStock = computed(() =>
  currentMaterial.value?.warningStock &&
  Number(currentMaterial.value?.stock) <= Number(currentMaterial.value?.warningStock)
);

const currentMaterialLabel = computed(() =>
  currentMaterial.value ? `${currentMaterial.value.name} (${currentMaterial.value.sku || '-'})` : ''
);

const columns = [
  { title: 'ID', key: 'materialId', width: 60 },
  { title: '名称', key: 'name', ellipsis: { tooltip: true } },
  { title: 'SKU', key: 'sku', width: 120 },
  { title: '品类', key: 'category', width: 80 },
  { title: '单位', key: 'unit', width: 60 },
  {
    title: '当前库存',
    key: 'stock',
    width: 100,
    align: 'right' as const,
    render(row: any) {
      const isLow = row.warningStock && Number(row.stock) <= Number(row.warningStock);
      return h('span', {
        style: isLow ? 'color: var(--status-warning-text); font-weight: 700' : 'color: var(--text-primary)'
      }, `${row.stock} ${row.unit || ''}`);
    }
  },
  { title: '预警值', key: 'warningStock', width: 80, align: 'right' as const, render: (r: any) => r.warningStock || '-' },
  {
    title: '状态',
    key: 'stockStatus',
    width: 70,
    render(row: any) {
      const isLow = Number(row.warningStock || 0) > 0 && Number(row.stock || 0) <= Number(row.warningStock || 0);
      return h(StatusBadge, {
        status: isLow ? 'warning' : 'normal',
        size: 'small',
        round: true,
        map: {
          warning: { label: '预警', type: 'warning' },
          normal: { label: '正常', type: 'success' },
        }
      });
    }
  },
  {
    title: '操作',
    key: 'action',
    width: 130,
    render(row: any) {
      return h(NSpace, { size: 4 }, {
        default: () => [
          h(NButton, { size: 'tiny', type: 'success', onClick: () => openStockModal('in', row) }, { default: () => '入库' }),
          h(NButton, { size: 'tiny', type: 'warning', onClick: () => openStockModal('out', row) }, { default: () => '出库' }),
        ]
      });
    }
  }
];

const openStockModal = (action: 'in' | 'out', row: any) => {
  stockAction.value = action;
  currentMaterial.value = row;
  stockQuantity.value = null;
  showStockModal.value = true;
};

const handleSubmitStock = async () => {
  if (!currentMaterial.value || !stockQuantity.value || stockQuantity.value <= 0) {
    message.warning('请输入有效数量'); return false;
  }
  const api = stockAction.value === 'in' ? stockIn : stockOut;
  await api(currentMaterial.value.materialId, { quantity: stockQuantity.value });
  message.success(stockAction.value === 'in' ? '入库成功' : '出库成功');
  showStockModal.value = false;
  await Promise.all([loadData(), loadLowStock()]);
};

const loadLowStock = async () => {
  lowStockList.value = (await getLowStock()) || [];
};

const loadData = async () => {
  loading.value = true;
  try {
    const params: any = {
      category: selectedCategory.value || undefined,
      keyword: keyword.value || undefined,
      pageNum: pageNum.value,
      pageSize: pageSize.value,
    };
    const res = await getMaterialList(params);
    tableData.value = res.records || [];
    total.value = res.total || 0;
  } finally { loading.value = false; }
};
const handleSearch = () => {
  pageNum.value = 1;
  loadData();
};

const handlePageChange = (page: number) => {
  pageNum.value = page;
  loadData();
};

const handlePageSizeChange = (size: number) => {
  pageSize.value = size;
  pageNum.value = 1;
  loadData();
};


onMounted(async () => {
  await Promise.all([loadData(), loadLowStock()]);
});
</script>

<script lang="ts">
import StatusBadge from '@/components/Business/StatusBadge.vue';
export default { name: 'SupplyInventory' }
</script>

<style scoped>
.inventory-page {
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
  width: 170px;
  flex-shrink: 0;
  border-right: 1px solid var(--border-light);
  background: var(--page-bg);
  display: flex;
  flex-direction: column;
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

.tree-items { padding: 8px 0; flex: 1; overflow-y: auto; }

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

/* 低库存预警区 */
.lowstock-alert {
  border-top: 1px solid var(--border-light);
  padding: 10px 12px;
}

.lowstock-alert__title {
  font-size: 12px;
  font-weight: 600;
  color: var(--status-warning-text);
  margin-bottom: 8px;
}

.lowstock-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 3px 0;
  font-size: 12px;
}

.lowstock-item__name {
  color: var(--text-secondary);
  flex: 1;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.lowstock-item__stock {
  color: var(--status-warning-text);
  font-weight: 600;
  font-size: 11px;
  margin-left: 6px;
}

.lowstock-alert__more {
  font-size: 11px;
  color: var(--text-tertiary);
  text-align: center;
  padding-top: 4px;
}

.directory-main {
  flex: 1;
  display: flex;
  flex-direction: column;
  overflow: hidden;
  min-height: 0;
  padding: 14px 16px;
  gap: 12px;
}

.compact-filter {
  display: flex;
  align-items: center;
  gap: 8px;
}


.directory-main :deep(.n-data-table) {
  flex: 1;
  min-height: 0;
}

.directory-main :deep(.n-data-table-wrapper),
.directory-main :deep(.n-data-table-base-table),
.directory-main :deep(.n-data-table-base-table-body) {
  min-height: 0;
}
.compact-pagination {
  display: flex;
  justify-content: flex-end;
  flex-shrink: 0;
  padding-top: 8px;
  border-top: 1px solid var(--border-light);
}
</style>
