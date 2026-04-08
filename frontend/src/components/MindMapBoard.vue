<template>
  <div class="board-wrap">
    <div class="board-toolbar">
      <button class="btn btn-ghost" @click="addNode">+ Caixa</button>
      <button class="btn btn-ghost" @click="addCentralNode">+ No Central</button>
      <button class="btn btn-ghost" @click="resetBoard">Limpar</button>
    </div>

    <VueFlow
      v-model:nodes="nodes"
      v-model:edges="edges"
      class="board-canvas"
      :fit-view-on-init="true"
      :delete-key-code="['Delete', 'Backspace']"
      @connect="onConnect"
      @node-double-click="onNodeDoubleClick"
    />
  </div>
</template>

<script setup>
import { ref, watch } from 'vue'
import { VueFlow, addEdge, MarkerType } from '@vue-flow/core'
import '@vue-flow/core/dist/style.css'
import '@vue-flow/core/dist/theme-default.css'

const props = defineProps({
  modelValue: {
    type: Object,
    default: () => ({ nodes: [], edges: [] })
  }
})

const emit = defineEmits(['update:modelValue'])

const nodes = ref([])
const edges = ref([])

function syncFromProps(value) {
  nodes.value = Array.isArray(value?.nodes) ? value.nodes : []
  edges.value = Array.isArray(value?.edges) ? value.edges : []
}

watch(
  () => props.modelValue,
  (value) => {
    syncFromProps(value)
  },
  { immediate: true, deep: true }
)

watch(
  [nodes, edges],
  () => {
    emit('update:modelValue', {
      nodes: nodes.value,
      edges: edges.value
    })
  },
  { deep: true }
)

function onConnect(connection) {
  edges.value = addEdge(
    {
      ...connection,
      markerEnd: MarkerType.ArrowClosed,
      style: { stroke: '#9f67ff', strokeWidth: 1.7 }
    },
    edges.value
  )
}

function addNode() {
  const id = `node-${Date.now()}`
  nodes.value = [
    ...nodes.value,
    {
      id,
      position: {
        x: 80 + (nodes.value.length % 4) * 180,
        y: 80 + Math.floor(nodes.value.length / 4) * 120
      },
      data: { label: `Etapa ${nodes.value.length + 1}` },
      style: {
        background: '#11111a',
        color: '#e2e4f0',
        border: '1px solid rgba(159, 103, 255, 0.35)',
        borderRadius: '12px',
        padding: '10px 12px',
        minWidth: '130px',
        textAlign: 'center'
      }
    }
  ]
}

function addCentralNode() {
  const id = `node-${Date.now()}`
  nodes.value = [
    ...nodes.value,
    {
      id,
      position: { x: 320, y: 180 },
      data: { label: 'Ideia central' },
      style: {
        background: 'rgba(124, 58, 237, 0.16)',
        color: '#ddd6fe',
        border: '1px solid rgba(159, 103, 255, 0.55)',
        borderRadius: '999px',
        padding: '12px 16px',
        minWidth: '150px',
        textAlign: 'center',
        fontWeight: 600
      }
    }
  ]
}

function onNodeDoubleClick({ node }) {
  const label = window.prompt('Texto do no:', node?.data?.label || '')
  if (!label || !node) return

  nodes.value = nodes.value.map((n) =>
    n.id === node.id ? { ...n, data: { ...n.data, label } } : n
  )
}

function resetBoard() {
  if (!window.confirm('Limpar o quadro atual?')) return
  nodes.value = []
  edges.value = []
}
</script>

<style scoped>
.board-wrap {
  border: 1px solid var(--border-soft);
  border-radius: var(--radius-lg);
  overflow: hidden;
  background: var(--surface);
}

.board-toolbar {
  display: flex;
  gap: 8px;
  padding: 10px;
  border-bottom: 1px solid var(--border-soft);
  background: rgba(124, 58, 237, 0.06);
}

.board-canvas {
  width: 100%;
  height: 62vh;
  background:
    radial-gradient(circle at 1px 1px, rgba(159, 103, 255, 0.18) 1px, transparent 0);
  background-size: 24px 24px;
}
</style>
