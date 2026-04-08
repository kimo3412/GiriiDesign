<template>
  <div class="kanban-page">
    <!-- 顶部统计概览 -->
    <div class="overview-bar">
      <!-- 单品类：显示步骤 -->
      <template v-if="isSingleCategory">
        <div
          v-for="(col, idx) in columns"
          :key="col.stepId"
          class="overview-item"
          :class="{ active: activeStep === col.stepId }"
          @click="switchStep(col.stepId)"
        >
          <div class="overview-count" :style="{ color: stepColors[idx % stepColors.length] }">
            {{ col.orders.length }}
          </div>
          <div class="overview-name">{{ col.stepName }}</div>
          <div class="overview-bar-indicator" :style="{ background: activeStep === col.stepId ? stepColors[idx % stepColors.length] : 'transparent' }"></div>
        </div>
      </template>
      <!-- 多品类：显示品类汇总 -->
      <template v-else>
        <div
          v-for="(count, catId, idx) in categoryOrderCounts"
          :key="catId"
          class="overview-item"
          :class="{ active: activeCategory === Number(catId) }"
          @click="filterByCategory(Number(catId))"
        >
          <div class="overview-count" :style="{ color: stepColors[idx % stepColors.length] }">
            {{ count }}
          </div>
          <div class="overview-name">{{ getCategoryName(Number(catId)) }}</div>
          <div class="overview-bar-indicator" :style="{ background: activeCategory === Number(catId) ? stepColors[idx % stepColors.length] : 'transparent' }"></div>
        </div>
      </template>
      <!-- 汇总 -->
      <div
        class="overview-item overview-total"
        :class="{ active: activeStep === null && activeCategory === null }"
        @click="clearAllFilter"
      >
        <div class="overview-count" style="color: #333;">{{ totalOrders }}</div>
        <div class="overview-name">全部</div>
        <div class="overview-bar-indicator" :style="{ background: (activeStep === null && activeCategory === null) ? '#333' : 'transparent' }"></div>
      </div>
    </div>

    <!-- 筛选栏 -->
    <div class="filter-bar">
      <n-space align="center" :size="12">
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
          placeholder="搜索订单号..."
          size="small"
          style="width: 200px"
          clearable
        >
          <template #prefix>🔍</template>
        </n-input>
      </n-space>
      <n-space align="center" :size="8">
        <n-tag v-if="activeStep !== null" closable @close="switchStep(null)" size="small">
          当前：{{ activeStepName }}
        </n-tag>
        <n-tag v-if="activeCategory !== null" closable @close="clearCategoryFilter" size="small">
          品类：{{ getCategoryName(activeCategory) }}
        </n-tag>
        <n-button size="small" quaternary @click="loadData">
          刷新
        </n-button>
      </n-space>
    </div>

    <!-- 订单列表 -->
    <n-spin :show="loading">
      <div v-if="!loading && filteredOrders.length === 0" class="empty-state">
        <div class="empty-icon">📋</div>
        <div class="empty-text">暂无订单</div>
      </div>

      <div v-else class="order-list">
        <div
          v-for="order in filteredOrders"
          :key="order.orderId"
          class="order-row"
          :class="{ 'is-blocked': order.isBlocked === 1 }"
          @click="goDetail(order.orderId)"
        >
          <!-- 左侧状态色条 -->
          <div class="row-accent" :style="{ background: getStepColor(order._stepIdx) }"></div>

          <!-- 主信息 -->
          <div class="row-main">
            <div class="row-top">
              <span class="order-sn">{{ order.orderSn }}</span>
              <n-tag v-if="order.isBlocked === 1" type="error" size="tiny" round>⚠ 阻塞</n-tag>
            </div>
            <div class="row-meta">
              <span class="meta-item">
                <span class="meta-label">品类</span>
                <span class="meta-value">{{ getCategoryName(order.categoryId) }}</span>
              </span>
              <span class="meta-item" v-if="order.totalAmount">
                <span class="meta-label">金额</span>
                <span class="meta-value amount">¥{{ Number(order.totalAmount).toLocaleString() }}</span>
              </span>
              <span class="meta-item" v-if="order.expectedDate">
                <span class="meta-label">交期</span>
                <span class="meta-value" :class="{ overdue: isOverdue(order.expectedDate) }">
                  {{ formatDate(order.expectedDate) }}
                </span>
              </span>
              <span class="meta-item">
                <span class="meta-label">创建</span>
                <span class="meta-value">{{ formatRelativeTime(order.createTime) }}</span>
              </span>
            </div>
          </div>

          <!-- 右侧：工作流进度可视化（按品类自己的步骤渲染） -->
          <div class="row-progress">
            <div class="progress-steps">
              <template v-for="(step, sIdx) in order._steps" :key="step.stepId">
                <div
                  class="step-dot"
                  :class="{
                    done: sIdx < order._stepIdx,
                    current: sIdx === order._stepIdx,
                    future: sIdx > order._stepIdx
                  }"
                  :style="sIdx <= order._stepIdx ? { background: getStepColor(order._stepIdx) } : {}"
                  :title="step.stepName"
                ></div>
                <div
                  v-if="sIdx < order._steps.length - 1"
                  class="step-line"
                  :class="{ done: sIdx < order._stepIdx }"
                  :style="sIdx < order._stepIdx ? { background: getStepColor(order._stepIdx) } : {}"
                ></div>
              </template>
            </div>
            <div class="progress-label">{{ order._stepName }}</div>
          </div>

          <!-- 箭头 -->
          <div class="row-arrow">›</div>
        </div>
      </div>
    </n-spin>
  </div>
