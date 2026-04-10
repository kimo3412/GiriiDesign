<template>
  <n-card title="作品管理" :bordered="false">
    <template #header-extra>
      <n-space>
        <n-select
          v-model:value="filterCategory"
          :options="categoryOptions"
          placeholder="全部品类"
          style="width: 140px"
          clearable
          @update:value="loadData"
        />
        <n-input
          v-model:value="keyword"
          placeholder="搜索标题"
          clearable
          @keyup.enter="loadData"
          style="width: 180px"
        />
        <n-button type="error" :disabled="!checkedKeys.length" @click="handleBatchDelete">
          批量删除{{ checkedKeys.length ? `(${checkedKeys.length})` : '' }}
        </n-button>
        <n-button type="primary" @click="handleAdd">新增作品</n-button>
      </n-space>
    </template>

    <n-data-table
      v-model:checked-row-keys="checkedKeys"
      :columns="columns"
      :data="tableData"
      :loading="loading"
      :row-key="row => row.portfolioId"
    />

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
            list-type="image-card"
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
            list-type="image-card"
            :custom-request="handleUpload"
            :max="9"
            multiple
            accept="image/*"
          >
            点击上传
          </n-upload>
        </n-form-item>
        <n-form-item label="描述">
          <n-input v-model:value="formData.description" type="textarea" placeholder="作品描述" :rows="4" />
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
  </n-card>
</template>

<script lang="ts" setup>
import { ref, onMounted, h } from 'vue';
import { NButton, NTag, NSpace, NImage, useMessage, useDialog } from 'naive-ui';
import type { UploadCustomRequestOptions, UploadFileInfo } from 'naive-ui';
import {
  getPortfolioList,
  addPortfolio,
  updatePortfolio,
  deletePortfolio,
  batchDeletePortfolios,
  togglePortfolioStatus,
} from '@/api/portfolio/index';
import { getCategoryList } from '@/api/config/category';
import { useGlobSetting } from '@/hooks/setting';
import { ACCESS_TOKEN } from '@/store/mutation-types';
import { storage } from '@/utils/Storage';

const { uploadUrl, fileUrl } = useGlobSetting();
const message = useMessage();
const dialog = useDialog();
const loading = ref(false);
const tableData = ref([]);

const filterCategory = ref<number | null>(null);
const keyword = ref('');
const categoryOptions = ref<{ label: string; value: number }[]>([]);
const categoryMap = ref<Record<number, string>>({});

const checkedKeys = ref<number[]>([]);

const showModal = ref(false);
const isEdit = ref(false);
const formRef = ref();
const coverFileList = ref<UploadFileInfo[]>([]);
const galleryFileList = ref<UploadFileInfo[]>([]);
const formData = ref<any>({
  title: '',
  categoryId: null,
  coverUrl: '',
  imageUrls: [],
  description: '',
  status: 0,
  sortOrder: 0,
});

const rules = {
  title: { required: true, message: '请输入作品标题', trigger: 'blur' },
};

