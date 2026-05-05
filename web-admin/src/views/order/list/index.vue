<template>
  <div class="order-list-page">
    <div class="status-strip">
      <button
        type="button"
        class="status-pill"
        :class="{ 'status-pill--active': selectedStatus === null }"
        @click="selectStatus(null)"
      >
        <span class="status-pill__label">全部订单</span>
        <span class="status-pill__value">{{ stats.total }}</span>
      </button>
      <button
        v-for="stat in statusQuickStats"
        :key="stat.value"
        type="button"
        class="status-pill"
        :class="[`status-pill--${stat.variant}`, { 'status-pill--active': selectedStatus === stat.value }]"
        @click="selectStatus(stat.value)"
      >
        <span class="status-pill__label">{{ stat.label }}</span>
        <span class="status-pill__value">{{ stat.count }}</span>
      </button>
    </div>

    <n-card :bordered="false" class="directory-card">
      <div class="directory-layout">
        <aside class="directory-tree">
          <div class="tree-header">状态筛选</div>
          <div class="tree-items">
            <div
              class="tree-item"
              :class="{ 'tree-item--active': selectedStatus === null }"
              @click="selectStatus(null)"
            >
              全部 <span class="tree-item__count">{{ stats.total }}</span>
            </div>
            <div
              v-for="status in statusDimTree"
              :key="status.value"
              class="tree-item"
              :class="{ 'tree-item--active': selectedStatus === status.value }"
              @click="selectStatus(status.value)"
            >
              <span class="tree-item__dot" :style="{ background: status.color }"></span>
              {{ status.label }}
              <span class="tree-item__count">{{ status.count }}</span>
            </div>
          </div>
        </aside>

        <section class="directory-main">
          <div class="compact-filter">
            <n-select
              v-model:value="filterCategory"
              :options="categoryOptions"
              placeholder="全部品类"
              clearable
              size="small"
              style="width: 140px"
              @update:value="handleSearch"
            />
            <n-input
              v-model:value="keyword"
              placeholder="搜索订单号/客户..."
              clearable
              size="small"
              style="width: 220px"
              @keyup.enter="handleSearch"
            >
              <template #prefix>
                <n-icon><Search /></n-icon>
              </template>
            </n-input>
            <n-button size="small" type="primary" @click="handleSearch">搜索</n-button>
          </div>

          <n-data-table
            :columns="columns"
            :data="displayData"
            :loading="loading"
            :row-key="(row) => row.orderId"
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
        </section>
      </div>
    </n-card>
  </div>
</template>

<script lang="ts" setup>
import { computed, h, onMounted, ref } from 'vue';
import { useRouter } from 'vue-router';
import { NButton, NIcon } from 'naive-ui';
import { Search } from '@vicons/ionicons5';
import { getOrderList } from '@/api/order/index';
import { getCategoryList } from '@/api/config/category';
import { getAdminList } from '@/api/system/adminList';
import { StatusBadge } from '@/components/Business';

const router = useRouter();

const loading = ref(false);
const tableData = ref<any[]>([]);
const total = ref(0);
const pageNum = ref(1);
const pageSize = ref(10);

const keyword = ref('');
const selectedStatus = ref<number | null>(null);
const filterCategory = ref<number | null>(null);
const categoryOptions = ref<{ label: string; value: number }[]>([]);
const categoryMap = ref<Record<number, string>>({});
const adminMap = ref<Record<number, string>>({});

const STATUS_LIST = [
  { label: '待支付', value: 0, variant: 'default' as const },
  { label: '生产中', value: 1, variant: 'info' as const },
  { label: '待发货', value: 2, variant: 'warning' as const },
  { label: '待收货', value: 3, variant: 'info' as const },
  { label: '已完成', value: 4, variant: 'success' as const },
  { label: '已取消', value: 5, variant: 'error' as const },
  { label: '待付尾款', value: 6, variant: 'warning' as const },
];

const statusBadgeMap = Object.fromEntries(
  STATUS_LIST.map((item) => [
    item.value,
    { label: item.label, type: item.variant === 'default' ? 'default' : item.variant },
  ])
);

