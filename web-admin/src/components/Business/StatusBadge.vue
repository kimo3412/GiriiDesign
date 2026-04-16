<template>
  <n-tag
    :type="badgeType"
    :color="badgeColor"
    :size="size"
    :round="round"
    :bordered="false"
  >
    <template #icon v-if="showDot">
      <span class="status-dot" :style="{ backgroundColor: dotColor }"></span>
    </template>
    {{ label }}
  </n-tag>
</template>

<script lang="ts" setup>
import { computed } from 'vue';
import { NTag } from 'naive-ui';

defineOptions({ name: 'StatusBadge' });

const props = defineProps<{
  status: number | string;
  map?: Record<string | number, { label: string; type?: 'success' | 'warning' | 'error' | 'info' | 'default' }>;
  size?: 'small' | 'medium' | 'large';
  round?: boolean;
  showDot?: boolean;
}>();

// 内置默认 map，子类可覆盖
const defaultMap: Record<number, { label: string; type: 'success' | 'warning' | 'error' | 'info' | 'default' }> = {
  0: { label: '待处理', type: 'warning' },
  1: { label: '已转单', type: 'success' },
  2: { label: '已关闭', type: 'error' },
};

const map = computed(() => props.map || defaultMap);

const config = computed(() => map.value[props.status] ?? { label: String(props.status), type: 'default' as const });

const label = computed(() => config.value.label);
const badgeType = computed(() => config.value.type || 'default');

// 纯色背景 + 文字色（非 naive 原生 type，用 color prop 手动控制）
const badgeColor = computed(() => {
  const { type } = config.value;
  const colors: Record<string, { color: string; textColor: string; borderColor: string }> = {
    success: { color: 'var(--status-success-bg)', textColor: 'var(--status-success-text)', borderColor: 'var(--status-success-border)' },
    warning: { color: 'var(--status-warning-bg)', textColor: 'var(--status-warning-text)', borderColor: 'var(--status-warning-border)' },
    error:   { color: 'var(--status-error-bg)',   textColor: 'var(--status-error-text)',   borderColor: 'var(--status-error-border)' },
    info:    { color: 'var(--status-info-bg)',     textColor: 'var(--status-info-text)',     borderColor: 'var(--status-info-border)' },
    default: { color: 'var(--status-default-bg)', textColor: 'var(--status-default-text)', borderColor: 'var(--status-default-border)' },
  };
  return colors[type] || colors.default;
});

const dotColor = computed(() => {
  const { type } = config.value;
  const dotColors: Record<string, string> = {
    success: 'var(--status-success-text)',
    warning: 'var(--status-warning-text)',
    error:   'var(--status-error-text)',
    info:    'var(--status-info-text)',
    default: 'var(--status-default-text)',
  };
  return dotColors[type] || dotColors.default;
});
</script>

<style scoped>
.status-dot {
  display: inline-block;
  width: 6px;
  height: 6px;
  border-radius: 50%;
  margin-right: 4px;
  flex-shrink: 0;
}
</style>
