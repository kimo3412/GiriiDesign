<template>
  <div class="request-page">
    <!-- 顶部统计卡片 -->
    <div class="stat-cards">
      <div class="stat-card-slot" :class="{ 'stat-card-slot--active': filterStatus === null }">
        <BusinessMetricCard
          label="全部"
          :value="stats.total"
          icon="📊"
          variant="primary"
          :clickable="true"
          @click="filterByStatus(null)"
        />
      </div>
      <div class="stat-card-slot" :class="{ 'stat-card-slot--active': filterStatus === 0 }">
        <BusinessMetricCard
          label="待处理"
          :value="stats.pending"
          icon="📩"
          variant="warning"
          :clickable="true"
          @click="filterByStatus(0)"
        />
      </div>
      <div class="stat-card-slot" :class="{ 'stat-card-slot--active': filterStatus === 1 }">
        <BusinessMetricCard
          label="已转单"
          :value="stats.converted"
          icon="✅"
          variant="success"
          :clickable="true"
          @click="filterByStatus(1)"
        />
      </div>
      <div class="stat-card-slot" :class="{ 'stat-card-slot--active': filterStatus === 2 }">
        <BusinessMetricCard
          label="已关闭"
          :value="stats.closed"
          icon="🚫"
          variant="error"
          :clickable="true"
          @click="filterByStatus(2)"
        />
      </div>
    </div>

    <!-- 筛选栏 -->
    <n-card :bordered="false" size="small">
      <n-space align="center" :size="12">
        <span style="font-weight: 600; font-size: 15px">意向池</span>
        <n-tag
          v-if="filterStatus !== null"
          closable
          @close="filterByStatus(null)"
          size="small"
          round
        >
          {{ statusMap[filterStatus]?.label }}
        </n-tag>
        <n-divider vertical />
        <n-select
          v-model:value="filterCategory"
          :options="categoryOptions"
          placeholder="品类"
          style="width: 130px"
          size="small"
          clearable
          @update:value="handleCategoryChange"
        />
        <n-input
          v-model:value="searchText"
          placeholder="搜索描述..."
          size="small"
          style="width: 160px"
          clearable
          @keyup.enter="loadData"
        />
        <n-button size="small" type="primary" @click="loadData">搜索</n-button>
      </n-space>
    </n-card>

    <!-- Master-Detail 主从布局 -->
    <n-card :bordered="false" class="master-detail-card">
      <div class="master-detail">
        <!-- 左侧：精简列表 -->
        <div class="master-list">
          <div v-if="loading && filteredData.length === 0" class="master-loading">
            <n-spin size="medium" />
          </div>
          <EmptyStateGuide
            v-else-if="filteredData.length === 0"
            icon="📭"
            title="暂无意向单"
            description="没有符合筛选条件的意向单"
            :action-label="undefined"
          />
          <div v-else class="master-list__items">
            <div
              v-for="row in filteredData"
              :key="row.requestId"
              class="master-item"
              :class="{
                'master-item--active': selectedId === row.requestId,
                'master-item--pending': row.status === 0,
              }"
              @click="handleSelect(row)"
            >
              <div class="master-item__header">
                <span class="master-item__id">#{{ row.requestId }}</span>
                <StatusBadge :status="row.status" size="small" round />
              </div>
              <div class="master-item__customer">
                {{ row.userName || `用户#${row.userId}` }}
              </div>
              <div class="master-item__footer">
                <span class="master-item__category">{{ getCategoryName(row.categoryId) }}</span>
                <span class="master-item__time">{{ row.createTime?.slice(5, 16) || '-' }}</span>
              </div>
            </div>
          </div>

          <!-- 分页 -->
          <div class="master-pagination">
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

        <!-- 右侧：详情面板 -->
        <div class="detail-panel">
          <EmptyStateGuide
            v-if="!selectedId"
            icon="👈"
            title="请选择一个意向"
            description="点击左侧列表查看详情"
          />
          <template v-else-if="detailData">
            <!-- 详情头部 -->
            <div class="detail-header">
              <div class="detail-header__left">
                <span class="detail-header__title">意向 #{{ detailData.requestId }}</span>
                <StatusBadge :status="detailData.status" round show-dot />
              </div>
              <n-space v-if="detailData?.status === 0" :size="8">
                <n-button size="small" type="error" ghost @click="openClose">关闭</n-button>
                <n-button size="small" type="primary" @click="openConvert">转为正式订单 →</n-button>
              </n-space>
            </div>

            <n-divider />

            <!-- 客户信息 -->
            <div class="detail-section">
              <div class="detail-section__title">客户信息</div>
              <div class="detail-grid">
                <div class="detail-item">
                  <span class="detail-item__label">客户</span>
                  <span class="detail-item__value">{{
                    detailData.userName || `用户#${detailData.userId}`
                  }}</span>
                </div>
                <div class="detail-item">
                  <span class="detail-item__label">品类</span>
                  <span class="detail-item__value">{{
                    getCategoryName(detailData.categoryId)
                  }}</span>
                </div>
                <div class="detail-item">
                  <span class="detail-item__label">提交时间</span>
                  <span class="detail-item__value">{{ detailData.createTime }}</span>
                </div>
              </div>
            </div>

            <!-- 客户描述 -->
            <div class="detail-section">
              <div class="detail-section__title">客户描述</div>
              <div class="detail-desc">{{ detailData.description || '客户未填写额外描述' }}</div>
            </div>

            <!-- 定制参数 -->
            <div class="detail-section">
              <div class="detail-section__title">定制参数</div>
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
              <div class="detail-section__title">参考图片</div>
              <div class="image-gallery">
                <n-image
                  v-for="(img, idx) in parsedImages"
                  :key="idx"
                  :src="img"
                  width="80"
                  height="80"
                  object-fit="cover"
                  style="border-radius: 6px"
                />
              </div>
            </div>
          </template>
          <div v-else class="detail-loading">
            <n-spin size="medium" />
          </div>
        </div>
      </div>
    </n-card>

    <!-- 转单弹窗 -->
    <n-modal
      v-model:show="showConvert"
      title="意向转正式订单"
      preset="dialog"
      positive-text="确认转单"
      negative-text="取消"
      @positive-click="handleConvert"
      style="width: 600px"
    >
      <div class="convert-hint">
        <n-alert type="info" :bordered="false">
          转单后将创建正式订单，并启动对应品类的工作流。客户可在小程序查看订单进度。
        </n-alert>
      </div>
      <n-form :model="convertForm" label-placement="left" label-width="80" style="margin-top: 16px">
        <n-form-item label="指派设计师">
          <n-select
            v-model:value="convertForm.designerId"
            :options="designerOptions"
            placeholder="选择负责的设计师"
          />
        </n-form-item>
        <n-form-item label="BOM模板" v-if="bomTemplateOptions.length > 0">
          <n-select
            v-model:value="convertForm.bomTemplateId"
            :options="bomTemplateOptions"
            placeholder="选择BOM模板（选填）"
            clearable
            @update:value="handleBomTemplateChange"
          />
        </n-form-item>
        <div v-if="bomPreviewItems.length > 0" class="bom-preview">
          <div class="bom-preview-title">物料明细预览</div>
          <n-data-table
            :columns="bomPreviewColumns"
            :data="bomPreviewItems"
            :bordered="false"
            size="tiny"
          />
          <div class="bom-cost-row">
            <span>物料成本合计：</span>
            <span class="bom-cost-value">¥{{ bomPreviewCost }}</span>
          </div>
        </div>
        <n-grid :cols="2" :x-gap="12">
          <n-gi>
            <n-form-item label="总金额">
              <n-input-number
                v-model:value="convertForm.totalAmount"
                :min="0"
                :precision="2"
                placeholder="¥ 报价"
                style="width: 100%"
              >
                <template #prefix>¥</template>
              </n-input-number>
            </n-form-item>
          </n-gi>
          <n-gi>
            <n-form-item label="预付款">
              <n-input-number
                v-model:value="convertForm.prepayAmount"
                :min="0"
                :precision="2"
                placeholder="¥ 预付"
                style="width: 100%"
              >
                <template #prefix>¥</template>
              </n-input-number>
            </n-form-item>
          </n-gi>
        </n-grid>
        <n-form-item label="交付日期">
          <n-date-picker
            v-model:value="convertForm.expectedDateTs"
            type="date"
            style="width: 100%"
          />
        </n-form-item>
        <n-form-item label="备注">
          <n-input
            v-model:value="convertForm.remark"
            type="textarea"
            placeholder="订单备注（选填）"
            :autosize="{ minRows: 2 }"
          />
        </n-form-item>
      </n-form>
    </n-modal>

    <!-- 关闭弹窗 -->
    <n-modal
      v-model:show="showClose"
      title="关闭意向"
      preset="dialog"
      positive-text="确认关闭"
      negative-text="取消"
      @positive-click="handleClose"
      style="width: 420px"
    >
      <n-alert type="warning" :bordered="false" style="margin-bottom: 12px">
        关闭后该意向将标记为已关闭，不可恢复。
      </n-alert>
      <n-form-item label="关闭原因">
        <n-input
          v-model:value="closeReason"
          type="textarea"
          placeholder="请输入关闭原因"
          :autosize="{ minRows: 2 }"
        />
      </n-form-item>
    </n-modal>
  </div>
