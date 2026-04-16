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

const handleClick = () => {
  if (props.clickable) emit('click');
};
</script>

<style scoped>
.metric-card {
  background: var(--panel-bg);
  border-radius: var(--panel-radius);
  padding: 20px 24px;
  transition: box-shadow 0.2s, transform 0.2s;
  box-shadow: var(--panel-shadow);
  border-bottom: 3px solid transparent;
}

.metric-card:hover {
  box-shadow: var(--panel-shadow-hover);
}

.metric-card--primary   { border-bottom-color: var(--primary-color); }
.metric-card--success   { border-bottom-color: var(--status-success-text); }
.metric-card--warning   { border-bottom-color: var(--status-warning-text); }
.metric-card--error     { border-bottom-color: var(--status-error-text); }
.metric-card--default   { border-bottom-color: var(--status-default-text); }

.metric-card__header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 8px;
}

.metric-card__label {
  font-size: 13px;
  color: var(--text-tertiary);
}

.metric-card__icon {
  font-size: 22px;
  opacity: 0.55;
}

.metric-card__value {
  font-size: 32px;
  font-weight: 700;
  line-height: 1.2;
  color: var(--text-primary);
}

.metric-card__sub {
  font-size: 12px;
  color: var(--text-placeholder);
  margin-top: 4px;
}

/* 点击态 */
.metric-card[style*="cursor: pointer"]:hover {
  transform: translateY(-2px);
}
</style>
