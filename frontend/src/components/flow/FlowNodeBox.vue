<template>
  <NodeResizer
    :min-width="80"
    :min-height="36"
    :is-visible="selected"
    :handle-style="{ width: '10px', height: '10px', borderRadius: '3px', background: '#a78bfa', border: '1px solid #6366f1' }"
    :line-style="{ borderColor: '#6366f1', borderWidth: '1px' }"
  />

  <Handle type="target" :position="Position.Top"    class="fh fh-top"    />
  <Handle type="target" :position="Position.Left"   class="fh fh-left"   />
  <Handle type="source" :position="Position.Bottom" class="fh fh-bottom" />
  <Handle type="source" :position="Position.Right"  class="fh fh-right"  />

  <div
    class="box-inner"
    :class="[`shape--${data.shape || 'rect'}`]"
    :style="innerStyle"
    @dblclick.stop="startEdit"
  >
    <textarea
      v-if="editing"
      ref="textarea"
      v-model="labelDraft"
      class="box-edit"
      @blur="commitEdit"
      @keydown.enter.exact.stop.prevent="commitEdit"
      @keydown.escape.stop="cancelEdit"
    />
    <span v-else class="box-label" :style="labelStyle">{{ data.label || 'Clique duplo' }}</span>
  </div>
</template>

<script setup>
import { ref, computed, nextTick } from 'vue'
import { Handle, Position, useNode } from '@vue-flow/core'
import { NodeResizer } from '@vue-flow/node-resizer'
import '@vue-flow/node-resizer/dist/style.css'

const { id, data, selected } = useNode()
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
  if (editing.value) {
    emit('update:data', { ...data, label: labelDraft.value.trim() || data.label })
  }
  editing.value = false
}

function cancelEdit() {
  editing.value = false
}

const innerStyle = computed(() => ({
  background: data.bgColor || '#11111a',
  borderColor: data.borderColor || 'rgba(159,103,255,0.45)',
  borderStyle: data.borderStyle || 'solid',
  borderWidth: data.borderWidth ? `${data.borderWidth}px` : '1.5px',
  width: '100%',
  height: '100%',
  display: 'flex',
  alignItems: 'center',
  justifyContent: data.textAlign === 'left' ? 'flex-start' : data.textAlign === 'right' ? 'flex-end' : 'center',
  padding: '8px 12px',
  boxSizing: 'border-box',
  cursor: 'default',
  userSelect: 'none',
}))

const labelStyle = computed(() => ({
  color: data.color || '#e2e4f0',
  fontSize: `${data.fontSize || 13}px`,
  fontWeight: data.bold ? '700' : data.semibold ? '600' : '400',
  fontStyle: data.italic ? 'italic' : 'normal',
  textDecoration: data.underline ? 'underline' : 'none',
  textAlign: data.textAlign || 'center',
  lineHeight: '1.4',
  wordBreak: 'break-word',
  whiteSpace: 'pre-wrap',
  width: '100%',
}))
</script>

<style scoped>
/* Shapes */
.box-inner {
  width: 100%;
  height: 100%;
  box-sizing: border-box;
  overflow: hidden;
  transition: box-shadow 0.15s ease;
}

/* Rectangle (default) */
.shape--rect   { border-radius: 10px; border-style: solid; }

/* Rounded pill */
.shape--pill   { border-radius: 999px; border-style: solid; }

/* Ellipse */
.shape--ellipse { border-radius: 50%; border-style: solid; }

/* Diamond / decision */
.shape--diamond {
  border-radius: 0;
  border-style: solid;
  clip-path: polygon(50% 0%, 100% 50%, 50% 100%, 0% 50%);
}

/* Hexagon */
.shape--hex {
  border-radius: 0;
  clip-path: polygon(25% 0%, 75% 0%, 100% 50%, 75% 100%, 25% 100%, 0% 50%);
  border-style: solid;
}

/* Parallelogram */
.shape--para {
  clip-path: polygon(12% 0%, 100% 0%, 88% 100%, 0% 100%);
  border-style: solid;
}

/* Cylinder (top arc only) */
.shape--cylinder {
  border-radius: 8px 8px 0 0;
  border-bottom: 3px solid;
  border-style: solid;
}

.box-label {
  display: block;
  pointer-events: none;
}

.box-edit {
  width: 100%;
  height: 100%;
  background: transparent;
  border: none;
  outline: none;
  resize: none;
  font: inherit;
  color: inherit;
  font-size: 13px;
  text-align: center;
  padding: 0;
}

/* Handles */
.fh {
  width: 10px !important;
  height: 10px !important;
  border-radius: 50%;
  background: #6366f1;
  border: 2px solid #a78bfa;
  opacity: 0;
  transition: opacity 0.15s;
}
:global(.vue-flow__node:hover) .fh,
:global(.vue-flow__node.selected) .fh {
  opacity: 1;
}
</style>
