<template>
  <div class="dashboard">
    <section class="dashboard-hero">
      <div class="dashboard-hero__content">
        <div class="dashboard-eyebrow">经营看板</div>
        <h2 class="dashboard-title">工作室经营概览</h2>
        <p class="dashboard-desc">从订单、营收、转化和流程效率四个维度快速判断当前经营状态。</p>
        <div class="dashboard-ribbon">
          <span class="dashboard-ribbon__chip">订单节奏</span>
          <span class="dashboard-ribbon__chip">营收质量</span>
          <span class="dashboard-ribbon__chip">流程效率</span>
        </div>
      </div>
      <div class="dashboard-hero__aside">
        <div class="hero-pill">
          <span>本月新增订单</span>
          <strong>{{ Number(data.monthOrders || 0) }}</strong>
        </div>
        <div class="hero-pill">
          <span>本月营收</span>
          <strong>¥{{ Number(data.monthRevenue || 0).toFixed(2) }}</strong>
        </div>
      </div>
    </section>

    <section class="stat-grid">
      <n-card
        v-for="card in topCards"
        :key="card.label"
        size="small"
        :bordered="false"
        class="stat-card"
      >
        <div class="stat-icon" :style="{ background: card.bg }">
          <n-icon size="22" color="#fff">
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
    </section>

    <section class="kpi-strip">
      <n-card size="small" :bordered="false" class="kpi-card">
        <div class="kpi-card__main">
          <div class="kpi-card__icon kpi-card__icon--warning">
            <n-icon size="18"><TagsOutlined /></n-icon>
          </div>
          <div>
            <div class="kpi-card__label">待处理意向</div>
            <div class="kpi-card__value">{{ Number(data.pendingRequests || 0) }}</div>
          </div>
        </div>
        <n-tag type="warning" size="small" round>需要跟进</n-tag>
      </n-card>
      <n-card size="small" :bordered="false" class="kpi-card">
        <div class="kpi-card__main">
          <div class="kpi-card__icon kpi-card__icon--error">
            <n-icon size="18"><BarChartOutlined /></n-icon>
          </div>
          <div>
            <div class="kpi-card__label">低库存物料</div>
            <div class="kpi-card__value">{{ Number(data.lowStockMaterials || 0) }}</div>
          </div>
        </div>
        <n-tag type="error" size="small" round>需要补货</n-tag>
      </n-card>
      <n-card size="small" :bordered="false" class="kpi-card">
        <div class="kpi-card__main">
          <div class="kpi-card__icon kpi-card__icon--info">
            <n-icon size="18"><AccountBookOutlined /></n-icon>
          </div>
          <div>
            <div class="kpi-card__label">平均客单价</div>
            <div class="kpi-card__value"
              >¥{{ Number(data.averageOrderAmount || 0).toFixed(2) }}</div
            >
          </div>
        </div>
        <n-tag type="info" size="small" round>质量指标</n-tag>
      </n-card>
      <n-card size="small" :bordered="false" class="kpi-card">
        <div class="kpi-card__main">
          <div class="kpi-card__icon kpi-card__icon--success">
            <n-icon size="18"><ProfileOutlined /></n-icon>
          </div>
          <div>
            <div class="kpi-card__label">复购客户</div>
            <div class="kpi-card__value">{{ Number(data.repeatCustomers || 0) }}</div>
          </div>
        </div>
        <n-tag type="success" size="small" round
          >{{ Number(data.repeatCustomerRate || 0).toFixed(2) }}%</n-tag
        >
      </n-card>
    </section>

    <section class="chart-section">
      <div class="section-head">
        <div class="section-head__main">
          <div class="section-head__badge">
            <n-icon size="16"><RiseOutlined /></n-icon>
            <span>趋势分析</span>
          </div>
          <div class="section-eyebrow">趋势分析</div>
          <h3>订单与营收走势</h3>
        </div>
      </div>
      <div class="chart-grid chart-grid--dual">
        <n-card title="近 7 天订单趋势" size="small" :bordered="false" class="panel-card">
          <div ref="trendChartRef" class="chart-box chart-box--wide"></div>
        </n-card>
        <n-card title="订单状态分布" size="small" :bordered="false" class="panel-card">
          <div ref="pieChartRef" class="chart-box"></div>
        </n-card>
        <n-card title="品类订单排名" size="small" :bordered="false" class="panel-card">
          <div ref="barChartRef" class="chart-box"></div>
        </n-card>
        <n-card title="月度营收趋势" size="small" :bordered="false" class="panel-card">
          <div ref="areaChartRef" class="chart-box"></div>
        </n-card>
      </div>
    </section>

    <section class="chart-section">
      <div class="section-head">
        <div class="section-head__main">
          <div class="section-head__badge section-head__badge--amber">
            <n-icon size="16"><BarChartOutlined /></n-icon>
            <span>转化与流程</span>
          </div>
          <div class="section-eyebrow">转化与流程</div>
          <h3>转化质量与流程瓶颈</h3>
        </div>
      </div>
      <div class="chart-grid chart-grid--dual">
        <n-card title="品类转化率" size="small" :bordered="false" class="panel-card">
          <div ref="conversionChartRef" class="chart-box"></div>
        </n-card>
        <n-card title="流程瓶颈节点" size="small" :bordered="false" class="panel-card">
          <div ref="bottleneckChartRef" class="chart-box"></div>
        </n-card>
      </div>
    </section>

    <section class="chart-section">
      <div class="section-head">
        <div class="section-head__main">
          <div class="section-head__badge section-head__badge--emerald">
            <n-icon size="16"><AccountBookOutlined /></n-icon>
            <span>效率明细</span>
          </div>
          <div class="section-eyebrow">效率明细</div>
          <h3>设计师效率与品类转化明细</h3>
        </div>
      </div>
      <div class="table-grid">
        <n-card title="设计师效率" size="small" :bordered="false" class="panel-card">
          <n-data-table :columns="designerColumns" :data="designerTableData" :pagination="false" />
        </n-card>
        <n-card title="品类转化明细" size="small" :bordered="false" class="panel-card">
          <n-data-table
            :columns="conversionColumns"
            :data="conversionTableData"
            :pagination="false"
          />
        </n-card>
      </div>
    </section>
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
    ProfileOutlined,
    RiseOutlined,
    ShoppingCartOutlined,
    TagsOutlined,
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
  const { setOptions: setConversionOptions } = useECharts(
    conversionChartRef as Ref<HTMLDivElement>
  );
  const { setOptions: setBottleneckOptions } = useECharts(
    bottleneckChartRef as Ref<HTMLDivElement>
  );

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
        conversionRate:
          requestCount > 0 ? Number(((convertedCount / requestCount) * 100).toFixed(2)) : 0,
        completionRate:
          convertedCount > 0 ? Number(((completedCount / convertedCount) * 100).toFixed(2)) : 0,
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
      yAxis: [
        { type: 'value', name: '订单' },
        { type: 'value', name: '元' },
      ],
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
      xAxis: {
        type: 'category',
        data: (d.monthlyRevenueTrend || []).map((item) => item.month || ''),
      },
      yAxis: [
        { type: 'value', name: '元' },
        { type: 'value', name: '订单' },
      ],
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
      xAxis: {
        type: 'category',
        data: conversionData.map((item) => item.category_name || '未命名'),
      },
      yAxis: { type: 'value', axisLabel: { formatter: '{value}%' } },
      series: [
        {
          name: '转化率',
          type: 'bar',
          data: conversionData.map((item) => Number(item.conversionRate || 0)),
        },
        {
          name: '完成率',
          type: 'line',
          smooth: true,
          data: conversionData.map((item) => Number(item.completionRate || 0)),
        },
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
          data: (d.workflowBottlenecks || [])
            .map((item) => Number(item.avg_stay_days || 0))
            .reverse(),
          barWidth: '50%',
        },
      ],
    });
  }
