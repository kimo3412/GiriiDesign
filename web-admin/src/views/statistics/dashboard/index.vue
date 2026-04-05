<template>
  <div class="dashboard">
    <!-- 统计卡片 -->
    <n-grid cols="1 s:2 m:4" responsive="screen" :x-gap="16" :y-gap="16">
      <n-grid-item>
        <n-card size="small" :bordered="false" class="stat-card">
          <div class="stat-icon" style="background: linear-gradient(135deg, #667eea, #764ba2)">
            <n-icon size="24" color="#fff"><UsergroupAddOutlined /></n-icon>
          </div>
          <div class="stat-info">
            <span class="stat-label">总客户数</span>
            <CountTo :startVal="0" :endVal="data.totalUsers" class="stat-value" />
          </div>
        </n-card>
      </n-grid-item>
      <n-grid-item>
        <n-card size="small" :bordered="false" class="stat-card">
          <div class="stat-icon" style="background: linear-gradient(135deg, #f093fb, #f5576c)">
            <n-icon size="24" color="#fff"><ShoppingCartOutlined /></n-icon>
          </div>
          <div class="stat-info">
            <span class="stat-label">总订单数</span>
            <CountTo :startVal="0" :endVal="data.totalOrders" class="stat-value" />
          </div>
        </n-card>
      </n-grid-item>
      <n-grid-item>
        <n-card size="small" :bordered="false" class="stat-card">
          <div class="stat-icon" style="background: linear-gradient(135deg, #4facfe, #00f2fe)">
            <n-icon size="24" color="#fff"><AccountBookOutlined /></n-icon>
          </div>
          <div class="stat-info">
            <span class="stat-label">总营收</span>
            <CountTo prefix="¥" :startVal="0" :endVal="data.totalRevenue" :decimals="2" class="stat-value" />
          </div>
        </n-card>
      </n-grid-item>
      <n-grid-item>
        <n-card size="small" :bordered="false" class="stat-card">
          <div class="stat-icon" style="background: linear-gradient(135deg, #43e97b, #38f9d7)">
            <n-icon size="24" color="#fff"><BarChartOutlined /></n-icon>
          </div>
          <div class="stat-info">
            <span class="stat-label">进行中订单</span>
            <CountTo :startVal="0" :endVal="data.activeOrders" class="stat-value" />
          </div>
        </n-card>
      </n-grid-item>
    </n-grid>

    <!-- 第二行：小指标卡片 -->
    <n-grid cols="1 s:2 m:4" responsive="screen" :x-gap="16" :y-gap="16" class="mt-4">
      <n-grid-item>
        <n-card size="small" :bordered="false">
          <n-statistic label="本月新增订单" :value="data.monthOrders" />
        </n-card>
      </n-grid-item>
      <n-grid-item>
        <n-card size="small" :bordered="false">
          <n-statistic label="本月营收">
            <template #prefix>¥</template>
            {{ data.monthRevenue?.toFixed(2) || '0.00' }}
          </n-statistic>
        </n-card>
      </n-grid-item>
      <n-grid-item>
        <n-card size="small" :bordered="false">
          <n-statistic label="待处理意向" :value="data.pendingRequests">
            <template #suffix>
              <n-tag v-if="data.pendingRequests > 0" type="warning" size="small">需关注</n-tag>
            </template>
          </n-statistic>
        </n-card>
      </n-grid-item>
      <n-grid-item>
        <n-card size="small" :bordered="false">
          <n-statistic label="低库存物料" :value="data.lowStockMaterials">
            <template #suffix>
              <n-tag v-if="data.lowStockMaterials > 0" type="error" size="small">预警</n-tag>
            </template>
          </n-statistic>
        </n-card>
      </n-grid-item>
    </n-grid>

    <!-- 第三行：图表 -->
    <n-grid cols="1 s:1 m:2" responsive="screen" :x-gap="16" :y-gap="16" class="mt-4">
      <n-grid-item>
        <n-card title="近7天订单趋势" size="small" :bordered="false">
          <div ref="trendChartRef" class="chart-box"></div>
        </n-card>
      </n-grid-item>
      <n-grid-item>
        <n-card title="订单状态分布" size="small" :bordered="false">
          <div ref="pieChartRef" class="chart-box"></div>
        </n-card>
      </n-grid-item>
    </n-grid>

    <!-- 第四行：图表 -->
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
  </div>
</template>

<script lang="ts" setup>
import { ref, onMounted, Ref } from 'vue';
import { getDashboardData } from '@/api/dashboard/console';
import { useECharts } from '@/hooks/web/useECharts';
import { CountTo } from '@/components/CountTo/index';
import {
  UsergroupAddOutlined,
  ShoppingCartOutlined,
  AccountBookOutlined,
  BarChartOutlined,
} from '@vicons/antd';

const data = ref<any>({
  totalUsers: 0,
  totalOrders: 0,
  totalRevenue: 0,
  activeOrders: 0,
  monthOrders: 0,
  monthRevenue: 0,
  pendingRequests: 0,
  lowStockMaterials: 0,
});

const trendChartRef = ref<HTMLDivElement | null>(null);
const pieChartRef = ref<HTMLDivElement | null>(null);
const barChartRef = ref<HTMLDivElement | null>(null);
const areaChartRef = ref<HTMLDivElement | null>(null);

