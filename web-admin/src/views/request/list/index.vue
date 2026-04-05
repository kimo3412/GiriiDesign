<template>
  <div class="request-page">
    <!-- 顶部统计卡片 -->
    <div class="stat-cards">
      <div class="stat-card stat-pending" @click="filterByStatus(0)">
        <div class="stat-number">{{ stats.pending }}</div>
        <div class="stat-label">待处理</div>
        <div class="stat-icon">📩</div>
      </div>
      <div class="stat-card stat-converted" @click="filterByStatus(1)">
        <div class="stat-number">{{ stats.converted }}</div>
        <div class="stat-label">已转单</div>
        <div class="stat-icon">✅</div>
      </div>
      <div class="stat-card stat-closed" @click="filterByStatus(2)">
        <div class="stat-number">{{ stats.closed }}</div>
        <div class="stat-label">已关闭</div>
        <div class="stat-icon">🚫</div>
      </div>
      <div class="stat-card stat-total" @click="filterByStatus(null)">
        <div class="stat-number">{{ stats.total }}</div>
        <div class="stat-label">全部</div>
        <div class="stat-icon">📊</div>
      </div>
    </div>

    <!-- 筛选与列表 -->
    <n-card :bordered="false">
      <template #header>
        <n-space align="center" :size="12">
          <span style="font-weight: 600; font-size: 16px;">意向池</span>
          <n-tag v-if="filterStatus !== null" closable @close="filterByStatus(null)" size="small">
            {{ statusMap[filterStatus]?.label }}
          </n-tag>
        </n-space>
      </template>
      <template #header-extra>
        <n-space :size="8">
          <n-select
            v-model:value="filterCategory"
            :options="categoryOptions"
            placeholder="品类"
            style="width: 140px"
            size="small"
            clearable
            @update:value="loadData"
          />
          <n-input
            v-model:value="searchText"
            placeholder="搜索描述..."
            size="small"
            style="width: 160px"
            clearable
          />
        </n-space>
      </template>

      <n-data-table
        :columns="columns"
        :data="filteredData"
        :loading="loading"
        :row-key="row => row.requestId"
        :row-class-name="rowClassName"
        striped
        size="small"
      />
    </n-card>

    <!-- 意向详情抽屉 -->
    <n-drawer v-model:show="showDetail" :width="520" placement="right">
      <n-drawer-content v-if="detailData">
        <template #header>
          <div class="drawer-header">
            <span class="drawer-title">意向 #{{ detailData.requestId }}</span>
            <n-tag :type="statusMap[detailData.status]?.type" size="small">
              {{ statusMap[detailData.status]?.label }}
            </n-tag>
          </div>
        </template>

        <!-- 客户信息 -->
        <div class="detail-section">
          <div class="detail-section-title">客户信息</div>
          <div class="detail-grid">
            <div class="detail-item">
              <span class="detail-label">客户</span>
              <span class="detail-value">{{ detailData.userName || ('用户#' + detailData.userId) }}</span>
            </div>
            <div class="detail-item">
              <span class="detail-label">品类</span>
              <span class="detail-value">{{ getCategoryName(detailData.categoryId) }}</span>
            </div>
            <div class="detail-item">
              <span class="detail-label">提交时间</span>
              <span class="detail-value">{{ detailData.createTime }}</span>
            </div>
          </div>
        </div>

        <!-- 客户描述 -->
        <div class="detail-section">
          <div class="detail-section-title">客户描述</div>
          <div class="detail-desc">{{ detailData.description || '客户未填写额外描述' }}</div>
        </div>

        <!-- 定制参数 -->
        <div class="detail-section">
          <div class="detail-section-title">定制参数</div>
          <div class="custom-params" v-if="parsedCustomData">
            <div v-for="(value, key) in parsedCustomData" :key="key" class="param-row">
              <span class="param-key">{{ key }}</span>
              <span class="param-value">{{ value }}</span>
            </div>
          </div>
          <div v-else class="detail-desc">无定制参数</div>
        </div>

        <!-- 参考图片 -->
        <div class="detail-section" v-if="parsedImages.length > 0">
          <div class="detail-section-title">参考图片</div>
          <div class="image-gallery">
            <n-image
              v-for="(img, idx) in parsedImages"
              :key="idx"
              :src="img"
              width="100"
              height="100"
              object-fit="cover"
              style="border-radius: 4px;"
            />
          </div>
        </div>

        <template #footer v-if="detailData?.status === 0">
          <n-space justify="end">
            <n-button @click="openClose" type="error" ghost>
              关闭意向
            </n-button>
            <n-button @click="openConvert" type="primary">
              转为正式订单 →
            </n-button>
          </n-space>
        </template>
      </n-drawer-content>
    </n-drawer>

    <!-- 转单弹窗 -->
    <n-modal v-model:show="showConvert" title="意向转正式订单" preset="dialog" positive-text="确认转单" negative-text="取消" @positive-click="handleConvert" style="width: 520px">
      <div class="convert-hint">
        <n-alert type="info" :bordered="false">
          转单后将创建正式订单，并启动对应品类的工作流。客户可在小程序查看订单进度。
        </n-alert>
      </div>
      <n-form :model="convertForm" label-placement="left" label-width="80" style="margin-top: 16px;">
        <n-form-item label="指派设计师">
          <n-select v-model:value="convertForm.designerId" :options="designerOptions" placeholder="选择负责的设计师" />
        </n-form-item>
        <n-grid :cols="2" :x-gap="12">
          <n-gi>
            <n-form-item label="总金额">
              <n-input-number v-model:value="convertForm.totalAmount" :min="0" :precision="2" placeholder="¥ 报价" style="width: 100%;">
                <template #prefix>¥</template>
              </n-input-number>
            </n-form-item>
          </n-gi>
          <n-gi>
            <n-form-item label="预付款">
              <n-input-number v-model:value="convertForm.prepayAmount" :min="0" :precision="2" placeholder="¥ 预付" style="width: 100%;">
                <template #prefix>¥</template>
              </n-input-number>
            </n-form-item>
          </n-gi>
        </n-grid>
        <n-form-item label="交付日期">
          <n-date-picker v-model:value="convertForm.expectedDateTs" type="date" style="width: 100%;" />
        </n-form-item>
        <n-form-item label="备注">
          <n-input v-model:value="convertForm.remark" type="textarea" placeholder="订单备注（选填）" :autosize="{ minRows: 2 }" />
        </n-form-item>
      </n-form>
    </n-modal>

    <!-- 关闭弹窗 -->
    <n-modal v-model:show="showClose" title="关闭意向" preset="dialog" positive-text="确认关闭" negative-text="取消" @positive-click="handleClose" style="width: 420px">
      <n-alert type="warning" :bordered="false" style="margin-bottom: 12px;">
        关闭后该意向将标记为已关闭，不可恢复。
      </n-alert>
      <n-form-item label="关闭原因">
        <n-input v-model:value="closeReason" type="textarea" placeholder="请输入关闭原因（如：客户主动取消、需求暂不支持等）" :autosize="{ minRows: 2 }" />
      </n-form-item>
    </n-modal>
  </div>
