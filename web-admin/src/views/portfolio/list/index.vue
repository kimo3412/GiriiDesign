<template>
  <div class="portfolio-page">
    <!-- 顶部统计 -->
    <div class="stat-cards">
      <BusinessMetricCard
        label="全部作品"
        :value="stats.total"
        icon="🖼️"
        variant="primary"
      />
      <BusinessMetricCard
        label="已发布"
        :value="stats.published"
        icon="✅"
        variant="success"
      />
      <BusinessMetricCard
        label="草稿"
        :value="stats.draft"
        icon="📝"
        variant="default"
      />
    </div>

    <n-card :bordered="false" class="directory-card">
      <div class="directory-layout">
        <!-- 左侧：品类维度树 -->
        <div class="directory-tree">
          <div class="tree-header">品类筛选</div>
          <div class="tree-items">
            <div
              class="tree-item"
              :class="{ 'tree-item--active': selectedCategory === null }"
              @click="selectCategory(null)"
            >
              全部 <span class="tree-item__count">{{ tableData.length }}</span>
            </div>
            <div
              v-for="cat in categoryStats"
              :key="cat.id"
              class="tree-item"
              :class="{ 'tree-item--active': selectedCategory === cat.id }"
              @click="selectCategory(cat.id)"
            >
              {{ cat.name }} <span class="tree-item__count">{{ cat.count }}</span>
            </div>
          </div>
        </div>

        <!-- 右侧：紧凑筛选 + 表格 -->
        <div class="directory-main">
          <!-- 紧凑筛选栏 -->
          <div class="compact-filter">
            <n-input
              v-model:value="keyword"
              placeholder="搜索标题..."
              size="small"
              clearable
              @keyup.enter="handleSearch"
              style="width: 200px"
            >
              <template #prefix>
                <n-icon><Search /></n-icon>
              </template>
            </n-input>
            <n-button size="small" type="primary" @click="handleSearch">搜索</n-button>
            <n-divider vertical />
            <n-space :size="6">
              <n-button :disabled="!checkedKeys.length" size="small" type="error" ghost @click="handleBatchDelete">
                批量删除{{ checkedKeys.length ? `(${checkedKeys.length})` : '' }}
              </n-button>
              <n-button size="small" type="primary" @click="handleAdd">新增作品</n-button>
            </n-space>
          </div>

          <!-- 表格 -->
          <n-data-table
            v-model:checked-row-keys="checkedKeys"
            :columns="columns"
            :data="displayData"
            :loading="loading"
            :row-key="row => row.portfolioId"
            size="small"
            :bordered="false"
          />

          <!-- 分页 -->
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
      :title="isEdit ? '编辑作品' : '新增作品'"
      preset="dialog"
      positive-text="确定"
      negative-text="取消"
      @positive-click="handleSubmit"
      style="width: 600px"
    >
      <n-form :model="formData" :rules="rules" ref="formRef" label-placement="left" label-width="80">
        <n-form-item label="标题" path="title">
          <n-input v-model:value="formData.title" placeholder="请输入作品标题" />
        </n-form-item>
        <n-form-item label="品类" path="categoryId">
          <n-select v-model:value="formData.categoryId" :options="categoryOptions" placeholder="选择品类" />
        </n-form-item>
        <n-form-item label="封面图">
          <n-upload
            v-model:file-list="coverFileList"
            list-type="image"
            :custom-request="handleUpload"
            :max="1"
            accept="image/*"
          >
            点击上传
          </n-upload>
        </n-form-item>
        <n-form-item label="图片集">
          <n-upload
            v-model:file-list="galleryFileList"
            list-type="image"
            :custom-request="handleUpload"
            :max="9"
            multiple
            accept="image/*"
          >
            点击上传
          </n-upload>
        </n-form-item>
        <n-form-item label="描述">
          <n-input v-model:value="formData.description" type="textarea" placeholder="作品描述" :rows="3" />
        </n-form-item>
        <n-form-item label="状态">
          <n-switch v-model:value="formData.status" :checked-value="1" :unchecked-value="0">
            <template #checked>已发布</template>
            <template #unchecked>草稿</template>
          </n-switch>
        </n-form-item>
        <n-form-item label="排序">
          <n-input-number v-model:value="formData.sortOrder" :min="0" style="width: 100%" />
        </n-form-item>
      </n-form>
    </n-modal>
  </div>
</template>

<script lang="ts" setup>
import { ref, computed, onMounted, h } from 'vue';
import { NButton, NTag, NSpace, NInput, NIcon, NDivider, NForm, NFormItem, NSelect, NModal, NSwitch, NAlert, NPagination, NImage, NUpload, useMessage, useDialog } from 'naive-ui';
import type { UploadCustomRequestOptions, UploadFileInfo } from 'naive-ui';
import { Search } from '@vicons/ionicons5';
import {
  getPortfolioList, addPortfolio, updatePortfolio,
  deletePortfolio, batchDeletePortfolios, togglePortfolioStatus,
} from '@/api/portfolio/index';
import { getCategoryList } from '@/api/config/category';
import { useGlobSetting } from '@/hooks/setting';
import { ACCESS_TOKEN } from '@/store/mutation-types';
import { storage } from '@/utils/Storage';
import { BusinessMetricCard, StatusBadge } from '@/components/Business';

