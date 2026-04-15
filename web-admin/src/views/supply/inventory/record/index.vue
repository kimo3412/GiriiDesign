<template>
  <n-card title="库存记录" :bordered="false">
    <template #header-extra>
      <n-space>
        <n-input
          v-model:value="keyword"
          clearable
          placeholder="搜索操作人或模块"
          style="width: 220px"
          @keyup.enter="loadData"
        />
        <n-select
          v-model:value="status"
          :options="statusOptions"
          clearable
          placeholder="状态"
          style="width: 120px"
          @update:value="loadData"
        />
        <n-button type="primary" @click="loadData">查询</n-button>
      </n-space>
    </template>

    <n-data-table
      :columns="columns"
      :data="tableData"
      :loading="loading"
      :row-key="(row) => row.logId"
      :pagination="{ pageSize: 15 }"
      striped
    />
  </n-card>
</template>

<script lang="ts" setup>
import { computed, h, onMounted, ref } from 'vue';
import { NTag } from 'naive-ui';
import { getOperLogList, type SysOperLog } from '@/api/system/operLog';

const loading = ref(false);
const sourceData = ref<SysOperLog[]>([]);
const keyword = ref('');
const status = ref<number | null>(null);

const statusOptions = [
  { label: '成功', value: 0 },
  { label: '异常', value: 1 },
];

const tableData = computed(() =>
  sourceData.value
    .filter((item) => item.title?.includes('物料入库') || item.title?.includes('物料出库'))
    .filter((item) => {
      if (!keyword.value) return true;
      const text = `${item.title || ''} ${item.operatorName || ''} ${item.operParam || ''}`.toLowerCase();
      return text.includes(keyword.value.toLowerCase());
    })
);

const columns = [
  { title: 'ID', key: 'logId', width: 70 },
  {
    title: '类型',
    key: 'title',
    width: 120,
    render(row: SysOperLog) {
      const isIn = row.title?.includes('入库');
      return h(NTag, { type: isIn ? 'success' : 'warning', size: 'small' }, { default: () => (isIn ? '入库' : '出库') });
    },
  },
  { title: '操作模块', key: 'title', width: 120 },
  { title: '操作人', key: 'operatorName', width: 100, render: (row: SysOperLog) => row.operatorName || '-' },
  { title: '请求地址', key: 'operUrl', ellipsis: { tooltip: true } },
  { title: '请求参数', key: 'operParam', ellipsis: { tooltip: true } },
  {
    title: '状态',
    key: 'status',
    width: 80,
    render(row: SysOperLog) {
      return h(NTag, { type: row.status === 0 ? 'success' : 'error', size: 'small' }, { default: () => (row.status === 0 ? '成功' : '异常') });
    },
  },
  { title: '时间', key: 'operTime', width: 180 },
];

const loadData = async () => {
  loading.value = true;
  try {
    sourceData.value = (await getOperLogList({
      status: status.value ?? undefined,
    })) || [];
  } finally {
    loading.value = false;
  }
};

onMounted(loadData);
</script>