</template>

<script lang="ts" setup>
import { ref, computed, onMounted, h } from 'vue';
import { NButton, NTag, NSpace, NImage, useMessage } from 'naive-ui';
import { getRequestList, getRequestDetail, convertRequest, closeRequest } from '@/api/order/index';
import { getCategoryList } from '@/api/config/category';
import { getAdminList } from '@/api/system/adminList';

const message = useMessage();
const loading = ref(false);
const tableData = ref<any[]>([]);
const searchText = ref('');

const filterStatus = ref<number | null>(null);
const filterCategory = ref(null);

const statusMap: any = {
  0: { label: '待处理', type: 'warning' },
  1: { label: '已转单', type: 'success' },
  2: { label: '已关闭', type: 'error' },
};

const categoryOptions = ref<any[]>([]);
const categoryMap = ref<Record<number, string>>({});
const designerOptions = ref<any[]>([]);

// 统计
const stats = computed(() => {
  const all = tableData.value;
  return {
    pending: all.filter((r: any) => r.status === 0).length,
    converted: all.filter((r: any) => r.status === 1).length,
    closed: all.filter((r: any) => r.status === 2).length,
    total: all.length,
  };
});

const filteredData = computed(() => {
  let list = tableData.value;
  if (filterStatus.value !== null) {
    list = list.filter((r: any) => r.status === filterStatus.value);
  }
  if (searchText.value) {
    const kw = searchText.value.toLowerCase();
    list = list.filter((r: any) =>
      (r.description || '').toLowerCase().includes(kw) ||
      String(r.requestId).includes(kw)
    );
  }
  return list;
});

// 详情抽屉
const showDetail = ref(false);
const detailData = ref<any>(null);

const parsedCustomData = computed(() => {
  if (!detailData.value?.customData) return null;
  try { return JSON.parse(detailData.value.customData); }
  catch { return null; }
});

const parsedImages = computed(() => {
  if (!detailData.value?.imageUrls) return [];
  try {
    const imgs = JSON.parse(detailData.value.imageUrls);
    return Array.isArray(imgs) ? imgs : [];
  } catch { return []; }
});

// 转单
const showConvert = ref(false);
const convertForm = ref({
  designerId: null as number | null,
  totalAmount: null as number | null,
  prepayAmount: null as number | null,
  expectedDateTs: null as number | null,
  remark: '',
});

// 关闭
const showClose = ref(false);
const closeReason = ref('');

const getCategoryName = (id: number) => categoryMap.value[id] || `品类#${id}`;

const rowClassName = (row: any) => {
  if (row.status === 0) return 'row-pending';
  return '';
};

