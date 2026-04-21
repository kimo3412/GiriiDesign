<template>
  <div class="admin-page">
    <div class="page-summary">
      <span class="page-summary__item">
        <span class="page-summary__label">全部用户</span>
        <span class="page-summary__value">{{ stats.total }}</span>
      </span>
      <span class="page-summary__item">
        <span class="page-summary__label">正常</span>
        <span class="page-summary__value">{{ stats.active }}</span>
      </span>
      <span class="page-summary__item">
        <span class="page-summary__label">已禁用</span>
        <span class="page-summary__value">{{ stats.inactive }}</span>
      </span>
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
              <span class="tree-item__dot" style="background: var(--status-success-text)"></span>
              正常 <span class="tree-item__count">{{ stats.active }}</span>
            </div>
            <div
              class="tree-item"
              :class="{ 'tree-item--active': selectedStatus === 0 }"
              @click="selectStatus(0)"
            >
              <span class="tree-item__dot" style="background: var(--status-error-text)"></span>
              已禁用 <span class="tree-item__count">{{ stats.inactive }}</span>
            </div>
          </div>
        </div>

        <!-- 右侧：紧凑筛选 + 表格 -->
        <div class="directory-main">
          <div class="compact-filter">
            <n-input
              v-model:value="keyword"
              placeholder="搜索账号/昵称..."
              size="small"
              clearable
              @keyup.enter="loadData"
              style="width: 200px"
            >
              <template #prefix><n-icon><Search /></n-icon></template>
            </n-input>
            <n-button size="small" type="primary" @click="loadData">搜索</n-button>
            <n-divider vertical />
            <n-button :disabled="!checkedKeys.length" size="small" type="error" ghost @click="handleBatchDelete">
              批量删除{{ checkedKeys.length ? `(${checkedKeys.length})` : '' }}
            </n-button>
            <n-button size="small" type="primary" @click="handleAdd">新增用户</n-button>
          </div>

          <n-data-table
            v-model:checked-row-keys="checkedKeys"
            :columns="columns"
            :data="displayData"
            :loading="loading"
            :row-key="row => row.adminId"
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
      :title="isEdit ? '编辑用户' : '新增用户'"
      preset="dialog"
      positive-text="确定"
      negative-text="取消"
      @positive-click="handleSubmit"
      style="width: 500px"
    >
      <n-form :model="formData" :rules="rules" ref="formRef" label-placement="left" label-width="80">
        <n-form-item label="登录账号" path="username">
          <n-input v-model:value="formData.username" placeholder="请输入账号" :disabled="isEdit && formData.adminId === 1" />
        </n-form-item>
        <n-form-item label="登录密码" path="password">
          <n-input
            v-model:value="formData.password"
            type="password"
            placeholder="留空则不修改，新增默认 123456"
          />
        </n-form-item>
        <n-form-item label="昵称" path="nickname">
          <n-input v-model:value="formData.nickname" placeholder="请输入昵称" />
        </n-form-item>
        <n-form-item label="手机号" path="phone">
          <n-input v-model:value="formData.phone" placeholder="请输入手机号" />
        </n-form-item>
        <n-form-item label="分配角色" path="roleIds">
          <n-select v-model:value="formData.roleIds" multiple :options="roleOptions" placeholder="请选择角色" />
        </n-form-item>
        <n-form-item label="负责品类">
          <n-select v-model:value="formData.categoryIds" multiple :options="categoryOptions" placeholder="选择设计师负责的品类（可空）" />
        </n-form-item>
        <n-form-item label="状态" path="status">
          <n-switch v-model:value="formData.status" :checked-value="1" :unchecked-value="0" />
        </n-form-item>
      </n-form>
    </n-modal>
  </div>
</template>

<script lang="ts" setup>
import { ref, computed, onMounted, h } from 'vue';
import { NButton, NTag, NSpace, NIcon, NDivider } from 'naive-ui';
import { Search } from '@vicons/ionicons5';
import { useMessage, useDialog } from 'naive-ui';
import { getAdminList, getAdminDetail, addAdmin, updateAdmin, deleteAdmin, batchDeleteAdmins, updateDesignerCategories, type AdminSaveDTO } from '@/api/system/adminList';
import { getRoleList } from '@/api/system/roleList';
import { getCategoryList } from '@/api/config/category';

const message = useMessage();
const dialog = useDialog();

const loading = ref(false);
const tableData = ref<any[]>([]);
const total = ref(0);
const pageNum = ref(1);
const pageSize = ref(10);
const keyword = ref('');
const selectedStatus = ref<number | null>(null);

const roleOptions = ref<{label: string, value: number}[]>([]);
const categoryOptions = ref<{label: string, value: number}[]>([]);

const showModal = ref(false);
const isEdit = ref(false);
const formRef = ref();
const checkedKeys = ref<number[]>([]);
const formData = ref<AdminSaveDTO & { categoryIds: number[] }>({
  username: '',
  password: '',
  nickname: '',
  phone: '',
  status: 1,
  roleIds: [],
  categoryIds: []
});

const rules = {
  username: { required: true, message: '请输入账号', trigger: 'blur' },
  nickname: { required: true, message: '请输入昵称', trigger: 'blur' },
};

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
    list = list.filter((r: any) =>
      (r.username || '').toLowerCase().includes(kw) ||
      (r.nickname || '').toLowerCase().includes(kw)
    );
  }
  return list;
});

