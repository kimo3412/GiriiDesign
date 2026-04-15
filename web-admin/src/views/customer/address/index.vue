<template>
  <n-card title="地址管理" :bordered="false">
    <template #header-extra>
      <n-space>
        <n-input
          v-model:value="keyword"
          clearable
          placeholder="搜索客户/收件人/电话/地址"
          style="width: 260px"
          @keyup.enter="reload"
        />
        <n-button type="primary" @click="reload">查询</n-button>
      </n-space>
    </template>

    <n-data-table
      :columns="columns"
      :data="tableData"
      :loading="loading"
      :row-key="(row) => row.addressId"
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
import { NTag } from 'naive-ui';
import { getCustomerAddressList, type CustomerAddressItem } from '@/api/customer';

const loading = ref(false);
const tableData = ref<CustomerAddressItem[]>([]);
const total = ref(0);
const pageNum = ref(1);
const pageSize = ref(10);
const keyword = ref('');

const columns = [
  { title: 'ID', key: 'addressId', width: 70 },
  {
    title: '客户',
    key: 'nickname',
    width: 180,
    render(row: CustomerAddressItem) {
      return h('div', {}, [
        h('div', { style: 'font-weight:600;' }, row.nickname || `用户#${row.userId}`),
        h('div', { style: 'font-size:12px;color:#999;' }, row.userPhone || '-'),
      ]);
    },
  },
  {
    title: '收件人',
    key: 'receiverName',
    width: 160,
    render(row: CustomerAddressItem) {
      return h('div', {}, [
        h('div', {}, row.receiverName || '-'),
        h('div', { style: 'font-size:12px;color:#999;' }, row.phone || '-'),
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
        ? h(NTag, { type: 'success', size: 'small' }, { default: () => '默认' })
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
  { title: '创建时间', key: 'createTime', width: 180, render: (row: CustomerAddressItem) => row.createTime || '-' },
];

const reload = () => {
  pageNum.value = 1;
  loadData();
};

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

onMounted(loadData);
</script>
