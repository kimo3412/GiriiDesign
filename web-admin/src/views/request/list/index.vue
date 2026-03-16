<template>
  <n-card title="意向池" :bordered="false">
    <template #header-extra>
      <n-space>
        <n-select
          v-model:value="filterStatus"
          :options="statusOptions"
          placeholder="状态筛选"
          style="width: 140px"
          clearable
          @update:value="loadData"
        />
        <n-select
          v-model:value="filterCategory"
          :options="categoryOptions"
          placeholder="品类筛选"
          style="width: 160px"
          clearable
          @update:value="loadData"
        />
      </n-space>
    </template>

    <n-data-table :columns="columns" :data="tableData" :loading="loading" :row-key="row => row.requestId" />

    <!-- 意向详情抽屉 -->
    <n-drawer v-model:show="showDetail" :width="480" placement="right">
      <n-drawer-content :title="'意向 #' + detailData?.requestId">
        <n-descriptions bordered :column="1" v-if="detailData">
          <n-descriptions-item label="品类ID">{{ detailData.categoryId }}</n-descriptions-item>
          <n-descriptions-item label="客户ID">{{ detailData.userId }}</n-descriptions-item>
          <n-descriptions-item label="状态">
            <n-tag :type="statusMap[detailData.status]?.type">{{ statusMap[detailData.status]?.label }}</n-tag>
          </n-descriptions-item>
          <n-descriptions-item label="客户描述">{{ detailData.description || '无' }}</n-descriptions-item>
          <n-descriptions-item label="定制参数">
            <pre style="white-space: pre-wrap; font-size: 12px;">{{ formatJson(detailData.customData) }}</pre>
          </n-descriptions-item>
          <n-descriptions-item label="提交时间">{{ detailData.createTime }}</n-descriptions-item>
        </n-descriptions>
        <template #footer v-if="detailData?.status === 0">
          <n-space>
            <n-button type="primary" @click="openConvert">转为订单</n-button>
            <n-button type="error" @click="openClose">关闭意向</n-button>
          </n-space>
        </template>
      </n-drawer-content>
    </n-drawer>

    <!-- 转单弹窗 -->
    <n-modal v-model:show="showConvert" title="意向转正订单" preset="dialog" positive-text="确认转单" negative-text="取消" @positive-click="handleConvert" style="width: 500px">
      <n-form :model="convertForm" label-placement="left" label-width="80">
        <n-form-item label="指派设计师">
          <n-select v-model:value="convertForm.designerId" :options="designerOptions" placeholder="请选择设计师" />
        </n-form-item>
        <n-form-item label="总金额">
          <n-input-number v-model:value="convertForm.totalAmount" :min="0" :precision="2" placeholder="报价金额" style="width: 100%;" />
        </n-form-item>
        <n-form-item label="预付款">
          <n-input-number v-model:value="convertForm.prepayAmount" :min="0" :precision="2" placeholder="预付款金额" style="width: 100%;" />
        </n-form-item>
        <n-form-item label="交付日期">
          <n-date-picker v-model:value="convertForm.expectedDateTs" type="date" style="width: 100%;" />
        </n-form-item>
        <n-form-item label="备注">
          <n-input v-model:value="convertForm.remark" type="textarea" placeholder="备注信息" />
        </n-form-item>
      </n-form>
    </n-modal>

    <!-- 关闭弹窗 -->
    <n-modal v-model:show="showClose" title="关闭意向" preset="dialog" positive-text="确认关闭" negative-text="取消" @positive-click="handleClose" style="width: 400px">
      <n-form-item label="关闭原因">
        <n-input v-model:value="closeReason" type="textarea" placeholder="请输入关闭原因" />
      </n-form-item>
    </n-modal>
  </n-card>
</template>

<script lang="ts" setup>
import { ref, onMounted, h } from 'vue';
import { NButton, NTag, NSpace, useMessage } from 'naive-ui';
import { getRequestList, getRequestDetail, convertRequest, closeRequest } from '@/api/order/index';
import { getCategoryList } from '@/api/config/category';
import { getAdminList } from '@/api/system/adminList';