const columns = [
  { title: '#', key: 'requestId', width: 60, align: 'center' as const },
  {
    title: '品类',
    key: 'categoryId',
    width: 100,
    render(row: any) {
      return h('span', {}, getCategoryName(row.categoryId));
    }
  },
  {
    title: '客户',
    key: 'userId',
    width: 90,
    render(row: any) {
      return h('span', { style: { color: '#555' } }, row.userName || `用户#${row.userId}`);
    }
  },
  {
    title: '需求描述',
    key: 'description',
    ellipsis: { tooltip: true },
    render(row: any) {
      return h('span', { style: { color: row.description ? '#333' : '#bbb' } },
        row.description || '客户未填写描述');
    }
  },
  {
    title: '状态',
    key: 'status',
    width: 90,
    align: 'center' as const,
    render(row: any) {
      const s = statusMap[row.status];
      return s ? h(NTag, { type: s.type, size: 'small', round: true }, { default: () => s.label }) : '';
    }
  },
  {
    title: '提交时间',
    key: 'createTime',
    width: 160,
    render(row: any) {
      return h('span', { style: { color: '#999', fontSize: '12px' } }, row.createTime || '-');
    }
  },
  {
    title: '操作',
    key: 'actions',
    width: 120,
    align: 'center' as const,
    render(row: any) {
      return h(NSpace, { size: 4, justify: 'center' }, {
        default: () => [
          h(NButton, { size: 'tiny', type: 'primary', text: true, onClick: () => handleViewDetail(row) },
            { default: () => '详情' }),
          row.status === 0
            ? h(NButton, { size: 'tiny', type: 'success', text: true, onClick: () => handleQuickConvert(row) },
              { default: () => '转单' })
            : null,
        ].filter(Boolean)
      });
    }
  },
];

const filterByStatus = (status: number | null) => {
  filterStatus.value = status;
};

const loadData = async () => {
  loading.value = true;
  try {
    const params: any = {};
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
    categoryMap.value = Object.fromEntries(cats.map((c: any) => [c.categoryId, c.name]));
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

const handleQuickConvert = async (row: any) => {
  try {
    detailData.value = await getRequestDetail(row.requestId);
    showDetail.value = false;
    openConvert();
  } catch (e) { console.error(e); }
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
    message.success('转单成功！订单已创建');
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

<style scoped>
.request-page {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

/* 统计卡片 */
.stat-cards {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 12px;
}

.stat-card {
  background: #fff;
  border-radius: 10px;
  padding: 20px 24px;
  cursor: pointer;
  transition: all 0.2s;
  position: relative;
  overflow: hidden;
  box-shadow: 0 1px 4px rgba(0,0,0,0.04);
}

.stat-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 16px rgba(0,0,0,0.08);
}

.stat-number {
  font-size: 32px;
  font-weight: 700;
  line-height: 1.2;
  margin-bottom: 4px;
}

.stat-label {
  font-size: 13px;
  color: #888;
}

.stat-icon {
  position: absolute;
  top: 16px;
  right: 20px;
  font-size: 28px;
  opacity: 0.6;
}

.stat-pending .stat-number { color: #E5A84B; }
.stat-converted .stat-number { color: #5B8C5A; }
.stat-closed .stat-number { color: #D35D6E; }
.stat-total .stat-number { color: #4B7BEC; }

.stat-pending { border-bottom: 3px solid #E5A84B; }
.stat-converted { border-bottom: 3px solid #5B8C5A; }
.stat-closed { border-bottom: 3px solid #D35D6E; }
.stat-total { border-bottom: 3px solid #4B7BEC; }

/* 表格行样式 */
:deep(.row-pending) {
  background: #FFFBE6 !important;
}

/* 抽屉样式 */
.drawer-header {
  display: flex;
  align-items: center;
  gap: 12px;
}

.drawer-title {
  font-size: 16px;
  font-weight: 600;
}

.detail-section {
  margin-bottom: 24px;
}

.detail-section-title {
  font-size: 13px;
  font-weight: 600;
  color: #999;
  letter-spacing: 1px;
  text-transform: uppercase;
  margin-bottom: 12px;
  padding-bottom: 8px;
  border-bottom: 1px solid #f0f0f0;
}

.detail-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 12px;
}

.detail-item {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.detail-label {
  font-size: 12px;
  color: #999;
}

.detail-value {
  font-size: 14px;
  color: #333;
  font-weight: 500;
}

.detail-desc {
  font-size: 14px;
  color: #555;
  line-height: 1.6;
  background: #f9f9f9;
  padding: 12px 16px;
  border-radius: 6px;
}

/* 定制参数 */
.custom-params {
  background: #f9f9f9;
  border-radius: 6px;
  padding: 4px 0;
}

.param-row {
  display: flex;
  justify-content: space-between;
  padding: 8px 16px;
  border-bottom: 1px solid #f0f0f0;
}

.param-row:last-child {
  border-bottom: none;
}

.param-key {
  font-size: 13px;
  color: #888;
}

.param-value {
  font-size: 13px;
  color: #333;
  font-weight: 500;
}

/* 图片画廊 */
.image-gallery {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

/* 转单提示 */
.convert-hint {
  margin-bottom: 4px;
}
</style>
