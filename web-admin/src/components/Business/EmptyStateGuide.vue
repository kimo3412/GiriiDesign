<template>
  <div class="empty-guide">
    <div class="empty-guide__icon">{{ icon }}</div>
    <div class="empty-guide__title">{{ title }}</div>
    <div v-if="description" class="empty-guide__desc">{{ description }}</div>
    <n-button
      v-if="actionLabel"
      type="primary"
      size="small"
      @click="emit('action')"
      style="margin-top: 16px;"
    >
      {{ actionLabel }}
    </n-button>
  </div>
</template>

<script lang="ts" setup>
import { NButton } from 'naive-ui';

defineOptions({ name: 'EmptyStateGuide' });

const props = defineProps<{
  icon?: string;
  title: string;
  description?: string;
  actionLabel?: string;
}>();

const emit = defineEmits<{ action: [] }>();
</script>

<style scoped>
.empty-guide {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 48px 24px;
  text-align: center;
}

.empty-guide__icon {
  font-size: 48px;
  margin-bottom: 16px;
  opacity: 0.6;
}

.empty-guide__title {
  font-size: 16px;
  font-weight: 600;
  color: var(--text-secondary);
  margin-bottom: 8px;
}

.empty-guide__desc {
  font-size: 13px;
  color: var(--text-tertiary);
  max-width: 320px;
  line-height: 1.6;
}
</style>
