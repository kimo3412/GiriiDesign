<template>
  <n-card title="操作日志" :bordered="false">
    <!-- 搜索栏 -->
    <div class="search-bar">
      <n-space>
        <n-input v-model:value="searchTitle" placeholder="操作模块" clearable style="width: 160px" />
        <n-input v-model:value="searchOperator" placeholder="操作人" clearable style="width: 140px" />
        <n-select
          v-model:value="searchStatus"
          placeholder="状态"
          clearable
          :options="statusOptions"
          style="width: 120px"
        />
        <n-button type="primary" @click="fetchLogs">查询</n-button>
        <n-button @click="resetSearch">重置</n-button>
        <n-popconfirm @positive-click="handleClean">
          <template #trigger>
            <n-button type="error">清空日志</n-button>
          </template>
          确定要清空所有操作日志吗？此操作不可恢复。
        </n-popconfirm>
      </n-space>
    </div>

    <!-- 日志表格 -->
    <n-data-table
      :columns="columns"
      :data="logList"
      :loading="loading"
      :pagination="{ pageSize: 15 }"
      :row-key="(row: any) => row.logId"
      striped
      style="margin-top: 16px"
    />

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
  </n-card>
</template>

<script lang="ts" setup>
import { ref, h, onMounted } from 'vue';
import { NButton, NTag, NSpace, useMessage } from 'naive-ui';
import { getOperLogList, deleteOperLog, cleanOperLog } from '@/api/system/operLog';
import type { SysOperLog } from '@/api/system/operLog';

const message = useMessage();
const loading = ref(false);
const logList = ref<SysOperLog[]>([]);
const showDetail = ref(false);
const currentLog = ref<SysOperLog | null>(null);

const searchTitle = ref('');
const searchOperator = ref('');
const searchStatus = ref<number | null>(null);

const statusOptions = [
  { label: '成功', value: 0 },
  { label: '异常', value: 1 },
];

const columns = [
  { title: 'ID', key: 'logId', width: 70 },
  { title: '操作模块', key: 'title', width: 120 },
  {
    title: '请求方式',
    key: 'requestMethod',
    width: 90,
    render: (row: any) =>
      h(NTag, { type: methodTagType(row.requestMethod), size: 'small' }, () => row.requestMethod),
  },
  { title: '操作人', key: 'operatorName', width: 100 },
  { title: '请求URL', key: 'operUrl', ellipsis: { tooltip: true } },
  { title: 'IP', key: 'operIp', width: 120 },
  {
    title: '状态',
    key: 'status',
    width: 80,
    render: (row: any) =>
      h(NTag, { type: row.status === 0 ? 'success' : 'error', size: 'small' }, () =>
        row.status === 0 ? '成功' : '异常'
      ),
  },
  { title: '操作时间', key: 'operTime', width: 170 },
  {
    title: '操作',
    key: 'action',
    width: 120,
    render: (row: any) =>
      h(NSpace, {}, () => [
        h(NButton, { size: 'small', quaternary: true, type: 'info', onClick: () => viewDetail(row) }, () => '详情'),
        h(NButton, { size: 'small', quaternary: true, type: 'error', onClick: () => handleDelete(row.logId) }, () => '删除'),
      ]),
  },
];

onMounted(() => fetchLogs());

const fetchLogs = async () => {
  loading.value = true;
  try {
    const params: any = {};
    if (searchTitle.value) params.title = searchTitle.value;
    if (searchOperator.value) params.operatorName = searchOperator.value;
    if (searchStatus.value !== null) params.status = searchStatus.value;
    logList.value = (await getOperLogList(params)) || [];
  } catch (e) {
    console.error('获取日志失败', e);
  }
  loading.value = false;
};

const resetSearch = () => {
  searchTitle.value = '';
  searchOperator.value = '';
  searchStatus.value = null;
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
.search-bar {
  padding-bottom: 8px;
}
</style>