const { uploadUrl, fileUrl } = useGlobSetting();
const message = useMessage();
const dialog = useDialog();
const loading = ref(false);
const tableData = ref<any[]>([]);
const total = ref(0);
const pageNum = ref(1);
const pageSize = ref(10);

const keyword = ref('');
const selectedCategory = ref<number | null>(null);
const categoryOptions = ref<{ label: string; value: number }[]>([]);
const categoryMap = ref<Record<number, string>>({});

const checkedKeys = ref<number[]>([]);
const showModal = ref(false);
const isEdit = ref(false);
const formRef = ref();
const coverFileList = ref<UploadFileInfo[]>([]);
const galleryFileList = ref<UploadFileInfo[]>([]);
const formData = ref<any>({ title: '', categoryId: null, coverUrl: '', imageUrls: [], description: '', status: 0, sortOrder: 0 });
const portfolioFallbackSrc =
  'data:image/svg+xml;utf8,' +
  encodeURIComponent(
    '<svg xmlns="http://www.w3.org/2000/svg" width="88" height="88" viewBox="0 0 88 88"><rect width="88" height="88" rx="10" fill="#f3f4f6"/><text x="44" y="40" text-anchor="middle" font-size="12" font-family="Arial" fill="#9ca3af">No Image</text><text x="44" y="56" text-anchor="middle" font-size="10" font-family="Arial" fill="#c0c4cc">ZeHana</text></svg>'
  );

const rules = { title: { required: true, message: '请输入作品标题', trigger: 'blur' } };

// 统计
const stats = computed(() => {
  const all = tableData.value;
  return {
    total: total.value,
    published: all.filter((r: any) => r.status === 1).length,
    draft: all.filter((r: any) => r.status === 0).length,
  };
});

// 分类统计
const categoryStats = ref<any[]>([]);

// 筛选后数据
const displayData = computed(() => tableData.value);

const selectCategory = (id: number | null) => {
  selectedCategory.value = id;
  pageNum.value = 1;
  loadData();
};