</template>

<script lang="ts" setup>
  import { ref, computed, onMounted, h } from 'vue';
  import {
    NButton,
    NTag,
    NSpace,
    NImage,
    NDivider,
    NCard,
    NPagination,
    NGrid,
    NGi,
    NForm,
    NFormItem,
    NInput,
    NInputNumber,
    NDatePicker,
    NSelect,
    NAlert,
    NModal,
    NSpin,
    useMessage,
  } from 'naive-ui';
  import {
    getRequestList,
    getRequestDetail,
    convertRequest,
    closeRequest,
  } from '@/api/order/index';
  import { getCategoryList } from '@/api/config/category';
  import { getFieldList } from '@/api/config/field';
  import { getDesignersByCategory } from '@/api/system/adminList';
  import { getBomTemplateList, getBomTemplateDetail } from '@/api/supply/index';
  import { BusinessMetricCard, StatusBadge, EmptyStateGuide } from '@/components/Business';

  const message = useMessage();
  const loading = ref(false);
  const tableData = ref<any[]>([]);
  const total = ref(0);
  const pageNum = ref(1);
  const pageSize = ref(10);
  const searchText = ref('');
  const statsState = ref({
    pending: 0,
    converted: 0,
    closed: 0,
    total: 0,
  });

  const filterStatus = ref<number | null>(null);
  const filterCategory = ref(null);

  // Master-Detail
  const selectedId = ref<number | null>(null);
  const detailData = ref<any>(null);
  const fieldLabelMap = ref<Record<string, string>>({});

  const statusMap: any = {
    0: { label: '待处理', type: 'warning' },
    1: { label: '已转单', type: 'success' },
    2: { label: '已关闭', type: 'error' },
  };

  const categoryOptions = ref<any[]>([]);
  const categoryMap = ref<Record<number, string>>({});
  const designerOptions = ref<any[]>([]);

  const toArray = (value: any) => {
    if (Array.isArray(value)) return value;
    if (Array.isArray(value?.records)) return value.records;
    if (Array.isArray(value?.list)) return value.list;
    return [];
  };

  // 统计
  const stats = computed(() => statsState.value);

  const filteredData = computed(() => {
    let list = toArray(tableData.value);
    if (filterStatus.value !== null) {
      list = list.filter((r: any) => r.status === filterStatus.value);
    }
    if (searchText.value) {
      const kw = searchText.value.toLowerCase();
      list = list.filter(
        (r: any) =>
          (r.description || '').toLowerCase().includes(kw) || String(r.requestId).includes(kw)
      );
    }
    return list;
  });

  // 详情面板
  const parsedCustomData = computed(() => {
    if (!detailData.value?.customData) return null;
    try {
      const rawData = JSON.parse(detailData.value.customData);
      const result: Record<string, any> = {};
      for (const [key, value] of Object.entries(rawData)) {
        const label = fieldLabelMap.value[key] || key;
        result[label] = value;
      }
      return result;
    } catch {
      return null;
    }
  });

  const parsedImages = computed(() => {
    if (!detailData.value?.imageUrls) return [];
    try {
      const imgs = JSON.parse(detailData.value.imageUrls);
      return Array.isArray(imgs) ? imgs : [];
    } catch {
      return [];
    }
  });

  // 转单
  const showConvert = ref(false);
  const convertForm = ref({
    designerId: null as number | null,
    totalAmount: null as number | null,
    prepayAmount: null as number | null,
    expectedDateTs: null as number | null,
    remark: '',
    bomTemplateId: null as number | null,
  });

  const bomTemplateOptions = ref<any[]>([]);
  const bomPreviewItems = ref<any[]>([]);
  const bomPreviewCost = ref('0.00');
  const bomPreviewColumns = [
    { title: '物料', key: 'name', width: 120 },
    { title: 'SKU', key: 'sku', width: 90 },
    { title: '用量', key: 'quantity', width: 70, align: 'center' as const },
    {
      title: '单价',
      key: 'unitPrice',
      width: 80,
      align: 'right' as const,
      render: (row: any) => `¥${row.unitPrice}`,
    },
    {
      title: '小计',
      key: 'subtotal',
      width: 80,
      align: 'right' as const,
      render: (row: any) => `¥${row.subtotal}`,
    },
  ];

  // 关闭
  const showClose = ref(false);
  const closeReason = ref('');

  const getCategoryName = (id: number) => categoryMap.value[id] || `品类#${id}`;

  const filterByStatus = (status: number | null) => {
    filterStatus.value = status;
    pageNum.value = 1;
    selectedId.value = null;
    detailData.value = null;
    loadData();
  };

  const handleCategoryChange = async () => {
    pageNum.value = 1;
    selectedId.value = null;
    detailData.value = null;
    await loadStats();
    loadData();
  };

  const loadStats = async () => {
    try {
      const baseParams: any = { pageNum: 1, pageSize: 1 };
      if (filterCategory.value != null) baseParams.categoryId = filterCategory.value;

      const [allRes, pendingRes, convertedRes, closedRes] = await Promise.all([
        getRequestList(baseParams),
        getRequestList({ ...baseParams, status: 0 }),
        getRequestList({ ...baseParams, status: 1 }),
        getRequestList({ ...baseParams, status: 2 }),
      ]);

      statsState.value = {
        total: Number(allRes?.total || 0),
        pending: Number(pendingRes?.total || 0),
        converted: Number(convertedRes?.total || 0),
        closed: Number(closedRes?.total || 0),
      };
    } catch (e) {
      console.error(e);
    }
  };

  const loadData = async () => {
    loading.value = true;
    try {
      const params: any = { pageNum: pageNum.value, pageSize: pageSize.value };
      if (filterCategory.value != null) params.categoryId = filterCategory.value;
      if (filterStatus.value !== null) params.status = filterStatus.value;
      const res = await getRequestList(params);
      tableData.value = toArray(res);
      total.value = res?.total || 0;
    } catch (e) {
      console.error(e);
    } finally {
      loading.value = false;
    }
  };

  const handleSelect = async (row: any) => {
    selectedId.value = row.requestId;
    detailData.value = null;
    try {
      detailData.value = await getRequestDetail(row.requestId);
      if (detailData.value?.categoryId) {
        try {
          const fields = toArray(await getFieldList(detailData.value.categoryId));
          fieldLabelMap.value = Object.fromEntries(
            (fields || []).map((f: any) => [f.fieldKey, f.label])
          );
        } catch (e) {
          /* ignore field load error */
        }
      }
    } catch (e) {
      console.error(e);
    }
  };

  const openConvert = async () => {
    convertForm.value = {
      designerId: null,
      totalAmount: null,
      prepayAmount: null,
      expectedDateTs: null,
      remark: '',
      bomTemplateId: null,
    };
    bomPreviewItems.value = [];
    bomPreviewCost.value = '0.00';
    bomTemplateOptions.value = [];
    if (detailData.value?.categoryId) {
      try {
        const designers = toArray(await getDesignersByCategory(detailData.value.categoryId));
        designerOptions.value = designers.map((d: any) => ({
          label: d.nickname || d.username,
          value: d.adminId,
        }));
      } catch (e) {
        designerOptions.value = [];
      }
      try {
        const templates = toArray(
          await getBomTemplateList({ categoryId: detailData.value.categoryId })
        );
        bomTemplateOptions.value = templates.map((t: any) => ({
          label: t.name,
          value: t.templateId,
        }));
      } catch (e) {
        bomTemplateOptions.value = [];
      }
    } else {
      designerOptions.value = [];
    }
    showConvert.value = true;
  };

  const handleBomTemplateChange = async (templateId: number | null) => {
    convertForm.value.bomTemplateId = templateId;
    if (!templateId) {
      bomPreviewItems.value = [];
      bomPreviewCost.value = '0.00';
      return;
    }
    try {
      const detail = await getBomTemplateDetail(templateId);
      const items = (detail?.items || []).map((item: any) => ({
        name: item.materialName || item.materialId,
        sku: item.materialSku || '-',
        quantity: item.quantity,
        unitPrice: item.unitPrice ?? 0,
        subtotal: ((item.quantity || 0) * (item.unitPrice || 0)).toFixed(2),
      }));
      bomPreviewItems.value = items;
      const total = items.reduce((sum: number, i: any) => sum + parseFloat(i.subtotal), 0);
      bomPreviewCost.value = total.toFixed(2);
    } catch (e) {
      bomPreviewItems.value = [];
    }
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
        bomTemplateId: convertForm.value.bomTemplateId,
      });
      message.success('转单成功！订单已创建');
      showConvert.value = false;
      detailData.value = null;
      selectedId.value = null;
      await loadStats();
      loadData();
    } catch (e) {
      console.error(e);
    }
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
      detailData.value = null;
      selectedId.value = null;
      await loadStats();
      loadData();
    } catch (e) {
      console.error(e);
    }
  };

  onMounted(async () => {
    await loadStats();
    loadData();
    try {
      const cats = toArray(await getCategoryList());
      categoryOptions.value = cats.map((c: any) => ({ label: c.name, value: c.categoryId }));
      categoryMap.value = Object.fromEntries(cats.map((c: any) => [c.categoryId, c.name]));
    } catch (e) {
      console.error(e);
    }
  });
