<template>
  <div class="filter-bar">
    <!-- 搜索区 -->
    <div class="filter-bar__search">
      <n-input
        v-if="showSearch"
        v-model:value="localKeyword"
        :placeholder="searchPlaceholder"
        size="small"
        clearable
        @keyup.enter="handleSearch"
        style="width: 200px"
      >
        <template #prefix>
          <n-icon><Search /></n-icon>
        </template>
      </n-input>
      <n-button v-if="showSearch" size="small" type="primary" @click="handleSearch">搜索</n-button>
    </div>

    <!-- 中间 slot（额外筛选项） -->
    <div v-if="$slots.extra" class="filter-bar__extra">
      <slot name="extra" />
    </div>

    <!-- 标签筛选区 -->
    <div v-if="tags.length" class="filter-bar__tags">
      <n-tag
        v-for="tag in tags"
        :key="tag.key"
        :type="activeTag === tag.key ? 'primary' : 'default'"
        size="small"
        round
        :closable="activeTag !== null"
        @click="toggleTag(tag.key)"
        @close="clearTag"
        style="cursor: pointer;"
      >
        {{ tag.label }}
      </n-tag>
    </div>

    <!-- 右侧 slot（操作按钮） -->
    <div v-if="$slots.actions" class="filter-bar__actions">
      <slot name="actions" />
    </div>
  </div>
</template>

<script lang="ts" setup>
import { ref, watch } from 'vue';
import { NInput, NButton, NIcon, NTag } from 'naive-ui';
import { Search } from '@vicons/ionicons5';

defineOptions({ name: 'PageFilterBar' });

const props = defineProps<{
  modelValue?: string;
  showSearch?: boolean;
  searchPlaceholder?: string;
  tags?: { label: string; key: string | number }[];
  activeTag?: string | number | null;
}>();

const emit = defineEmits<{
  'update:modelValue': [string];
  'update:activeTag': [string | number | null];
  search: [];
}>();

const localKeyword = ref(props.modelValue || '');

watch(() => props.modelValue, (v) => { localKeyword.value = v || ''; });

const handleSearch = () => {
  emit('update:modelValue', localKeyword.value);
  emit('search');
};

const toggleTag = (key: string | number) => {
  if (props.activeTag === key) {
    emit('update:activeTag', null);
  } else {
    emit('update:activeTag', key);
  }
};

const clearTag = () => {
  emit('update:activeTag', null);
};
</script>

<style scoped>
.filter-bar {
  display: flex;
  align-items: center;
  gap: 8px;
  flex-wrap: wrap;
}

.filter-bar__search {
  display: flex;
  align-items: center;
  gap: 6px;
}

.filter-bar__extra {
  display: flex;
  align-items: center;
  gap: 6px;
}

.filter-bar__tags {
  display: flex;
  align-items: center;
  gap: 4px;
}

.filter-bar__actions {
  display: flex;
  align-items: center;
  gap: 6px;
  margin-left: auto;
}
</style>