</template>

<script lang="ts" setup>
import { ref, computed, onMounted } from 'vue';
import { useRouter } from 'vue-router';
import { getKanbanData } from '@/api/order/index';
import { getCategoryList } from '@/api/config/category';
import { getWorkflow } from '@/api/config/workflow';

const router = useRouter();
const loading = ref(false);
const filterCategory = ref<number | null>(null);
const searchText = ref('');
const activeStep = ref<number | null>(null);
const activeCategory = ref<number | null>(null);
const categoryOptions = ref<any[]>([]);
const categoryMap = ref<Record<number, string>>({});
const columns = ref<any[]>([]);

// 品类 → 工作流步骤 的映射（从工作流配置API加载）
const workflowStepsMap = ref<Record<number, any[]>>({});

const stepColors = ['#5B8C5A', '#4B7BEC', '#E5A84B', '#D35D6E', '#6C5CE7', '#00B894', '#E17055'];

const getStepColor = (idx: number) => stepColors[idx % stepColors.length];
const getCategoryName = (id: number) => categoryMap.value[id] || `品类#${id}`;

// 构建 stepId → categoryId 的反向映射
const stepCategoryLookup = computed(() => {
  const map: Record<number, number> = {};
  Object.entries(workflowStepsMap.value).forEach(([catId, steps]) => {
    steps.forEach(step => {
      map[step.stepId] = Number(catId);
    });
  });
  return map;
});

// 按品类分组看板列
const categoryColumnsMap = computed(() => {
  const map: Record<number, any[]> = {};
  columns.value.forEach(col => {
    const catId = col.categoryId || stepCategoryLookup.value[col.stepId];
    if (!catId) return;
    if (!map[catId]) map[catId] = [];
    map[catId].push(col);
  });
  return map;
});

const isSingleCategory = computed(() => {
  return Object.keys(categoryColumnsMap.value).length <= 1;
});

// 品类级别的订单数量
const categoryOrderCounts = computed(() => {
  const counts: Record<number, number> = {};
  columns.value.forEach(col => {
    const catId = col.categoryId || stepCategoryLookup.value[col.stepId];
    if (catId) {
      counts[catId] = (counts[catId] || 0) + col.orders.length;
    }
  });
  return counts;
});

const totalOrders = computed(() => columns.value.reduce((sum, col) => sum + col.orders.length, 0));

const activeStepName = computed(() => {
  const col = columns.value.find(c => c.stepId === activeStep.value);
  return col?.stepName || '';
});

// 将所有订单扁平化，携带品类专属的步骤信息
const allOrders = computed(() => {
  const result: any[] = [];
  columns.value.forEach((col) => {
    col.orders.forEach((order: any) => {
      const steps = workflowStepsMap.value[order.categoryId] || [];
      const stepIdx = steps.findIndex((s: any) => s.stepId === col.stepId);
      result.push({
        ...order,
        _stepId: col.stepId,
        _stepName: col.stepName,
        _stepIdx: stepIdx >= 0 ? stepIdx : 0,
        _steps: steps,
      });
    });
  });
  return result;
});

const filteredOrders = computed(() => {
  let list = allOrders.value;
  if (activeStep.value !== null) {
    list = list.filter(o => o._stepId === activeStep.value);
  }
  if (activeCategory.value !== null) {
    list = list.filter(o => o.categoryId === activeCategory.value);
  }
  if (searchText.value) {
    const kw = searchText.value.toLowerCase();
    list = list.filter(o => o.orderSn?.toLowerCase().includes(kw));
  }
  return list;
});

const switchStep = (stepId: number | null) => {
  activeStep.value = stepId;
};

const filterByCategory = (catId: number) => {
  activeCategory.value = activeCategory.value === catId ? null : catId;
  activeStep.value = null;
};

const clearCategoryFilter = () => {
  activeCategory.value = null;
};

const clearAllFilter = () => {
  activeStep.value = null;
  activeCategory.value = null;
};

const isOverdue = (dateStr: string) => {
  if (!dateStr) return false;
  return new Date(dateStr) < new Date();
};