function toFileUrl(url?: string | null) {
  if (!url) return '';
  if (/^https?:\/\//i.test(url)) return url;
  if (url.startsWith('/api/')) return url;
  if (url.startsWith('/uploads/')) return fileUrl ? `${fileUrl}${url}` : url;
  const normalized = url.startsWith('/') ? url : `/${url}`;
  return fileUrl ? `${fileUrl}/uploads${normalized}` : `/uploads${normalized}`;
}

function parseImageUrls(value: any): string[] {
  if (!value) return [];
  if (Array.isArray(value)) return value.filter((url) => typeof url === 'string' && !!url);
  if (typeof value === 'string') {
    try {
      const parsed = JSON.parse(value);
      return Array.isArray(parsed) ? parsed.filter((url) => typeof url === 'string' && !!url) : [value];
    } catch {
      return [value];
    }
  }
  return [];
}

function createUploadFile(id: string, name: string, url: string): UploadFileInfo {
  return {
    id,
    name,
    status: 'finished',
    url: toFileUrl(url),
    sourceUrl: url,
  } as UploadFileInfo & { sourceUrl: string };
}

const columns = [
  { type: 'selection', width: 40 },
  {
    title: '封面',
    key: 'coverUrl',
    width: 60,
    render(row: any) {
      if (!row.coverUrl) return '-';
      return h(NImage, {
        src: toFileUrl(row.coverUrl),
        width: 44,
        height: 44,
        objectFit: 'cover',
        style: 'border-radius: 4px',
        previewSrc: toFileUrl(row.coverUrl),
        fallbackSrc: portfolioFallbackSrc,
      });
    },
  },
  { title: '标题', key: 'title', ellipsis: { tooltip: true } },
  {
    title: '品类',
    key: 'categoryId',
    width: 90,
    render(row: any) {
      return categoryMap.value[row.categoryId] || '-';
    }
  },
  {
    title: '状态',
    key: 'status',
    width: 70,
    render(row: any) {
      return h(StatusBadge, { status: row.status === 1 ? 'published' : 'draft', size: 'small', round: true,
        map: { published: { label: '已发布', type: 'success' }, draft: { label: '草稿', type: 'default' } } });
    }
  },
  { title: '浏览', key: 'viewCount', width: 60, render: (r: any) => r.viewCount || 0 },
  { title: '排序', key: 'sortOrder', width: 60 },
  {
    title: '操作',
    key: 'actions',
    width: 180,
    render(row: any) {
      return h(NSpace, { size: 4 }, {
        default: () => [
          h(NButton, { size: 'tiny', type: 'primary', onClick: () => handleEdit(row) }, { default: () => '编辑' }),
          h(NButton, { size: 'tiny', type: row.status === 1 ? 'warning' : 'success', onClick: () => handleToggleStatus(row) },
            { default: () => row.status === 1 ? '下架' : '发布' }),
          h(NButton, { size: 'tiny', type: 'error', onClick: () => handleDelete(row) }, { default: () => '删除' }),
        ]
      });
    }
  }
];

const loadData = async () => {
  loading.value = true;
  try {
    const params: any = { pageNum: pageNum.value, pageSize: pageSize.value };
    if (keyword.value) params.keyword = keyword.value;
    if (selectedCategory.value !== null) params.categoryId = selectedCategory.value;
    const res: any = await getPortfolioList(params);
    tableData.value = res.records || [];
    total.value = res.total || 0;
    categoryStats.value = (res.categoryStats || []).map((c: any) => ({
      id: c.id,
      name: categoryMap.value[c.id] || `ID#${c.id}`,
      count: c.count,
    }));
  } catch (e) { console.error(e); }
  finally { loading.value = false; }
};

const loadCategories = async () => {
  try {
    const cats = await getCategoryList();
    categoryOptions.value = cats.map((c: any) => ({ label: c.name, value: c.categoryId }));
    categoryMap.value = Object.fromEntries(cats.map((c: any) => [c.categoryId, c.name]));
  } catch (e) { console.error(e); }
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


onMounted(() => { loadData(); loadCategories(); });

async function handleUpload(options: UploadCustomRequestOptions) {
  const file = options.file.file;
  if (!file) { options.onError(); return; }
  try {
    const fd = new FormData();
    fd.append('file', file);
    const token = storage.get(ACCESS_TOKEN);
    const response = await fetch(uploadUrl || '/api/v1/oss/upload', {
      method: 'POST',
      headers: token ? { Authorization: `Bearer ${token}` } : undefined,
      body: fd,
    });
    const result = await response.json();
    if (!response.ok || result.code !== 200 || !result.data) {
      message.error(result.msg || '图片上传失败'); options.onError(); return;
    }
    (options.file as UploadFileInfo & { sourceUrl?: string }).sourceUrl = result.data;
    options.file.url = toFileUrl(result.data);
    options.onFinish();
  } catch (error) {
    message.error('图片上传失败'); options.onError();
  }
}

function getUrlsFromFileList(fileList: UploadFileInfo[]) {
  return fileList
    .map((f) => (f as UploadFileInfo & { sourceUrl?: string }).sourceUrl || f.url)
    .filter((url): url is string => typeof url === 'string' && !!url);
}

const handleAdd = () => {
  isEdit.value = false;
  formData.value = { title: '', categoryId: null, coverUrl: '', imageUrls: [], description: '', status: 0, sortOrder: 0 };
  coverFileList.value = [];
  galleryFileList.value = [];
  showModal.value = true;
};

const handleEdit = (row: any) => {
  isEdit.value = true;
  formData.value = { ...row };
  coverFileList.value = row.coverUrl ? [createUploadFile('cover-existing', 'cover.jpg', row.coverUrl)] : [];
  galleryFileList.value = parseImageUrls(row.imageUrls).map((url: string, idx: number) => createUploadFile(`gallery-${idx}`, `image-${idx}.jpg`, url));
  showModal.value = true;
};

const handleSubmit = () => {
  formRef.value?.validate(async (errors: any) => {
    if (!errors) {
      try {
        const coverUrls = getUrlsFromFileList(coverFileList.value);
        const galleryUrls = getUrlsFromFileList(galleryFileList.value);
        const data = { ...formData.value, coverUrl: coverUrls[0] || '', imageUrls: galleryUrls };
        if (isEdit.value) { await updatePortfolio(formData.value.portfolioId, data); message.success('修改成功'); }
        else { await addPortfolio(data); message.success('新增成功'); }
        showModal.value = false;
        loadData();
      } catch (e) { console.error(e); }
    }
  });
  return false;
};

const handleDelete = (row: any) => {
  dialog.warning({
    title: '确认删除', content: `确认删除作品「${row.title}」吗？`,
    positiveText: '确认', negativeText: '取消',
    onPositiveClick: async () => { await deletePortfolio(row.portfolioId); message.success('已删除'); loadData(); },
  });
};

const handleBatchDelete = () => {
  dialog.warning({
    title: '确认批量删除', content: `确定要删除选中的 ${checkedKeys.value.length} 个作品吗？`,
    positiveText: '确认', negativeText: '取消',
    onPositiveClick: async () => {
      try { await batchDeletePortfolios(checkedKeys.value); message.success('批量删除成功'); checkedKeys.value = []; loadData(); }
      catch (e) { console.error(e); }
    },
  });
};

const handleToggleStatus = (row: any) => {
  const newStatus = row.status === 1 ? 0 : 1;
  const label = newStatus === 1 ? '发布' : '下架';
  dialog.warning({
    title: `确认${label}`, content: `确定要${label}作品「${row.title}」吗？`,
    positiveText: '确认', negativeText: '取消',
    onPositiveClick: async () => { await togglePortfolioStatus(row.portfolioId, newStatus); message.success(`${label}成功`); loadData(); },
  });
};
</script>

<style scoped>
.portfolio-page {
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
  flex-wrap: wrap;
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
