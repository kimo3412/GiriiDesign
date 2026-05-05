<template>
  <div class="category-page">
    <!-- 顶部统计 -->
    <div class="stat-cards">
      <BusinessMetricCard label="全部品类" :value="stats.total" icon="📋" variant="primary" />
      <BusinessMetricCard label="已启用" :value="stats.active" icon="✅" variant="success" />
      <BusinessMetricCard label="停用中" :value="stats.inactive" icon="🚫" variant="error" />
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
              全部 <span class="tree-item__count">{{ stats.total }}</span>
            </div>
            <div
              class="tree-item"
              :class="{ 'tree-item--active': selectedStatus === 1 }"
              @click="selectStatus(1)"
            >
              已启用 <span class="tree-item__count">{{ stats.active }}</span>
            </div>
            <div
              class="tree-item"
              :class="{ 'tree-item--active': selectedStatus === 0 }"
              @click="selectStatus(0)"
            >
              停用中 <span class="tree-item__count">{{ stats.inactive }}</span>
            </div>
          </div>
        </div>

        <!-- 右侧：紧凑筛选 + 表格 -->
        <div class="directory-main">
          <div class="compact-filter">
            <n-input
              v-model:value="keyword"
              placeholder="搜索品类名称..."
              size="small"
              clearable
              @keyup.enter="handleSearch"
              style="width: 200px"
            >
              <template #prefix><n-icon><Search /></n-icon></template>
            </n-input>
            <n-button size="small" type="primary" @click="handleSearch">搜索</n-button>
            <n-divider vertical />
            <n-button :disabled="!checkedKeys.length" size="small" type="error" ghost @click="handleBatchDelete">
              批量删除{{ checkedKeys.length ? `(${checkedKeys.length})` : '' }}
            </n-button>
            <n-button size="small" type="primary" @click="handleAdd">新增品类</n-button>
          </div>

          <n-data-table
            v-model:checked-row-keys="checkedKeys"
            :columns="columns"
            :data="pagedData"
            :loading="loading"
            :row-key="row => row.categoryId"
            size="small"
            :bordered="false"
          />

          <div class="compact-pagination">
            <n-pagination
              v-model:page="pageNum"
              v-model:page-size="pageSize"
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

    <!-- 新增/编辑弹窗 -->
    <n-modal
      v-model:show="showModal"
      :title="isEdit ? '编辑品类' : '新增品类'"
      preset="dialog"
      positive-text="确定"
      negative-text="取消"
      @positive-click="handleSubmit"
      @negative-click="showModal = false"
      style="width: 500px"
    >
      <n-form
        ref="formRef"
        :model="formData"
        :rules="rules"
        label-placement="left"
        label-width="80"
      >
        <n-form-item label="品类名称" path="name">
          <n-input v-model:value="formData.name" placeholder="请输入品类名称" />
        </n-form-item>
        <n-form-item label="图标URL" path="iconUrl">
          <n-input v-model:value="formData.iconUrl" placeholder="图标地址（可选）" />
        </n-form-item>
        <n-form-item label="排序" path="sortOrder">
          <n-input-number v-model:value="formData.sortOrder" :min="0" style="width: 100%" />
        </n-form-item>
        <n-form-item label="需要BOM">
          <n-switch v-model:value="formData.hasBom" :checked-value="1" :unchecked-value="0" />
        </n-form-item>
        <n-form-item label="实体产品">
          <n-switch v-model:value="formData.isPhysical" :checked-value="1" :unchecked-value="0" />
        </n-form-item>
        <n-form-item label="是否启用">
          <n-switch v-model:value="formData.isActive" :checked-value="1" :unchecked-value="0" />
        </n-form-item>
      </n-form>
    </n-modal>
  </div>
</template>

<script lang="ts" setup>
import { ref, computed, onMounted, h, watch } from 'vue';
import { useRouter } from 'vue-router';
import { NButton, NTag, NSpace, NIcon, NDivider } from 'naive-ui';
import { Search } from '@vicons/ionicons5';
import { PlusOutlined } from '@vicons/antd';
import { useMessage, useDialog } from 'naive-ui';
import { BusinessMetricCard } from '@/components/Business';
import {
  getCategoryList,
  addCategory,
  updateCategory,
  deleteCategory,
  batchDeleteCategories,
} from '@/api/config/category';

const message = useMessage();
const dialog = useDialog();
const router = useRouter();

const loading = ref(false);
const tableData = ref<any[]>([]);
const total = ref(0);
const pageNum = ref(1);
const pageSize = ref(10);

const keyword = ref('');
const selectedStatus = ref<number | null>(null);
const showModal = ref(false);
const isEdit = ref(false);
const formRef = ref();
const checkedKeys = ref<number[]>([]);

const formData = ref({
  categoryId: null as number | null,
  name: '',
  iconUrl: '',
  sortOrder: 0,
  hasBom: 0,
  isPhysical: 1,
  isActive: 1,
});

const rules = {
  name: { required: true, message: '请输入品类名称', trigger: 'blur' },
};

// 统计
const stats = computed(() => {
  const all = tableData.value;
  return {
    total: all.length,
    active: all.filter((r: any) => r.isActive === 1).length,
    inactive: all.filter((r: any) => r.isActive === 0).length,
  };
});

