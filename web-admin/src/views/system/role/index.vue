<template>
  <div class="role-page">
    <div class="page-summary">
      <span class="page-summary__item">
        <span class="page-summary__label">全部角色</span>
        <span class="page-summary__value">{{ stats.total }}</span>
      </span>
      <span class="page-summary__item">
        <span class="page-summary__label">内置角色</span>
        <span class="page-summary__value">{{ stats.builtin }}</span>
      </span>
      <span class="page-summary__item">
        <span class="page-summary__label">自定义</span>
        <span class="page-summary__value">{{ stats.custom }}</span>
      </span>
    </div>

    <n-card :bordered="false" class="directory-card">
      <div class="directory-layout">
        <!-- 左侧：类型维度树 -->
        <div class="directory-tree">
          <div class="tree-header">类型筛选</div>
          <div class="tree-items">
            <div
              class="tree-item"
              :class="{ 'tree-item--active': selectedType === null }"
              @click="selectType(null)"
            >
              全部 <span class="tree-item__count">{{ stats.total }}</span>
            </div>
            <div
              class="tree-item"
              :class="{ 'tree-item--active': selectedType === 'builtin' }"
              @click="selectType('builtin')"
            >
              <span class="tree-item__dot" style="background: var(--status-info-text)"></span>
              内置角色 <span class="tree-item__count">{{ stats.builtin }}</span>
            </div>
            <div
              class="tree-item"
              :class="{ 'tree-item--active': selectedType === 'custom' }"
              @click="selectType('custom')"
            >
              <span class="tree-item__dot" style="background: var(--status-success-text)"></span>
              自定义 <span class="tree-item__count">{{ stats.custom }}</span>
            </div>
          </div>
        </div>

        <!-- 右侧：紧凑筛选 + 表格 -->
        <div class="directory-main">
          <div class="compact-filter">
            <n-input
              v-model:value="keyword"
              placeholder="搜索角色名称..."
              size="small"
              clearable
              @keyup.enter="loadData"
              style="width: 200px"
            >
              <template #prefix><n-icon><Search /></n-icon></template>
            </n-input>
            <n-button size="small" type="primary" @click="loadData">搜索</n-button>
            <n-divider vertical />
            <n-button size="small" type="primary" @click="handleAdd">新增角色</n-button>
          </div>

          <n-data-table
            :columns="columns"
            :data="displayData"
            :loading="loading"
            :row-key="row => row.roleId"
            size="small"
            :bordered="false"
          />
        </div>
      </div>
    </n-card>

    <!-- 新增/编辑弹窗 -->
    <n-modal
      v-model:show="showModal"
      :title="isEdit ? '编辑角色' : '新增角色'"
      preset="dialog"
      positive-text="确定"
      negative-text="取消"
      @positive-click="handleSubmit"
      style="width: 500px"
    >
      <n-form :model="formData" :rules="rules" ref="formRef" label-placement="left" label-width="80">
        <n-form-item label="角色名称" path="roleName">
          <n-input v-model:value="formData.roleName" placeholder="请输入角色名称" />
        </n-form-item>
        <n-form-item label="角色标识" path="roleKey">
          <n-input v-model:value="formData.roleKey" placeholder="如：admin、designer" :disabled="isEdit && (formData.roleId === 1 || formData.roleId === 2)" />
        </n-form-item>
        <n-form-item label="角色类型" path="roleType">
          <n-select v-model:value="formData.roleType" :options="ROLE_TYPE_OPTIONS" placeholder="请选择角色类型" />
        </n-form-item>
        <n-form-item label="备注" path="remark">
          <n-input v-model:value="formData.remark" type="textarea" placeholder="请输入备注" />
        </n-form-item>
        <n-form-item label="菜单权限" path="menuIds">
          <n-tree
            block-line
            cascade
            checkable
            :data="menuTreeData"
            key-field="menuId"
            label-field="menuName"
            children-field="children"
            :checked-keys="formData.menuIds"
            @update:checked-keys="handleCheckMenu"
            style="max-height: 300px; overflow-y: auto"
          />
        </n-form-item>
      </n-form>
    </n-modal>
  </div>
</template>

<script lang="ts" setup>
import { ref, computed, onMounted, h } from 'vue';
import { NButton, NSelect, NSpace, NIcon, NDivider } from 'naive-ui';
import { Search } from '@vicons/ionicons5';
import { useMessage, useDialog } from 'naive-ui';
import { getRoleList, getRoleDetail, addRole, updateRole, deleteRole, type RoleSaveDTO, ROLE_TYPE_OPTIONS, ROLE_TYPE_MAP } from '@/api/system/roleList';
import { getMenuList } from '@/api/system/menuConfig';