const selectStatus = (val: number | null) => {
  selectedStatus.value = val;
  pageNum.value = 1;
};

const columns = [
  { type: 'selection', width: 40 },
  { title: 'ID', key: 'adminId', width: 60 },
  { title: '账号', key: 'username', ellipsis: { tooltip: true } },
  { title: '昵称', key: 'nickname', ellipsis: { tooltip: true } },
  { title: '手机号', key: 'phone', width: 120, render: (r: any) => r.phone || '-' },
  {
    title: '状态',
    key: 'status',
    width: 80,
    render(row: any) {
      return h(NTag, { type: row.status === 1 ? 'success' : 'error', size: 'small', round: true }, { default: () => (row.status === 1 ? '正常' : '禁用') });
    }
  },
  { title: '创建时间', key: 'createTime', width: 150, render: (r: any) => r.createTime ? r.createTime.slice(0, 16) : '-' },
  {
    title: '操作',
    key: 'actions',
    width: 120,
    render(row: any) {
      return h(NSpace, { size: 4 }, {
        default: () => [
          h(NButton, { size: 'tiny', type: 'primary', onClick: () => handleEdit(row) }, { default: () => '编辑' }),
          h(NButton, { size: 'tiny', type: 'error', disabled: row.adminId === 1, onClick: () => handleDelete(row) }, { default: () => '删除' })
        ]
      });
    }
  }
];

const loadData = async () => {
  loading.value = true;
  try {
    tableData.value = await getAdminList() as any;
    total.value = tableData.value.length;
  } catch (e) { console.error(e); }
  finally { loading.value = false; }
};

const loadRoles = async () => {
  try {
    const res = await getRoleList();
    roleOptions.value = res.map((r: any) => ({ label: r.roleName, value: r.roleId }));
  } catch (e) { console.error(e); }
};

const loadCategories = async () => {
  try {
    const res = await getCategoryList();
    categoryOptions.value = res.map((c: any) => ({ label: c.name, value: c.categoryId }));
  } catch (e) { console.error(e); }
};

onMounted(() => {
  loadData();
  loadRoles();
  loadCategories();
});

const handleAdd = () => {
  isEdit.value = false;
  formData.value = { username: '', password: '', nickname: '', phone: '', status: 1, roleIds: [], categoryIds: [] };
  showModal.value = true;
};

const handleEdit = async (row: any) => {
  try {
    const res = await getAdminDetail(row.adminId);
    isEdit.value = true;
    formData.value = {
      ...res.admin,
      password: '',
      roleIds: res.roleIds || [],
      categoryIds: res.categoryIds || []
    };
    showModal.value = true;
  } catch (e) { console.error(e); }
};

const handleDelete = (row: any) => {
  dialog.warning({
    title: '确认删除',
    content: `确认删除用户 ${row.username} 吗？`,
    positiveText: '确认',
    negativeText: '取消',
    onPositiveClick: async () => {
      try {
        await deleteAdmin(row.adminId);
        message.success('删除成功');
        loadData();
      } catch (e) { console.error(e); }
    }
  });
};

const handleBatchDelete = () => {
  dialog.warning({
    title: '确认批量删除',
    content: `确定要删除选中的 ${checkedKeys.value.length} 个用户吗？`,
    positiveText: '确认',
    negativeText: '取消',
    onPositiveClick: async () => {
      try {
        await batchDeleteAdmins(checkedKeys.value);
        message.success('批量删除成功');
        checkedKeys.value = [];
        loadData();
      } catch (e) { console.error(e); }
    },
  });
};

const handleSubmit = () => {
  formRef.value?.validate(async (errors: any) => {
    if (!errors) {
      try {
        if (isEdit.value) {
          await updateAdmin(formData.value.adminId!, formData.value);
          if (formData.value.categoryIds) {
            await updateDesignerCategories(formData.value.adminId!, formData.value.categoryIds);
          }
          message.success('修改成功');
        } else {
          await addAdmin(formData.value);
          if (formData.value.categoryIds?.length) {
            const newList = await getAdminList() as any;
            const newAdmin = newList.find((a: any) => a.username === formData.value.username);
            if (newAdmin) {
              await updateDesignerCategories(newAdmin.adminId, formData.value.categoryIds);
            }
          }
          message.success('新增成功');
        }
        showModal.value = false;
        loadData();
      } catch (err) { console.error(err); }
    }
  });
  return false;
};
</script>

<style scoped>
.admin-page {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.page-summary {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
}

.page-summary__item {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  padding: 6px 10px;
  border-radius: 999px;
  border: 1px solid var(--border-light);
  background: rgba(255, 255, 255, 0.78);
}

.page-summary__label {
  font-size: 12px;
  color: var(--text-tertiary);
}

.page-summary__value {
  font-size: 13px;
  font-weight: 700;
  color: var(--text-primary);
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
  align-items: center;
  gap: 6px;
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
.tree-item__dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  flex-shrink: 0;
}
.tree-item__count {
  font-size: 11px;
  color: var(--text-placeholder);
  background: var(--border-light);
  padding: 1px 6px;
  border-radius: 8px;
  margin-left: auto;
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
