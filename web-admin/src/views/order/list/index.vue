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
          @update:value="() => { pageNum = 1; loadData(); }"
        />
        <n-select
          v-model:value="filterCategory"
          :options="categoryOptions"
          placeholder="品类"
          style="width: 140px"
          clearable
          @update:value="() => { pageNum = 1; loadData(); }"
        />
      </n-space>
    </template>

    <n-data-table :columns="columns" :data="tableData" :loading="loading" :row-key="row => row.orderId" />

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
import { ref, onMounted, h } from 'vue';
import { NButton, NTag, NSpace, useMessage } from 'naive-ui';
import { useRouter } from 'vue-router';
import { getOrderList } from '@/api/order/index';
import { getCategoryList } from '@/api/config/category';
import { getAdminList } from '@/api/system/adminList';

const router = useRouter();
const message = useMessage();
const loading = ref(false);
const tableData = ref([]);
const total = ref(0);
const pageNum = ref(1);
const pageSize = ref(10);

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
const categoryMap = ref<Record<number, string>>({});
const adminMap = ref<Record<number, string>>({});

const columns = [
  { title: '订单号', key: 'orderSn', width: 180 },
  {
    title: '品类', key: 'categoryId', width: 100,
    render(row: any) {
      return categoryMap.value[row.categoryId] || row.categoryId || '-';
    }
  },
  {
    title: '客户', key: 'userId', width: 80,
    render(row: any) {
      return `用户#${row.userId}`;
    }
  },
  {
    title: '设计师', key: 'designerId', width: 100,
    render(row: any) {
      return adminMap.value[row.designerId] || row.designerId || '-';
    }
  },
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
    const params: any = { pageNum: pageNum.value, pageSize: pageSize.value };
    if (filterStatus.value != null) params.status = filterStatus.value;
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
    const catMap: any = {};
    cats.forEach((c: any) => { catMap[c.categoryId] = c.name; });
    categoryMap.value = catMap;
  } catch (e) { console.error(e); }
  try {
    const admins = await getAdminList();
    const aMap: any = {};
    admins.forEach((a: any) => { aMap[a.adminId] = a.nickname || a.username; });
    adminMap.value = aMap;
  } catch (e) { console.error(e); }
});
</script>
