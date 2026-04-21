<template>
  <div class="log-page">
    <div class="page-summary">
      <span class="page-summary__item">
        <span class="page-summary__label">全部日志</span>
        <span class="page-summary__value">{{ stats.total }}</span>
      </span>
      <span class="page-summary__item">
        <span class="page-summary__label">成功</span>
        <span class="page-summary__value">{{ stats.success }}</span>
      </span>
      <span class="page-summary__item">
        <span class="page-summary__label">异常</span>
        <span class="page-summary__value">{{ stats.error }}</span>
      </span>
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
              class="tree-item"
              :class="{ 'tree-item--active': selectedStatus === 0 }"
              @click="selectStatus(0)"
            >
              <span class="tree-item__dot" style="background: var(--status-success-text)"></span>
              成功 <span class="tree-item__count">{{ stats.success }}</span>
            </div>
            <div
              class="tree-item"
              :class="{ 'tree-item--active': selectedStatus === 1 }"
              @click="selectStatus(1)"
            >
              <span class="tree-item__dot" style="background: var(--status-error-text)"></span>
              异常 <span class="tree-item__count">{{ stats.error }}</span>
            </div>
          </div>
        </div>

        <!-- 右侧：紧凑筛选 + 表格 -->
        <div class="directory-main">
          <div class="compact-filter">
            <n-input
              v-model:value="searchTitle"
              placeholder="操作模块..."
              size="small"
              clearable
              style="width: 160px"
            />
            <n-input
              v-model:value="searchOperator"
              placeholder="操作人..."
              size="small"
              clearable
              style="width: 140px"
            />
            <n-select
              v-model:value="searchStatus"
              placeholder="状态"
              clearable
              :options="statusOptions"
              style="width: 120px"
              size="small"
            />
            <n-button size="small" type="primary" @click="fetchLogs">搜索</n-button>
            <n-button size="small" @click="resetSearch">重置</n-button>
            <n-divider vertical />
            <n-popconfirm @positive-click="handleClean">
              <template #trigger>
                <n-button size="small" type="error">清空日志</n-button>
              </template>
              确定要清空所有操作日志吗？此操作不可恢复。
            </n-popconfirm>
          </div>

          <n-data-table
            :columns="columns"
            :data="displayData"
            :loading="loading"
            :row-key="(row: any) => row.logId"
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
              @update:page="fetchLogs"
              @update:page-size="fetchLogs"
            />
          </div>
        </div>
      </div>
    </n-card>

    <!-- 详情弹窗 -->
    <n-modal v-model:show="showDetail" preset="card" title="日志详情" style="width: 700px">
      <n-descriptions bordered :column="1" label-placement="left" v-if="currentLog">
        <n-descriptions-item label="日志ID">{{ currentLog.logId }}</n-descriptions-item>
        <n-descriptions-item label="操作模块">{{ currentLog.title }}</n-descriptions-item>
        <n-descriptions-item label="请求方式">
          <n-tag :type="methodTagType(currentLog.requestMethod)" size="small">
            {{ currentLog.requestMethod }}
          </n-tag>
        </n-descriptions-item>
        <n-descriptions-item label="方法名">{{ currentLog.method }}</n-descriptions-item>
        <n-descriptions-item label="请求URL">{{ currentLog.operUrl }}</n-descriptions-item>
        <n-descriptions-item label="操作人">{{ currentLog.operatorName }}</n-descriptions-item>
        <n-descriptions-item label="IP地址">{{ currentLog.operIp }}</n-descriptions-item>
        <n-descriptions-item label="状态">
          <n-tag :type="currentLog.status === 0 ? 'success' : 'error'" size="small">
            {{ currentLog.status === 0 ? '成功' : '异常' }}
          </n-tag>
        </n-descriptions-item>
        <n-descriptions-item label="操作时间">{{ currentLog.operTime }}</n-descriptions-item>
        <n-descriptions-item label="请求参数" v-if="currentLog.operParam">
          <n-code :code="formatJson(currentLog.operParam)" language="json" />
        </n-descriptions-item>
        <n-descriptions-item label="返回结果" v-if="currentLog.jsonResult">
          <n-code :code="formatJson(currentLog.jsonResult)" language="json" />
        </n-descriptions-item>
        <n-descriptions-item label="错误信息" v-if="currentLog.errorMsg">
          <n-text type="error">{{ currentLog.errorMsg }}</n-text>
        </n-descriptions-item>
      </n-descriptions>
    </n-modal>
  </div>
</template>

<script lang="ts" setup>
import { ref, computed, onMounted, h } from 'vue';
import { NButton, NTag, NSpace, NIcon, NDivider } from 'naive-ui';
import { useMessage } from 'naive-ui';
import { getOperLogList, deleteOperLog, cleanOperLog } from '@/api/system/operLog';
import type { SysOperLog } from '@/api/system/operLog';