const stats = computed(() => {
  const map: Record<number, number> = {};
  STATUS_LIST.forEach((item) => {
    map[item.value] = 0;
  });
  tableData.value.forEach((row: any) => {
    if (map[row.status] !== undefined) map[row.status] += 1;
  });
  return { total: total.value, ...map };
});

const statusDimTree = computed(() =>
  STATUS_LIST.filter((item) => stats.value[item.value] > 0).map((item) => ({
    ...item,
    count: stats.value[item.value],
    color:
      item.variant === 'success'
        ? 'var(--status-success-text)'
        : item.variant === 'warning'
          ? 'var(--status-warning-text)'
          : item.variant === 'error'
            ? 'var(--status-error-text)'
            : item.variant === 'info'
              ? 'var(--status-info-text)'
              : 'var(--text-tertiary)',
  }))
);

const statusQuickStats = computed(() => [
  { label: '生产中', value: 1, count: stats.value[1] || 0, variant: 'info' as const },
  { label: '待发货', value: 2, count: stats.value[2] || 0, variant: 'warning' as const },
  { label: '待收货', value: 3, count: stats.value[3] || 0, variant: 'info' as const },
  { label: '已完成', value: 4, count: stats.value[4] || 0, variant: 'success' as const },
]);

const displayData = computed(() => tableData.value);

const columns = [
  { title: '订单号', key: 'orderSn', width: 180, ellipsis: { tooltip: true } },
  {
    title: '品类',
    key: 'categoryId',
    width: 96,
    render(row: any) {
      return categoryMap.value[row.categoryId] || '-';
    },
  },
  {
    title: '客户',
    key: 'customerName',
    width: 90,
    render(row: any) {
      return row.customerName || `用户#${row.userId}`;
    },
  },
  {
    title: '设计师',
    key: 'designerId',
    width: 96,
    render(row: any) {
      return adminMap.value[row.designerId] || '-';
    },
  },
  {
    title: '金额',
    key: 'totalAmount',
    width: 90,
    align: 'right' as const,
    render(row: any) {
      return row.totalAmount ? `¥${Number(row.totalAmount).toFixed(0)}` : '-';
    },
  },
  {
    title: '状态',
    key: 'status',
    width: 96,
    render(row: any) {
      return h(StatusBadge, {
        status: row.status,
        round: true,
        size: 'small',
        map: statusBadgeMap,
      });
    },
  },
  {
    title: '阻塞',
    key: 'isBlocked',
    width: 78,
    render(row: any) {
      if (row.isBlocked !== 1) return '';
      return h(StatusBadge, {
        status: 'blocked',
        round: true,
        size: 'small',
        map: { blocked: { label: '已阻塞', type: 'error' } },
      });
    },
  },
  {
    title: '交付日期',
    key: 'expectedDate',
    width: 112,
    render(row: any) {
      return row.expectedDate || '-';
    },
  },
  {
    title: '创建时间',
    key: 'createTime',
    width: 150,
    render(row: any) {
      return row.createTime ? row.createTime.slice(0, 16) : '-';
    },
  },
  {
    title: '操作',
    key: 'actions',
    width: 72,
    render(row: any) {
      return h(
        NButton,
        {
          size: 'tiny',
          type: 'primary',
          text: true,
          onClick: () => router.push(`/order/detail/${row.orderId}`),
        },
        { default: () => '详情' }
      );
    },
  },
];

function selectStatus(value: number | null) {
  selectedStatus.value = value;
  pageNum.value = 1;
}

async function loadData() {
  loading.value = true;
  try {
    const params: any = { pageNum: pageNum.value, pageSize: pageSize.value };
    if (filterCategory.value !== null) params.categoryId = filterCategory.value;
    const res: any = await getOrderList(params);
    tableData.value = res.records || [];
    total.value = res.total || 0;
  } catch (error) {
    console.error(error);
  } finally {
    loading.value = false;
  }
}
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
  await loadData();

  try {
    const categories = await getCategoryList();
    categoryOptions.value = categories.map((item: any) => ({ label: item.name, value: item.categoryId }));
    categoryMap.value = Object.fromEntries(categories.map((item: any) => [item.categoryId, item.name]));
  } catch (error) {
    console.error(error);
  }

  try {
    const admins = await getAdminList();
    adminMap.value = Object.fromEntries(admins.map((item: any) => [item.adminId, item.nickname || item.username]));
  } catch (error) {
    console.error(error);
  }
});
</script>

