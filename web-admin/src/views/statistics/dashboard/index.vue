<template>
  <div class="dashboard">
    <n-grid cols="1 s:2 m:4" responsive="screen" :x-gap="16" :y-gap="16">
      <n-grid-item v-for="card in topCards" :key="card.label">
        <n-card size="small" :bordered="false" class="stat-card">
          <div class="stat-icon" :style="{ background: card.bg }">
            <n-icon size="24" color="#fff">
              <component :is="card.icon" />
            </n-icon>
          </div>
          <div class="stat-info">
            <span class="stat-label">{{ card.label }}</span>
            <CountTo
              :startVal="0"
              :endVal="card.value"
              :decimals="card.decimals || 0"
              :prefix="card.prefix || ''"
              :suffix="card.suffix || ''"
              class="stat-value"
            />
          </div>
        </n-card>
      </n-grid-item>
    </n-grid>

    <n-grid cols="1 s:2 m:4" responsive="screen" :x-gap="16" :y-gap="16" class="mt-4">
      <n-grid-item>
        <n-card size="small" :bordered="false">
          <n-statistic label="本月新增订单" :value="data.monthOrders || 0" />
        </n-card>
      </n-grid-item>
      <n-grid-item>
        <n-card size="small" :bordered="false">
          <n-statistic label="本月营收" :value="Number(data.monthRevenue || 0)">
            <template #prefix>¥</template>
          </n-statistic>
        </n-card>
      </n-grid-item>
      <n-grid-item>
        <n-card size="small" :bordered="false">
          <n-statistic label="平均客单价" :value="Number(data.averageOrderAmount || 0)">
            <template #prefix>¥</template>
          </n-statistic>
        </n-card>
      </n-grid-item>
      <n-grid-item>
        <n-card size="small" :bordered="false">
          <n-statistic label="复购客户" :value="data.repeatCustomers || 0">
            <template #suffix>
              <n-tag type="info" size="small">{{ Number(data.repeatCustomerRate || 0).toFixed(2) }}%</n-tag>
            </template>
          </n-statistic>
        </n-card>
      </n-grid-item>
    </n-grid>

    <n-grid cols="1 s:1 m:2" responsive="screen" :x-gap="16" :y-gap="16" class="mt-4">
      <n-grid-item>
        <n-card title="近 7 天订单趋势" size="small" :bordered="false">
          <div ref="trendChartRef" class="chart-box"></div>
        </n-card>
      </n-grid-item>
      <n-grid-item>
        <n-card title="订单状态分布" size="small" :bordered="false">
          <div ref="pieChartRef" class="chart-box"></div>
        </n-card>
      </n-grid-item>
    </n-grid>

    <n-grid cols="1 s:1 m:2" responsive="screen" :x-gap="16" :y-gap="16" class="mt-4">
      <n-grid-item>
        <n-card title="品类订单排名" size="small" :bordered="false">
          <div ref="barChartRef" class="chart-box"></div>
        </n-card>
      </n-grid-item>
      <n-grid-item>
        <n-card title="月度营收趋势" size="small" :bordered="false">
          <div ref="areaChartRef" class="chart-box"></div>
        </n-card>
      </n-grid-item>
    </n-grid>

    <n-grid cols="1 s:1 m:2" responsive="screen" :x-gap="16" :y-gap="16" class="mt-4">
      <n-grid-item>
        <n-card title="品类转化率" size="small" :bordered="false">
          <div ref="conversionChartRef" class="chart-box"></div>
        </n-card>
      </n-grid-item>
      <n-grid-item>
        <n-card title="流程瓶颈节点" size="small" :bordered="false">
          <div ref="bottleneckChartRef" class="chart-box"></div>
        </n-card>
      </n-grid-item>
    </n-grid>

    <n-grid cols="1 s:1 m:2" responsive="screen" :x-gap="16" :y-gap="16" class="mt-4">
      <n-grid-item>
        <n-card title="设计师效率" size="small" :bordered="false">
          <n-data-table :columns="designerColumns" :data="designerTableData" :pagination="false" />
        </n-card>
      </n-grid-item>
      <n-grid-item>
        <n-card title="品类转化明细" size="small" :bordered="false">
          <n-data-table :columns="conversionColumns" :data="conversionTableData" :pagination="false" />
        </n-card>
      </n-grid-item>
    </n-grid>
  </div>
</template>