const message = useMessage();

const loading = ref(false);
const logList = ref<SysOperLog[]>([]);
const total = ref(0);
const pageNum = ref(1);
const pageSize = ref(10);

const showDetail = ref(false);
const currentLog = ref<SysOperLog | null>(null);

const searchTitle = ref('');
const searchOperator = ref('');
const searchStatus = ref<number | null>(null);
const selectedStatus = ref<number | null>(null);

const statusOptions = [
  { label: '成功', value: 0 },
  { label: '异常', value: 1 },
];

const stats = computed(() => {
  const all = logList.value;
  return {
    total: all.length,
    success: all.filter((r: any) => r.status === 0).length,
    error: all.filter((r: any) => r.status === 1).length,
  };
});

const displayData = computed(() => {
  let list = [...logList.value];
  if (selectedStatus.value !== null) {
    list = list.filter((r: any) => r.status === selectedStatus.value);
  }
  return list;
});

const selectStatus = (val: number | null) => {
  selectedStatus.value = val;
  pageNum.value = 1;
};

const columns = [
  { title: 'ID', key: 'logId', width: 70 },
  { title: '操作模块', key: 'title', width: 120, ellipsis: { tooltip: true } },
  {
    title: '请求方式',
    key: 'requestMethod',
    width: 90,
    render: (row: any) =>
      h(NTag, { type: methodTagType(row.requestMethod), size: 'small', round: true }, () => row.requestMethod),
  },
  { title: '操作人', key: 'operatorName', width: 100 },
  { title: '请求URL', key: 'operUrl', ellipsis: { tooltip: true } },
  { title: 'IP', key: 'operIp', width: 120 },
  {
    title: '状态',
    key: 'status',
    width: 80,
    render: (row: any) =>
      h(NTag, { type: row.status === 0 ? 'success' : 'error', size: 'small', round: true }, () =>
        row.status === 0 ? '成功' : '异常'
      ),
  },
  { title: '操作时间', key: 'operTime', width: 150, render: (r: any) => r.operTime ? r.operTime.slice(0, 16) : '-' },
  {
    title: '操作',
    key: 'action',
    width: 120,
    render: (row: any) =>
      h(NSpace, { size: 4 }, () => [
        h(NButton, { size: 'tiny', quaternary: true, type: 'info', onClick: () => viewDetail(row) }, () => '详情'),
        h(NButton, { size: 'tiny', quaternary: true, type: 'error', onClick: () => handleDelete(row.logId) }, () => '删除'),
      ]),
  },
];

onMounted(() => fetchLogs());

const fetchLogs = async () => {
  loading.value = true;
  try {
    const params: any = { pageNum: pageNum.value, pageSize: pageSize.value };
    if (searchTitle.value) params.title = searchTitle.value;
    if (searchOperator.value) params.operatorName = searchOperator.value;
    if (searchStatus.value !== null) params.status = searchStatus.value;
    const res = await getOperLogList(params) || [];
    logList.value = res;
    total.value = res.length;
  } catch (e) {
    console.error('获取日志失败', e);
  } finally {
    loading.value = false;
  }
};

const resetSearch = () => {
  searchTitle.value = '';
  searchOperator.value = '';
  searchStatus.value = null;
  selectedStatus.value = null;
  pageNum.value = 1;
  fetchLogs();
};

const viewDetail = (row: SysOperLog) => {
  currentLog.value = row;
  showDetail.value = true;
};

const handleDelete = async (id: number) => {
  await deleteOperLog(id);
  message.success('删除成功');
  fetchLogs();
};

const handleClean = async () => {
  await cleanOperLog();
  message.success('已清空');
  fetchLogs();
};

const methodTagType = (method: string) => {
  const map: Record<string, string> = { GET: 'info', POST: 'success', PUT: 'warning', DELETE: 'error' };
  return (map[method] || 'default') as any;
};

const formatJson = (str: string) => {
  try {
    return JSON.stringify(JSON.parse(str), null, 2);
  } catch {
    return str || '';
  }
};
</script>

<style scoped>
.log-page {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.page-summary {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
}

.page-summary__item {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  padding: 6px 10px;
  border-radius: 999px;
  border: 1px solid var(--border-light);
  background: rgba(255, 255, 255, 0.78);
}

.page-summary__label {
  font-size: 12px;
  color: var(--text-tertiary);
}

.page-summary__value {
  font-size: 13px;
  font-weight: 700;
  color: var(--text-primary);
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
  flex-wrap: wrap;
}

.compact-pagination {
  display: flex;
  justify-content: flex-end;
  padding-top: 8px;
  border-top: 1px solid var(--border-light);
}
</style>
