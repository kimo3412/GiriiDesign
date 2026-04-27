<template>
  <div class="banner-page">
    <!-- 顶部统计 -->
    <div class="stat-cards">
      <BusinessMetricCard label="全部轮播图" :value="stats.total" icon="📋" variant="primary" />
      <BusinessMetricCard label="已启用" :value="stats.active" icon="✅" variant="success" />
      <BusinessMetricCard label="已禁用" :value="stats.inactive" icon="🚫" variant="error" />
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
              已禁用 <span class="tree-item__count">{{ stats.inactive }}</span>
            </div>
          </div>
        </div>

        <!-- 右侧：紧凑筛选 + 表格 -->
        <div class="directory-main">
          <div class="compact-filter">
            <n-input
              v-model:value="keyword"
              placeholder="搜索标题..."
              size="small"
              clearable
              @keyup.enter="loadData"
              style="width: 200px"
            >
              <template #prefix><n-icon><Search /></n-icon></template>
            </n-input>
            <n-button size="small" type="primary" @click="loadData">搜索</n-button>
            <n-divider vertical />
            <n-button size="small" type="primary" @click="handleAdd">新增轮播图</n-button>
          </div>

          <n-data-table
            :columns="columns"
            :data="displayData"
            :loading="loading"
            :row-key="row => row.bannerId"
            size="small"
            :bordered="false"
          />

          <div class="compact-pagination">
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
      </div>
    </n-card>

    <!-- 新增/编辑弹窗 -->
    <n-modal
      v-model:show="showModal"
      :title="isEdit ? '编辑轮播图' : '新增轮播图'"
      preset="dialog"
      positive-text="确定"
      negative-text="取消"
      @positive-click="handleSubmit"
      style="width: 520px"
    >
      <n-form :model="formData" ref="formRef" label-placement="left" label-width="80">
        <n-form-item label="标题" path="title">
          <n-input v-model:value="formData.title" placeholder="请输入轮播图标题" />
        </n-form-item>
        <n-form-item label="图片" path="imageUrl">
          <n-upload
            :custom-request="handleUpload"
            :file-list="coverFileList"
            list-type="image"
            :max="1"
            accept="image/*"
          >
            <n-button size="small">点击上传</n-button>
          </n-upload>
        </n-form-item>
        <n-form-item label="跳转类型" path="linkType">
          <n-select v-model:value="formData.linkType" :options="linkTypeOptions" placeholder="选择跳转类型（可选）" clearable />
        </n-form-item>
        <n-form-item label="跳转链接" path="linkUrl">
          <n-input v-model:value="formData.linkUrl" placeholder="跳转链接（可选）" />
        </n-form-item>
        <n-form-item label="排序" path="sortOrder">
          <n-input-number v-model:value="formData.sortOrder" :min="0" style="width: 100%" />
        </n-form-item>
        <n-form-item label="状态" path="status">
          <n-switch v-model:value="formData.status" :checked-value="1" :unchecked-value="0">
            <template #checked>启用</template>
            <template #unchecked>禁用</template>
          </n-switch>
        </n-form-item>
      </n-form>
    </n-modal>
  </div>
</template>

<script lang="ts" setup>
import { ref, computed, onMounted, h } from 'vue';
import { NButton, NSpace, NIcon, NDivider, NImage, NSwitch } from 'naive-ui';
import { Search } from '@vicons/ionicons5';
import { useMessage, useDialog } from 'naive-ui';
import type { UploadCustomRequestOptions, UploadFileInfo } from 'naive-ui';
import { BusinessMetricCard } from '@/components/Business';
import { getBannerList, getBannerDetail, addBanner, updateBanner, deleteBanner } from '@/api/config/banner';
import { useGlobSetting } from '@/hooks/setting';
import { ACCESS_TOKEN } from '@/store/mutation-types';
import { storage } from '@/utils/Storage';

const { uploadUrl, fileUrl } = useGlobSetting();
const message = useMessage();
const dialog = useDialog();

const loading = ref(false);
const tableData = ref<any[]>([]);
const total = ref(0);
const pageNum = ref(1);
const pageSize = ref(10);

const keyword = ref('');
const selectedStatus = ref<number | null>(null);
const statusUpdatingIds = ref<number[]>([]);
const showModal = ref(false);
const isEdit = ref(false);
const formRef = ref();
const coverFileList = ref<UploadFileInfo[]>([]);
const formData = ref<any>({
  bannerId: null as number | null,
  title: '',
  imageUrl: '',
  linkUrl: '',
  linkType: null,
  sortOrder: 0,
  status: 1,
});

const linkTypeOptions = [
  { label: '作品集', value: 'portfolio' },
  { label: '订单', value: 'order' },
  { label: '定制表单', value: 'custom' },
];

// 统计
const stats = computed(() => {
  const all = tableData.value;
  return {
    total: all.length,
    active: all.filter((r: any) => r.status === 1).length,
    inactive: all.filter((r: any) => r.status === 0).length,
  };
});

// 筛选后数据
const displayData = computed(() => {
  let list = [...tableData.value];
  if (selectedStatus.value !== null) {
    list = list.filter((r: any) => r.status === selectedStatus.value);
  }
  if (keyword.value) {
    const kw = keyword.value.toLowerCase();
    list = list.filter((r: any) => (r.title || '').toLowerCase().includes(kw));
  }
  return list;
});

const selectStatus = (val: number | null) => {
  selectedStatus.value = val;
  pageNum.value = 1;
};

