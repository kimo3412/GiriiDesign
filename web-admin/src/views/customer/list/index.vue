<template>
  <div class="customer-page">
    <!-- 顶部统计 -->
    <div class="stat-cards">
      <BusinessMetricCard label="全部客户" :value="total" icon="👥" variant="primary" />
      <BusinessMetricCard label="正常" :value="statusStats.find(s => s.value === 1)?.count || 0" icon="✅" variant="success" />
      <BusinessMetricCard label="禁用" :value="statusStats.find(s => s.value === 0)?.count || 0" icon="🚫" variant="error" />
    </div>

    <n-card :bordered="false" class="directory-card">
      <div class="directory-layout">
        <!-- 左侧：状态维度树 -->
        <div class="directory-tree">
          <div class="tree-header">状态筛选</div>
          <div class="tree-items">
            <div
              class="tree-item"
              :class="{ 'tree-item--active': selectedStatus === null }"
              @click="selectStatus(null)"
            >
              全部 <span class="tree-item__count">{{ total }}</span>
            </div>
            <div
              v-for="s in statusStats"
              :key="s.value"
              class="tree-item"
              :class="{ 'tree-item--active': selectedStatus === s.value }"
              @click="selectStatus(s.value)"
            >
              {{ s.label }} <span class="tree-item__count">{{ s.count }}</span>
            </div>
          </div>
        </div>

        <!-- 右侧：紧凑筛选 + 表格 -->
        <div class="directory-main">
          <div class="compact-filter">
            <n-input
              v-model:value="keyword"
              placeholder="搜索昵称或手机号..."
              size="small"
              clearable
              @keyup.enter="handleSearch"
              style="width: 200px"
            >
              <template #prefix
                ><n-icon><Search /></n-icon
              ></template>
            </n-input>
            <n-button size="small" type="primary" @click="loadData">搜索</n-button>
          </div>

          <n-data-table
            :columns="columns"
            :data="displayData"
            :loading="loading"
            :row-key="(row) => row.userId"
            size="small"
            :bordered="false"
          />

          <div class="compact-pagination">
            <n-pagination
              v-model:page="pageNum"
              v-modelv-model:page-size="pageSize"
              :page-sizes="[10, 20, 50]"
              :item-count="total"
              show-size-picker
              size="small"
              @update:page="handlePageChange"
              @update:page-size="handlePageSizeChange"
            />
          </div>
        </div>
      </div>
    </n-card>
  </div>
</template>

<script lang="ts" setup>
  import { ref, computed, onMounted, h } from 'vue';
  import { NAvatar, NIcon } from 'naive-ui';
  import { Search } from '@vicons/ionicons5';
  import { getCustomerList, type CustomerItem } from '@/api/customer';
  import { BusinessMetricCard } from '@/components/Business';
  import defaultCustomerAvatar from '@/assets/images/default-customer-avatar.png';

  const loading = ref(false);
  const tableData = ref<CustomerItem[]>([]);
  const total = ref(0);
  const pageNum = ref(1);
  const pageSize = ref(10);
  const keyword = ref('');
  const selectedStatus = ref<number | null>(null);

  const stats = computed(() => ({
    total: total.value,
    enabled: tableData.value.filter((r: CustomerItem) => r.status === 1).length,
    disabled: tableData.value.filter((r: CustomerItem) => r.status === 0).length,
  }));

  const statusStats = ref<{ label: string; value: number; count: number }[]>([
    { label: '正常', value: 1, count: 0 },
    { label: '禁用', value: 0, count: 0 },
  ]);

  const displayData = computed(() => tableData.value);

  const selectStatus = (val: number | null) => {
    selectedStatus.value = val;
    pageNum.value = 1;
    loadData();
  };

  const columns = [
    { title: 'ID', key: 'userId', width: 60 },
    {
      title: '客户',
      key: 'nickname',
      ellipsis: { tooltip: true },
      render(row: CustomerItem) {
        return h('div', { style: 'display:flex;align-items:center;gap:10px;' }, [
          h(NAvatar, {
            size: 36,
            round: true,
            src: row.avatarUrl || defaultCustomerAvatar,
            fallbackSrc: defaultCustomerAvatar,
          }),
          h('div', {}, [
            h(
              'div',
              { style: 'font-weight:600;font-size:13px;' },
              row.nickname || `用户#${row.userId}`
            ),
            h('div', { style: 'font-size:12px;color:var(--text-tertiary);' }, row.phone || '-'),
          ]),
        ]);
      },
    },
    {
      title: '状态',
      key: 'status',
      width: 70,
      render(row: CustomerItem) {
        const enabled = row.status === 1;
        return h(StatusBadge, {
          status: enabled ? 'enabled' : 'disabled',
          size: 'small',
          round: true,
          map: {
            enabled: { label: '正常', type: 'success' },
            disabled: { label: '禁用', type: 'error' },
          },
        });
      },
    },
    {
      title: '地址',
      key: 'addressCount',
      width: 60,
      align: 'center' as const,
      render: (r: CustomerItem) => r.addressCount || 0,
    },
    {
      title: '默认地址',
      key: 'defaultAddress',
      ellipsis: { tooltip: true },
      render: (r: CustomerItem) => r.defaultAddress || '-',
    },
    {
      title: '最后登录',
      key: 'lastLoginTime',
      width: 150,
      render: (r: CustomerItem) => (r.lastLoginTime ? r.lastLoginTime.slice(0, 16) : '-'),
    },
    {
      title: '注册时间',
      key: 'createTime',
      width: 150,
      render: (r: CustomerItem) => (r.createTime ? r.createTime.slice(0, 16) : '-'),
    },
  ];

  const loadData = async () => {
    loading.value = true;
    try {
      const res = await getCustomerList({
        keyword: keyword.value || undefined,
        status: selectedStatus.value ?? undefined,
        pageNum: pageNum.value,
        pageSize: pageSize.value,
      });
      tableData.value = res.records || [];
      total.value = res.total || 0;
      if (res.stats) {
        statusStats.value = [
          { label: '正常', value: 1, count: res.stats.enabled || 0 },
          { label: '禁用', value: 0, count: res.stats.disabled || 0 },
        ];
      }
    } finally {
      loading.value = false;
    }
  };
  const handleSearch = () => {
    pageNum.value = 1;
    loadData();
  };

  const handlePageChange = (page: number) => {
    pageNum.value = page;
    loadData();
  };

  const handlePageSizeChange = (size: number) => {
    pageSize.value = size;
    pageNum.value = 1;
    loadData();
  };


  onMounted(loadData);