<script lang="ts" setup>
import { computed, onMounted, ref, type Ref } from 'vue';
import { getDashboardData, type DashboardData } from '@/api/dashboard/console';
import { CountTo } from '@/components/CountTo/index';
import { useECharts } from '@/hooks/web/useECharts';
import {
  AccountBookOutlined,
  BarChartOutlined,
  RiseOutlined,
  ShoppingCartOutlined,
} from '@vicons/antd';

const data = ref<Partial<DashboardData>>({});

const trendChartRef = ref<HTMLDivElement | null>(null);
const pieChartRef = ref<HTMLDivElement | null>(null);
const barChartRef = ref<HTMLDivElement | null>(null);
const areaChartRef = ref<HTMLDivElement | null>(null);
const conversionChartRef = ref<HTMLDivElement | null>(null);
const bottleneckChartRef = ref<HTMLDivElement | null>(null);

const { setOptions: setTrendOptions } = useECharts(trendChartRef as Ref<HTMLDivElement>);
const { setOptions: setPieOptions } = useECharts(pieChartRef as Ref<HTMLDivElement>);
const { setOptions: setBarOptions } = useECharts(barChartRef as Ref<HTMLDivElement>);
const { setOptions: setAreaOptions } = useECharts(areaChartRef as Ref<HTMLDivElement>);
const { setOptions: setConversionOptions } = useECharts(conversionChartRef as Ref<HTMLDivElement>);
const { setOptions: setBottleneckOptions } = useECharts(bottleneckChartRef as Ref<HTMLDivElement>);

const STATUS_MAP: Record<number, string> = {
  0: '待支付',
  1: '生产中',
  2: '待发货',
  3: '待收货',
  4: '已完成',
  5: '已取消',
  6: '待付尾款',
};

const topCards = computed(() => [
  {
    label: '总订单数',
    value: Number(data.value.totalOrders || 0),
    icon: ShoppingCartOutlined,
    bg: 'linear-gradient(135deg, #667eea, #764ba2)',
  },
  {
    label: '总营收',
    value: Number(data.value.totalRevenue || 0),
    icon: AccountBookOutlined,
    bg: 'linear-gradient(135deg, #4facfe, #00f2fe)',
    prefix: '¥',
    decimals: 2,
  },
  {
    label: '进行中订单',
    value: Number(data.value.activeOrders || 0),
    icon: BarChartOutlined,
    bg: 'linear-gradient(135deg, #43e97b, #38f9d7)',
  },
  {
    label: '复购率',
    value: Number(data.value.repeatCustomerRate || 0),
    icon: RiseOutlined,
    bg: 'linear-gradient(135deg, #f093fb, #f5576c)',
    suffix: '%',
    decimals: 2,
  },
]);

const conversionTableData = computed(() =>
  (data.value.conversionMetrics || []).map((item) => {
    const requestCount = Number(item.request_count || 0);
    const convertedCount = Number(item.converted_count || 0);
    const completedCount = Number(item.completed_count || 0);
    return {
      ...item,
      conversionRate: requestCount > 0 ? Number(((convertedCount / requestCount) * 100).toFixed(2)) : 0,
      completionRate: convertedCount > 0 ? Number(((completedCount / convertedCount) * 100).toFixed(2)) : 0,
    };
  })
);

const designerTableData = computed(() =>
  (data.value.designerEfficiency || []).map((item) => ({
    ...item,
    overtimeText: Number(item.overtime_count || 0) > 0 ? `${item.overtime_count} 单` : '0 单',
    avgCycleText: Number(item.avg_cycle_days || 0).toFixed(2),
  }))
);

const designerColumns = [
  { title: '设计师', key: 'designer_name' },
  { title: '订单数', key: 'total_orders' },
  { title: '平均工期(天)', key: 'avgCycleText' },
  { title: '逾期单', key: 'overtimeText' },
];

const conversionColumns = [
  { title: '品类', key: 'category_name' },
  { title: '意向数', key: 'request_count' },
  { title: '转单数', key: 'converted_count' },
  { title: '完成单', key: 'completed_count' },
  {
    title: '转化率',
    key: 'conversionRate',
    render(row: any) {
      return `${Number(row.conversionRate || 0).toFixed(2)}%`;
    },
  },
  {
    title: '完成率',
    key: 'completionRate',
    render(row: any) {
      return `${Number(row.completionRate || 0).toFixed(2)}%`;
    },
  },
];

onMounted(async () => {
  const res = await getDashboardData();
  data.value = res;
  renderCharts(res);
});

