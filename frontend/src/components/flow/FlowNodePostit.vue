<template>
  <NodeResizer
    :min-width="100"
    :min-height="60"
    :is-visible="selected"
    :handle-style="{ width: '9px', height: '9px', borderRadius: '3px', background: '#fbbf24', border: '1.5px solid #d97706' }"
    :line-style="{ borderColor: '#fbbf24', borderWidth: '1px' }"
  />

  <Handle type="target" :position="Position.Top"    class="ph ph-top"    />
  <Handle type="target" :position="Position.Left"   class="ph ph-left"   />
  <Handle type="source" :position="Position.Bottom" class="ph ph-bottom" />
  <Handle type="source" :position="Position.Right"  class="ph ph-right"  />

  <!-- Pin icon -->
  <div class="pi-pin" title="Post-it">
    <svg width="10" height="10" fill="currentColor" viewBox="0 0 24 24">
      <path d="M16 1H8a2 2 0 0 0-2 2v18l6-4 6 4V3a2 2 0 0 0-2-2z"/>
    </svg>
  </div>

  <div class="pi-inner" :style="innerStyle" @dblclick.stop="startEdit">
    <textarea
      v-if="editing"
      ref="textarea"
      v-model="labelDraft"
      class="pi-edit"
      @blur="commitEdit"
      @keydown.enter.exact.stop.prevent="commitEdit"
      @keydown.escape.stop="cancelEdit"
    />
    <span v-else class="pi-label">{{ data.label || 'Observação...' }}</span>
  </div>
</template>

<script setup>
import { ref, computed, nextTick } from 'vue'
import { Handle, Position, useNode } from '@vue-flow/core'
import { NodeResizer } from '@vue-flow/node-resizer'

const { data, selected } = useNode()
const emit = defineEmits(['update:data'])

const editing = ref(false)
const labelDraft = ref('')
const textarea = ref(null)

function startEdit() {
  labelDraft.value = data.label || ''
  editing.value = true
  nextTick(() => textarea.value?.focus())
}
function commitEdit() {
  if (editing.value) emit('update:data', { ...data, label: labelDraft.value || data.label })
  editing.value = false
}
function cancelEdit() { editing.value = false }

const COLORS = {
  yellow: { bg: '#fef9c3', border: '#fde047', accent: '#ca8a04' },
  amber:  { bg: '#fef3c7', border: '#fbbf24', accent: '#d97706' },
  lime:   { bg: '#ecfccb', border: '#bef264', accent: '#65a30d' },
  cyan:   { bg: '#cffafe', border: '#67e8f9', accent: '#0891b2' },
  pink:   { bg: '#fce7f3', border: '#f9a8d4', accent: '#be185d' },
  purple: { bg: '#f3e8ff', border: '#d8b4fe', accent: '#7c3aed' },
}
const palette = computed(() => COLORS[data.postitColor || 'yellow'])

const innerStyle = computed(() => ({
  background: palette.value.bg,
  borderColor: palette.value.border,
  width: '100%',
  height: '100%',
  boxSizing: 'border-box',
  overflow: 'hidden',
  display: 'flex',
  alignItems: 'flex-start',
  justifyContent: 'flex-start',
  padding: '10px 10px 6px',
  cursor: 'default',
}))
</script>

<style scoped>
.pi-pin {
  position: absolute;
  top: -6px;
  left: 50%;
  transform: translateX(-50%);
  color: #d97706;
  z-index: 2;
  filter: drop-shadow(0 1px 2px rgba(0,0,0,0.3));
}

.pi-inner {
  width: 100%;
  height: 100%;
  border-radius: 4px 4px 4px 14px;
  border: 1.5px solid;
  box-shadow: 3px 4px 12px rgba(0,0,0,0.15), inset 0 1px 0 rgba(255,255,255,0.6);
  position: relative;
}

.pi-inner::after {
  content: '';
  position: absolute;
  bottom: 0;
  left: 0;
  width: 14px;
  height: 14px;
  background: inherit;
  filter: brightness(0.86);
  border-radius: 0 4px 0 0;
  clip-path: polygon(0 0, 100% 100%, 0 100%);
}

.pi-label {
  font-size: 12px;
  line-height: 1.5;
  color: #1c1917;
  white-space: pre-wrap;
  word-break: break-word;
  font-family: 'Caveat', 'Patrick Hand', cursive, sans-serif;
}

.pi-edit {
  width: 100%;
  height: 100%;
  background: transparent;
  border: none;
  outline: none;
  resize: none;
  font-size: 12px;
  font-family: 'Caveat', 'Patrick Hand', cursive, sans-serif;
  color: #1c1917;
  padding: 0;
  line-height: 1.5;
}

/* Handles */
.ph {
  width: 9px !important;
  height: 9px !important;
  border-radius: 50%;
  background: #fbbf24;
  border: 1.5px solid #d97706;
  opacity: 0;
  transition: opacity 0.15s;
}
:global(.vue-flow__node:hover) .ph,
:global(.vue-flow__node.selected) .ph {
  opacity: 1;
}
</style>
