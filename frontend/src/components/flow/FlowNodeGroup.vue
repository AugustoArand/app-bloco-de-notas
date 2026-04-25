<template>
  <NodeResizer
    :min-width="160"
    :min-height="100"
    :is-visible="props.selected"
    :handle-style="{ width: '10px', height: '10px', borderRadius: '3px', background: '#34d399', border: '1.5px solid #059669' }"
    :line-style="{ borderColor: '#34d399', borderWidth: '1px' }"
  />

  <div class="grp-outer" :style="outerStyle">
    <!-- Group label at top -->
    <div class="grp-label-bar" :style="barStyle" @dblclick.stop="startEdit">
      <svg width="10" height="10" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
        <rect x="2" y="3" width="10" height="7" rx="1"/><rect x="12" y="3" width="10" height="7" rx="1"/>
        <rect x="2" y="14" width="10" height="7" rx="1"/><rect x="12" y="14" width="10" height="7" rx="1"/>
      </svg>
      <input
        v-if="editing"
        ref="inputEl"
        v-model="labelDraft"
        class="grp-input"
        @blur="commitEdit"
        @keydown.enter.stop.prevent="commitEdit"
        @keydown.escape.stop="cancelEdit"
        @click.stop
      />
      <span v-else class="grp-title">{{ props.data?.label || 'Grupo' }}</span>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, nextTick } from 'vue'
import { NodeResizer } from '@vue-flow/node-resizer'

const props = defineProps({
  id: { type: String, required: true },
  data: { type: Object, default: () => ({}) },
  selected: { type: Boolean, default: false },
})
const emit = defineEmits(['update-data'])

const editing = ref(false)
const labelDraft = ref('')
const inputEl = ref(null)

function startEdit() {
  labelDraft.value = props.data?.label || 'Grupo'
  editing.value = true
  nextTick(() => inputEl.value?.focus())
}
function commitEdit() {
  if (editing.value) emit('update-data', { id: props.id, patch: { label: labelDraft.value.trim() || 'Grupo' } })
  editing.value = false
}
function cancelEdit() { editing.value = false }

const accentColor = computed(() => props.data?.groupColor || '#34d399')

const outerStyle = computed(() => ({
  width: '100%',
  height: '100%',
  borderRadius: '12px',
  border: `1.5px dashed ${accentColor.value}`,
  background: `${accentColor.value}10`,
  boxSizing: 'border-box',
  position: 'relative',
  pointerEvents: 'none',
}))

const barStyle = computed(() => ({
  position: 'absolute',
  top: '-1px',
  left: '0',
  display: 'flex',
  alignItems: 'center',
  gap: '5px',
  padding: '3px 10px',
  background: accentColor.value,
  color: '#fff',
  fontSize: '11px',
  fontWeight: '700',
  borderRadius: '10px 10px 10px 0',
  pointerEvents: 'auto',
  cursor: 'pointer',
  userSelect: 'none',
  boxShadow: '0 2px 8px rgba(0,0,0,0.2)',
  maxWidth: 'calc(100% - 20px)',
}))
</script>

<style scoped>
.grp-outer { overflow: visible; }

.grp-title {
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  max-width: 200px;
}

.grp-input {
  background: transparent;
  border: none;
  outline: none;
  color: white;
  font-size: 11px;
  font-weight: 700;
  font-family: inherit;
  width: 120px;
  min-width: 60px;
  padding: 0;
}
.grp-input::placeholder { color: rgba(255,255,255,0.6); }
</style>
