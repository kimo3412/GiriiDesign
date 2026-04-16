<template>
  <div class="order-list-page">
    <!-- 顶部统计 -->
    <div class="stat-cards">
      <BusinessMetricCard
        v-for="stat in statusStats"
        :key="stat.value"
        :label="stat.label"
        :value="stat.count"
        :icon="stat.icon"
        :variant="stat.variant"
        :clickable="true"
        @click="selectStatus(stat.value)"
      />
    </div>

    <n-card :bordered="false" class="directory-card">
      <div class="directory-layout">
        <!-- 左侧：状态维度树 -->
        <div class="directory-tree">
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
              v-for="s in statusDimTree"
              :key="s.value"
              class="tree-item"
              :class="{ 'tree-item--active': selectedStatus === s.value }"
              @click="selectStatus(s.value)"
            >
              <span class="tree-item__dot" :style="{ background: s.color }"></span>
              {{ s.label }} <span class="tree-item__count">{{ s.count }}</span>
            </div>
          </div>
        </div>

        <!-- 右侧：紧凑筛选 + 表格 -->
        <div class="directory-main">
          <!-- 紧凑筛选栏 -->
          <div class="compact-filter">
            <n-select
              v-model:value="filterCategory"
              :options="categoryOptions"
              placeholder="全部品类"
              style="width: 130px"
              size="small"
              clearable
              @update:value="loadData"
            />
            <n-input
              v-model:value="keyword"
              placeholder="搜索订单号/客户..."
              size="small"
              clearable
              @keyup.enter="loadData"
              style="width: 200px"
            >
              <template #prefix><n-icon><Search /></n-icon></template>
            </n-input>
            <n-button size="small" type="primary" @click="loadData">搜索</n-button>
          </div>

          <!-- 表格 -->
          <n-data-table
            :columns="columns"
            :data="displayData"
            :loading="loading"
            :row-key="row => row.orderId"
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
  </div>
</template>

<script lang="ts" setup>
import { ref, computed, onMounted, h } from 'vue';
import { useRouter } from 'vue-router';
import { NButton, NTag, NSpace, NIcon } from 'naive-ui';
import { Search } from '@vicons/ionicons5';
import { getOrderList } from '@/api/order/index';
import { getCategoryList } from '@/api/config/category';
import { getAdminList } from '@/api/system/adminList';
import { BusinessMetricCard, StatusBadge } from '@/components/Business';

const router = useRouter();

const loading = ref(false);
const tableData = ref<any[]>([]);
const total = ref(0);
const pageNum = ref(1);
const pageSize = ref(10);

const keyword = ref('');
const selectedStatus = ref<number | null>(null);
const filterCategory = ref<number | null>(null);
const categoryOptions = ref<any[]>([]);
const categoryMap = ref<Record<number, string>>({});
const adminMap = ref<Record<number, string>>({});

// 状态定义
const STATUS_LIST = [
  { label: '待支付', value: 0, icon: '💳', variant: 'default' as const },
  { label: '生产中', value: 1, icon: '🔨', variant: 'info' as const },
  { label: '待发货', value: 2, icon: '📦', variant: 'warning' as const },
  { label: '待收货', value: 3, icon: '🚚', variant: 'info' as const },
  { label: '已完成', value: 4, icon: '✅', variant: 'success' as const },
  { label: '已取消', value: 5, icon: '🚫', variant: 'error' as const },
  { label: '待付尾款', value: 6, icon: '💰', variant: 'warning' as const },
];

// 统计
const stats = computed(() => {
  const all = tableData.value;
  const map: Record<number, number> = {};
  STATUS_LIST.forEach(s => { map[s.value] = 0; });
  all.forEach((r: any) => { if (map[r.status] !== undefined) map[r.status]++; });
  return { total: all.length, ...map };
});

const statusDimTree = computed(() =>
  STATUS_LIST.filter(s => stats.value[s.value] > 0).map(s => ({
    ...s,
    count: stats.value[s.value],
    color: s.variant === 'success' ? 'var(--status-success-text)' :
           s.variant === 'warning' ? 'var(--status-warning-text)' :
           s.variant === 'error' ? 'var(--status-error-text)' :
           s.variant === 'info' ? 'var(--status-info-text)' : 'var(--text-tertiary)',
  }))
);