const { setOptions: setTrendOptions } = useECharts(trendChartRef as Ref<HTMLDivElement>);
const { setOptions: setPieOptions } = useECharts(pieChartRef as Ref<HTMLDivElement>);
const { setOptions: setBarOptions } = useECharts(barChartRef as Ref<HTMLDivElement>);
const { setOptions: setAreaOptions } = useECharts(areaChartRef as Ref<HTMLDivElement>);

const STATUS_MAP: Record<number, string> = {
  0: '待支付',
  1: '生产中',
  2: '待发货',
  3: '待收货',
  4: '已完成',
  5: '已取消',
};

onMounted(async () => {
  try {
    const res = await getDashboardData();
    data.value = res;
    renderCharts(res);
  } catch (e) {
    console.error('获取看板数据失败', e);
  }
});

function renderCharts(d: any) {
  // 1. 近7天订单趋势
  const trendDates = (d.dailyOrderTrend || []).map((i: any) => i.date?.substring(5) || '');
  const trendCounts = (d.dailyOrderTrend || []).map((i: any) => i.order_count || 0);
  const trendRevenue = (d.dailyOrderTrend || []).map((i: any) => Number(i.revenue) || 0);

  setTrendOptions({
    tooltip: { trigger: 'axis' },
    legend: { data: ['订单数', '营收(¥)'], bottom: 0 },
    grid: { left: '3%', right: '4%', bottom: '15%', top: '10%', containLabel: true },
    xAxis: { type: 'category', data: trendDates, boundaryGap: false },
    yAxis: [
      { type: 'value', name: '订单', position: 'left' },
      { type: 'value', name: '¥', position: 'right' },
    ],
    series: [
      {
        name: '订单数',
        type: 'line',
        smooth: true,
        data: trendCounts,
        itemStyle: { color: '#667eea' },
        areaStyle: { color: 'rgba(102, 126, 234, 0.15)' },
      },
      {
        name: '营收(¥)',
        type: 'line',
        smooth: true,
        yAxisIndex: 1,
        data: trendRevenue,
        itemStyle: { color: '#f5576c' },
        areaStyle: { color: 'rgba(245, 87, 108, 0.1)' },
      },
    ],
  });

  // 2. 订单状态分布
  const pieData = (d.orderStatusDistribution || []).map((i: any) => ({
    name: STATUS_MAP[i.status] || `状态${i.status}`,
    value: i.count,
  }));

  setPieOptions({
    tooltip: { trigger: 'item', formatter: '{b}: {c} ({d}%)' },
    legend: { bottom: 0, type: 'scroll' },
    series: [
      {
        type: 'pie',
        radius: ['40%', '65%'],
        center: ['50%', '45%'],
        avoidLabelOverlap: true,
        itemStyle: { borderRadius: 6, borderColor: '#fff', borderWidth: 2 },
        label: { show: true, formatter: '{b}\n{c}单' },
        data: pieData,
        color: ['#95afc0', '#667eea', '#f093fb', '#43e97b', '#4facfe', '#ffd93d'],
      },
    ],
  });

  // 3. 品类订单排名
  const categoryNames = (d.categoryRank || []).map((i: any) => i.category_name || '未知').reverse();
  const categoryCounts = (d.categoryRank || []).map((i: any) => i.order_count || 0).reverse();

  setBarOptions({
    tooltip: { trigger: 'axis', axisPointer: { type: 'shadow' } },
    grid: { left: '3%', right: '10%', bottom: '3%', top: '3%', containLabel: true },
    xAxis: { type: 'value' },
    yAxis: { type: 'category', data: categoryNames },
    series: [
      {
        type: 'bar',
        data: categoryCounts,
        barWidth: '50%',
        itemStyle: {
          borderRadius: [0, 4, 4, 0],
          color: {
            type: 'linear', x: 0, y: 0, x2: 1, y2: 0,
            colorStops: [
              { offset: 0, color: '#667eea' },
              { offset: 1, color: '#764ba2' },
            ],
          } as any,
        },
      },
    ],
  });

  // 4. 月度营收
  const months = (d.monthlyRevenueTrend || []).map((i: any) => i.month || '');
  const monthlyRevenues = (d.monthlyRevenueTrend || []).map((i: any) => Number(i.revenue) || 0);
  const monthlyOrders = (d.monthlyRevenueTrend || []).map((i: any) => i.order_count || 0);

  setAreaOptions({
    tooltip: { trigger: 'axis' },
    legend: { data: ['营收(¥)', '订单数'], bottom: 0 },
    grid: { left: '3%', right: '4%', bottom: '15%', top: '10%', containLabel: true },
    xAxis: { type: 'category', data: months, boundaryGap: false },
    yAxis: [
      { type: 'value', name: '¥', position: 'left' },
      { type: 'value', name: '订单', position: 'right' },
    ],
    series: [
      {
        name: '营收(¥)',
        type: 'line',
        smooth: true,
        data: monthlyRevenues,
        areaStyle: {
          color: {
            type: 'linear', x: 0, y: 0, x2: 0, y2: 1,
            colorStops: [
              { offset: 0, color: 'rgba(67, 233, 123, 0.5)' },
              { offset: 1, color: 'rgba(67, 233, 123, 0.02)' },
            ],
          } as any,
        },
        itemStyle: { color: '#43e97b' },
      },
      {
        name: '订单数',
        type: 'bar',
        yAxisIndex: 1,
        data: monthlyOrders,
        barWidth: '30%',
        itemStyle: { color: 'rgba(102, 126, 234, 0.6)', borderRadius: [4, 4, 0, 0] },
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
