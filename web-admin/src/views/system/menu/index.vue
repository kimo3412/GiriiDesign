<template>
  <n-card title="菜单管理" :bordered="false">
    <template #header-extra>
      <n-button type="primary" @click="handleAdd(0)">新增顶级菜单</n-button>
    </template>

    <n-data-table
      :columns="columns"
      :data="tableData"
      :loading="loading"
      :row-key="row => row.menuId"
      default-expand-all
      :cascade="false"
    />

    <n-modal
      v-model:show="showModal"
      :title="isEdit ? '编辑菜单' : '新增菜单'"
      preset="dialog"
      positive-text="确定"
      negative-text="取消"
      @positive-click="handleSubmit"
      style="width: 500px"
    >
      <n-form :model="formData" :rules="rules" ref="formRef" label-placement="left" label-width="80">
        <n-form-item label="父菜单" path="parentId">
          <!-- 这里简写为数值输入，实际可使用 TreeSelect 组件 -->
          <n-tree-select
            v-model:value="formData.parentId"
            :options="[{ menuId: 0, menuName: '顶级菜单', children: tableData }]"
            key-field="menuId"
            label-field="menuName"
            children-field="children"
            placeholder="请选择父菜单"
          />
        </n-form-item>
        <n-form-item label="菜单类型" path="menuType">
          <n-radio-group v-model:value="formData.menuType">
            <n-radio value="M">目录 (M)</n-radio>
            <n-radio value="C">菜单 (C)</n-radio>
            <n-radio value="F">按钮 (F)</n-radio>
          </n-radio-group>
        </n-form-item>
        <n-form-item label="菜单名称" path="menuName">
          <n-input v-model:value="formData.menuName" placeholder="请输入名称" />
        </n-form-item>
        <n-form-item label="路由地址" path="path" v-if="formData.menuType !== 'F'">
          <n-input v-model:value="formData.path" placeholder="如：/system/user" />
        </n-form-item>
        <n-form-item label="组件路径" path="component" v-if="formData.menuType === 'C'">
          <n-input v-model:value="formData.component" placeholder="如：/system/user/index" />
        </n-form-item>
        <n-form-item label="权限标识" path="perms" v-if="formData.menuType !== 'M'">
          <n-input v-model:value="formData.perms" placeholder="如：user:list" />
        </n-form-item>
        <n-form-item label="显示排序" path="sortOrder">
          <n-input-number v-model:value="formData.sortOrder" :min="0" />
        </n-form-item>
        <n-form-item label="是否可见" path="visible" v-if="formData.menuType !== 'F'">
          <n-switch v-model:value="formData.visible" :checked-value="1" :unchecked-value="0" />
        </n-form-item>
      </n-form>
    </n-modal>
  </n-card>
</template>

<script lang="ts" setup>
import { ref, onMounted, h } from 'vue';
import { NButton, NTag, NSpace, useMessage, useDialog } from 'naive-ui';
import { getMenuList, getMenuDetail, addMenu, updateMenu, deleteMenu, type SysMenu } from '@/api/system/menuConfig';

const message = useMessage();
const dialog = useDialog();

const loading = ref(false);
const tableData = ref([]);

const showModal = ref(false);
const isEdit = ref(false);
const formRef = ref();
const formData = ref<SysMenu>({
  parentId: 0,
  menuName: '',
  menuType: 'C',
  path: '',
  component: '',
  perms: '',
  icon: '',
  sortOrder: 0,
  visible: 1
});

const rules = {
  menuName: { required: true, message: '请输入名称', trigger: 'blur' },
};

const columns = [
  { title: '菜单名称', key: 'menuName' },
  { title: '图标', key: 'icon', width: 80 },
  { title: '排序', key: 'sortOrder', width: 60 },
  { title: '权限标识', key: 'perms' },
  { title: '组件路径', key: 'component' },
  {
    title: '类型',
    key: 'menuType',
    width: 80,
    render(row: any) {
      const map: any = { 'M': { type: 'info', label: '目录' }, 'C': { type: 'success', label: '菜单' }, 'F': { type: 'warning', label: '按钮' } };
      const status = map[row.menuType];
      return status ? h(NTag, { type: status.type, size: 'small' }, { default: () => status.label }) : null;
    }
  },
  {
    title: '可见',
    key: 'visible',
    width: 80,
    render(row: any) {
      return row.menuType === 'F' ? '' : h(NTag, { type: row.visible === 1 ? 'success' : 'error', size: 'small' }, { default: () => (row.visible === 1 ? '是' : '隐藏') });
    }
  },
  {
    title: '操作',
    key: 'actions',
    width: 200,
    render(row: any) {
      return h(NSpace, {}, {
        default: () => [
          h(NButton, { size: 'small', type: 'info', onClick: () => handleAdd(row.menuId) }, { default: () => '新增' }),
          h(NButton, { size: 'small', type: 'primary', onClick: () => handleEdit(row) }, { default: () => '编辑' }),
          h(NButton, { size: 'small', type: 'error', onClick: () => handleDelete(row) }, { default: () => '删除' })
        ]
      });
    }
  }
];

const loadData = async () => {
  loading.value = true;
  try {
    tableData.value = await getMenuList() as any;
  } catch (e) {
    console.error(e);
  } finally {
    loading.value = false;
  }
};

onMounted(() => {
  loadData();
});

const handleAdd = (parentId: number) => {
  isEdit.value = false;
  formData.value = {
    parentId: parentId || 0,
    menuName: '',
    menuType: 'C',
    path: '',
    component: '',
    perms: '',
    icon: '',
    sortOrder: 0,
    visible: 1
  };
  showModal.value = true;
};

const handleEdit = async (row: any) => {
  try {
    const res = await getMenuDetail(row.menuId);
    isEdit.value = true;
    formData.value = { ...res };
    showModal.value = true;
  } catch (e) {
    console.error(e);
  }
};

const handleDelete = (row: any) => {
  dialog.warning({
    title: '确认删除',
    content: `确认删除菜单 ${row.menuName} 吗？`,
    positiveText: '确认',
    negativeText: '取消',
    onPositiveClick: async () => {
      try {
        await deleteMenu(row.menuId);
        message.success('删除成功');
        loadData();
      } catch (e) {
        console.error(e);
      }
    }
  });
};

const handleSubmit = (e: MouseEvent) => {
  e.preventDefault();
  formRef.value?.validate(async (errors: any) => {
    if (!errors) {
      try {
        if (isEdit.value) {
          await updateMenu(formData.value.menuId!, formData.value);
          message.success('修改成功');
        } else {
          await addMenu(formData.value);
          message.success('新增成功');
        }
        showModal.value = false;
        loadData();
      } catch (err) {
        console.error(err);
      }
    }
  });
  return false;
};
</script>
