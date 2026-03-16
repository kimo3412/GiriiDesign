<template>
  <n-card title="订单看板" :bordered="false">
    <template #header-extra>
      <n-select
        v-model:value="filterCategory"
        :options="categoryOptions"
        placeholder="按品类筛选"
        style="width: 180px"
        clearable
        @update:value="loadData"
      />
    </template>

    <n-spin :show="loading">
      <div v-if="columns.length === 0" class="empty-hint">
        暂无生产中的订单
      </div>
      <div v-else class="kanban-board">
        <div v-for="col in columns" :key="col.stepId" class="kanban-column">
          <div class="kanban-column-header">
            <span>{{ col.stepName }}</span>
            <n-badge :value="col.orders.length" :max="99" />
          </div>
          <draggable
            :list="col.orders"
            group="kanban"
            item-key="orderId"
            class="kanban-list"
            animation="200"
            @end="onDragEnd"
          >
            <template #item="{ element }">
              <div class="kanban-card" :class="{ 'is-blocked': element.isBlocked === 1 }" @click="goDetail(element.orderId)">
                <div class="card-header">
                  <span class="order-sn">{{ element.orderSn }}</span>
                  <n-tag v-if="element.isBlocked === 1" type="error" size="tiny">阻塞</n-tag>
                </div>
                <div class="card-body">
                  <div class="card-row">
                    <span class="label">品类:</span>
                    <span>{{ getCategoryName(element.categoryId) }}</span>
                  </div>
                  <div class="card-row" v-if="element.totalAmount">
                    <span class="label">金额:</span>
                    <span>¥{{ element.totalAmount }}</span>
                  </div>
                  <div class="card-row" v-if="element.expectedDate">
                    <span class="label">交付:</span>
                    <span>{{ element.expectedDate }}</span>
                  </div>
                </div>
              </div>
            </template>
          </draggable>
        </div>
      </div>
    </n-spin>
  </n-card>
</template>

<script lang="ts" setup>
import { ref, onMounted } from 'vue';
import { useRouter } from 'vue-router';
import { useMessage } from 'naive-ui';
import draggable from 'vuedraggable';
import { getKanbanData, advanceOrder } from '@/api/order/index';
import { getCategoryList } from '@/api/config/category';

const router = useRouter();
const message = useMessage();
const loading = ref(false);

const filterCategory = ref(null);
const categoryOptions = ref<any[]>([]);
const categoryMap = ref<Record<number, string>>({});

const columns = ref<any[]>([]);

onMounted(async () => {
  try {
    const cats = await getCategoryList();
    categoryOptions.value = cats.map((c: any) => ({ label: c.name, value: c.categoryId }));
    categoryMap.value = Object.fromEntries(cats.map((c: any) => [c.categoryId, c.name]));
  } catch (e) { console.error(e); }
  loadData();
});

const getCategoryName = (id: number) => categoryMap.value[id] || id;

const loadData = async () => {
  loading.value = true;
  try {
    const params: any = {};
    if (filterCategory.value != null) params.categoryId = filterCategory.value;
    columns.value = await getKanbanData(params) || [];
  } catch (e) { console.error(e); }
  finally { loading.value = false; }
};

const goDetail = (orderId: number) => {
  router.push(`/order/detail/${orderId}`);
};

const onDragEnd = async (evt: any) => {
  // 拖拽结束后，简单提示。实际推进需要通过详情页操作。
  // 看板主要用于可视化，深度操作在详情页进行。
  message.info('看板排序已更新（如需推进节点，请进入订单详情操作）');
};
</script>

<style scoped>
.empty-hint {
  text-align: center;
  padding: 80px 0;
  color: #999;
}

.kanban-board {
  display: flex;
  gap: 16px;
  overflow-x: auto;
  padding-bottom: 12px;
  min-height: 400px;
}

.kanban-column {
  min-width: 260px;
  max-width: 300px;
  flex-shrink: 0;
  background: #f5f5f5;
  border-radius: 8px;
  display: flex;
  flex-direction: column;
}

.kanban-column-header {
  padding: 12px 16px;
  font-weight: 600;
  display: flex;
  align-items: center;
  justify-content: space-between;
  border-bottom: 2px solid #e0e0e0;
}

.kanban-list {
  padding: 8px;
  flex: 1;
  min-height: 100px;
}

.kanban-card {
  background: #fff;
  border-radius: 6px;
  padding: 12px;
  margin-bottom: 8px;
  box-shadow: 0 1px 3px rgba(0,0,0,0.08);
  cursor: pointer;
  transition: box-shadow 0.2s, transform 0.15s;
}

.kanban-card:hover {
  box-shadow: 0 3px 8px rgba(0,0,0,0.15);
  transform: translateY(-1px);
}

.kanban-card.is-blocked {
  border-left: 3px solid #e03e3e;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 8px;
}

.order-sn {
  font-weight: 600;
  font-size: 13px;
  font-family: monospace;
}

.card-body {
  font-size: 12px;
  color: #666;
}

.card-row {
  display: flex;
  gap: 4px;
  margin-bottom: 2px;
}

.card-row .label {
  color: #999;
}
</style>
