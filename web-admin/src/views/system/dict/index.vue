<template>
  <n-card title="字典管理" :bordered="false">
    <n-grid :cols="2" :x-gap="16">
      <!-- 左侧：字典类型列表 -->
      <n-gi>
        <n-card title="字典类型" size="small" :bordered="true">
          <template #header-extra>
            <n-button size="small" type="primary" @click="handleAddType">新增</n-button>
          </template>
          <n-data-table
            :columns="typeColumns"
            :data="typeList"
            :loading="typeLoading"
            :row-key="(row) => row.dictId"
            :row-class-name="(row) => selectedType?.dictId === row.dictId ? 'selected-row' : ''"
            @update:checked-row-keys="handleTypeSelect"
            size="small"
            striped
          />
        </n-card>
      </n-gi>

      <!-- 右侧：字典数据列表 -->
      <n-gi>
        <n-card :title="selectedType ? `字典数据 - ${selectedType.dictName}` : '字典数据'" size="small" :bordered="true">
          <template #header-extra>
            <n-button size="small" type="primary" :disabled="!selectedType" @click="handleAddData">新增</n-button>
          </template>
          <n-data-table
            v-if="selectedType"
            :columns="dataColumns"
            :data="dataList"
            :loading="dataLoading"
            :row-key="(row) => row.dictCode"
            size="small"
            striped
          />
          <n-empty v-else description="请在左侧选择一个字典类型" />
        </n-card>
      </n-gi>
    </n-grid>

    <!-- 字典类型弹窗 -->
    <n-modal
      v-model:show="showTypeModal"
      :title="isEditType ? '编辑字典类型' : '新增字典类型'"
      preset="dialog"
      positive-text="确定"
      negative-text="取消"
      @positive-click="submitType"
      style="width: 450px"
    >
      <n-form :model="typeForm" label-placement="left" label-width="80">
        <n-form-item label="字典名称">
          <n-input v-model:value="typeForm.dictName" placeholder="如：订单状态" />
        </n-form-item>
        <n-form-item label="字典类型">
          <n-input v-model:value="typeForm.dictType" placeholder="如：order_status" :disabled="isEditType" />
        </n-form-item>
        <n-form-item label="备注">
          <n-input v-model:value="typeForm.remark" type="textarea" placeholder="备注说明" />
        </n-form-item>
      </n-form>
    </n-modal>

    <!-- 字典数据弹窗 -->
    <n-modal
      v-model:show="showDataModal"
      :title="isEditData ? '编辑字典数据' : '新增字典数据'"
      preset="dialog"
      positive-text="确定"
      negative-text="取消"
      @positive-click="submitData"
      style="width: 450px"
    >
      <n-form :model="dataForm" label-placement="left" label-width="80">
        <n-form-item label="字典标签">
          <n-input v-model:value="dataForm.dictLabel" placeholder="显示标签" />
        </n-form-item>
        <n-form-item label="字典值">
          <n-input v-model:value="dataForm.dictValue" placeholder="实际值" />
        </n-form-item>
        <n-form-item label="排序">
          <n-input-number v-model:value="dataForm.sortOrder" :min="0" style="width: 100%" />
        </n-form-item>
        <n-form-item label="备注">
          <n-input v-model:value="dataForm.remark" placeholder="备注" />
        </n-form-item>
      </n-form>
    </n-modal>
  </n-card>
</template>

