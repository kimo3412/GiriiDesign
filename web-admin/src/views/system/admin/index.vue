<template>
  <n-card title="用户管理" :bordered="false">
    <template #header-extra>
      <n-button type="primary" @click="handleAdd">新增用户</n-button>
    </template>

    <n-data-table
      :columns="columns"
      :data="tableData"
      :loading="loading"
      :row-key="row => row.adminId"
    />

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
  </n-card>
</template>

<script lang="ts" setup>
import { ref, onMounted, h } from 'vue';
import { NButton, NTag, NSpace, useMessage, useDialog } from 'naive-ui';
import { getAdminList, getAdminDetail, addAdmin, updateAdmin, deleteAdmin, updateDesignerCategories, type AdminSaveDTO } from '@/api/system/adminList';
import { getRoleList } from '@/api/system/roleList';
import { getCategoryList } from '@/api/config/category';

const message = useMessage();
const dialog = useDialog();

const loading = ref(false);
const tableData = ref([]);

const roleOptions = ref<{label: string, value: number}[]>([]);
const categoryOptions = ref<{label: string, value: number}[]>([]);

const showModal = ref(false);
const isEdit = ref(false);
const formRef = ref();
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

const columns = [
  { title: 'ID', key: 'adminId', width: 60 },
  { title: '账号', key: 'username' },
  { title: '昵称', key: 'nickname' },
  { title: '手机号', key: 'phone' },
  {
    title: '状态',
    key: 'status',
    render(row: any) {
      return h(NTag, { type: row.status === 1 ? 'success' : 'error' }, { default: () => (row.status === 1 ? '正常' : '禁用') });
    }
  },
  { title: '创建时间', key: 'createTime' },
  {
    title: '操作',
    key: 'actions',
    width: 150,
    render(row: any) {
      return h(NSpace, {}, {
        default: () => [
          h(NButton, { size: 'small', type: 'primary', onClick: () => handleEdit(row) }, { default: () => '编辑' }),
          h(NButton, { size: 'small', type: 'error', disabled: row.adminId === 1, onClick: () => handleDelete(row) }, { default: () => '删除' })
        ]
      });
    }
  }
];

const loadData = async () => {
  loading.value = true;
  try {
    tableData.value = await getAdminList() as any;
  } catch (e) {
    console.error(e);
  } finally {
    loading.value = false;
  }
};

const loadRoles = async () => {
  try {
    const res = await getRoleList();
    roleOptions.value = res.map((r: any) => ({ label: r.roleName, value: r.roleId }));
  } catch (e) {
    console.error(e);
  }
};

onMounted(() => {
  loadData();
  loadRoles();
  loadCategories();
});

const loadCategories = async () => {
  try {
    const res = await getCategoryList();
    categoryOptions.value = res.map((c: any) => ({ label: c.name, value: c.categoryId }));
  } catch (e) { console.error(e); }
};

const handleAdd = () => {
  isEdit.value = false;
  formData.value = {
    username: '',
    password: '',
    nickname: '',
    phone: '',
    status: 1,
    roleIds: [],
    categoryIds: []
  };
  showModal.value = true;
};

const handleEdit = async (row: any) => {
  try {
    const res = await getAdminDetail(row.adminId);
    isEdit.value = true;
    formData.value = {
      ...res.admin,
      password: '', // 密码不回显
      roleIds: res.roleIds || [],
      categoryIds: res.categoryIds || []
    };
    showModal.value = true;
  } catch (e) {
    console.error(e);
  }
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
      } catch (e) {
        console.error(e);
      }
    }
  });
};

const handleSubmit = () => {
  formRef.value?.validate(async (errors: any) => {
    if (!errors) {
      try {
        if (isEdit.value) {
          await updateAdmin(formData.value.adminId!, formData.value);
          // 同步更新设计师-品类关联
          if (formData.value.categoryIds) {
            await updateDesignerCategories(formData.value.adminId!, formData.value.categoryIds);
          }
          message.success('修改成功');
        } else {
          await addAdmin(formData.value);
          // 新增用户时如果有品类，也需要设置
          if (formData.value.categoryIds?.length) {
            // 需要拿到新用户的ID——从列表中取最新的
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
      } catch (err) {
        console.error(err);
      }
    }
  });
  return false;
};
</script>
