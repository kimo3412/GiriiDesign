<template>
  <div class="address-page">
    <!-- 顶部统计 -->
    <div class="stat-cards">
      <BusinessMetricCard label="全部地址" :value="stats.total" icon="📋" variant="primary" />
      <BusinessMetricCard label="默认地址" :value="stats.defaultCount" icon="🏠" variant="success" />
      <BusinessMetricCard label="非默认" :value="stats.normalCount" icon="📍" variant="default" />
    </div>

    <n-card :bordered="false" class="directory-card">
      <div class="directory-layout">
        <!-- 左侧：状态维度树 -->
        <div class="directory-tree">
          <div class="tree-header">地址筛选</div>
          <div class="tree-items">
            <div
              class="tree-item"
              :class="{ 'tree-item--active': selectedDefault === null }"
              @click="selectDefault(null)"
            >
              全部 <span class="tree-item__count">{{ stats.total }}</span>
            </div>
            <div
              class="tree-item"
              :class="{ 'tree-item--active': selectedDefault === 1 }"
              @click="selectDefault(1)"
            >
              默认地址 <span class="tree-item__count">{{ stats.defaultCount }}</span>
            </div>
            <div
              class="tree-item"
              :class="{ 'tree-item--active': selectedDefault === 0 }"
              @click="selectDefault(0)"
            >
              非默认 <span class="tree-item__count">{{ stats.normalCount }}</span>
            </div>
          </div>
        </div>

        <!-- 右侧：紧凑筛选 + 表格 -->
        <div class="directory-main">
          <div class="compact-filter">
            <n-input
              v-model:value="keyword"
              placeholder="搜索客户/收件人/电话/地址..."
              size="small"
              clearable
              @keyup.enter="handleSearch"
              style="width: 260px"
            >
              <template #prefix><n-icon><Search /></n-icon></template>
            </n-input>
            <n-button size="small" type="primary" @click="handleSearch">搜索</n-button>
          </div>

          <n-data-table
            :columns="columns"
            :data="displayData"
            :loading="loading"
            :row-key="row => row.addressId"
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
  </div>
</template>

<script lang="ts" setup>
import { ref, computed, onMounted, h } from 'vue';
import { NTag, NIcon } from 'naive-ui';
import { Search } from '@vicons/ionicons5';
import { BusinessMetricCard } from '@/components/Business';
import { getCustomerAddressList, type CustomerAddressItem } from '@/api/customer';

const loading = ref(false);
const tableData = ref<CustomerAddressItem[]>([]);
const total = ref(0);
const pageNum = ref(1);
const pageSize = ref(10);

const keyword = ref('');
const selectedDefault = ref<number | null>(null);

const stats = computed(() => {
  const all = tableData.value;
  return {
    total: total.value,
    defaultCount: all.filter((r: any) => r.isDefault === 1).length,
    normalCount: all.filter((r: any) => r.isDefault !== 1).length,
  };
});

const displayData = computed(() => tableData.value);

const selectDefault = (val: number | null) => {
  selectedDefault.value = val;
  pageNum.value = 1;
  loadData();
};

const columns = [
  { title: 'ID', key: 'addressId', width: 60 },
  {
    title: '客户',
    key: 'nickname',
    width: 160,
    render(row: CustomerAddressItem) {
      return h('div', {}, [
        h('div', { style: 'font-weight:600;color:var(--text-primary)' }, row.nickname || `用户#${row.userId}`),
        h('div', { style: 'font-size:12px;color:var(--text-tertiary)' }, row.userPhone || '-'),
      ]);
    },
  },
  {
    title: '收件人',
    key: 'receiverName',
    width: 150,
    render(row: CustomerAddressItem) {
      return h('div', {}, [
        h('div', { style: 'color:var(--text-primary)' }, row.receiverName || '-'),
        h('div', { style: 'font-size:12px;color:var(--text-tertiary)' }, row.phone || '-'),
      ]);
    },
  },
  {
    title: '默认',
    key: 'isDefault',
    width: 80,
    align: 'center' as const,
    render(row: CustomerAddressItem) {
      return row.isDefault
        ? h(NTag, { type: 'success', size: 'small', round: true }, { default: () => '默认' })
        : '-';
    },
  },
  {
    title: '详细地址',
    key: 'fullAddress',
    ellipsis: { tooltip: true },
    render(row: CustomerAddressItem) {
      return [row.province, row.city, row.district, row.detailAddress].filter(Boolean).join(' ') || '-';
    },
  },
  { title: '创建时间', key: 'createTime', width: 150, render: (row: CustomerAddressItem) => row.createTime ? row.createTime.slice(0, 16) : '-' },
];

const loadData = async () => {
  loading.value = true;
  try {
    const res = await getCustomerAddressList({
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

onMounted(loadData);
</script>

<style scoped>
.address-page {
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
