<template>
  <span class="tag-badge" :style="badgeStyle">
    <span class="tag-dot" :style="{ background: dotColor }"></span>
    <span class="tag-name">{{ tag.name }}</span>
    <button v-if="removable" class="tag-remove" @click.stop="$emit('remove', tag)" title="Remover tag">
      <svg width="10" height="10" fill="none" stroke="currentColor" stroke-width="2.5" viewBox="0 0 24 24">
        <line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/>
      </svg>
    </button>
  </span>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  tag: { type: Object, required: true },
  removable: { type: Boolean, default: false }
})

defineEmits(['remove'])

const COLOR_MAP = {
  purple:  { bg: 'rgba(139,92,246,0.15)', dot: '#8b5cf6', text: '#a78bfa' },
  blue:    { bg: 'rgba(59,130,246,0.15)', dot: '#3b82f6', text: '#60a5fa' },
  green:   { bg: 'rgba(34,197,94,0.15)', dot: '#22c55e', text: '#4ade80' },
  amber:   { bg: 'rgba(245,158,11,0.15)', dot: '#f59e0b', text: '#fbbf24' },
  rose:    { bg: 'rgba(244,63,94,0.15)', dot: '#f43f5e', text: '#fb7185' },
  cyan:    { bg: 'rgba(6,182,212,0.15)', dot: '#06b6d4', text: '#22d3ee' },
  orange:  { bg: 'rgba(249,115,22,0.15)', dot: '#f97316', text: '#fb923c' },
  pink:    { bg: 'rgba(236,72,153,0.15)', dot: '#ec4899', text: '#f472b6' },
  teal:    { bg: 'rgba(20,184,166,0.15)', dot: '#14b8a6', text: '#2dd4bf' },
  indigo:  { bg: 'rgba(99,102,241,0.15)', dot: '#6366f1', text: '#818cf8' },
  lime:    { bg: 'rgba(132,204,22,0.15)', dot: '#84cc16', text: '#a3e635' },
  slate:   { bg: 'rgba(100,116,139,0.15)', dot: '#64748b', text: '#94a3b8' }
}

const palette = computed(() => COLOR_MAP[props.tag.color] || COLOR_MAP.purple)
const badgeStyle = computed(() => ({
  background: palette.value.bg,
  color: palette.value.text
}))
const dotColor = computed(() => palette.value.dot)
</script>

<style scoped>
.tag-badge {
  display: inline-flex;
  align-items: center;
  gap: 5px;
  padding: 2px 8px;
  border-radius: 99px;
  font-size: 11px;
  font-weight: 600;
  letter-spacing: 0.02em;
  white-space: nowrap;
  transition: opacity 0.15s;
}
.tag-dot {
  width: 6px;
  height: 6px;
  border-radius: 50%;
  flex-shrink: 0;
}
.tag-name {
  max-width: 100px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
.tag-remove {
  background: none; border: none; cursor: pointer;
  padding: 0; margin: 0; display: flex;
  align-items: center; color: inherit; opacity: 0.6;
  transition: opacity 0.15s;
}
.tag-remove:hover { opacity: 1; }
</style>