const formatDate = (dateStr: string) => {
  if (!dateStr) return '-';
  const d = new Date(dateStr);
  return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`;
};

const formatRelativeTime = (timeStr: string) => {
  if (!timeStr) return '';
  const diff = Date.now() - new Date(timeStr).getTime();
  const days = Math.floor(diff / 86400000);
  if (days > 30) return `${Math.floor(days / 30)}月前`;
  if (days > 0) return `${days}天前`;
  const hours = Math.floor(diff / 3600000);
  if (hours > 0) return `${hours}小时前`;
  return '刚刚';
};

onMounted(async () => {
  try {
    const cats = await getCategoryList();
    categoryOptions.value = cats.map((c: any) => ({ label: c.name, value: c.categoryId }));
    categoryMap.value = Object.fromEntries(cats.map((c: any) => [c.categoryId, c.name]));

    // 加载每个品类的工作流步骤
    const stepsMap: Record<number, any[]> = {};
    await Promise.all(cats.map(async (c: any) => {
      try {
        const res = await getWorkflow(c.categoryId);
        if (res.steps?.length) {
          stepsMap[c.categoryId] = res.steps;
        }
      } catch (e) { /* ignore */ }
    }));
    workflowStepsMap.value = stepsMap;
  } catch (e) { console.error(e); }
  loadData();
});

const loadData = async () => {
  loading.value = true;
  activeStep.value = null;
  activeCategory.value = null;
  try {
    const params: any = {};
    if (filterCategory.value != null) params.categoryId = filterCategory.value;
    columns.value = await getKanbanData(params) || [];
  } catch (e) { console.error(e); }
  finally { loading.value = false; }
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

/* ========== 概览统计 ========== */
.overview-bar {
  display: flex;
  background: #fff;
  border-radius: 10px;
  padding: 4px 8px;
  box-shadow: 0 1px 4px rgba(0,0,0,0.04);
  overflow-x: auto;
}

.overview-item {
  flex: 1;
  min-width: 80px;
  text-align: center;
  padding: 16px 12px 12px;
  cursor: pointer;
  position: relative;
  transition: all 0.2s;
  border-radius: 8px;
}

.overview-item:hover { background: #f9f9f9; }
.overview-item.active { background: #f5f7f5; }

.overview-count {
  font-size: 28px;
  font-weight: 700;
  line-height: 1.2;
  margin-bottom: 4px;
}

.overview-name {
  font-size: 12px;
  color: #888;
  letter-spacing: 0.5px;
}

.overview-bar-indicator {
  position: absolute;
  bottom: 0;
  left: 50%;
  transform: translateX(-50%);
  width: 30px;
  height: 3px;
  border-radius: 2px;
  transition: background 0.2s;
}

.overview-total .overview-count { font-size: 24px; }

/* ========== 筛选栏 ========== */
.filter-bar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  background: #fff;
  border-radius: 10px;
  padding: 10px 16px;
  box-shadow: 0 1px 4px rgba(0,0,0,0.04);
}

/* ========== 订单列表 ========== */
.empty-state {
  text-align: center;
  padding: 80px 0;
}
.empty-icon { font-size: 40px; margin-bottom: 12px; }
.empty-text { font-size: 14px; color: #999; }

.order-list {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.order-row {
  display: flex;
  align-items: center;
  background: #fff;
  border-radius: 10px;
  padding: 16px 20px;
  gap: 16px;
  cursor: pointer;
  transition: all 0.2s;
  box-shadow: 0 1px 3px rgba(0,0,0,0.04);
  border: 1px solid transparent;
}

.order-row:hover {
  box-shadow: 0 3px 12px rgba(0,0,0,0.08);
  border-color: #eee;
}

.order-row.is-blocked {
  border-left: 4px solid #e74c3c;
}

/* 左侧色条 */
.row-accent {
  width: 4px;
  height: 40px;
  border-radius: 2px;
  flex-shrink: 0;
}

/* 主信息 */
.row-main {
  flex: 1;
  min-width: 0;
}

.row-top {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 8px;
}

.order-sn {
  font-weight: 700;
  font-size: 14px;
  color: #1a1a2e;
  font-family: 'Monaco', 'Consolas', monospace;
}

.row-meta {
  display: flex;
  gap: 20px;
  flex-wrap: wrap;
}

.meta-item {
  display: flex;
  align-items: center;
  gap: 4px;
  font-size: 12px;
}

.meta-label {
  color: #aaa;
}

.meta-value {
  color: #555;
}

.meta-value.amount {
  font-weight: 600;
  color: #2c3e50;
}

.meta-value.overdue {
  color: #e74c3c;
  font-weight: 600;
}

/* ========== 进度可视化 ========== */
.row-progress {
  flex-shrink: 0;
  min-width: 180px;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 6px;
}

.progress-steps {
  display: flex;
  align-items: center;
}

.step-dot {
  width: 10px;
  height: 10px;
  border-radius: 50%;
  transition: all 0.2s;
}

.step-dot.done {
  /* color set inline */
}

.step-dot.current {
  width: 12px;
  height: 12px;
  box-shadow: 0 0 0 3px rgba(91, 140, 90, 0.2);
}

.step-dot.future {
  background: #e0e0e0;
}

.step-line {
  width: 16px;
  height: 2px;
  background: #e0e0e0;
  transition: all 0.2s;
}

.step-line.done {
  /* color set inline */
}

.progress-label {
  font-size: 11px;
  color: #888;
  text-align: center;
  letter-spacing: 0.5px;
}

/* 箭头 */
.row-arrow {
  font-size: 20px;
  color: #ccc;
  flex-shrink: 0;
  transition: color 0.2s;
}

.order-row:hover .row-arrow {
  color: #5B8C5A;
}
</style>
