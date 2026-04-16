<template>
  <div class="action-panel" :class="`action-panel--${layout}`">
    <n-space :size="6" :wrap="true">
      <slot />
    </n-space>
  </div>
</template>

<script lang="ts" setup>
defineOptions({ name: 'ActionPanel' });

defineProps<{
  layout?: 'horizontal' | 'vertical';
}>();
</script>

<style scoped>
.action-panel {
  display: flex;
  align-items: center;
}

.action-panel--vertical {
  flex-direction: column;
  align-items: flex-start;
}
</style>
