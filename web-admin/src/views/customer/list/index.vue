<template>
  <n-card title="客户列表" :bordered="false">
    <template #header-extra>
      <n-space>
        <n-input
          v-model:value="keyword"
          clearable
          placeholder="搜索昵称或手机号"
          style="width: 220px"
          @keyup.enter="reload"
        />
        <n-select
          v-model:value="status"
          :options="statusOptions"
          clearable
          placeholder="状态"
          style="width: 120px"
          @update:value="reload"
        />
        <n-button type="primary" @click="reload">查询</n-button>
      </n-space>
    </template>

    <n-data-table
      :columns="columns"
      :data="tableData"
      :loading="loading"
      :row-key="(row) => row.userId"
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
</template>

<script lang="ts" setup>
import { h, onMounted, ref } from 'vue';
import { NAvatar, NTag } from 'naive-ui';
import { getCustomerList, type CustomerItem } from '@/api/customer';

const loading = ref(false);
const tableData = ref<CustomerItem[]>([]);
const total = ref(0);
const pageNum = ref(1);
const pageSize = ref(10);
const keyword = ref('');
const status = ref<number | null>(null);

const statusOptions = [
  { label: '正常', value: 1 },
  { label: '禁用', value: 0 },
];

const columns = [
  { title: 'ID', key: 'userId', width: 70 },
  {
    title: '客户',
    key: 'nickname',
    width: 220,
    render(row: CustomerItem) {
      return h('div', { style: 'display:flex;align-items:center;gap:10px;' }, [
        h(NAvatar, {
          size: 36,
          round: true,
          src: row.avatarUrl || undefined,
          fallbackSrc: '',
        }),
        h('div', {}, [
          h('div', { style: 'font-weight:600;' }, row.nickname || `用户#${row.userId}`),
          h('div', { style: 'font-size:12px;color:#999;' }, row.phone || '-'),
        ]),
      ]);
    },
  },
  {
    title: '状态',
    key: 'status',
    width: 100,
    render(row: CustomerItem) {
      const enabled = row.status === 1;
      return h(NTag, { type: enabled ? 'success' : 'default', size: 'small' }, { default: () => (enabled ? '正常' : '禁用') });
    },
  },
  { title: '地址数', key: 'addressCount', width: 90, align: 'center' as const },
  {
    title: '默认地址',
    key: 'defaultAddress',
    ellipsis: { tooltip: true },
    render: (row: CustomerItem) => row.defaultAddress || '-',
  },
  { title: '最后登录', key: 'lastLoginTime', width: 180, render: (row: CustomerItem) => row.lastLoginTime || '-' },
  { title: '注册时间', key: 'createTime', width: 180, render: (row: CustomerItem) => row.createTime || '-' },
];

const reload = () => {
  pageNum.value = 1;
  loadData();
};

const loadData = async () => {
  loading.value = true;
  try {
    const res = await getCustomerList({
      keyword: keyword.value || undefined,
      status: status.value ?? undefined,
      pageNum: pageNum.value,
      pageSize: pageSize.value,
    });
    tableData.value = res.records || [];
    total.value = res.total || 0;
  } finally {
    loading.value = false;
  }
};

onMounted(loadData);
</script>