<script lang="ts" setup>
  import { ref, h, onMounted } from 'vue';
  import { useMessage, NButton, NSpace } from 'naive-ui';
  import {
    getDictTypeList,
    getDictDataList,
  } from '@/api/common/index';
  import { Alova } from '@/utils/http/alova/index';

  const message = useMessage();

  // ========== 字典类型 ==========
  const typeLoading = ref(false);
  const typeList = ref<any[]>([]);
  const selectedType = ref<any>(null);
  const showTypeModal = ref(false);
  const isEditType = ref(false);
  const typeForm = ref({ dictId: null, dictName: '', dictType: '', remark: '' });

  const typeColumns = [
    { title: '字典名称', key: 'dictName', width: 120 },
    { title: '字典类型', key: 'dictType', width: 120 },
    {
      title: '操作',
      key: 'actions',
      width: 120,
      render(row: any) {
        return h(NSpace, null, {
          default: () => [
            h(NButton, { text: true, type: 'primary', onClick: () => { selectedType.value = row; loadDataList(); } }, { default: () => '查看' }),
            h(NButton, { text: true, type: 'primary', onClick: () => handleEditType(row) }, { default: () => '编辑' }),
          ],
        });
      },
    },
  ];

  const loadTypeList = async () => {
    typeLoading.value = true;
    try {
      typeList.value = await getDictTypeList();
    } finally {
      typeLoading.value = false;
    }
  };

  const handleAddType = () => {
    isEditType.value = false;
    typeForm.value = { dictId: null, dictName: '', dictType: '', remark: '' };
    showTypeModal.value = true;
  };

  const handleEditType = (row: any) => {
    isEditType.value = true;
    typeForm.value = { ...row };
    showTypeModal.value = true;
  };

  const submitType = async () => {
    try {
      if (isEditType.value) {
        await Alova.Put(`/v1/admin/dict/types/${typeForm.value.dictId}`, typeForm.value);
      } else {
        await Alova.Post('/v1/admin/dict/types', typeForm.value);
      }
      message.success('操作成功');
      showTypeModal.value = false;
      await loadTypeList();
    } catch (e) { return false; }
  };

  const handleTypeSelect = (keys: any[]) => {
    if (keys.length > 0) {
      selectedType.value = typeList.value.find((t) => t.dictId === keys[0]);
      loadDataList();
    }
  };

  // ========== 字典数据 ==========
  const dataLoading = ref(false);
  const dataList = ref<any[]>([]);
  const showDataModal = ref(false);
  const isEditData = ref(false);
  const dataForm = ref({ dictCode: null, dictType: '', dictLabel: '', dictValue: '', sortOrder: 0, remark: '' });

  const dataColumns = [
    { title: '标签', key: 'dictLabel', width: 100 },
    { title: '值', key: 'dictValue', width: 100 },
    { title: '排序', key: 'sortOrder', width: 60 },
    {
      title: '操作',
      key: 'actions',
      width: 120,
      render(row: any) {
        return h(NSpace, null, {
          default: () => [
            h(NButton, { text: true, type: 'primary', onClick: () => handleEditData(row) }, { default: () => '编辑' }),
            h(NButton, { text: true, type: 'error', onClick: () => handleDeleteData(row) }, { default: () => '删除' }),
          ],
        });
      },
    },
  ];

  const loadDataList = async () => {
    if (!selectedType.value) return;
    dataLoading.value = true;
    try {
      dataList.value = await getDictDataList(selectedType.value.dictType);
    } finally {
      dataLoading.value = false;
    }
  };

  const handleAddData = () => {
    isEditData.value = false;
    dataForm.value = { dictCode: null, dictType: selectedType.value.dictType, dictLabel: '', dictValue: '', sortOrder: 0, remark: '' };
    showDataModal.value = true;
  };

  const handleEditData = (row: any) => {
    isEditData.value = true;
    dataForm.value = { ...row };
    showDataModal.value = true;
  };

  const submitData = async () => {
    try {
      if (isEditData.value) {
        await Alova.Put(`/v1/admin/dict/data/${dataForm.value.dictCode}`, dataForm.value);
      } else {
        await Alova.Post('/v1/admin/dict/data', dataForm.value);
      }
      message.success('操作成功');
      showDataModal.value = false;
      await loadDataList();
    } catch (e) { return false; }
  };

  const handleDeleteData = async (row: any) => {
    await Alova.Delete(`/v1/admin/dict/data/${row.dictCode}`);
    message.success('删除成功');
    await loadDataList();
  };

  onMounted(() => {
    loadTypeList();
  });
</script>

<style scoped>
  :deep(.selected-row) {
    background-color: rgba(45, 140, 240, 0.08);
  }
</style>