</script>

<style scoped>
  .request-page {
    display: flex;
    flex-direction: column;
    gap: 12px;
  }

  /* 统计卡片区 */
  .stat-cards {
    display: flex;
    flex-wrap: wrap;
    gap: 10px;
  }

  .stat-card-slot {
    flex: 0 1 180px;
    border-radius: 16px;
    transition: box-shadow 0.2s ease, transform 0.2s ease;
  }

  .stat-card-slot :deep(.metric-card) {
    flex: 0 1 180px;
  }

  .stat-card-slot--active {
    box-shadow: 0 0 0 2px rgba(72, 115, 255, 0.14);
  }

  /* Master-Detail 主容器 */
  .master-detail-card :deep(.n-card__content) {
    padding: 0;
  }

  .master-detail {
    display: flex;
    height: calc(100vh - 320px);
    min-height: 400px;
  }

  /* 左侧列表 */
  .master-list {
    width: 340px;
    flex-shrink: 0;
    border-right: 1px solid var(--border-light);
    display: flex;
    flex-direction: column;
    overflow: hidden;
  }

  .master-list__items {
    flex: 1;
    overflow-y: auto;
  }

  .master-item {
    padding: 14px 16px;
    border-bottom: 1px solid var(--border-light);
    cursor: pointer;
    transition: background 0.15s;
    position: relative;
  }

  .master-item:hover {
    background: var(--row-selected-bg);
  }

  .master-item--active {
    background: var(--row-selected-bg);
    border-left: 3px solid var(--primary-color);
  }

  .master-item--pending {
    background: var(--row-pending-bg);
  }

  .master-item--pending.master-item--active {
    background: var(--row-pending-bg);
  }

  .master-item__header {
    display: flex;
    align-items: flex-start;
    justify-content: space-between;
    gap: 12px;
    margin-bottom: 6px;
  }

  .master-item__id {
    font-size: 14px;
    font-weight: 600;
    color: var(--text-primary);
    min-width: 0;
  }

  .master-item__customer {
    font-size: 13px;
    color: var(--text-secondary);
    margin-bottom: 6px;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
  }

  .master-item__footer {
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 12px;
    font-size: 12px;
    color: var(--text-tertiary);
  }

  .master-item__category,
  .master-item__time {
    min-width: 0;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
  }

  .master-pagination {
    padding: 10px 12px;
    border-top: 1px solid var(--border-light);
    display: flex;
    justify-content: flex-end;
  }

  .master-loading,
  .detail-loading {
    display: flex;
    align-items: center;
    justify-content: center;
    height: 100%;
  }

  /* 右侧详情面板 */
  .detail-panel {
    flex: 1;
    padding: 20px 24px;
    overflow-y: auto;
  }

  .detail-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
  }

  .detail-header__left {
    display: flex;
    align-items: center;
    gap: 12px;
  }

  .detail-header__title {
    font-size: 18px;
    font-weight: 700;
    color: var(--text-primary);
  }

  .detail-section {
    margin-bottom: 24px;
  }

  .detail-section__title {
    font-size: 12px;
    font-weight: 600;
    color: var(--text-tertiary);
    letter-spacing: 0.5px;
    text-transform: uppercase;
    margin-bottom: 10px;
    padding-bottom: 8px;
    border-bottom: 1px solid var(--border-light);
  }

  .detail-grid {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 12px;
  }

  .detail-item {
    display: flex;
    flex-direction: column;
    gap: 3px;
  }

  .detail-item__label {
    font-size: 12px;
    color: var(--text-tertiary);
  }

  .detail-item__value {
    font-size: 14px;
    color: var(--text-primary);
    font-weight: 500;
  }

  .detail-desc {
    font-size: 14px;
    color: var(--text-secondary);
    line-height: 1.6;
    background: var(--page-bg);
    padding: 12px 16px;
    border-radius: 6px;
  }

  .custom-params {
    background: var(--page-bg);
    border-radius: 6px;
    overflow: hidden;
  }

  .param-row {
    display: flex;
    justify-content: space-between;
    padding: 8px 16px;
    border-bottom: 1px solid var(--border-light);
  }

  .param-row:last-child {
    border-bottom: none;
  }

  .param-key {
    font-size: 13px;
    color: var(--text-tertiary);
  }

  .param-value {
    font-size: 13px;
    color: var(--text-primary);
    font-weight: 500;
  }

  .image-gallery {
    display: flex;
    flex-wrap: wrap;
    gap: 8px;
  }

  /* 转单提示 */
  .convert-hint {
    margin-bottom: 4px;
  }

  /* BOM预览 */
  .bom-preview {
    background: var(--page-bg);
    border-radius: 6px;
    padding: 10px 12px;
    margin-bottom: 12px;
  }

  .bom-preview-title {
    font-size: 13px;
    font-weight: 600;
    color: var(--text-secondary);
    margin-bottom: 8px;
  }

  .bom-cost-row {
    display: flex;
    justify-content: flex-end;
    align-items: center;
    gap: 8px;
    padding-top: 8px;
    font-size: 13px;
    color: var(--text-secondary);
  }

  .bom-cost-value {
    font-weight: 700;
    font-size: 15px;
    color: var(--money-color);
  }
</style>
