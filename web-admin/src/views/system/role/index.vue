<template>
  <n-card title="角色管理" :bordered="false">
    <template #header-extra>
      <n-button type="primary" @click="handleAdd">新增角色</n-button>
    </template>

    <n-data-table
      :columns="columns"
      :data="tableData"
      :loading="loading"
      :row-key="row => row.roleId"
    />

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
        <n-form-item label="备注" path="remark">
          <n-input v-model:value="formData.remark" type="textarea" placeholder="请输入备注" />
        </n-form-item>
        <n-form-item label="菜单权限" path="menuIds">
          <!-- 这里简写，直接使用级联选择器加载菜单，更高级的系统会用 Tree 组件 -->
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
  </n-card>
</template>

<script lang="ts" setup>
import { ref, onMounted, h } from 'vue';
import { NButton, NSpace, useMessage, useDialog } from 'naive-ui';
import { getRoleList, getRoleDetail, addRole, updateRole, deleteRole, type RoleSaveDTO } from '@/api/system/roleList';
import { getMenuList } from '@/api/system/menuConfig';

const message = useMessage();
const dialog = useDialog();

const loading = ref(false);
const tableData = ref([]);

const menuTreeData = ref([]);

const showModal = ref(false);
const isEdit = ref(false);
const formRef = ref();
const formData = ref<RoleSaveDTO>({
  roleName: '',
  roleKey: '',
  remark: '',
  menuIds: []
});

const rules = {
  roleName: { required: true, message: '请输入名称', trigger: 'blur' },
  roleKey: { required: true, message: '请输入标识', trigger: 'blur' },
};

const columns = [
  { title: 'ID', key: 'roleId', width: 60 },
  { title: '角色名', key: 'roleName' },
  { title: '角色标识', key: 'roleKey' },
  { title: '备注', key: 'remark' },
  { title: '创建时间', key: 'createTime' },
  {
    title: '操作',
    key: 'actions',
    width: 150,
    render(row: any) {
      return h(NSpace, {}, {
        default: () => [
          h(NButton, { size: 'small', type: 'primary', onClick: () => handleEdit(row) }, { default: () => '编辑' }),
          h(NButton, { size: 'small', type: 'error', disabled: row.roleId === 1 || row.roleId === 2, onClick: () => handleDelete(row) }, { default: () => '删除' })
        ]
      });
    }
  }
];

const loadData = async () => {
  loading.value = true;
  try {
    tableData.value = await getRoleList() as any;
  } catch (e) {
    console.error(e);
  } finally {
    loading.value = false;
  }
};

const loadMenus = async () => {
  try {
    menuTreeData.value = await getMenuList() as any;
  } catch (e) {
    console.error(e);
  }
};

onMounted(() => {
  loadData();
  loadMenus();
});

const handleAdd = () => {
  isEdit.value = false;
  formData.value = {
    roleName: '',
    roleKey: '',
    remark: '',
    menuIds: []
  };
  showModal.value = true;
};

const handleEdit = async (row: any) => {
  try {
    const res = await getRoleDetail(row.roleId);
    isEdit.value = true;
    formData.value = {
      ...res.role,
      menuIds: res.menuIds || []
    };
    showModal.value = true;
  } catch (e) {
    console.error(e);
  }
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
      } catch (e) {
        console.error(e);
      }
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
      } catch (err) {
        console.error(err);
      }
    }
  });
  return false;
};
</script>
