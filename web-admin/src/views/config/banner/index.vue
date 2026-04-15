<template>
  <n-card title="轮播图管理" :bordered="false">
    <template #header-extra>
      <n-button type="primary" @click="handleAdd">新增轮播图</n-button>
    </template>

    <n-data-table
      :columns="columns"
      :data="tableData"
      :loading="loading"
      :row-key="row => row.bannerId"
    />

    <div style="margin-top: 16px; display: flex; justify-content: flex-end">
      <n-pagination
        v-model:page="pageNum"
        :page-size="pageSize"
        :page-sizes="[10, 20, 50]"
        :total="total"
        show-size-picker
        @update:page="loadData"
        @update:page-size="loadData"
      />
    </div>

    <!-- 新增/编辑弹窗 -->
    <n-modal v-model:show="showModal" :title="isEdit ? '编辑轮播图' : '新增轮播图'" preset="dialog" positive-text="确定" negative-text="取消" @positive-click="handleSubmit" style="width: 520px">
      <n-form :model="formData" ref="formRef" label-placement="left" label-width="80">
        <n-form-item label="标题" path="title">
          <n-input v-model:value="formData.title" placeholder="请输入轮播图标题" />
        </n-form-item>
        <n-form-item label="图片" path="imageUrl">
          <n-upload
            :custom-request="handleUpload"
            :file-list="coverFileList"
            list-type="image-card"
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
  </n-card>
</template>

<script lang="ts" setup>
import { ref, onMounted, h } from 'vue';
import { NButton, NTag, NSpace, NImage, useMessage, useDialog } from 'naive-ui';
import type { UploadCustomRequestOptions, UploadFileInfo } from 'naive-ui';
import { getBannerList, getBannerDetail, addBanner, updateBanner, deleteBanner } from '@/api/config/banner';
import { useGlobSetting } from '@/hooks/setting';
import { ACCESS_TOKEN } from '@/store/mutation-types';
import { storage } from '@/utils/Storage';

const { uploadUrl, fileUrl } = useGlobSetting();
const message = useMessage();
const dialog = useDialog();
const loading = ref(false);
const tableData = ref([]);
const total = ref(0);
const pageNum = ref(1);
const pageSize = ref(10);

const showModal = ref(false);
const isEdit = ref(false);
const formRef = ref();
const coverFileList = ref<UploadFileInfo[]>([]);
const formData = ref<any>({
  title: '',
  imageUrl: '',
  linkUrl: '',
  linkType: null,
  sortOrder: 0,
  status: 1,
});

const getRecords = (value: any) => {
  if (Array.isArray(value)) return value;
  if (Array.isArray(value?.records)) return value.records;
  if (Array.isArray(value?.list)) return value.list;
  return [];
};

const linkTypeOptions = [
  { label: '作品集', value: 'portfolio' },
  { label: '订单', value: 'order' },
  { label: '定制表单', value: 'custom' },
];

const columns = [
  { title: 'ID', key: 'bannerId', width: 60 },
  {
    title: '图片',
    key: 'imageUrl',
    width: 100,
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
  { title: '标题', key: 'title' },
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
    width: 70,
    render(row: any) {
      return h(NTag, { type: row.status === 1 ? 'success' : 'default', size: 'small' }, {
        default: () => row.status === 1 ? '启用' : '禁用',
      });
    },
  },
  {
    title: '操作',
    key: 'actions',
    width: 150,
    render(row: any) {
      return h(NSpace, {}, {
        default: () => [
          h(NButton, { size: 'small', type: 'primary', onClick: () => handleEdit(row) }, { default: () => '编辑' }),
          h(NButton, { size: 'small', type: 'error', onClick: () => handleDelete(row) }, { default: () => '删除' }),
        ],
      });
    },
  },
];

function toFileUrl(url?: string | null) {
  if (!url) return '';
  if (/^https?:\/\//i.test(url)) return url;
  if (fileUrl) {
    return `${fileUrl}${url}`;
  }
  return url;
}

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
  formData.value = { title: '', imageUrl: '', linkUrl: '', linkType: null, sortOrder: 0, status: 1 };
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
</script>
