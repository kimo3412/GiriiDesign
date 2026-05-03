<template>
  <div class="dashboard">
    <section class="dashboard-hero">
      <div class="dashboard-hero__content">
        <div class="dashboard-eyebrow">经营看板</div>
        <h2 class="dashboard-title">工作室经营概览</h2>
        <p class="dashboard-desc">
          首屏只保留关键经营信号，详细图表按主题展开，避免所有分析内容一次性堆在页面里。
        </p>
        <div class="dashboard-ribbon">
          <span class="dashboard-ribbon__chip">订单节奏</span>
          <span class="dashboard-ribbon__chip">营收质量</span>
          <span class="dashboard-ribbon__chip">流程效率</span>
        </div>
      </div>
      <div class="dashboard-hero__aside">
        <button
          v-for="hero in heroCards"
          :key="hero.label"
          class="hero-pill"
          type="button"
          @click="openDetail(hero.detail)"
        >
          <span>{{ hero.label }}</span>
          <strong>{{ hero.value }}</strong>
        </button>
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

    <section class="risk-strip">
      <button
        v-for="risk in riskCards"
        :key="risk.label"
        class="risk-card"
        type="button"
        @click="openDetail(risk.detail)"
      >
        <span class="risk-card__icon" :class="risk.iconClass">
          <n-icon size="18">
            <component :is="risk.icon" />
          </n-icon>
        </span>
        <span class="risk-card__body">
          <span class="risk-card__label">{{ risk.label }}</span>
          <strong>{{ risk.value }}</strong>
          <n-tag :type="risk.tagType" size="small" round>{{ risk.tag }}</n-tag>
        </span>
      </button>
    </section>

    <n-card :bordered="false" class="analysis-shell">
      <div class="analysis-header">
        <div>
          <div class="analysis-kicker">
            <n-icon size="16"><RiseOutlined /></n-icon>
            <span>主题分析</span>
          </div>
          <h3>{{ activeTabMeta.title }}</h3>
          <p>{{ activeTabMeta.desc }}</p>
        </div>
        <n-button text type="primary" @click="openDetail(activeTab)">查看完整明细</n-button>
      </div>

      <n-tabs v-model:value="activeTab" type="segment" animated class="analysis-tabs">
        <n-tab-pane name="orders" tab="订单趋势">
          <div class="chart-grid">
            <n-card title="近 7 天订单与营收" size="small" :bordered="false" class="panel-card">
              <div ref="trendChartRef" class="chart-box chart-box--wide"></div>
            </n-card>
            <n-card title="订单状态分布" size="small" :bordered="false" class="panel-card">
              <div ref="pieChartRef" class="chart-box"></div>
            </n-card>
          </div>
        </n-tab-pane>

        <n-tab-pane name="revenue" tab="营收结构">
          <div class="chart-grid">
            <n-card title="月度营收趋势" size="small" :bordered="false" class="panel-card">
              <div ref="areaChartRef" class="chart-box chart-box--wide"></div>
            </n-card>
            <n-card title="品类订单排名" size="small" :bordered="false" class="panel-card">
              <div ref="barChartRef" class="chart-box"></div>
            </n-card>
          </div>
        </n-tab-pane>

        <n-tab-pane name="conversion" tab="转化流程">
          <div class="chart-grid">
            <n-card title="品类转化率" size="small" :bordered="false" class="panel-card">
              <div ref="conversionChartRef" class="chart-box"></div>
            </n-card>
            <n-card title="流程瓶颈节点" size="small" :bordered="false" class="panel-card">
              <div ref="bottleneckChartRef" class="chart-box"></div>
            </n-card>
          </div>
        </n-tab-pane>

        <n-tab-pane name="efficiency" tab="团队效率">
          <div class="table-grid">
            <n-card title="设计师效率" size="small" :bordered="false" class="panel-card">
              <n-data-table
                :columns="designerColumns"
                :data="designerTableData"
                :pagination="false"
              />
            </n-card>
            <n-card title="品类转化明细" size="small" :bordered="false" class="panel-card">
              <n-data-table
                :columns="conversionColumns"
                :data="conversionTableData"
                :pagination="false"
              />
            </n-card>
          </div>
        </n-tab-pane>
      </n-tabs>
    </n-card>

    <n-drawer v-model:show="showDetailDrawer" :width="520" placement="right">
      <n-drawer-content :title="drawerMeta.title" closable>
        <p class="drawer-desc">{{ drawerMeta.desc }}</p>

        <div v-if="drawerMode === 'orders'" class="drawer-section">
          <h4>订单状态</h4>
          <div v-if="statusList.length" class="drawer-list">
            <div v-for="item in statusList" :key="item.name" class="drawer-row">
              <span>{{ item.name }}</span>
              <strong>{{ item.value }} 单</strong>
            </div>
          </div>
          <n-empty v-else description="暂无订单状态数据" />
        </div>

        <div v-if="drawerMode === 'revenue'" class="drawer-section">
          <h4>营收趋势</h4>
          <div v-if="monthlyRevenueList.length" class="drawer-list">
            <div v-for="item in monthlyRevenueList" :key="item.month" class="drawer-row">
              <span>{{ item.month }}</span>
              <strong>{{ formatCurrency(item.revenue) }}</strong>
            </div>
          </div>
          <n-empty v-else description="暂无营收数据" />
        </div>

        <div v-if="drawerMode === 'conversion'" class="drawer-section">
          <h4>品类转化</h4>
          <div v-if="conversionTableData.length" class="drawer-list">
            <div v-for="item in conversionTableData" :key="item.category_name" class="drawer-row">
              <span>{{ item.category_name || '未命名品类' }}</span>
              <strong>{{ Number(item.conversionRate || 0).toFixed(2) }}%</strong>
            </div>
          </div>
          <n-empty v-else description="暂无转化数据" />
        </div>

        <div v-if="drawerMode === 'efficiency'" class="drawer-section">
          <h4>流程瓶颈</h4>
          <div v-if="workflowBottleneckList.length" class="drawer-list">
            <div v-for="item in workflowBottleneckList" :key="item.step_name" class="drawer-row">
              <span>{{ item.step_name || '未知节点' }}</span>
              <strong>{{ Number(item.avg_stay_days || 0).toFixed(2) }} 天</strong>
            </div>
          </div>
          <n-empty v-else description="暂无流程瓶颈数据" />
        </div>

        <div v-if="drawerMode === 'risk'" class="drawer-section drawer-risk">
          <div class="drawer-risk__card">
            <span>待处理意向</span>
            <strong>{{ Number(data.pendingRequests || 0) }}</strong>
          </div>
          <div class="drawer-risk__card">
            <span>低库存物料</span>
            <strong>{{ Number(data.lowStockMaterials || 0) }}</strong>
          </div>
          <div class="drawer-risk__card">
            <span>复购客户</span>
            <strong>{{ Number(data.repeatCustomers || 0) }}</strong>
          </div>
        </div>
      </n-drawer-content>
    </n-drawer>
  </div>