</script>

<script lang="ts">
  import StatusBadge from '@/components/Business/StatusBadge.vue';
  export default { name: 'CustomerList' };
</script>

<style scoped>
  .customer-page {
    display: flex;
    flex-direction: column;
    gap: 12px;
  }

  .stat-cards {
    display: flex;
    flex-wrap: wrap;
    gap: 10px;
  }

  .stat-cards :deep(.metric-card) {
    flex: 0 1 180px;
  }

  .directory-card :deep(.n-card__content) {
    padding: 0;
  }

  .directory-layout {
    display: flex;
    height: calc(100vh - 260px);
    min-height: 400px;
  }

  .directory-tree {
    width: 150px;
    flex-shrink: 0;
    border-right: 1px solid var(--border-light);
    background: var(--page-bg);
  }

  .tree-header {
    font-size: 12px;
    font-weight: 600;
    color: var(--text-tertiary);
    text-transform: uppercase;
    letter-spacing: 0.5px;
    padding: 12px 16px 8px;
    border-bottom: 1px solid var(--border-light);
  }

  .tree-items {
    padding: 8px 0;
  }

  .tree-item {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 8px 16px;
    font-size: 13px;
    color: var(--text-secondary);
    cursor: pointer;
    transition: background 0.15s;
  }
  .tree-item:hover {
    background: var(--row-selected-bg);
  }
  .tree-item--active {
    background: var(--row-selected-bg);
    color: var(--primary-color);
    font-weight: 600;
    border-left: 3px solid var(--primary-color);
  }
  .tree-item__count {
    font-size: 11px;
    color: var(--text-placeholder);
    background: var(--border-light);
    padding: 1px 6px;
    border-radius: 8px;
  }
  .tree-item--active .tree-item__count {
    background: var(--primary-bg);
    color: var(--primary-color);
  }

  .directory-main {
    flex: 1;
    display: flex;
    flex-direction: column;
    overflow: hidden;
    min-height: 0;
    padding: 14px 16px;
    gap: 12px;
  }

  .compact-filter {
    display: flex;
    align-items: center;
    gap: 8px;
  }

  .directory-main :deep(.n-data-table) {
    flex: 1;
    min-height: 0;
  }

  .directory-main :deep(.n-data-table-wrapper),
  .directory-main :deep(.n-data-table-base-table),
  .directory-main :deep(.n-data-table-base-table-body) {
    min-height: 0;
  }

  .compact-pagination {
    display: flex;
    justify-content: flex-end;
    flex-shrink: 0;
    padding-top: 8px;
    border-top: 1px solid var(--border-light);
  }
</style>
