<template>
  <div class="kanban-page">
    <div class="page-head">
      <div class="page-head__title">
        <div class="page-head__eyebrow">生产订单看板</div>
        <div class="page-head__main">
          <h2>订单看板</h2>
          <span class="page-head__count">共 {{ totalOrders }} 单</span>
        </div>
      </div>
      <div class="page-head__actions">
        <span v-if="activeStep !== null" class="active-pill active-pill--step"
          >当前节点：{{ activeStepName }}</span
        >
        <span v-if="activeCategory !== null" class="active-pill active-pill--category"
          >品类：{{ getCategoryName(activeCategory) }}</span
        >
      </div>
    </div>

    <div class="overview-bar">
      <template v-if="isSingleCategory">
        <button
          v-for="(col, idx) in columns"
          :key="col.stepId"
          class="overview-item"
          :class="{ active: activeStep === col.stepId }"
          type="button"
          @click="switchStep(col.stepId)"
        >
          <div class="overview-topline">
            <div class="overview-count" :style="{ color: stepColors[idx % stepColors.length] }">
              {{ Number(col.total ?? col.orders.length) }}
            </div>
            <div class="overview-name">{{ col.stepName }}</div>
          </div>
          <div
            class="overview-bar-indicator"
            :style="{
              background:
                activeStep === col.stepId ? stepColors[idx % stepColors.length] : 'transparent',
            }"
          ></div>
        </button>
      </template>

      <template v-else>
        <button
          v-for="(count, catId, idx) in categoryOrderCounts"
          :key="catId"
          class="overview-item"
          :class="{ active: activeCategory === Number(catId) }"
          type="button"
          @click="filterByCategory(Number(catId))"
        >
          <div class="overview-topline">
            <div class="overview-count" :style="{ color: stepColors[idx % stepColors.length] }">
              {{ count }}
            </div>
            <div class="overview-name">{{ getCategoryName(Number(catId)) }}</div>
          </div>
          <div
            class="overview-bar-indicator"
            :style="{
              background:
                activeCategory === Number(catId)
                  ? stepColors[idx % stepColors.length]
                  : 'transparent',
            }"
          ></div>
        </button>
      </template>

      <button
        class="overview-item overview-total"
        :class="{ active: activeStep === null && activeCategory === null }"
        type="button"
        @click="clearAllFilter"
      >
        <div class="overview-topline">
          <div class="overview-count">{{ totalOrders }}</div>
          <div class="overview-name">全部</div>
        </div>
        <div
          class="overview-bar-indicator"
          :style="{
            background: activeStep === null && activeCategory === null ? '#334155' : 'transparent',
          }"
        ></div>
      </button>
    </div>

    <div class="filter-bar">
      <n-space align="center" :size="12" wrap>
        <n-select
          v-model:value="filterCategory"
          :options="categoryOptions"
          placeholder="全部品类"
          style="width: 160px"
          size="small"
          clearable
          @update:value="loadData"
        />
        <n-input
          v-model:value="searchText"
          placeholder="搜索订单号 / 客户 / 设计师"
          size="small"
          style="width: 260px"
          clearable
          @keydown.enter="loadData"
        >
          <template #prefix>🔍</template>
        </n-input>
      </n-space>

      <n-space align="center" :size="8" wrap>
        <n-tag v-if="activeStep !== null" closable @close="switchStep(null)" size="small"
          >当前：{{ activeStepName }}</n-tag
        >
        <n-tag v-if="activeCategory !== null" closable @close="clearCategoryFilter" size="small">
          品类：{{ getCategoryName(activeCategory) }}
        </n-tag>
        <n-button size="small" quaternary @click="loadData">刷新</n-button>
      </n-space>
    </div>

    <n-spin :show="loading">
      <div v-if="!loading && groupedOrders.length === 0" class="empty-state">
        <div class="empty-icon">📋</div>
        <div class="empty-text">暂无订单</div>
      </div>

      <div v-else class="group-list">
        <section v-for="group in groupedOrders" :key="group.stepId" class="order-group">
          <button class="group-head" type="button" @click="toggleGroup(group.stepId)">
            <div class="group-head__main">
              <span class="group-head__accent" :style="{ background: group.color }"></span>
              <div class="group-head__title">
                <strong>{{ group.stepName }}</strong>
              <span>{{ group.total }} 单</span>
              </div>
            </div>
            <div class="group-head__meta">
              <span class="group-head__hint">{{
                expandedGroupIds.includes(group.stepId) ? '收起' : '展开'
              }}</span>
              <span
                class="group-head__arrow"
                :class="{ 'is-open': expandedGroupIds.includes(group.stepId) }"
                >⌄</span
              >
            </div>
          </button>

          <div v-if="expandedGroupIds.includes(group.stepId)" class="group-body">
            <div
              v-for="order in group.pagedOrders"
              :key="order.orderId"
              class="order-row"
              :class="{ 'is-blocked': order.isBlocked === 1 }"
              @click="goDetail(order.orderId)"
            >
              <div class="row-main">
                <div class="row-top">
                  <span class="order-sn">{{ order.orderSn }}</span>
                  <n-tag v-if="order.isBlocked === 1" type="error" size="tiny" round>阻塞</n-tag>
                  <span
                    v-if="order.expectedDate"
                    class="date-pill"
                    :class="{ overdue: isOverdue(order.expectedDate) }"
                  >
                    {{ formatDate(order.expectedDate) }}
                  </span>
                </div>

                <div class="row-meta">
                  <span class="meta-item">
                    <span class="meta-label">客户</span>
                    <span class="meta-value">{{ getCustomerLabel(order) }}</span>
                  </span>
                  <span class="meta-item">
                    <span class="meta-label">设计师</span>
                    <span class="meta-value">{{ getDesignerLabel(order) }}</span>
                  </span>
                  <span class="meta-item">
                    <span class="meta-label">品类</span>
                    <span class="meta-value">{{ getCategoryName(order.categoryId) }}</span>
                  </span>
                  <span v-if="order.totalAmount" class="meta-item">
                    <span class="meta-label">金额</span>
                    <span class="meta-value amount"
                      >¥{{ Number(order.totalAmount).toLocaleString() }}</span
                    >
                  </span>
                  <span class="meta-item">
                    <span class="meta-label">创建</span>
                    <span class="meta-value">{{ formatRelativeTime(order.createTime) }}</span>
                  </span>
                </div>
              </div>

              <div class="row-side">
                <div class="mini-progress">
                  <template v-for="(step, sIdx) in order._steps" :key="step.stepId">
                    <span
                      class="mini-progress__dot"
                      :class="{ current: sIdx === order._stepIdx, done: sIdx < order._stepIdx }"
                      :style="sIdx <= order._stepIdx ? { background: group.color } : {}"
                    ></span>
                  </template>
                </div>
                <div class="row-side__text"
                  >进度 {{ order._stepIdx + 1 }}/{{ order._steps.length || 1 }}</div
                >
              </div>
            </div>

            <div v-if="group.totalPages > 1" class="group-pagination">
              <n-button
                size="small"
                quaternary
                :disabled="group.currentPage <= 1"
                @click="setGroupPage(group.stepId, group.currentPage - 1)"
              >
                上一页
              </n-button>
              <span class="group-pagination__page">
                {{ group.currentPage }} / {{ group.totalPages }}
              </span>
              <n-button
                size="small"
                quaternary
                :disabled="group.currentPage >= group.totalPages"
                @click="setGroupPage(group.stepId, group.currentPage + 1)"
              >
                下一页
              </n-button>
              <span class="group-pagination__total">共 {{ group.total }} 单</span>
            </div>
          </div>
        </section>
      </div>
    </n-spin>
  </div>
