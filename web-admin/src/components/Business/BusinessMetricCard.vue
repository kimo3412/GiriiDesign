<template>
  <div
    class="metric-card"
    :class="`metric-card--${variant}`"
    :style="{ cursor: clickable ? 'pointer' : 'default' }"
    @click="handleClick"
  >
    <div class="metric-card__header">
      <span class="metric-card__label">{{ label }}</span>
      <span v-if="icon" class="metric-card__icon">{{ icon }}</span>
    </div>
    <div class="metric-card__value">{{ displayValue }}</div>
    <div v-if="subLabel" class="metric-card__sub">{{ subLabel }}</div>
  </div>
</template>

<script lang="ts" setup>
import { computed } from 'vue';

defineOptions({ name: 'BusinessMetricCard' });

const props = defineProps<{
  label: string;
  value: number | string;
  icon?: string;
  variant?: 'primary' | 'success' | 'warning' | 'error' | 'default';
  subLabel?: string;
  clickable?: boolean;
  prefix?: string;
}>();

const emit = defineEmits<{ click: [] }>();

const displayValue = computed(() =>
  props.prefix ? `${props.prefix}${props.value}` : String(props.value)
);

function handleClick() {
  if (props.clickable) emit('click');
}
</script>

<style scoped>
.metric-card {
  display: grid;
  grid-template-columns: auto auto auto;
  align-items: center;
  justify-content: start;
  column-gap: 8px;
  min-height: 52px;
  padding: 10px 14px;
  border: 1px solid var(--border-light);
  border-bottom-width: 1px;
  border-radius: 14px;
  background: var(--panel-bg);
  box-shadow: none;
  transition: border-color 0.2s, background 0.2s, transform 0.2s;
}

.metric-card:hover {
  background: var(--row-selected-bg);
}

.metric-card--primary {
  border-color: rgba(72, 115, 255, 0.24);
}

.metric-card--success {
  border-color: rgba(101, 191, 115, 0.3);
}

.metric-card--warning {
  border-color: rgba(228, 171, 59, 0.3);
}

.metric-card--error {
  border-color: rgba(220, 89, 110, 0.28);
}

.metric-card--default {
  border-color: var(--border-light);
}

.metric-card__header {
  display: contents;
}

.metric-card__label {
  color: var(--text-tertiary);
  font-size: 12px;
  font-weight: 600;
  white-space: nowrap;
}

.metric-card__icon {
  order: 3;
  font-size: 14px;
  opacity: 0.34;
}

.metric-card__value {
  color: var(--text-primary);
  order: 2;
  font-size: 18px;
  font-weight: 800;
  line-height: 1.2;
}

.metric-card__sub {
  grid-column: 1 / -1;
  color: var(--text-placeholder);
  font-size: 11px;
}

.metric-card[style*='cursor: pointer']:hover {
  transform: translateY(-1px);
}

@media (max-width: 768px) {
  .metric-card {
    min-height: 48px;
    padding: 10px 12px;
  }

  .metric-card__value {
    font-size: 16px;
  }
}
</style>