const message = useMessage();
const dialog = useDialog();

const loading = ref(false);
const tableData = ref<any[]>([]);
const keyword = ref('');
const selectedType = ref<'builtin' | 'custom' | null>(null);

const menuTreeData = ref([]);
const showModal = ref(false);
const isEdit = ref(false);
const formRef = ref();
const formData = ref<RoleSaveDTO>({
  roleName: '',
  roleKey: '',
  roleType: '',
  remark: '',
  menuIds: []
});

const rules = {
  roleName: { required: true, message: '请输入名称', trigger: 'blur' },
  roleKey: { required: true, message: '请输入标识', trigger: 'blur' },
};

// 内置角色标识
const BUILTIN_KEYS = ['admin', 'designer'];

const stats = computed(() => {
  const all = tableData.value;
  return {
    total: all.length,
    builtin: all.filter((r: any) => BUILTIN_KEYS.includes(r.roleKey || '')).length,
    custom: all.filter((r: any) => !BUILTIN_KEYS.includes(r.roleKey || '')).length,
  };
});

const displayData = computed(() => {
  let list = [...tableData.value];
  if (selectedType.value === 'builtin') {
    list = list.filter((r: any) => BUILTIN_KEYS.includes(r.roleKey || ''));
  } else if (selectedType.value === 'custom') {
    list = list.filter((r: any) => !BUILTIN_KEYS.includes(r.roleKey || ''));
  }
  if (keyword.value) {
    const kw = keyword.value.toLowerCase();
    list = list.filter((r: any) =>
      (r.roleName || '').toLowerCase().includes(kw) ||
      (r.roleKey || '').toLowerCase().includes(kw)
    );
  }
  return list;
});

const selectType = (val: 'builtin' | 'custom' | null) => {
  selectedType.value = val;
};

const columns = [
  { title: 'ID', key: 'roleId', width: 60 },
  { title: '角色名', key: 'roleName', ellipsis: { tooltip: true } },
  { title: '角色标识', key: 'roleKey', width: 120, ellipsis: { tooltip: true } },
  { title: '角色类型', key: 'roleType', width: 100, render(row: any) {
    return ROLE_TYPE_MAP[row.roleType] || row.roleType || '-';
  }},
  { title: '备注', key: 'remark', ellipsis: { tooltip: true }, render: (r: any) => r.remark || '-' },
  { title: '创建时间', key: 'createTime', width: 150, render: (r: any) => r.createTime ? r.createTime.slice(0, 16) : '-' },
  {
    title: '操作',
    key: 'actions',
    width: 120,
    render(row: any) {
      return h(NSpace, { size: 4 }, {
        default: () => [
          h(NButton, { size: 'tiny', type: 'primary', onClick: () => handleEdit(row) }, { default: () => '编辑' }),
          h(NButton, { size: 'tiny', type: 'error', disabled: row.roleId === 1 || row.roleId === 2, onClick: () => handleDelete(row) }, { default: () => '删除' })
        ]
      });
    }
  }
];

const loadData = async () => {
  loading.value = true;
  try {
    tableData.value = await getRoleList() as any;
  } catch (e) { console.error(e); }
  finally { loading.value = false; }
};

const loadMenus = async () => {
  try {
    menuTreeData.value = await getMenuList() as any;
  } catch (e) { console.error(e); }
};

onMounted(() => {
  loadData();
  loadMenus();
});

const handleAdd = () => {
  isEdit.value = false;
  formData.value = { roleName: '', roleKey: '', roleType: '', remark: '', menuIds: [] };
  showModal.value = true;
};

const handleEdit = async (row: any) => {
  try {
    const res = await getRoleDetail(row.roleId);
    isEdit.value = true;
    formData.value = { ...res.role, menuIds: res.menuIds || [] };
    showModal.value = true;
  } catch (e) { console.error(e); }
};

const handleDelete = (row: any) => {
  dialog.warning({
    title: '确认删除',
    content: `确认删除角色 ${row.roleName} 吗？`,
    positiveText: '确认',
    negativeText: '取消',
    onPositiveClick: async () => {
      try {
        await deleteRole(row.roleId);
        message.success('删除成功');
        loadData();
      } catch (e) { console.error(e); }
    }
  });
};

const handleCheckMenu = (keys: Array<string | number>) => {
  formData.value.menuIds = keys as number[];
};

const handleSubmit = (e: MouseEvent) => {
  e.preventDefault();
  formRef.value?.validate(async (errors: any) => {
    if (!errors) {
      try {
        if (isEdit.value) {
          await updateRole(formData.value.roleId!, formData.value);
          message.success('修改成功');
        } else {
          await addRole(formData.value);
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
.role-page {
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
  width: 170px;
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
</style>
