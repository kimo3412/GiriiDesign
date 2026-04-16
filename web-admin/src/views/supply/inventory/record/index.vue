<template>
  <div class="record-page">
    <!-- 顶部统计 -->
    <div class="stat-cards">
      <BusinessMetricCard label="全部记录" :value="stats.total" icon="📋" variant="primary" />
      <BusinessMetricCard label="入库" :value="stats.inbound" icon="📥" variant="success" />
      <BusinessMetricCard label="出库" :value="stats.outbound" icon="📤" variant="warning" />
    </div>

    <n-card :bordered="false" class="directory-card">
      <div class="directory-layout">
        <!-- 左侧：类型维度树 -->
        <div class="directory-tree">
          <div class="tree-header">类型筛选</div>
          <div class="tree-items">
            <div
              class="tree-item"
              :class="{ 'tree-item--active': selectedType === null }"
              @click="selectType(null)"
            >
              全部 <span class="tree-item__count">{{ stats.total }}</span>
            </div>
            <div
              class="tree-item"
              :class="{ 'tree-item--active': selectedType === 'inbound' }"
              @click="selectType('inbound')"
            >
              <span class="tree-item__dot" style="background: var(--status-success-text)"></span>
              入库 <span class="tree-item__count">{{ stats.inbound }}</span>
            </div>
            <div
              class="tree-item"
              :class="{ 'tree-item--active': selectedType === 'outbound' }"
              @click="selectType('outbound')"
            >
              <span class="tree-item__dot" style="background: var(--status-warning-text)"></span>
              出库 <span class="tree-item__count">{{ stats.outbound }}</span>
            </div>
          </div>
        </div>

        <!-- 右侧：紧凑筛选 + 表格 -->
        <div class="directory-main">
          <div class="compact-filter">
            <n-input
              v-model:value="keyword"
              placeholder="搜索操作人或模块..."
              size="small"
              clearable
              @keyup.enter="loadData"
              style="width: 220px"
            >
              <template #prefix><n-icon><Search /></n-icon></template>
            </n-input>
            <n-select
              v-model:value="searchStatus"
              :options="statusOptions"
              clearable
              placeholder="状态"
              style="width: 120px"
              size="small"
              @update:value="loadData"
            />
            <n-button size="small" type="primary" @click="loadData">搜索</n-button>
          </div>

          <n-data-table
            :columns="columns"
            :data="displayData"
            :loading="loading"
            :row-key="row => row.logId"
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
  </div>
</template>

<script lang="ts" setup>
import { ref, computed, onMounted, h } from 'vue';
import { NTag, NIcon } from 'naive-ui';
import { Search } from '@vicons/ionicons5';
import { BusinessMetricCard } from '@/components/Business';
import { getOperLogList, type SysOperLog } from '@/api/system/operLog';

const loading = ref(false);
const tableData = ref<SysOperLog[]>([]);
const total = ref(0);
const pageNum = ref(1);
const pageSize = ref(10);

const keyword = ref('');
const searchStatus = ref<number | null>(null);
const selectedType = ref<'inbound' | 'outbound' | null>(null);

const statusOptions = [
  { label: '成功', value: 0 },
  { label: '异常', value: 1 },
];

const isInbound = (title?: string) => title?.includes('入库');
const isOutbound = (title?: string) => title?.includes('出库');

const stats = computed(() => {
  const all = tableData.value.filter((item) =>
    item.title?.includes('物料入库') || item.title?.includes('物料出库')
  );
  return {
    total: all.length,
    inbound: all.filter((r: any) => isInbound(r.title)).length,
    outbound: all.filter((r: any) => isOutbound(r.title)).length,
  };
});

const displayData = computed(() => {
  let list = tableData.value.filter((item) =>
    item.title?.includes('物料入库') || item.title?.includes('物料出库')
  );
  if (selectedType.value === 'inbound') {
    list = list.filter((r: any) => isInbound(r.title));
  } else if (selectedType.value === 'outbound') {
    list = list.filter((r: any) => isOutbound(r.title));
  }
  if (keyword.value) {
    const kw = keyword.value.toLowerCase();
    list = list.filter((item) => {
      const text = `${item.title || ''} ${item.operatorName || ''} ${item.operParam || ''}`.toLowerCase();
      return text.includes(kw);
    });
  }
  return list;
});

const selectType = (val: 'inbound' | 'outbound' | null) => {
  selectedType.value = val;
  pageNum.value = 1;
};

const columns = [
  { title: 'ID', key: 'logId', width: 70 },
  {
    title: '类型',
    key: 'title',
    width: 100,
    render(row: SysOperLog) {
      const isIn = isInbound(row.title);
      return h(NTag, { type: isIn ? 'success' : 'warning', size: 'small', round: true }, { default: () => (isIn ? '入库' : '出库') });
    },
  },
  { title: '操作模块', key: 'title', width: 120, ellipsis: { tooltip: true } },
  { title: '操作人', key: 'operatorName', width: 100, render: (row: SysOperLog) => row.operatorName || '-' },
  { title: '请求地址', key: 'operUrl', ellipsis: { tooltip: true } },
  { title: '请求参数', key: 'operParam', ellipsis: { tooltip: true } },
  {
    title: '状态',
    key: 'status',
    width: 80,
    render(row: SysOperLog) {
      return h(NTag, { type: row.status === 0 ? 'success' : 'error', size: 'small', round: true }, { default: () => (row.status === 0 ? '成功' : '异常') });
    },
  },
  { title: '时间', key: 'operTime', width: 150, render: (r: SysOperLog) => r.operTime ? r.operTime.slice(0, 16) : '-' },
];

const loadData = async () => {
  loading.value = true;
  try {
    const params: any = { pageNum: pageNum.value, pageSize: pageSize.value };
    if (searchStatus.value !== null) params.status = searchStatus.value;
    tableData.value = (await getOperLogList(params)) || [];
    total.value = tableData.value.length;
  } finally {
    loading.value = false;
  }
};

onMounted(loadData);
</script>

<style scoped>
.record-page {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.stat-cards {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 12px;
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