function renderCharts(d: Partial<DashboardData>) {
  const trendDates = (d.dailyOrderTrend || []).map((item) => item.date?.substring(5) || '');
  const trendCounts = (d.dailyOrderTrend || []).map((item) => Number(item.order_count || 0));
  const trendRevenue = (d.dailyOrderTrend || []).map((item) => Number(item.revenue || 0));

  setTrendOptions({
    tooltip: { trigger: 'axis' },
    legend: { data: ['订单数', '营收'], bottom: 0 },
    grid: { left: '3%', right: '4%', bottom: '15%', containLabel: true },
    xAxis: { type: 'category', data: trendDates, boundaryGap: false },
    yAxis: [{ type: 'value', name: '订单' }, { type: 'value', name: '元' }],
    series: [
      { name: '订单数', type: 'line', smooth: true, data: trendCounts },
      { name: '营收', type: 'line', smooth: true, data: trendRevenue, yAxisIndex: 1 },
    ],
  });

  setPieOptions({
    tooltip: { trigger: 'item', formatter: '{b}: {c} ({d}%)' },
    legend: { bottom: 0 },
    series: [
      {
        type: 'pie',
        radius: ['40%', '66%'],
        center: ['50%', '42%'],
        data: (d.orderStatusDistribution || []).map((item) => ({
          name: STATUS_MAP[item.status] || `状态${item.status}`,
          value: item.count,
        })),
      },
    ],
  });

  setBarOptions({
    tooltip: { trigger: 'axis', axisPointer: { type: 'shadow' } },
    grid: { left: '3%', right: '8%', bottom: '3%', containLabel: true },
    xAxis: { type: 'value' },
    yAxis: {
      type: 'category',
      data: (d.categoryRank || []).map((item) => item.category_name || '未命名').reverse(),
    },
    series: [
      {
        type: 'bar',
        data: (d.categoryRank || []).map((item) => Number(item.order_count || 0)).reverse(),
        barWidth: '50%',
      },
    ],
  });

  setAreaOptions({
    tooltip: { trigger: 'axis' },
    legend: { data: ['营收', '订单数'], bottom: 0 },
    grid: { left: '3%', right: '4%', bottom: '15%', containLabel: true },
    xAxis: { type: 'category', data: (d.monthlyRevenueTrend || []).map((item) => item.month || '') },
    yAxis: [{ type: 'value', name: '元' }, { type: 'value', name: '订单' }],
    series: [
      {
        name: '营收',
        type: 'line',
        smooth: true,
        data: (d.monthlyRevenueTrend || []).map((item) => Number(item.revenue || 0)),
        areaStyle: {},
      },
      {
        name: '订单数',
        type: 'bar',
        yAxisIndex: 1,
        data: (d.monthlyRevenueTrend || []).map((item) => Number(item.order_count || 0)),
      },
    ],
  });

  const conversionData = conversionTableData.value;
  setConversionOptions({
    tooltip: { trigger: 'axis' },
    legend: { data: ['转化率', '完成率'], bottom: 0 },
    grid: { left: '3%', right: '4%', bottom: '15%', containLabel: true },
    xAxis: { type: 'category', data: conversionData.map((item) => item.category_name || '未命名') },
    yAxis: { type: 'value', axisLabel: { formatter: '{value}%' } },
    series: [
      { name: '转化率', type: 'bar', data: conversionData.map((item) => Number(item.conversionRate || 0)) },
      { name: '完成率', type: 'line', smooth: true, data: conversionData.map((item) => Number(item.completionRate || 0)) },
    ],
  });

  setBottleneckOptions({
    tooltip: { trigger: 'axis', axisPointer: { type: 'shadow' } },
    grid: { left: '3%', right: '8%', bottom: '3%', containLabel: true },
    xAxis: { type: 'value', name: '天' },
    yAxis: {
      type: 'category',
      data: (d.workflowBottlenecks || []).map((item) => item.step_name || '未知节点').reverse(),
    },
    series: [
      {
        type: 'bar',
        data: (d.workflowBottlenecks || []).map((item) => Number(item.avg_stay_days || 0)).reverse(),
        barWidth: '50%',
      },
    ],
  });
}
</script>

<style scoped>
.dashboard {
  padding: 4px;
}

.stat-card :deep(.n-card__content) {
  display: flex;
  align-items: center;
  gap: 16px;
  padding: 16px 20px !important;
}

.stat-icon {
  width: 48px;
  height: 48px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.stat-info {
  display: flex;
  flex-direction: column;
}

.stat-label {
  font-size: 13px;
  color: #999;
  margin-bottom: 4px;
}

.stat-value {
  font-size: 24px;
  font-weight: 600;
  color: #333;
}

.chart-box {
  width: 100%;
  height: 320px;
}

.mt-4 {
  margin-top: 16px;
}
</style>