/** 将存储的相对路径转为通过 API 代理访问的 URL */
function toFileUrl(url?: string | null) {
  if (!url) return '';
  if (/^https?:\/\//i.test(url)) return url;
  // 相对路径如 /uploads/xxx.png → /api/v1/oss/files/uploads/xxx.png（走 Vite 代理，无跨域）
  return `/api/v1/oss/files${url}`;
}

const columns = [
  { type: 'selection' },
  {
    title: '封面',
    key: 'coverUrl',
    width: 80,
    render(row: any) {
      if (!row.coverUrl) return '-';
      return h(NImage, {
        src: toFileUrl(row.coverUrl),
        width: 50,
        height: 50,
        objectFit: 'cover',
        style: 'border-radius: 4px',
        previewSrc: toFileUrl(row.coverUrl),
      });
    },
  },
  { title: '标题', key: 'title', ellipsis: { tooltip: true } },
  {
    title: '品类',
    key: 'categoryId',
    width: 100,
    render(row: any) {
      return categoryMap.value[row.categoryId] || '-';
    },
  },
  {
    title: '状态',
    key: 'status',
    width: 80,
    render(row: any) {
      return h(NTag, { type: row.status === 1 ? 'success' : 'default', size: 'small' }, {
        default: () => (row.status === 1 ? '已发布' : '草稿'),
      });
    },
  },
  { title: '浏览量', key: 'viewCount', width: 80 },
  { title: '排序', key: 'sortOrder', width: 60 },
  { title: '创建时间', key: 'createTime', width: 170 },
  {
    title: '操作',
    key: 'actions',
    width: 200,
    render(row: any) {
      return h(NSpace, {}, {
        default: () => [
          h(NButton, { size: 'small', type: 'primary', onClick: () => handleEdit(row) }, { default: () => '编辑' }),
          h(
            NButton,
            { size: 'small', type: row.status === 1 ? 'warning' : 'success', onClick: () => handleToggleStatus(row) },
            { default: () => (row.status === 1 ? '下架' : '发布') }
          ),
          h(NButton, { size: 'small', type: 'error', onClick: () => handleDelete(row) }, { default: () => '删除' }),
        ],
      });
    },
  },
];

const loadData = async () => {
  loading.value = true;
  try {
    const params: any = {};
    if (filterCategory.value != null) params.categoryId = filterCategory.value;
    if (keyword.value) params.keyword = keyword.value;
    tableData.value = await getPortfolioList(params);
  } catch (e) {
    console.error(e);
  } finally {
    loading.value = false;
  }
};

const loadCategories = async () => {
  try {
    const cats = await getCategoryList();
    categoryOptions.value = cats.map((c: any) => ({ label: c.name, value: c.categoryId }));
    const cMap: any = {};
    cats.forEach((c: any) => { cMap[c.categoryId] = c.name; });
    categoryMap.value = cMap;
  } catch (e) {
    console.error(e);
  }
};

onMounted(() => {
  loadData();
  loadCategories();
});

/** 上传图片到服务器 */
async function handleUpload(options: UploadCustomRequestOptions) {
  const file = options.file.file;
  if (!file) {
    options.onError();
    return;
  }
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
      message.error(result.msg || '图片上传失败');
      options.onError();
      return;
    }
    options.file.url = result.data;
    options.onFinish();
  } catch (error) {
    console.error(error);
    message.error('图片上传失败');
    options.onError();
  }
}

/** 从文件列表提取已上传的 URL */
function getUrlsFromFileList(fileList: UploadFileInfo[]) {
  return fileList
    .map((f) => f.url || f.status === 'finished' && f.url)
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
  // 封面图回显
  if (row.coverUrl) {
    coverFileList.value = [{
      id: 'cover-existing',
      name: 'cover.jpg',
      status: 'finished',
      url: row.coverUrl,
    }];
  } else {
    coverFileList.value = [];
  }
  // 图片集回显
  galleryFileList.value = (row.imageUrls || []).map((url: string, idx: number) => ({
    id: `gallery-${idx}`,
    name: `image-${idx}.jpg`,
    status: 'finished',
    url,
  }));
  showModal.value = true;
};

const handleSubmit = () => {
  formRef.value?.validate(async (errors: any) => {
    if (!errors) {
      try {
        const coverUrls = getUrlsFromFileList(coverFileList.value);
        const galleryUrls = getUrlsFromFileList(galleryFileList.value);
        const data = {
          ...formData.value,
          coverUrl: coverUrls[0] || '',
          imageUrls: galleryUrls,
        };
        if (isEdit.value) {
          await updatePortfolio(formData.value.portfolioId, data);
          message.success('修改成功');
        } else {
          await addPortfolio(data);
          message.success('新增成功');
        }
        showModal.value = false;
        loadData();
      } catch (e) {
        console.error(e);
      }
    }
  });
  return false;
};

const handleDelete = (row: any) => {
  dialog.warning({
    title: '确认删除',
    content: `确认删除作品「${row.title}」吗？`,
    positiveText: '确认',
    negativeText: '取消',
    onPositiveClick: async () => {
      await deletePortfolio(row.portfolioId);
      message.success('已删除');
      loadData();
    },
  });
};

const handleBatchDelete = () => {
  dialog.warning({
    title: '确认批量删除',
    content: `确定要删除选中的 ${checkedKeys.value.length} 个作品吗？`,
    positiveText: '确认',
    negativeText: '取消',
    onPositiveClick: async () => {
      try {
        await batchDeletePortfolios(checkedKeys.value);
        message.success('批量删除成功');
        checkedKeys.value = [];
        loadData();
      } catch (e) {
        console.error(e);
      }
    },
  });
};

const handleToggleStatus = (row: any) => {
  const newStatus = row.status === 1 ? 0 : 1;
  const label = newStatus === 1 ? '发布' : '下架';
  dialog.warning({
    title: `确认${label}`,
    content: `确定要${label}作品「${row.title}」吗？`,
    positiveText: '确认',
    negativeText: '取消',
    onPositiveClick: async () => {
      await togglePortfolioStatus(row.portfolioId, newStatus);
      message.success(`${label}成功`);
      loadData();
    },
  });
};
</script>