const statusStats = computed(() => [
  { label: '全部', value: -1, count: stats.value.total, icon: '📋', variant: 'primary' as const },
  { label: '生产中', value: 1, count: stats.value[1] || 0, icon: '🔨', variant: 'info' as const },
  { label: '待发货', value: 2, count: stats.value[2] || 0, icon: '📦', variant: 'warning' as const },
  { label: '待收货', value: 3, count: stats.value[3] || 0, icon: '🚚', variant: 'info' as const },
  { label: '已完成', value: 4, count: stats.value[4] || 0, icon: '✅', variant: 'success' as const },
]);

// 筛选后数据（前端分页但保留筛选功能，实际分页由后端负责）
const displayData = computed(() => {
  let list = [...tableData.value];
  if (selectedStatus.value !== null) {
    list = list.filter((r: any) => r.status === selectedStatus.value);
  }
  if (filterCategory.value !== null) {
    list = list.filter((r: any) => r.categoryId === filterCategory.value);
  }
  if (keyword.value) {
    const kw = keyword.value.toLowerCase();
    list = list.filter((r: any) =>
      (r.orderSn || '').toLowerCase().includes(kw) ||
      (r.customerName || '').toLowerCase().includes(kw) ||
      String(r.orderId).includes(kw)
    );
  }
  return list;
});

const selectStatus = (val: number | null) => {
  selectedStatus.value = val;
  pageNum.value = 1;
};

const columns = [
  { title: '订单号', key: 'orderSn', width: 180, ellipsis: { tooltip: true } },
  {
    title: '品类',
    key: 'categoryId',
    width: 90,
    render(row: any) { return categoryMap.value[row.categoryId] || '-'; }
  },
  {
    title: '客户',
    key: 'customerName',
    width: 80,
    render(row: any) { return row.customerName || `用户#${row.userId}`; }
  },
  {
    title: '设计师',
    key: 'designerId',
    width: 90,
    render(row: any) { return adminMap.value[row.designerId] || '-'; }
  },
  {
    title: '金额',
    key: 'totalAmount',
    width: 90,
    align: 'right' as const,
    render(row: any) { return row.totalAmount ? `¥${Number(row.totalAmount).toFixed(0)}` : '-'; }
  },
  {
    title: '状态',
    key: 'status',
    width: 90,
    render(row: any) {
      const s = STATUS_LIST.find(x => x.value === row.status);
      return s ? h(StatusBadge, { status: row.status, round: true, size: 'small',
        map: Object.fromEntries(STATUS_LIST.map(x => [x.value, { label: x.label, type: x.variant === 'default' ? 'default' : x.variant }]))
      }) : '-';
    }
  },
  {
    title: '阻塞',
    key: 'isBlocked',
    width: 70,
    render(row: any) {
      return row.isBlocked === 1
        ? h(StatusBadge, { status: 'blocked', round: true, size: 'small',
            map: { blocked: { label: '已阻塞', type: 'error' } } })
        : '';
    }
  },
  { title: '交付日期', key: 'expectedDate', width: 110, render: (r: any) => r.expectedDate || '-' },
  { title: '创建时间', key: 'createTime', width: 150, render: (r: any) => r.createTime ? r.createTime.slice(0, 16) : '-' },
  {
    title: '操作',
    key: 'actions',
    width: 70,
    render(row: any) {
      return h(NButton, {
        size: 'tiny', type: 'primary', text: true,
        onClick: () => router.push(`/order/detail/${row.orderId}`)
      }, { default: () => '详情' });
    }
  }
];

const loadData = async () => {
  loading.value = true;
  try {
    const params: any = { pageNum: pageNum.value, pageSize: pageSize.value };
    if (filterCategory.value != null) params.categoryId = filterCategory.value;
    const res: any = await getOrderList(params);
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
    const admins = await getAdminList();
    adminMap.value = Object.fromEntries(admins.map((a: any) => [a.adminId, a.nickname || a.username]));
  } catch (e) { /* ignore */ }
});
</script>

<style scoped>
.order-list-page {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.stat-cards {
  display: grid;
  grid-template-columns: repeat(5, 1fr);
  gap: 12px;
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
  align-items: center;
  gap: 6px;
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
.tree-item__dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  flex-shrink: 0;
}
.tree-item__count {
  font-size: 11px;
  color: var(--text-placeholder);
  background: var(--border-light);
  padding: 1px 6px;
  border-radius: 8px;
  margin-left: auto;
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
