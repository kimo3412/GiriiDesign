<template>
  <div class="inventory-page">
    <n-grid :cols="3" :x-gap="16">
      <n-gi>
        <n-card :bordered="false">
          <div class="metric-label">物料总数</div>
          <div class="metric-value">{{ total }}</div>
        </n-card>
      </n-gi>
      <n-gi>
        <n-card :bordered="false">
          <div class="metric-label">低库存预警</div>
          <div class="metric-value metric-warn">{{ lowStockList.length }}</div>
        </n-card>
      </n-gi>
      <n-gi>
        <n-card :bordered="false">
          <div class="metric-label">当前页库存总量</div>
          <div class="metric-value">{{ currentPageStock }}</div>
        </n-card>
      </n-gi>
    </n-grid>

    <n-card title="库存管理" :bordered="false">
      <template #header-extra>
        <n-space>
          <n-select
            v-model:value="filterCategory"
            :options="categoryOptions"
            clearable
            placeholder="品类"
            style="width: 120px"
            @update:value="reload"
          />
          <n-input
            v-model:value="keyword"
            clearable
            placeholder="搜索名称/编码"
            style="width: 180px"
            @keyup.enter="reload"
          />
          <n-button type="primary" @click="reload">查询</n-button>
        </n-space>
      </template>

      <n-alert v-if="lowStockList.length" type="warning" :bordered="false" style="margin-bottom: 16px;">
        低库存预警：
        {{ lowStockList.map((item) => `${item.name}(${item.stock || 0}/${item.warningStock || 0})`).join('，') }}
      </n-alert>

      <n-data-table
        :columns="columns"
        :data="tableData"
        :loading="loading"
        :row-key="(row) => row.materialId"
        striped
      />

      <div style="margin-top: 16px; display: flex; justify-content: flex-end">
        <n-pagination
          v-model:page="pageNum"
          :page-size="pageSize"
          :page-sizes="[10, 20, 50]"
          :total="total"
          show-size-picker
          @update:page="loadData"
          @update:page-size="loadData"
        />
      </div>
    </n-card>

    <n-modal
      v-model:show="showStockModal"
      :title="stockAction === 'in' ? '物料入库' : '物料出库'"
      preset="dialog"
      positive-text="确认"
      negative-text="取消"
      @positive-click="handleSubmitStock"
    >
      <n-form-item label="物料">
        <n-input :value="currentMaterialLabel" disabled />
      </n-form-item>
      <n-form-item label="数量">
        <n-input-number v-model:value="stockQuantity" :min="0.01" :precision="2" style="width: 100%" />
      </n-form-item>
    </n-modal>
  </div>
</template>

<script lang="ts" setup>
import { computed, h, onMounted, ref } from 'vue';
import { NButton, NSpace, NTag, useMessage } from 'naive-ui';
import { getLowStock, getMaterialList, stockIn, stockOut } from '@/api/supply';

const message = useMessage();
const loading = ref(false);
const tableData = ref<any[]>([]);
const lowStockList = ref<any[]>([]);
const total = ref(0);
const pageNum = ref(1);
const pageSize = ref(10);
const filterCategory = ref<string | null>(null);
const keyword = ref('');
const showStockModal = ref(false);
const stockAction = ref<'in' | 'out'>('in');
const stockQuantity = ref<number | null>(null);
const currentMaterial = ref<any>(null);

const categoryOptions = [
  { label: '面料', value: '面料' },
  { label: '辅料', value: '辅料' },
  { label: '五金件', value: '五金件' },
];

const currentPageStock = computed(() =>
  tableData.value.reduce((sum, item) => sum + Number(item.stock || 0), 0).toFixed(2)
);

const currentMaterialLabel = computed(() =>
  currentMaterial.value ? `${currentMaterial.value.name} (${currentMaterial.value.sku || '-'})` : ''
);

const columns = [
  { title: 'ID', key: 'materialId', width: 70 },
  { title: '物料名称', key: 'name', width: 220 },
  { title: 'SKU', key: 'sku', width: 130 },
  { title: '分类', key: 'category', width: 100 },
  { title: '单位', key: 'unit', width: 80 },
  { title: '当前库存', key: 'stock', width: 110, align: 'right' as const },
  { title: '预警阈值', key: 'warningStock', width: 110, align: 'right' as const },
  {
    title: '库存状态',
    key: 'stockStatus',
    width: 100,
    render(row: any) {
      const low = Number(row.warningStock || 0) > 0 && Number(row.stock || 0) <= Number(row.warningStock || 0);
      return h(NTag, { type: low ? 'error' : 'success', size: 'small' }, { default: () => (low ? '预警' : '正常') });
    },
  },
  {
    title: '操作',
    key: 'action',
    width: 160,
    render(row: any) {
      return h(NSpace, {}, {
        default: () => [
          h(NButton, { size: 'small', type: 'success', onClick: () => openStockModal('in', row) }, { default: () => '入库' }),
          h(NButton, { size: 'small', type: 'warning', onClick: () => openStockModal('out', row) }, { default: () => '出库' }),
        ],
      });
    },
  },
];

const reload = () => {
  pageNum.value = 1;
  loadData();
};

const openStockModal = (action: 'in' | 'out', row: any) => {
  stockAction.value = action;
  currentMaterial.value = row;
  stockQuantity.value = null;
  showStockModal.value = true;
};

const handleSubmitStock = async () => {
  if (!currentMaterial.value || !stockQuantity.value || stockQuantity.value <= 0) {
    message.warning('请输入有效数量');
    return false;
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
    const res = await getMaterialList({
      category: filterCategory.value || undefined,
      keyword: keyword.value || undefined,
      pageNum: pageNum.value,
      pageSize: pageSize.value,
    });
    tableData.value = res.records || [];
    total.value = res.total || 0;
  } finally {
    loading.value = false;
  }
};

onMounted(async () => {
  await Promise.all([loadData(), loadLowStock()]);
});
</script>

<style scoped>
.inventory-page {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.metric-label {
  color: #888;
  font-size: 13px;
}

.metric-value {
  margin-top: 8px;
  font-size: 32px;
  font-weight: 700;
}

.metric-warn {
  color: #d03050;
}
</style>