</template>

<script lang="ts" setup>
  import { computed, nextTick, onMounted, ref, watch, type Ref } from 'vue';
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

  type AnalysisTab = 'orders' | 'revenue' | 'conversion' | 'efficiency';
  type DrawerMode = AnalysisTab | 'risk';

  const data = ref<Partial<DashboardData>>({});
  const activeTab = ref<AnalysisTab>('orders');
  const showDetailDrawer = ref(false);
  const drawerMode = ref<DrawerMode>('orders');

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

  const tabMeta: Record<AnalysisTab, { title: string; desc: string }> = {
    orders: {
      title: '订单趋势',
      desc: '关注最近 7 天订单与营收节奏，判断工作室当前接单状态。',
    },
    revenue: {
      title: '营收结构',
      desc: '查看月度营收与品类贡献，快速定位最值得投入的业务方向。',
    },
    conversion: {
      title: '转化流程',
      desc: '追踪意向到订单、订单到完成的链路质量，发现转化断点。',
    },
    efficiency: {
      title: '团队效率',
      desc: '对比设计师处理效率与节点停留时长，及时发现流程瓶颈。',
    },
  };

  const drawerConfig: Record<DrawerMode, { title: string; desc: string }> = {
    orders: {
      title: '订单明细',
      desc: '这里保留订单状态分布，适合查看当前订单池是否健康。',
    },
    revenue: {
      title: '营收明细',
      desc: '按月查看营收走势，辅助判断近期订单质量。',
    },
    conversion: {
      title: '转化明细',
      desc: '按品类查看意向转单效率，适合排查哪个品类需要重点跟进。',
    },
    efficiency: {
      title: '效率明细',
      desc: '查看流程中平均停留较久的节点，辅助优化排期。',
    },
    risk: {
      title: '经营提醒',
      desc: '把需要马上处理的经营信号聚合到一起，避免被图表淹没。',
    },
  };

  const activeTabMeta = computed(() => tabMeta[activeTab.value]);
  const drawerMeta = computed(() => drawerConfig[drawerMode.value]);

  const heroCards = computed(() => [
    {
      label: '本月新增订单',
      value: Number(data.value.monthOrders || 0).toString(),
      detail: 'orders' as DrawerMode,
    },
    {
      label: '本月营收',
      value: formatCurrency(data.value.monthRevenue || 0),
      detail: 'revenue' as DrawerMode,
    },
  ]);

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
      prefix: '￥',
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

  const riskCards = computed(() => [
    {
      label: '待处理意向',
      value: Number(data.value.pendingRequests || 0),
      icon: TagsOutlined,
      iconClass: 'risk-card__icon--warning',
      tag: '需要跟进',
      tagType: 'warning' as const,
      detail: 'risk' as DrawerMode,
    },
    {
      label: '低库存物料',
      value: Number(data.value.lowStockMaterials || 0),
      icon: BarChartOutlined,
      iconClass: 'risk-card__icon--error',
      tag: '需要补货',
      tagType: 'error' as const,
      detail: 'risk' as DrawerMode,
    },
    {
      label: '平均客单价',
      value: formatCurrency(data.value.averageOrderAmount || 0),
      icon: AccountBookOutlined,
      iconClass: 'risk-card__icon--info',
      tag: '质量指标',
      tagType: 'info' as const,
      detail: 'revenue' as DrawerMode,
    },
    {
      label: '复购客户',
      value: Number(data.value.repeatCustomers || 0),
      icon: ProfileOutlined,
      iconClass: 'risk-card__icon--success',
      tag: `${Number(data.value.repeatCustomerRate || 0).toFixed(2)}%`,
      tagType: 'success' as const,
      detail: 'risk' as DrawerMode,
    },
  ]);

  const statusList = computed(() =>
    (data.value.orderStatusDistribution || []).map((item) => ({
      name: STATUS_MAP[item.status] || `状态 ${item.status}`,
      value: Number(item.count || 0),
    }))
  );

  const monthlyRevenueList = computed(() => data.value.monthlyRevenueTrend || []);
  const workflowBottleneckList = computed(() => data.value.workflowBottlenecks || []);

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
    await renderActiveCharts();
  });

  watch(activeTab, () => {
    renderActiveCharts();
  });

  function openDetail(mode: DrawerMode) {
    drawerMode.value = mode;
    showDetailDrawer.value = true;
  }

  async function renderActiveCharts() {
    await nextTick();
    if (!data.value) return;

    if (activeTab.value === 'orders') {
      renderOrderCharts(data.value);
      return;
    }

    if (activeTab.value === 'revenue') {
      renderRevenueCharts(data.value);
      return;
    }

    if (activeTab.value === 'conversion') {
      renderConversionCharts(data.value);
    }
  }

  function renderOrderCharts(d: Partial<DashboardData>) {
    const trendDates = (d.dailyOrderTrend || []).map((item) => item.date?.substring(5) || '');
    const trendCounts = (d.dailyOrderTrend || []).map((item) => Number(item.order_count || 0));
    const trendRevenue = (d.dailyOrderTrend || []).map((item) => Number(item.revenue || 0));

    setTrendOptions({
      color: ['#1f2f82', '#24a3c7'],
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
      color: ['#1f2f82', '#4f6ef7', '#28b6a5', '#f5a524', '#ef5b72', '#94a3b8'],
      tooltip: { trigger: 'item', formatter: '{b}: {c} ({d}%)' },
      legend: { bottom: 0 },
      series: [
        {
          type: 'pie',
          radius: ['42%', '66%'],
          center: ['50%', '42%'],
          data: statusList.value.map((item) => ({
            name: item.name,
            value: item.value,
          })),
        },
      ],
    });
  }

  function renderRevenueCharts(d: Partial<DashboardData>) {
    setAreaOptions({
      color: ['#1f2f82', '#f59e0b'],
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
          areaStyle: { opacity: 0.12 },
        },
        {
          name: '订单数',
          type: 'bar',
          yAxisIndex: 1,
          data: (d.monthlyRevenueTrend || []).map((item) => Number(item.order_count || 0)),
        },
      ],
    });

    setBarOptions({
      color: ['#1f2f82'],
      tooltip: { trigger: 'axis', axisPointer: { type: 'shadow' } },
      grid: { left: '3%', right: '8%', bottom: '3%', containLabel: true },
      xAxis: { type: 'value' },
      yAxis: {
        type: 'category',
        data: (d.categoryRank || []).map((item) => item.category_name || '未命名品类').reverse(),
      },
      series: [
        {
          type: 'bar',
          data: (d.categoryRank || []).map((item) => Number(item.order_count || 0)).reverse(),
          barWidth: '48%',
          itemStyle: { borderRadius: [0, 8, 8, 0] },
        },
      ],
    });
  }

  function renderConversionCharts(d: Partial<DashboardData>) {
    const conversionData = conversionTableData.value;
    setConversionOptions({
      color: ['#1f2f82', '#28b6a5'],
      tooltip: { trigger: 'axis' },
      legend: { data: ['转化率', '完成率'], bottom: 0 },
      grid: { left: '3%', right: '4%', bottom: '15%', containLabel: true },
      xAxis: {
        type: 'category',
        data: conversionData.map((item) => item.category_name || '未命名品类'),
      },
      yAxis: { type: 'value', axisLabel: { formatter: '{value}%' } },
      series: [
        {
          name: '转化率',
          type: 'bar',
          data: conversionData.map((item) => Number(item.conversionRate || 0)),
          itemStyle: { borderRadius: [8, 8, 0, 0] },
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
      color: ['#f59e0b'],
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
          barWidth: '48%',
          itemStyle: { borderRadius: [0, 8, 8, 0] },
        },
      ],
    });
  }

  function formatCurrency(value: unknown) {
    return `￥${Number(value || 0).toFixed(2)}`;
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

  .dashboard-hero__content,
  .dashboard-hero__aside {
    position: relative;
    z-index: 1;
  }

  .dashboard-hero__content {
    max-width: 720px;
  }

  .dashboard-eyebrow {
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
    border: 1px solid rgba(99, 102, 241, 0.12);
    border-radius: 18px;
    background: rgba(255, 255, 255, 0.92);
    text-align: left;
    cursor: pointer;
    transition: all 0.2s ease;
  }

  .hero-pill:hover {
    transform: translateY(-1px);
    box-shadow: 0 12px 26px rgba(31, 47, 130, 0.08);
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

  .stat-grid,
  .risk-strip {
    display: grid;
    gap: 14px;
  }

  .stat-grid {
    grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
  }

  .risk-strip {
    grid-template-columns: repeat(auto-fit, minmax(210px, 1fr));
  }

  .stat-card,
  .panel-card,
  .analysis-shell,
  .risk-card {
    position: relative;
    border-radius: 20px;
    background: rgba(255, 255, 255, 0.96);
    border: 1px solid rgba(226, 232, 240, 0.7);
    overflow: hidden;
    box-shadow: 0 10px 26px rgba(15, 23, 42, 0.04);
  }

  .stat-card::before,
  .panel-card::before,
  .analysis-shell::before,
  .risk-card::before {
    content: '';
    position: absolute;
    inset: 0 auto auto 0;
    width: 100%;
    height: 1px;
    background: linear-gradient(90deg, rgba(99, 102, 241, 0.34), transparent 72%);
  }

  .stat-card:hover,
  .panel-card:hover,
  .risk-card:hover {
    transform: translateY(-1px);
    box-shadow: 0 14px 30px rgba(15, 23, 42, 0.06);
  }

  .stat-card :deep(.n-card__content) {
    display: flex;
    align-items: center;
    gap: 16px;
    padding: 18px 20px !important;
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

  .stat-label,
  .risk-card__label {
    font-size: 12px;
    color: #718096;
  }

  .stat-label {
    margin-bottom: 6px;
  }

  .stat-value {
    font-size: clamp(24px, 2vw, 30px);
    font-weight: 800;
    color: #18243d;
    line-height: 1.1;
  }

  .risk-card {
    display: flex;
    align-items: center;
    gap: 12px;
    padding: 16px;
    text-align: left;
    cursor: pointer;
    transition: all 0.2s ease;
  }

  .risk-card__icon {
    width: 42px;
    height: 42px;
    border-radius: 14px;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    flex-shrink: 0;
    color: #fff;
  }

  .risk-card__icon--warning {
    background: linear-gradient(135deg, #fbbf24, #f59e0b);
  }

  .risk-card__icon--error {
    background: linear-gradient(135deg, #fb7185, #ef4444);
  }

  .risk-card__icon--info {
    background: linear-gradient(135deg, #60a5fa, #2563eb);
  }

  .risk-card__icon--success {
    background: linear-gradient(135deg, #34d399, #10b981);
  }

  .risk-card__body {
    display: flex;
    flex-direction: column;
    align-items: flex-start;
    gap: 6px;
    min-width: 0;
  }

  .risk-card__body strong {
    font-size: 22px;
    font-weight: 800;
    color: #18243d;
    line-height: 1;
  }

  .analysis-shell :deep(.n-card__content) {
    padding: 20px !important;
  }

  .analysis-header {
    display: flex;
    justify-content: space-between;
    gap: 16px;
    margin-bottom: 18px;
  }

  .analysis-kicker {
    display: inline-flex;
    align-items: center;
    gap: 8px;
    padding: 7px 12px;
    border-radius: 999px;
    background: rgba(99, 102, 241, 0.1);
    color: #4f46e5;
    font-size: 12px;
    font-weight: 700;
  }

  .analysis-header h3 {
    margin: 10px 0 4px;
    font-size: 20px;
    font-weight: 800;
    color: #18243d;
  }

  .analysis-header p {
    margin: 0;
    color: #667085;
    font-size: 13px;
    line-height: 1.6;
  }

  .analysis-tabs :deep(.n-tabs-nav) {
    margin-bottom: 16px;
  }

  .chart-grid,
  .table-grid {
    display: grid;
    grid-template-columns: repeat(2, minmax(0, 1fr));
    gap: 16px;
  }

  .panel-card :deep(.n-card-header) {
    padding: 18px 20px 0 !important;
  }

  .panel-card :deep(.n-card__content) {
    padding: 18px 20px !important;
  }

  .panel-card :deep(.n-card-header__main) {
    font-size: 15px;
    font-weight: 700;
    color: #18243d;
  }

  .panel-card :deep(.n-data-table) {
    font-size: 13px;
  }

  .chart-box {
    width: 100%;
    height: clamp(250px, 30vh, 320px);
  }

  .chart-box--wide {
    height: clamp(280px, 34vh, 360px);
  }

  .drawer-desc {
    margin: 0 0 18px;
    color: #667085;
    line-height: 1.7;
  }

  .drawer-section {
    display: flex;
    flex-direction: column;
    gap: 12px;
  }

  .drawer-section h4 {
    margin: 0;
    font-size: 15px;
    color: #18243d;
  }

  .drawer-list {
    display: flex;
    flex-direction: column;
    gap: 10px;
  }

  .drawer-row {
    display: flex;
    justify-content: space-between;
    gap: 12px;
    padding: 12px 14px;
    border-radius: 14px;
    background: #f8fafc;
    color: #475467;
  }

  .drawer-row strong {
    color: #18243d;
    white-space: nowrap;
  }

  .drawer-risk {
    display: grid;
    grid-template-columns: repeat(2, minmax(0, 1fr));
  }

  .drawer-risk__card {
    padding: 14px;
    border-radius: 16px;
    background: #f8fafc;
  }

  .drawer-risk__card span {
    display: block;
    color: #718096;
    font-size: 12px;
    margin-bottom: 8px;
  }

  .drawer-risk__card strong {
    font-size: 22px;
    color: #18243d;
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
    .chart-grid,
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
    .stat-grid,
    .risk-strip {
      grid-template-columns: 1fr;
    }

    .analysis-header {
      flex-direction: column;
      align-items: flex-start;
    }

    .analysis-shell :deep(.n-card__content),
    .panel-card :deep(.n-card__content),
    .stat-card :deep(.n-card__content) {
      padding: 16px !important;
    }

    .drawer-risk {
      grid-template-columns: 1fr;
    }
  }
</style>
