<template>
  <div class="inline-flex items-center gap-1.5 rounded-full border border-[var(--line-subtle)] bg-[var(--surface-base)] px-2.5 py-1">
    <span
      :class="[
        'inline-block h-2 w-2 rounded-full',
        variantClass
      ]"
    ></span>
    <span class="text-xs font-medium text-[var(--text-main)]">
      {{ label }}
    </span>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'

const props = defineProps<{
  status: string
  label: string
}>()

const variantClass = computed(() => {
  switch (props.status) {
    case 'active':
    case 'success':
      return 'bg-[var(--success)]'
    case 'disabled':
    case 'inactive':
    case 'warning':
      return 'bg-[var(--warning)]'
    case 'error':
    case 'danger':
      return 'bg-[var(--danger)]'
    default:
      return 'bg-[var(--text-muted)]'
  }
})
</script>
