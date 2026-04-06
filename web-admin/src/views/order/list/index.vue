<template>
  <n-card title="订单列表" :bordered="false">
    <template #header-extra>
      <n-space>
        <n-select
          v-model:value="filterStatus"
          :options="statusOptions"
          placeholder="状态"
          style="width: 120px"
          clearable
          @update:value="loadData"
        />
        <n-select
          v-model:value="filterCategory"
          :options="categoryOptions"
          placeholder="品类"
          style="width: 140px"
          clearable
          @update:value="loadData"
        />
      </n-space>
    </template>

    <n-data-table :columns="columns" :data="tableData" :loading="loading" :row-key="row => row.orderId" />
  </n-card>
</template>

<script lang="ts" setup>
import { ref, onMounted, h } from 'vue';
import { NButton, NTag, NSpace, useMessage } from 'naive-ui';
import { useRouter } from 'vue-router';
import { getOrderList } from '@/api/order/index';
import { getCategoryList } from '@/api/config/category';

const router = useRouter();
const message = useMessage();
const loading = ref(false);
const tableData = ref([]);

const filterStatus = ref(null);
const filterCategory = ref(null);

const statusOptions = [
  { label: '待支付', value: 0 },
  { label: '生产中', value: 1 },
  { label: '待发货', value: 2 },
  { label: '待收货', value: 3 },
  { label: '已完成', value: 4 },
  { label: '已取消', value: 5 },
];

const statusMap: any = {
  0: { label: '待支付', type: 'default' },
  1: { label: '生产中', type: 'info' },
  2: { label: '待发货', type: 'warning' },
  3: { label: '待收货', type: 'success' },
  4: { label: '已完成', type: 'success' },
  5: { label: '已取消', type: 'error' },
  6: { label: '待付尾款', type: 'warning' },
};

const categoryOptions = ref<any[]>([]);

const columns = [
  { title: '订单号', key: 'orderSn', width: 180 },
  { title: '品类', key: 'categoryId', width: 80 },
  { title: '客户', key: 'userId', width: 80 },
  { title: '设计师', key: 'designerId', width: 80 },
  {
    title: '金额',
    key: 'totalAmount',
    width: 100,
    render(row: any) {
      return row.totalAmount ? `¥${row.totalAmount}` : '-';
    }
  },
  {
    title: '状态',
    key: 'status',
    width: 100,
    render(row: any) {
      const s = statusMap[row.status];
      return s ? h(NTag, { type: s.type, size: 'small' }, { default: () => s.label }) : '';
    }
  },
  {
    title: '阻塞',
    key: 'isBlocked',
    width: 80,
    render(row: any) {
      return row.isBlocked === 1
        ? h(NTag, { type: 'error', size: 'small' }, { default: () => '已阻塞' })
        : '';
    }
  },
  { title: '预计交付', key: 'expectedDate', width: 120 },
  { title: '创建时间', key: 'createTime', width: 170 },
  {
    title: '操作',
    key: 'actions',
    width: 80,
    render(row: any) {
      return h(NButton, {
        size: 'small', type: 'primary', text: true,
        onClick: () => router.push(`/order/detail/${row.orderId}`)
      }, { default: () => '详情' });
    }
  }
];

const loadData = async () => {
  loading.value = true;
  try {
    const params: any = {};
    if (filterStatus.value != null) params.status = filterStatus.value;
    if (filterCategory.value != null) params.categoryId = filterCategory.value;
    tableData.value = await getOrderList(params);
  } catch (e) { console.error(e); }
  finally { loading.value = false; }
};

onMounted(async () => {
  loadData();
  try {
    const cats = await getCategoryList();
    categoryOptions.value = cats.map((c: any) => ({ label: c.name, value: c.categoryId }));
  } catch (e) { console.error(e); }
});
</script>