const columns = [
  { title: 'ID', key: 'bannerId', width: 60 },
  {
    title: '图片',
    key: 'imageUrl',
    width: 80,
    render(row: any) {
      if (!row.imageUrl) return '-';
      return h(NImage, {
        src: toFileUrl(row.imageUrl),
        width: 60,
        height: 40,
        objectFit: 'cover',
        style: 'border-radius: 4px',
      });
    },
  },
  { title: '标题', key: 'title', ellipsis: { tooltip: true } },
  {
    title: '跳转类型',
    key: 'linkType',
    width: 100,
    render(row: any) {
      const map: any = { portfolio: '作品集', order: '订单', custom: '定制', null: '-' };
      return map[row.linkType] || '-';
    },
  },
  { title: '跳转链接', key: 'linkUrl', ellipsis: { tooltip: true }, render: (r: any) => r.linkUrl || '-' },
  { title: '排序', key: 'sortOrder', width: 60 },
  {
    title: '状态',
    key: 'status',
    width: 110,
    render(row: any) {
      return h(NSwitch, {
        value: row.status,
        checkedValue: 1,
        uncheckedValue: 0,
        size: 'small',
        loading: statusUpdatingIds.value.includes(row.bannerId),
        onUpdateValue: (value: number) => handleToggleStatus(row, value),
      }, {
        checked: () => '启用',
        unchecked: () => '禁用',
      });
    },
  },
  {
    title: '操作',
    key: 'actions',
    width: 120,
    render(row: any) {
      return h(NSpace, { size: 4 }, {
        default: () => [
          h(NButton, { size: 'tiny', type: 'primary', onClick: () => handleEdit(row) }, { default: () => '编辑' }),
          h(NButton, { size: 'tiny', type: 'error', onClick: () => handleDelete(row) }, { default: () => '删除' }),
        ],
      });
    },
  },
];

function toFileUrl(url?: string | null) {
  if (!url) return '';
  if (/^https?:\/\//i.test(url)) return url;
  if (fileUrl) return `${fileUrl}${url}`;
  return url;
}

const getRecords = (value: any) => {
  if (Array.isArray(value)) return value;
  if (Array.isArray(value?.records)) return value.records;
  if (Array.isArray(value?.list)) return value.list;
  return [];
};

const loadData = async () => {
  loading.value = true;
  try {
    const res: any = await getBannerList({ pageNum: pageNum.value, pageSize: pageSize.value });
    tableData.value = getRecords(res);
    total.value = res?.total || tableData.value.length;
  } catch (e) { console.error(e); }
  finally { loading.value = false; }
};

onMounted(() => {
  loadData();
});

const handleAdd = () => {
  isEdit.value = false;
  formData.value = { bannerId: null, title: '', imageUrl: '', linkUrl: '', linkType: null, sortOrder: 0, status: 1 };
  coverFileList.value = [];
  showModal.value = true;
};

const handleEdit = async (row: any) => {
  try {
    const res = await getBannerDetail(row.bannerId);
    isEdit.value = true;
    formData.value = { ...res };
    if (res.imageUrl) {
      coverFileList.value = [{ id: 'existing', name: 'image.jpg', status: 'finished', url: toFileUrl(res.imageUrl) }];
    } else {
      coverFileList.value = [];
    }
    showModal.value = true;
  } catch (e) { console.error(e); }
};

const handleDelete = (row: any) => {
  dialog.warning({
    title: '确认删除',
    content: `确认删除轮播图「${row.title}」吗？`,
    positiveText: '确认',
    negativeText: '取消',
    onPositiveClick: async () => {
      await deleteBanner(row.bannerId);
      message.success('已删除');
      loadData();
    },
  });
};

const handleToggleStatus = async (row: any, status: number) => {
  const oldStatus = row.status;
  row.status = status;
  statusUpdatingIds.value = [...statusUpdatingIds.value, row.bannerId];

  try {
    await updateBanner(row.bannerId, { ...row, status });
    message.success(status === 1 ? '已启用' : '已禁用');
  } catch (e) {
    row.status = oldStatus;
    console.error(e);
    message.error('状态更新失败');
  } finally {
    statusUpdatingIds.value = statusUpdatingIds.value.filter((id) => id !== row.bannerId);
  }
};

const handleSubmit = async () => {
  try {
    if (isEdit.value) {
      await updateBanner(formData.value.bannerId, formData.value);
      message.success('修改成功');
    } else {
      await addBanner(formData.value);
      message.success('新增成功');
    }
    showModal.value = false;
    loadData();
  } catch (e) { console.error(e); }
};

async function handleUpload(options: UploadCustomRequestOptions) {
  const file = options.file.file;
  if (!file) { options.onError(); return; }
  try {
    const fd = new FormData();
    fd.append('file', file);
    const token = storage.get(ACCESS_TOKEN);
    const response = await fetch(uploadUrl || '/api/v1/oss/upload', {
      method: 'POST',
      headers: token ? { Authorization: `Bearer ${token}` } : {},
      body: fd,
    });
    const result = await response.json();
    if (!response.ok || result.code !== 200 || !result.data) {
      message.error(result.msg || '上传失败');
      options.onError();
      return;
    }
    formData.value.imageUrl = result.data;
    options.onFinish();
  } catch (e) {
    console.error(e);
    message.error('上传失败');
    options.onError();
  }
}
</script>

<style scoped>
.banner-page {
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
  padding: 14px 16px;
  gap: 12px;
}

.compact-filter {
  display: flex;
  align-items: center;
  gap: 8px;
}

.compact-pagination {
  display: flex;
  justify-content: flex-end;
  padding-top: 8px;
  border-top: 1px solid var(--border-light);
}
</style>