<style scoped>
.order-list-page {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.status-strip {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
}

.status-pill {
  display: inline-flex;
  align-items: center;
  gap: 10px;
  min-height: 42px;
  padding: 0 14px;
  border: 1px solid var(--border-light);
  border-radius: 999px;
  background: var(--panel-bg);
  color: var(--text-secondary);
  cursor: pointer;
  transition: all 0.18s ease;
}

.status-pill:hover {
  border-color: var(--primary-color);
  color: var(--primary-color);
}

.status-pill--active {
  border-color: var(--primary-color);
  background: var(--primary-bg);
  color: var(--primary-color);
  box-shadow: inset 0 0 0 1px rgba(72, 115, 255, 0.06);
}

.status-pill__label {
  font-size: 13px;
  font-weight: 600;
}

.status-pill__value {
  min-width: 24px;
  padding: 2px 8px;
  border-radius: 999px;
  background: var(--border-light);
  color: var(--text-tertiary);
  font-size: 12px;
  font-weight: 700;
}

.status-pill--active .status-pill__value {
  background: rgba(72, 115, 255, 0.12);
  color: var(--primary-color);
}

.status-pill--success.status-pill--active {
  border-color: var(--status-success-text);
  background: var(--status-success-bg);
  color: var(--status-success-text);
}

.status-pill--warning.status-pill--active {
  border-color: var(--status-warning-text);
  background: var(--status-warning-bg);
  color: var(--status-warning-text);
}

.status-pill--info.status-pill--active {
  border-color: var(--status-info-text);
  background: var(--status-info-bg);
  color: var(--status-info-text);
}

.status-pill--success.status-pill--active .status-pill__value,
.status-pill--warning.status-pill--active .status-pill__value,
.status-pill--info.status-pill--active .status-pill__value {
  background: rgba(255, 255, 255, 0.72);
  color: inherit;
}

.directory-card :deep(.n-card__content) {
  padding: 0;
}

.directory-layout {
  display: flex;
  height: calc(100vh - 230px);
  min-height: 420px;
}

.directory-tree {
  width: 170px;
  flex-shrink: 0;
  border-right: 1px solid var(--border-light);
  background: var(--page-bg);
}

.tree-header {
  padding: 12px 16px 8px;
  border-bottom: 1px solid var(--border-light);
  color: var(--text-tertiary);
  font-size: 12px;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.tree-items {
  padding: 8px 0;
}

.tree-item {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 8px 16px;
  color: var(--text-secondary);
  font-size: 13px;
  cursor: pointer;
  transition: background 0.15s ease;
}

.tree-item:hover {
  background: var(--row-selected-bg);
}

.tree-item--active {
  border-left: 3px solid var(--primary-color);
  background: var(--row-selected-bg);
  color: var(--primary-color);
  font-weight: 600;
}

.tree-item__dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  flex-shrink: 0;
}

.tree-item__count {
  margin-left: auto;
  padding: 1px 6px;
  border-radius: 8px;
  background: var(--border-light);
  color: var(--text-placeholder);
  font-size: 11px;
}

.tree-item--active .tree-item__count {
  background: var(--primary-bg);
  color: var(--primary-color);
}

.directory-main {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 12px;
  overflow: hidden;
  padding: 14px 16px;
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

@media (max-width: 1024px) {
  .directory-layout {
    flex-direction: column;
    height: auto;
  }

  .directory-tree {
    width: 100%;
    border-right: none;
    border-bottom: 1px solid var(--border-light);
  }

  .tree-items {
    display: flex;
    flex-wrap: wrap;
    gap: 8px;
    padding: 12px;
  }

  .tree-item {
    padding: 8px 12px;
    border: 1px solid var(--border-light);
    border-radius: 999px;
    background: var(--panel-bg);
  }

  .tree-item--active {
    border-left-width: 1px;
  }
}

@media (max-width: 768px) {
  .compact-filter {
    flex-wrap: wrap;
  }
}
</style>