const message = useMessage();
const loading = ref(false);
const tableData = ref([]);

const filterStatus = ref(null);
const filterCategory = ref(null);

const statusOptions = [
  { label: '待处理', value: 0 },
  { label: '已转单', value: 1 },
  { label: '已关闭', value: 2 },
];

const statusMap: any = {
  0: { label: '待处理', type: 'warning' },
  1: { label: '已转单', type: 'success' },
  2: { label: '已关闭', type: 'error' },
};

const categoryOptions = ref<any[]>([]);
const designerOptions = ref<any[]>([]);

// 详情抽屉
const showDetail = ref(false);
const detailData = ref<any>(null);

// 转单弹窗
const showConvert = ref(false);
const convertForm = ref({
  designerId: null as number | null,
  totalAmount: null as number | null,
  prepayAmount: null as number | null,
  expectedDateTs: null as number | null,
  remark: '',
});

// 关闭弹窗
const showClose = ref(false);
const closeReason = ref('');

const columns = [
  { title: 'ID', key: 'requestId', width: 60 },
  { title: '品类', key: 'categoryId', width: 80 },
  { title: '客户ID', key: 'userId', width: 80 },
  { title: '描述', key: 'description', ellipsis: { tooltip: true } },
  {
    title: '状态',
    key: 'status',
    width: 100,
    render(row: any) {
      const s = statusMap[row.status];
      return s ? h(NTag, { type: s.type, size: 'small' }, { default: () => s.label }) : '';
    }
  },
  { title: '提交时间', key: 'createTime', width: 170 },
  {
    title: '操作',
    key: 'actions',
    width: 80,
    render(row: any) {
      return h(NButton, { size: 'small', type: 'primary', text: true, onClick: () => handleViewDetail(row) }, { default: () => '查看' });
    }
  }
];

const loadData = async () => {
  loading.value = true;
  try {
    const params: any = {};
    if (filterStatus.value != null) params.status = filterStatus.value;
    if (filterCategory.value != null) params.categoryId = filterCategory.value;
    tableData.value = await getRequestList(params);
  } catch (e) { console.error(e); }
  finally { loading.value = false; }
};

onMounted(async () => {
  loadData();
  try {
    const cats = await getCategoryList();
    categoryOptions.value = cats.map((c: any) => ({ label: c.name, value: c.categoryId }));
  } catch (e) { console.error(e); }
  try {
    const admins = await getAdminList();
    designerOptions.value = admins.map((a: any) => ({ label: a.nickname || a.username, value: a.adminId }));
  } catch (e) { console.error(e); }
});

const handleViewDetail = async (row: any) => {
  try {
    detailData.value = await getRequestDetail(row.requestId);
    showDetail.value = true;
  } catch (e) { console.error(e); }
};

const formatJson = (str: string) => {
  if (!str) return '无';
  try { return JSON.stringify(JSON.parse(str), null, 2); }
  catch { return str; }
};

const openConvert = () => {
  convertForm.value = { designerId: null, totalAmount: null, prepayAmount: null, expectedDateTs: null, remark: '' };
  showConvert.value = true;
};

const handleConvert = async () => {
  if (!detailData.value) return;
  try {
    const expectedDate = convertForm.value.expectedDateTs
        ? new Date(convertForm.value.expectedDateTs).toISOString().split('T')[0]
        : null;
    await convertRequest(detailData.value.requestId, {
      designerId: convertForm.value.designerId,
      totalAmount: convertForm.value.totalAmount,
      prepayAmount: convertForm.value.prepayAmount,
      expectedDate,
      remark: convertForm.value.remark,
    });
    message.success('转单成功');
    showConvert.value = false;
    showDetail.value = false;
    loadData();
  } catch (e) { console.error(e); }
};

const openClose = () => {
  closeReason.value = '';
  showClose.value = true;
};

const handleClose = async () => {
  if (!detailData.value) return;
  try {
    await closeRequest(detailData.value.requestId, { closeReason: closeReason.value });
    message.success('已关闭');
    showClose.value = false;
    showDetail.value = false;
    loadData();
  } catch (e) { console.error(e); }
};
</script>