// 筛选后数据
const displayData = computed(() => {
  let list = [...tableData.value];
  if (selectedStatus.value !== null) {
    list = list.filter((r: any) => r.isActive === selectedStatus.value);
  }
  if (keyword.value) {
    const kw = keyword.value.toLowerCase();
    list = list.filter((r: any) => (r.name || '').toLowerCase().includes(kw));
  }
  return list;
});

const pagedData = computed(() => {
  const start = (pageNum.value - 1) * pageSize.value;
  return displayData.value.slice(start, start + pageSize.value);
});

watch(displayData, (list) => {
  total.value = list.length;
  const maxPage = Math.max(1, Math.ceil(list.length / pageSize.value));
  if (pageNum.value > maxPage) pageNum.value = maxPage;
}, { immediate: true });


const selectStatus = (val: number | null) => {
  selectedStatus.value = val;
  pageNum.value = 1;
};

const columns = [
  { type: 'selection', width: 40 },
  { title: 'ID', key: 'categoryId', width: 60 },
  { title: '品类名称', key: 'name', ellipsis: { tooltip: true } },
  {
    title: '状态',
    key: 'isActive',
    width: 80,
    render(row: any) {
      return h(NTag, { type: row.isActive === 1 ? 'success' : 'default', size: 'small', round: true }, {
        default: () => row.isActive === 1 ? '启用' : '停用',
      });
    },
  },
  {
    title: '需要BOM',
    key: 'hasBom',
    width: 90,
    render(row: any) {
      return h(NTag, { type: row.hasBom === 1 ? 'info' : 'default', size: 'small', round: true }, {
        default: () => row.hasBom === 1 ? '是' : '否',
      });
    },
  },
  {
    title: '实体产品',
    key: 'isPhysical',
    width: 90,
    render(row: any) {
      return h(NTag, { type: row.isPhysical === 1 ? 'info' : 'default', size: 'small', round: true }, {
        default: () => row.isPhysical === 1 ? '是' : '否',
      });
    },
  },
  { title: '排序', key: 'sortOrder', width: 60 },
  {
    title: '操作',
    key: 'actions',
    width: 200,
    render(row: any) {
      return h(NSpace, { size: 4 }, {
        default: () => [
          h(NButton, { text: true, type: 'primary', size: 'tiny', onClick: () => handleEdit(row) }, { default: () => '编辑' }),
          h(NButton, { text: true, type: 'info', size: 'tiny', onClick: () => handleFields(row) }, { default: () => '字段' }),
          h(NButton, { text: true, type: 'info', size: 'tiny', onClick: () => handleWorkflow(row) }, { default: () => '工作流' }),
          h(NButton, { text: true, type: 'error', size: 'tiny', onClick: () => handleDelete(row) }, { default: () => '删除' }),
        ],
      });
    },
  },
];

const loadData = async () => {
  loading.value = true;
  try {
    tableData.value = await getCategoryList();
    total.value = tableData.value.length;
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
};

const handlePageSizeChange = (size: number) => {
  pageSize.value = size;
  pageNum.value = 1;
};

onMounted(() => {
  loadData();
});

const handleAdd = () => {
  isEdit.value = false;
  formData.value = { categoryId: null, name: '', iconUrl: '', sortOrder: 0, hasBom: 0, isPhysical: 1, isActive: 1 };
  showModal.value = true;
};

const handleEdit = (row: any) => {
  isEdit.value = true;
  formData.value = { ...row };
  showModal.value = true;
};

const handleSubmit = async () => {
  try {
    if (isEdit.value && formData.value.categoryId) {
      await updateCategory(formData.value.categoryId, formData.value);
      message.success('修改成功');
    } else {
      await addCategory(formData.value);
      message.success('新增成功');
    }
    showModal.value = false;
    await loadData();
  } catch (e) {
    return false;
  }
};

const handleDelete = (row: any) => {
  dialog.warning({
    title: '确认删除',
    content: `确定要删除品类「${row.name}」吗？`,
    positiveText: '删除',
    negativeText: '取消',
    onPositiveClick: async () => {
      await deleteCategory(row.categoryId);
      message.success('删除成功');
      await loadData();
    },
  });
};

const handleBatchDelete = () => {
  dialog.warning({
    title: '确认批量删除',
    content: `确定要删除选中的 ${checkedKeys.value.length} 个品类吗？`,
    positiveText: '删除',
    negativeText: '取消',
    onPositiveClick: async () => {
      try {
        await batchDeleteCategories(checkedKeys.value);
        message.success('批量删除成功');
        checkedKeys.value = [];
        await loadData();
      } catch (e) { console.error(e); }
    },
  });
};

const handleFields = (row: any) => {
  router.push({ path: '/config/config/field', query: { categoryId: row.categoryId } });
};

const handleWorkflow = (row: any) => {
  router.push({ path: '/config/config/workflow', query: { categoryId: row.categoryId } });
};
</script>

<style scoped>
.category-page {
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

.directory-card :deep(.n-card__content) { padding: 0; }

.directory-layout {
  display: flex;
  height: calc(100vh - 260px);
  min-height: 400px;
}

.directory-tree {
  width: 160px;
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

.tree-items { padding: 8px 0; }

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
.tree-item:hover { background: var(--row-selected-bg); }
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
.tree-item--active .tree-item__count { background: var(--primary-bg); color: var(--primary-color); }

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