</template>

<script lang="ts" setup>
  import { computed, onMounted, ref, watch } from 'vue';
  import { useRouter } from 'vue-router';
  import { getCategoryList } from '@/api/config/category';
  import { getWorkflow } from '@/api/config/workflow';
  import { getKanbanData } from '@/api/order/index';

  const router = useRouter();
  const loading = ref(false);
  const filterCategory = ref<number | null>(null);
  const searchText = ref('');
  const activeStep = ref<number | null>(null);
  const activeCategory = ref<number | null>(null);
  const expandedGroupIds = ref<number[]>([]);
  const groupPages = ref<Record<number, number>>({});
  const groupPageSize = 8;
  const categoryOptions = ref<any[]>([]);
  const categoryMap = ref<Record<number, string>>({});
  const columns = ref<any[]>([]);
  const workflowStepsMap = ref<Record<number, any[]>>({});
  let searchTimer: ReturnType<typeof setTimeout> | null = null;

  const stepColors = ['#5B8C5A', '#4B7BEC', '#E5A84B', '#D35D6E', '#6C5CE7', '#00B894', '#E17055'];

  const getStepColor = (idx: number) => stepColors[idx % stepColors.length];
  const getCategoryName = (id: number) => categoryMap.value[id] || `品类#${id}`;
  const getCustomerLabel = (order: any) =>
    order.customerName || (order.userId ? `客户#${order.userId}` : '-');
  const getDesignerLabel = (order: any) =>
    order.designerName || (order.designerId ? `设计师#${order.designerId}` : '-');

  const stepCategoryLookup = computed(() => {
    const map: Record<number, number> = {};
    Object.entries(workflowStepsMap.value).forEach(([catId, steps]) => {
      steps.forEach((step: any) => {
        map[step.stepId] = Number(catId);
      });
    });
    return map;
  });

  const categoryColumnsMap = computed(() => {
    const map: Record<number, any[]> = {};
    columns.value.forEach((col) => {
        const catId = col.categoryId || stepCategoryLookup.value[col.stepId];
      if (!catId) return;
      if (!map[catId]) map[catId] = [];
      map[catId].push(col);
    });
    return map;
  });

  const isSingleCategory = computed(() => Object.keys(categoryColumnsMap.value).length <= 1);

  const categoryOrderCounts = computed(() => {
    const counts: Record<number, number> = {};
    columns.value.forEach((col) => {
      const catId = col.categoryId || stepCategoryLookup.value[col.stepId];
      if (catId) counts[catId] = (counts[catId] || 0) + Number(col.total ?? col.orders.length);
    });
    return counts;
  });

  const totalOrders = computed(() =>
    columns.value.reduce((sum, col) => sum + Number(col.total ?? col.orders?.length ?? 0), 0)
  );

  const activeStepName = computed(() => {
    const col = columns.value.find((item) => item.stepId === activeStep.value);
    return col?.stepName || '';
  });

  const allOrders = computed(() => {
    const result: any[] = [];
    columns.value.forEach((col) => {
      (col.orders || []).forEach((order: any) => {
        const steps = workflowStepsMap.value[order.categoryId] || [];
        const stepIdx = steps.findIndex((step: any) => step.stepId === col.stepId);
        result.push({
          ...order,
          _stepId: col.stepId,
          _stepName: col.stepName,
          _stepIdx: col.stepId === 0 ? -1 : stepIdx >= 0 ? stepIdx : 0,
          _steps: steps,
        });
      });
    });
    return result;
  });

  const filteredOrders = computed(() => {
    let list = allOrders.value;
    if (activeStep.value !== null) list = list.filter((item) => item._stepId === activeStep.value);
    if (activeCategory.value !== null)
      list = list.filter((item) => item.categoryId === activeCategory.value);
    return list;
  });

  const groupedOrders = computed(() => {
    const groups = new Map<
      number,
      { stepId: number; stepName: string; stepIdx: number; color: string; orders: any[] }
    >();
    filteredOrders.value.forEach((order) => {
      if (!groups.has(order._stepId)) {
        groups.set(order._stepId, {
          stepId: order._stepId,
          stepName: order._stepName,
          stepIdx: order._stepIdx,
          color: getStepColor(order._stepIdx),
          orders: [],
        });
      }
      groups.get(order._stepId)!.orders.push(order);
    });
    return Array.from(groups.values())
      .sort((a, b) => a.stepIdx - b.stepIdx)
      .map((group) => {
        const sourceCol = columns.value.find((col) => col.stepId === group.stepId);
        const total = Number(sourceCol?.total ?? group.orders.length);
        const totalPages = Math.max(1, Number(sourceCol?.totalPages ?? Math.ceil(total / groupPageSize)));
        const currentPage = Math.min(groupPages.value[group.stepId] || Number(sourceCol?.pageNum ?? 1), totalPages);
        return {
          ...group,
          total,
          currentPage,
          totalPages,
          pagedOrders: group.orders,
        };
      });
  });

  function syncExpandedGroups() {
    const available = groupedOrders.value.map((group) => group.stepId);
    if (available.length === 0) {
      expandedGroupIds.value = [];
      return;
    }
    if (activeStep.value !== null && available.includes(activeStep.value)) {
      expandedGroupIds.value = [activeStep.value];
      return;
    }
    const preserved = expandedGroupIds.value.filter((id) => available.includes(id));
    expandedGroupIds.value = preserved.length ? preserved : [available[0]];
  }

  const setGroupPage = async (stepId: number, page: number) => {
    groupPages.value = { ...groupPages.value, [stepId]: page };
    await loadGroupPage(stepId, page);
  };

  const resetGroupPages = () => {
    groupPages.value = {};
  };

  const switchStep = (stepId: number | null) => {
    activeStep.value = activeStep.value === stepId ? null : stepId;
    resetGroupPages();
    syncExpandedGroups();
  };

  const filterByCategory = (catId: number) => {
    activeCategory.value = activeCategory.value === catId ? null : catId;
    activeStep.value = null;
    resetGroupPages();
    syncExpandedGroups();
  };

  const clearCategoryFilter = () => {
    activeCategory.value = null;
    resetGroupPages();
    syncExpandedGroups();
  };

  const clearAllFilter = () => {
    activeStep.value = null;
    activeCategory.value = null;
    resetGroupPages();
    syncExpandedGroups();
  };

  const toggleGroup = (stepId: number) => {
    expandedGroupIds.value = expandedGroupIds.value.includes(stepId)
      ? expandedGroupIds.value.filter((id) => id !== stepId)
      : [stepId];
  };

  const isOverdue = (dateStr: string) => {
    if (!dateStr) return false;
    return new Date(dateStr) < new Date();
  };

  const formatDate = (dateStr: string) => {
    if (!dateStr) return '-';
    const date = new Date(dateStr);
    return `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}-${String(
      date.getDate()
    ).padStart(2, '0')}`;
  };

  const formatRelativeTime = (timeStr: string) => {
    if (!timeStr) return '';
    const diff = Date.now() - new Date(timeStr).getTime();
    const days = Math.floor(diff / 86400000);
    if (days > 30) return `${Math.floor(days / 30)}个月前`;
    if (days > 0) return `${days}天前`;
    const hours = Math.floor(diff / 3600000);
    if (hours > 0) return `${hours}小时前`;
    return '刚刚';
  };

  watch(
    () => groupedOrders.value.map((group) => group.stepId).join(','),
    () => syncExpandedGroups()
  );

  watch(searchText, () => {
    if (searchTimer) clearTimeout(searchTimer);
    searchTimer = setTimeout(() => {
      loadData();
    }, 350);
  });

  onMounted(async () => {
    try {
      const categories = await getCategoryList();
      categoryOptions.value = categories.map((item: any) => ({
        label: item.name,
        value: item.categoryId,
      }));
      categoryMap.value = Object.fromEntries(
        categories.map((item: any) => [item.categoryId, item.name])
      );

      const stepsMap: Record<number, any[]> = {};
      await Promise.all(
        categories.map(async (item: any) => {
          try {
            const workflow = await getWorkflow(item.categoryId);
            if (workflow.steps?.length) stepsMap[item.categoryId] = workflow.steps;
          } catch (error) {
            console.error(error);
          }
        })
      );
      workflowStepsMap.value = stepsMap;
    } catch (error) {
      console.error(error);
    }

    loadData();
  });

  const loadData = async () => {
    loading.value = true;
    activeStep.value = null;
    activeCategory.value = null;
    resetGroupPages();
    try {
      const params: any = { pageNum: 1, pageSize: groupPageSize };
      if (filterCategory.value != null) params.categoryId = filterCategory.value;
      if (searchText.value.trim()) params.keyword = searchText.value.trim();
      const res: any = await getKanbanData(params);
      columns.value = Array.isArray(res) ? res : res?.records || [];
      syncExpandedGroups();
    } catch (error) {
      console.error(error);
    } finally {
      loading.value = false;
    }
  };

  const loadGroupPage = async (stepId: number, page: number) => {
    try {
      const params: any = { stepId, pageNum: page, pageSize: groupPageSize };
      if (filterCategory.value != null) params.categoryId = filterCategory.value;
      if (searchText.value.trim()) params.keyword = searchText.value.trim();
      const res: any = await getKanbanData(params);
      const nextColumns = Array.isArray(res) ? res : res?.records || [];
      const nextColumn = nextColumns[0];
      if (!nextColumn) return;
      columns.value = columns.value.map((column) =>
        column.stepId === stepId ? { ...column, ...nextColumn } : column
      );
    } catch (error) {
      console.error(error);
    }
  };

  const goDetail = (orderId: number) => {
    router.push(`/order/detail/${orderId}`);
  };