</script>

<style scoped>
  .dashboard {
    display: flex;
    flex-direction: column;
    gap: 18px;
    padding: 6px;
  }

  .dashboard-hero {
    position: relative;
    display: flex;
    align-items: stretch;
    justify-content: space-between;
    gap: 16px;
    padding: 24px 26px;
    border-radius: 24px;
    background: radial-gradient(circle at top right, rgba(99, 102, 241, 0.12), transparent 34%),
      linear-gradient(135deg, rgba(255, 255, 255, 0.98), rgba(245, 247, 255, 0.96));
    border: 1px solid rgba(148, 163, 184, 0.14);
    overflow: hidden;
  }

  .dashboard-hero::before,
  .dashboard-hero::after {
    content: '';
    position: absolute;
    border-radius: 999px;
    pointer-events: none;
  }

  .dashboard-hero::before {
    width: 220px;
    height: 220px;
    right: -70px;
    top: -90px;
    background: radial-gradient(circle, rgba(99, 102, 241, 0.14), transparent 68%);
  }

  .dashboard-hero::after {
    width: 180px;
    height: 180px;
    left: 42%;
    bottom: -110px;
    background: radial-gradient(circle, rgba(56, 189, 248, 0.12), transparent 70%);
  }

  .dashboard-hero__content {
    position: relative;
    z-index: 1;
    max-width: 680px;
  }

  .dashboard-eyebrow,
  .section-eyebrow {
    font-size: 12px;
    font-weight: 700;
    letter-spacing: 0.08em;
    text-transform: uppercase;
    color: #718096;
  }

  .dashboard-title {
    margin: 8px 0 10px;
    font-size: clamp(28px, 3vw, 34px);
    line-height: 1.1;
    font-weight: 800;
    color: #18243d;
  }

  .dashboard-desc {
    margin: 0;
    font-size: 14px;
    line-height: 1.7;
    color: #667085;
  }

  .dashboard-ribbon {
    display: flex;
    flex-wrap: wrap;
    gap: 10px;
    margin-top: 18px;
  }

  .dashboard-ribbon__chip {
    display: inline-flex;
    align-items: center;
    padding: 8px 12px;
    border-radius: 999px;
    background: rgba(255, 255, 255, 0.78);
    border: 1px solid rgba(148, 163, 184, 0.16);
    color: #475467;
    font-size: 12px;
    font-weight: 700;
    backdrop-filter: blur(8px);
  }

  .dashboard-hero__aside {
    position: relative;
    z-index: 1;
    display: grid;
    grid-template-columns: repeat(2, minmax(150px, 1fr));
    gap: 12px;
    min-width: min(100%, 360px);
  }

  .hero-pill {
    display: flex;
    flex-direction: column;
    justify-content: space-between;
    gap: 10px;
    padding: 16px 18px;
    border-radius: 18px;
    background: rgba(255, 255, 255, 0.92);
    border: 1px solid rgba(99, 102, 241, 0.12);
  }

  .hero-pill span {
    font-size: 12px;
    color: #718096;
  }

  .hero-pill strong {
    font-size: 20px;
    font-weight: 800;
    color: #1d2a57;
  }

  .stat-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
    gap: 16px;
  }

  .stat-card,
  .panel-card,
  .kpi-card {
    position: relative;
    border-radius: 20px;
    background: rgba(255, 255, 255, 0.96);
    border: 1px solid rgba(226, 232, 240, 0.7);
    overflow: hidden;
    box-shadow: 0 10px 26px rgba(15, 23, 42, 0.04);
  }

  .stat-card::before,
  .panel-card::before,
  .kpi-card::before {
    content: '';
    position: absolute;
    inset: 0 auto auto 0;
    width: 100%;
    height: 1px;
    background: linear-gradient(90deg, rgba(99, 102, 241, 0.34), transparent 72%);
  }

  .stat-card:hover,
  .panel-card:hover,
  .kpi-card:hover {
    transform: translateY(-1px);
    box-shadow: 0 14px 30px rgba(15, 23, 42, 0.06);
  }

  .stat-card :deep(.n-card__content) {
    display: flex;
    align-items: center;
    gap: 16px;
    padding: 18px 20px !important;
  }

  .panel-card :deep(.n-card-header) {
    padding: 18px 20px 0 !important;
  }

  .panel-card :deep(.n-card__content),
  .kpi-card :deep(.n-card__content) {
    padding: 18px 20px !important;
  }

  .panel-card :deep(.n-card-header__main) {
    font-size: 15px;
    font-weight: 700;
    color: #18243d;
  }

  .kpi-strip {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
    gap: 14px;
  }

  .kpi-card {
    display: flex;
    flex-direction: column;
    align-items: flex-start;
    justify-content: flex-start;
    gap: 12px;
  }

  .kpi-card__main {
    display: flex;
    align-items: flex-start;
    gap: 12px;
    min-width: 0;
    width: 100%;
  }

  .kpi-card__icon {
    width: 40px;
    height: 40px;
    border-radius: 14px;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    flex-shrink: 0;
    color: #fff;
  }

  .kpi-card__icon--warning {
    background: linear-gradient(135deg, #fbbf24, #f59e0b);
  }

  .kpi-card__icon--error {
    background: linear-gradient(135deg, #fb7185, #ef4444);
  }

  .kpi-card__icon--info {
    background: linear-gradient(135deg, #60a5fa, #2563eb);
  }

  .kpi-card__icon--success {
    background: linear-gradient(135deg, #34d399, #10b981);
  }

  .kpi-card__label {
    font-size: 12px;
    color: #718096;
    margin-bottom: 6px;
  }

  .kpi-card__value {
    font-size: 22px;
    font-weight: 800;
    color: #18243d;
    line-height: 1.1;
  }

  .kpi-card :deep(.n-tag) {
    align-self: flex-start;
  }

  .stat-icon {
    width: 46px;
    height: 46px;
    border-radius: 14px;
    display: flex;
    align-items: center;
    justify-content: center;
    flex-shrink: 0;
    box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.4);
  }

  .stat-info {
    display: flex;
    flex-direction: column;
    min-width: 0;
  }

  .stat-label {
    font-size: 12px;
    color: #718096;
    margin-bottom: 6px;
  }

  .stat-value {
    font-size: clamp(24px, 2vw, 30px);
    font-weight: 800;
    color: #18243d;
    line-height: 1.1;
  }

  .section-head {
    display: flex;
    align-items: center;
    justify-content: space-between;
    margin-bottom: 12px;
  }

  .section-head__main {
    display: flex;
    flex-direction: column;
    gap: 8px;
  }

  .section-head__badge {
    display: inline-flex;
    align-items: center;
    gap: 8px;
    padding: 7px 12px;
    border-radius: 999px;
    background: rgba(99, 102, 241, 0.1);
    color: #4f46e5;
    font-size: 12px;
    font-weight: 700;
    width: fit-content;
  }

  .section-head__badge--amber {
    background: rgba(245, 158, 11, 0.12);
    color: #b45309;
  }

  .section-head__badge--emerald {
    background: rgba(16, 185, 129, 0.12);
    color: #047857;
  }

  .section-head h3 {
    margin: 6px 0 0;
    font-size: 20px;
    font-weight: 800;
    color: #18243d;
  }

  .chart-section {
    display: flex;
    flex-direction: column;
  }

  .chart-grid,
  .table-grid {
    display: grid;
    gap: 16px;
  }

  .chart-grid--dual,
  .table-grid {
    grid-template-columns: repeat(2, minmax(0, 1fr));
  }

  .chart-box {
    width: 100%;
    height: clamp(250px, 30vh, 320px);
  }

  .chart-box--wide {
    height: clamp(280px, 34vh, 360px);
  }

  .panel-card :deep(.n-data-table) {
    font-size: 13px;
  }

  @media (max-width: 1280px) {
    .dashboard-hero {
      flex-direction: column;
    }

    .dashboard-hero__aside {
      grid-template-columns: repeat(2, minmax(0, 1fr));
      min-width: 0;
    }
  }

  @media (max-width: 1024px) {
    .chart-grid--dual,
    .table-grid {
      grid-template-columns: 1fr;
    }
  }

  @media (max-width: 768px) {
    .dashboard {
      gap: 14px;
      padding: 2px;
    }

    .dashboard-hero {
      padding: 18px 16px;
      border-radius: 18px;
    }

    .dashboard-hero__aside,
    .kpi-strip,
    .stat-grid {
      grid-template-columns: 1fr;
    }

    .dashboard-ribbon {
      gap: 8px;
    }

    .panel-card :deep(.n-card__content),
    .kpi-card :deep(.n-card__content),
    .stat-card :deep(.n-card__content) {
      padding: 16px !important;
    }

    .section-head h3 {
      font-size: 18px;
    }
  }
</style>