</script>

<style scoped>
  .kanban-page {
    display: flex;
    flex-direction: column;
    gap: 12px;
  }

  .page-head {
    display: flex;
    justify-content: space-between;
    align-items: flex-end;
    gap: 12px;
  }

  .page-head__eyebrow {
    font-size: 12px;
    color: var(--text-tertiary);
  }

  .page-head__main {
    display: flex;
    align-items: baseline;
    gap: 10px;
  }

  .page-head__main h2 {
    margin: 0;
    font-size: 24px;
    line-height: 1.1;
    color: var(--text-primary);
  }

  .page-head__count {
    font-size: 13px;
    color: var(--text-tertiary);
  }

  .page-head__actions {
    display: flex;
    flex-wrap: wrap;
    justify-content: flex-end;
    gap: 8px;
  }

  .active-pill {
    padding: 6px 10px;
    border-radius: 999px;
    font-size: 12px;
    font-weight: 600;
    border: 1px solid var(--border-light);
    background: rgba(255, 255, 255, 0.82);
  }

  .active-pill--step {
    color: #4b7bec;
  }

  .active-pill--category {
    color: #5b8c5a;
  }

  .overview-bar {
    display: flex;
    gap: 8px;
    overflow-x: auto;
  }

  .overview-item {
    flex: 0 0 auto;
    min-width: 124px;
    padding: 10px 12px;
    border: 1px solid var(--border-light);
    border-radius: 14px;
    background: rgba(255, 255, 255, 0.84);
    position: relative;
    cursor: pointer;
    transition: all 0.2s ease;
  }

  .overview-item:hover {
    background: #fff;
    border-color: rgba(75, 123, 236, 0.16);
  }

  .overview-item.active {
    background: rgba(255, 255, 255, 0.96);
    border-color: rgba(75, 123, 236, 0.22);
  }

  .overview-topline {
    display: flex;
    align-items: baseline;
    gap: 8px;
  }

  .overview-count {
    font-size: 20px;
    font-weight: 700;
    line-height: 1.2;
  }

  .overview-name {
    font-size: 13px;
    color: #5c6370;
    font-weight: 600;
  }

  .overview-bar-indicator {
    position: absolute;
    left: 12px;
    right: 12px;
    bottom: -1px;
    height: 3px;
    border-radius: 2px;
    transition: background 0.2s ease;
  }

  .overview-total .overview-count {
    color: #334155;
    font-size: 18px;
  }

  .filter-bar {
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 12px;
    padding: 10px 14px;
    border: 1px solid var(--border-light);
    border-radius: 14px;
    background: rgba(255, 255, 255, 0.88);
  }

  .empty-state {
    text-align: center;
    padding: 80px 0;
  }

  .empty-icon {
    font-size: 40px;
    margin-bottom: 12px;
  }

  .empty-text {
    font-size: 14px;
    color: #999;
  }

  .group-list {
    display: flex;
    flex-direction: column;
    gap: 10px;
  }

  .order-group {
    border: 1px solid var(--border-light);
    border-radius: 16px;
    background: rgba(255, 255, 255, 0.92);
    overflow: hidden;
  }

  .group-head {
    width: 100%;
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 12px;
    padding: 12px 14px;
    border: 0;
    background: rgba(248, 250, 252, 0.88);
    cursor: pointer;
  }

  .group-head__main {
    display: flex;
    align-items: center;
    gap: 10px;
    min-width: 0;
  }

  .group-head__accent {
    width: 4px;
    height: 20px;
    border-radius: 999px;
    flex-shrink: 0;
  }

  .group-head__title {
    display: flex;
    align-items: baseline;
    gap: 8px;
  }

  .group-head__title strong {
    font-size: 14px;
    color: #1f2937;
  }

  .group-head__title span,
  .group-head__hint {
    font-size: 12px;
    color: #8a94a6;
  }

  .group-head__meta {
    display: flex;
    align-items: center;
    gap: 6px;
  }

  .group-head__arrow {
    font-size: 14px;
    color: #8a94a6;
    transition: transform 0.2s ease;
  }

  .group-head__arrow.is-open {
    transform: rotate(180deg);
  }

  .group-body {
    display: flex;
    flex-direction: column;
  }

  .group-pagination {
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 8px;
    padding: 10px 14px;
    border-top: 1px solid rgba(226, 232, 240, 0.82);
    background: rgba(248, 250, 252, 0.72);
    flex-wrap: wrap;
  }

  .group-pagination__page {
    min-width: 64px;
    text-align: center;
    color: #64748b;
    font-size: 13px;
    font-weight: 600;
    white-space: nowrap;
  }

  .group-pagination__total {
    flex-shrink: 0;
    font-size: 12px;
    color: #8a94a6;
    white-space: nowrap;
  }

  .order-row {
    display: flex;
    align-items: center;
    gap: 14px;
    padding: 12px 14px;
    border-top: 1px solid rgba(226, 232, 240, 0.82);
    cursor: pointer;
    transition: background 0.2s ease;
  }

  .order-row:hover {
    background: rgba(248, 250, 252, 0.92);
  }

  .order-row.is-blocked {
    background: rgba(255, 250, 250, 0.96);
  }

  .row-main {
    flex: 1;
    min-width: 0;
  }

  .row-top {
    display: flex;
    align-items: center;
    gap: 8px;
    flex-wrap: wrap;
    margin-bottom: 8px;
  }

  .order-sn {
    font-weight: 700;
    font-size: 14px;
    color: #16213e;
    font-family: 'Monaco', 'Consolas', monospace;
  }

  .date-pill {
    padding: 2px 8px;
    border-radius: 999px;
    background: rgba(238, 242, 247, 0.95);
    color: #64748b;
    font-size: 11px;
    font-weight: 600;
  }

  .date-pill.overdue {
    background: rgba(254, 226, 226, 0.95);
    color: #d92d20;
  }

  .row-meta {
    display: flex;
    gap: 8px;
    flex-wrap: wrap;
  }

  .meta-item {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    padding: 3px 8px;
    border-radius: 999px;
    background: rgba(245, 247, 250, 0.9);
    font-size: 12px;
  }

  .meta-label {
    color: #8a94a6;
  }

  .meta-value {
    color: #475467;
    font-weight: 600;
  }

  .meta-value.amount {
    color: #0f172a;
  }

  .row-side {
    flex-shrink: 0;
    min-width: 120px;
    display: flex;
    flex-direction: column;
    align-items: flex-end;
    gap: 6px;
  }

  .mini-progress {
    display: flex;
    align-items: center;
    gap: 4px;
  }

  .mini-progress__dot {
    width: 8px;
    height: 8px;
    border-radius: 50%;
    background: #dbe2ea;
  }

  .mini-progress__dot.current {
    width: 10px;
    height: 10px;
  }

  .row-side__text {
    font-size: 11px;
    color: #8a94a6;
    text-align: right;
  }

  @media (max-width: 1280px) {
    .order-row {
      flex-wrap: wrap;
      align-items: flex-start;
    }

    .row-side {
      width: 100%;
      align-items: flex-start;
    }

    .row-side__text {
      text-align: left;
    }
  }

  @media (max-width: 768px) {
    .page-head,
    .filter-bar {
      flex-direction: column;
      align-items: stretch;
    }

    .page-head__actions {
      justify-content: flex-start;
    }
  }
</style>
