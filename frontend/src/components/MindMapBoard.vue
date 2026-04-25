<template>
  <div class="mb-wrap" @keydown="onKeydown" tabindex="0">

    <!-- ══ Toolbar ══ -->
    <div class="mb-toolbar">
      <!-- Add nodes -->
      <div class="mb-toolbar-group">
        <button class="mb-btn mb-btn--primary" @click="addBox" title="Nova caixa (N)">
          <svg width="12" height="12" fill="none" stroke="currentColor" stroke-width="2.5" viewBox="0 0 24 24">
            <rect x="3" y="3" width="18" height="18" rx="3"/><line x1="12" y1="8" x2="12" y2="16"/><line x1="8" y1="12" x2="16" y2="12"/>
          </svg>
          Caixa
        </button>
        <button class="mb-btn" @click="addCentral" title="Nó central">
          <svg width="12" height="12" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
            <circle cx="12" cy="12" r="10"/><circle cx="12" cy="12" r="4" fill="currentColor"/>
          </svg>
          Central
        </button>
        <button class="mb-btn mb-btn--postit" @click="addPostit" title="Post-it">
          <svg width="12" height="12" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
            <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h8l6-6V4a2 2 0 0 0-2-2z"/>
            <polyline points="14,2 14,8 20,8"/>
          </svg>
          Post-it
        </button>
        <button class="mb-btn mb-btn--group" @click="groupSelected" title="Agrupar seleção (Ctrl+G)">
          <svg width="12" height="12" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
            <rect x="2" y="3" width="10" height="7" rx="1"/><rect x="12" y="3" width="10" height="7" rx="1"/>
            <rect x="2" y="14" width="10" height="7" rx="1"/><rect x="12" y="14" width="10" height="7" rx="1"/>
          </svg>
          Grupo
        </button>
      </div>

      <div class="mb-toolbar-sep"/>

      <!-- Layout tools -->
      <div class="mb-toolbar-group">
        <button class="mb-btn" @click="autoLayout('grid')" title="Organizar em grade">
          <svg width="12" height="12" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
            <rect x="3" y="3" width="7" height="7"/><rect x="14" y="3" width="7" height="7"/>
            <rect x="14" y="14" width="7" height="7"/><rect x="3" y="14" width="7" height="7"/>
          </svg>
          Grade
        </button>
        <button class="mb-btn" @click="autoLayout('tree')" title="Organizar em árvore">
          <svg width="12" height="12" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
            <line x1="12" y1="2" x2="12" y2="8"/><circle cx="12" cy="4" r="2"/>
            <line x1="6" y1="16" x2="12" y2="8"/><circle cx="6" cy="18" r="2"/>
            <line x1="18" y1="16" x2="12" y2="8"/><circle cx="18" cy="18" r="2"/>
          </svg>
          Árvore
        </button>
        <button class="mb-btn" @click="duplicateSelected" title="Duplicar seleção (Ctrl+D)">
          <svg width="12" height="12" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
            <rect x="9" y="9" width="13" height="13" rx="2"/><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"/>
          </svg>
          Duplicar
        </button>
      </div>

      <div class="mb-toolbar-sep"/>

      <!-- Danger & export -->
      <div class="mb-toolbar-group">
        <button class="mb-btn mb-btn--danger" @click="deleteSelected" :disabled="!hasSelection" title="Excluir (Del)">
          <svg width="12" height="12" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
            <polyline points="3,6 5,6 21,6"/><path d="M19,6l-1,14H6L5,6"/><path d="M9,6V4h6v2"/>
          </svg>
          Excluir
        </button>
        <button class="mb-btn" @click="resetBoard" title="Limpar quadro">
          <svg width="12" height="12" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
            <polyline points="3 6 5 6 21 6"/><path d="M19 6l-1 14H6L5 6"/>
          </svg>
          Limpar
        </button>
        <button class="mb-btn mb-btn--export" @click="exportPng" title="Exportar PNG">
          <svg width="12" height="12" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
            <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/>
            <polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/>
          </svg>
          PNG
        </button>
      </div>

      <!-- Spacer -->
      <div style="flex:1"/>

      <!-- Shortcut hint -->
      <div class="mb-hint">
        <span>Duplo clique = editar</span>
        <span class="mb-hint-sep">·</span>
        <span>Ctrl+G = agrupar</span>
        <span class="mb-hint-sep">·</span>
        <span>Ctrl+D = duplicar</span>
      </div>
    </div>

    <!-- ══ Canvas + Inspector ══ -->
    <div class="mb-body">
      <VueFlow
        v-model:nodes="nodes"
        v-model:edges="edges"
        class="mb-canvas"
        :fit-view-on-init="true"
        :delete-key-code="['Delete', 'Backspace']"
        :node-types="nodeTypes"
        :default-edge-options="defaultEdgeOptions"
        :connect-on-click="false"
        @connect="onConnect"
        @node-click="onNodeClick"
        @pane-click="onPaneClick"
        @node-drag-stop="onNodeMoved"
        @nodes-change="onNodesChange"
        @edges-change="onEdgesChange"
        @update-data="onNodeDataChange"
      >
        <Background :variant="BackgroundVariant.Dots" :gap="24" :size="1.2" :color="'rgba(159,103,255,0.18)'" />
        <MiniMap
          :node-color="minimapColor"
          :mask-color="'rgba(10,10,20,0.7)'"
          style="background: rgba(10,10,20,0.85); border: 1px solid rgba(255,255,255,0.07); border-radius: 8px;"
        />
        <Controls />
      </VueFlow>

      <!-- ══ Inspector Panel (right sidebar) ══ -->
      <Transition name="insp">
        <aside v-if="selectedNode" class="mb-inspector" @click.stop>
          <div class="insp-header">
            <span class="insp-title">Propriedades</span>
            <button class="insp-close" @click="selectedNodeId = null">✕</button>
          </div>

          <!-- Node label quick edit -->
          <div class="insp-section">
            <label class="insp-label">Texto</label>
            <textarea
              class="insp-textarea"
              v-model="inspLabel"
              rows="2"
              placeholder="Texto do nó..."
              @input="applyLabel"
            />
          </div>

          <!-- Text style (only for box nodes) -->
          <template v-if="selectedNode.type === 'box' || selectedNode.type === 'default'">
            <div class="insp-section">
              <label class="insp-label">Estilo do texto</label>
              <div class="insp-row">
                <button class="insp-fmt-btn" :class="{ active: inspBold }" @click="toggleBold" title="Negrito"><b>B</b></button>
                <button class="insp-fmt-btn" :class="{ active: inspItalic }" @click="toggleItalic" title="Itálico"><i>I</i></button>
                <button class="insp-fmt-btn fm-u" :class="{ active: inspUnderline }" @click="toggleUnderline" title="Sublinhado"><u>U</u></button>
                <span class="insp-divider"/>
                <label class="insp-label" style="margin:0">Tam.</label>
                <input class="insp-number" type="number" v-model.number="inspFontSize" min="8" max="64" step="1" @input="applyFontSize" />
              </div>
              <div class="insp-row" style="margin-top:6px">
                <label class="insp-label" style="margin:0;flex-shrink:0">Cor texto</label>
                <input type="color" class="insp-color" v-model="inspTextColor" @input="applyTextColor" />
                <label class="insp-label" style="margin:0;flex-shrink:0">Alinhamento</label>
                <div class="insp-align-btns">
                  <button class="insp-fmt-btn" :class="{ active: inspTextAlign === 'left' }" @click="setAlign('left')">⟵</button>
                  <button class="insp-fmt-btn" :class="{ active: inspTextAlign === 'center' }" @click="setAlign('center')">⟺</button>
                  <button class="insp-fmt-btn" :class="{ active: inspTextAlign === 'right' }" @click="setAlign('right')">⟶</button>
                </div>
              </div>
            </div>

            <div class="insp-section">
              <label class="insp-label">Formato da caixa</label>
              <div class="insp-shapes-grid">
                <button
                  v-for="s in shapes"
                  :key="s.value"
                  class="insp-shape-btn"
                  :class="{ active: inspShape === s.value }"
                  @click="applyShape(s.value)"
                  :title="s.label"
                >
                  <svg :viewBox="s.vb" width="36" height="28" fill="none" stroke="currentColor" stroke-width="1.5">
                    <component :is="'path'" :d="s.path" :rx="s.rx" :ry="s.ry" />
                  </svg>
                  <span>{{ s.label }}</span>
                </button>
              </div>
            </div>

            <div class="insp-section">
              <label class="insp-label">Aparência da caixa</label>
              <div class="insp-row">
                <label class="insp-label" style="margin:0;flex-shrink:0">Fundo</label>
                <input type="color" class="insp-color" v-model="inspBgColor" @input="applyBgColor" />
                <label class="insp-label" style="margin:0;flex-shrink:0">Borda</label>
                <input type="color" class="insp-color" v-model="inspBorderColor" @input="applyBorderColor" />
              </div>
              <div class="insp-row" style="margin-top:6px">
                <label class="insp-label" style="margin:0;flex-shrink:0">Estilo borda</label>
                <select class="insp-select" v-model="inspBorderStyle" @change="applyBorderStyle">
                  <option value="solid">Sólida</option>
                  <option value="dashed">Tracejada</option>
                  <option value="dotted">Pontilhada</option>
                  <option value="double">Dupla</option>
                </select>
                <label class="insp-label" style="margin:0;flex-shrink:0">Espessura</label>
                <input class="insp-number" type="number" v-model.number="inspBorderWidth" min="1" max="8" step="1" @input="applyBorderWidth" />
              </div>
            </div>
          </template>

          <!-- Post-it color picker -->
          <template v-if="selectedNode.type === 'postit'">
            <div class="insp-section">
              <label class="insp-label">Cor do post-it</label>
              <div class="insp-postit-colors">
                <button
                  v-for="c in postitColors"
                  :key="c.id"
                  class="insp-postit-swatch"
                  :style="{ background: c.bg, borderColor: c.border }"
                  :class="{ active: inspPostitColor === c.id }"
                  @click="applyPostitColor(c.id)"
                  :title="c.label"
                />
              </div>
            </div>
          </template>

          <!-- Group color -->
          <template v-if="selectedNode.type === 'group'">
            <div class="insp-section">
              <label class="insp-label">Cor do grupo</label>
              <div class="insp-postit-colors">
                <button
                  v-for="c in groupColors"
                  :key="c.value"
                  class="insp-postit-swatch"
                  :style="{ background: c.value + '22', borderColor: c.value }"
                  :class="{ active: inspGroupColor === c.value }"
                  @click="applyGroupColor(c.value)"
                />
              </div>
            </div>
          </template>

          <!-- Edge options (only box) -->
          <template v-if="selectedNode.type === 'box' || selectedNode.type === 'default'">
            <div class="insp-section">
              <label class="insp-label">Conectar post-it</label>
              <button class="insp-action-btn" @click="connectPostitToSelected">
                <svg width="11" height="11" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                  <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h8l6-6V4a2 2 0 0 0-2-2z"/>
                </svg>
                Adicionar post-it vinculado
              </button>
            </div>
          </template>
        </aside>
      </Transition>
    </div>
  </div>
</template>

<script setup>
import { ref, watch, computed, markRaw, nextTick } from 'vue'
import {
  VueFlow, addEdge, MarkerType,
} from '@vue-flow/core'
import { Background, BackgroundVariant } from '@vue-flow/background'
import { MiniMap } from '@vue-flow/minimap'
import { Controls } from '@vue-flow/controls'
import '@vue-flow/core/dist/style.css'
import '@vue-flow/core/dist/theme-default.css'
import '@vue-flow/controls/dist/style.css'
import '@vue-flow/minimap/dist/style.css'

import FlowNodeBox    from '@/components/flow/FlowNodeBox.vue'
import FlowNodePostit from '@/components/flow/FlowNodePostit.vue'
import FlowNodeGroup  from '@/components/flow/FlowNodeGroup.vue'

// ── Props / emits ──────────────────────────────────────
const props = defineProps({
  modelValue: { type: Object, default: () => ({ nodes: [], edges: [] }) }
})
const emit = defineEmits(['update:modelValue'])

// ── Node types (must be markRaw) ───────────────────────
const nodeTypes = {
  box:    markRaw(FlowNodeBox),
  postit: markRaw(FlowNodePostit),
  group:  markRaw(FlowNodeGroup),
}

// ── State ──────────────────────────────────────────────
const nodes = ref([])
const edges = ref([])
const flowRef = ref(null)
const selectedNodeId = ref(null)

// ── Sync props → state (only when it actually changes from parent) ─────
let syncLock = false
function syncFromProps(value) {
  if (syncLock) return
  nodes.value = Array.isArray(value?.nodes) ? value.nodes : []
  edges.value = Array.isArray(value?.edges) ? value.edges : []
}
watch(() => props.modelValue, syncFromProps, { immediate: true, deep: false })

// ── Sync state → parent ────────────────────────────────
watch([nodes, edges], () => {
  syncLock = true
  emit('update:modelValue', { nodes: nodes.value, edges: edges.value })
  nextTick(() => { syncLock = false })
}, { deep: true })

// ── Handle data update from child nodes ────────────────
function onNodeDataChange({ id, patch }) {
  nodes.value = nodes.value.map(n =>
    n.id === id ? { ...n, data: { ...n.data, ...patch } } : n
  )
}

// ── Default edge options ────────────────────────────────
const defaultEdgeOptions = {
  type: 'smoothstep',
  markerEnd: { type: MarkerType.ArrowClosed, color: '#9f67ff' },
  style: { stroke: '#9f67ff', strokeWidth: 1.8 },
}

// ── Connect handler ─────────────────────────────────────
function onConnect(connection) {
  const sourceNode = nodes.value.find(n => n.id === connection.source)
  const targetNode = nodes.value.find(n => n.id === connection.target)
  const isPostitEdge = sourceNode?.type === 'postit' || targetNode?.type === 'postit'

  edges.value = addEdge({
    ...connection,
    type: 'smoothstep',
    markerEnd: { type: MarkerType.ArrowClosed, color: isPostitEdge ? '#fbbf24' : '#9f67ff' },
    style: {
      stroke: isPostitEdge ? '#fbbf24' : '#9f67ff',
      strokeWidth: 1.8,
      strokeDasharray: isPostitEdge ? '6 4' : undefined,
    },
    animated: isPostitEdge,
  }, edges.value)
}

// ── Selection ───────────────────────────────────────────
const selectedNode = computed(() =>
  selectedNodeId.value ? nodes.value.find(n => n.id === selectedNodeId.value) : null
)
const hasSelection = computed(() => nodes.value.some(n => n.selected))

function onNodeClick({ node }) {
  selectedNodeId.value = node.id
  syncInspectorFromNode(node)
}
function onPaneClick() {
  selectedNodeId.value = null
}

// ── Inspector state ────────────────────────────────────
const inspLabel       = ref('')
const inspBold        = ref(false)
const inspItalic      = ref(false)
const inspUnderline   = ref(false)
const inspFontSize    = ref(13)
const inspTextColor   = ref('#e2e4f0')
const inspTextAlign   = ref('center')
const inspShape       = ref('rect')
const inspBgColor     = ref('#11111a')
const inspBorderColor = ref('#9f67ff')
const inspBorderStyle = ref('solid')
const inspBorderWidth = ref(1)
const inspPostitColor = ref('yellow')
const inspGroupColor  = ref('#34d399')

function syncInspectorFromNode(node) {
  const d = node.data || {}
  inspLabel.value       = d.label || ''
  inspBold.value        = !!d.bold
  inspItalic.value      = !!d.italic
  inspUnderline.value   = !!d.underline
  inspFontSize.value    = d.fontSize || 13
  inspTextColor.value   = d.color || '#e2e4f0'
  inspTextAlign.value   = d.textAlign || 'center'
  inspShape.value       = d.shape || 'rect'
  inspBgColor.value     = d.bgColor || '#11111a'
  inspBorderColor.value = d.borderColor || '#9f67ff'
  inspBorderStyle.value = d.borderStyle || 'solid'
  inspBorderWidth.value = d.borderWidth || 1
  inspPostitColor.value = d.postitColor || 'yellow'
  inspGroupColor.value  = d.groupColor || '#34d399'
}

// ── Inspector helpers ──────────────────────────────────
function patchNodeData(patch) {
  if (!selectedNodeId.value) return
  nodes.value = nodes.value.map(n =>
    n.id === selectedNodeId.value
      ? { ...n, data: { ...n.data, ...patch } }
      : n
  )
}
function applyLabel()       { patchNodeData({ label: inspLabel.value }) }
function toggleBold()       { inspBold.value = !inspBold.value; patchNodeData({ bold: inspBold.value }) }
function toggleItalic()     { inspItalic.value = !inspItalic.value; patchNodeData({ italic: inspItalic.value }) }
function toggleUnderline()  { inspUnderline.value = !inspUnderline.value; patchNodeData({ underline: inspUnderline.value }) }
function applyFontSize()    { patchNodeData({ fontSize: inspFontSize.value }) }
function applyTextColor()   { patchNodeData({ color: inspTextColor.value }) }
function setAlign(a)        { inspTextAlign.value = a; patchNodeData({ textAlign: a }) }
function applyShape(s)      { inspShape.value = s; patchNodeData({ shape: s }) }
function applyBgColor()     { patchNodeData({ bgColor: inspBgColor.value }) }
function applyBorderColor() { patchNodeData({ borderColor: inspBorderColor.value }) }
function applyBorderStyle() { patchNodeData({ borderStyle: inspBorderStyle.value }) }
function applyBorderWidth() { patchNodeData({ borderWidth: inspBorderWidth.value }) }
function applyPostitColor(id) { inspPostitColor.value = id; patchNodeData({ postitColor: id }) }
function applyGroupColor(v)   { inspGroupColor.value = v; patchNodeData({ groupColor: v }) }

// ── Post-it connected to selected node ─────────────────
function connectPostitToSelected() {
  if (!selectedNodeId.value) return
  const sourceNode = nodes.value.find(n => n.id === selectedNodeId.value)
  if (!sourceNode) return

  const id = `postit-${Date.now()}`
  const pos = { x: (sourceNode.position?.x || 0) + 200, y: (sourceNode.position?.y || 0) - 60 }

  nodes.value = [...nodes.value, {
    id,
    type: 'postit',
    position: pos,
    style: { width: '150px', height: '100px' },
    data: { label: 'Observação...', postitColor: 'yellow' }
  }]

  edges.value = addEdge({
    id: `e-${selectedNodeId.value}-${id}`,
    source: id,
    target: selectedNodeId.value,
    type: 'smoothstep',
    style: { stroke: '#fbbf24', strokeWidth: 1.6, strokeDasharray: '6 4' },
    markerEnd: { type: MarkerType.ArrowClosed, color: '#fbbf24' },
    animated: true,
  }, edges.value)
}

// ── Add nodes ──────────────────────────────────────────
function addBox() {
  const id = `box-${Date.now()}`
  const offset = nodes.value.filter(n => n.type === 'box').length
  nodes.value = [...nodes.value, {
    id,
    type: 'box',
    position: { x: 80 + (offset % 4) * 200, y: 80 + Math.floor(offset / 4) * 130 },
    style: { width: '140px', height: '52px' },
    data: { label: `Etapa ${offset + 1}`, shape: 'rect', bgColor: '#11111a', borderColor: '#9f67ff', fontSize: 13 }
  }]
}

function addCentral() {
  const id = `box-${Date.now()}`
  nodes.value = [...nodes.value, {
    id,
    type: 'box',
    position: { x: 280, y: 160 },
    style: { width: '160px', height: '60px' },
    data: { label: 'Ideia Central', shape: 'ellipse', bgColor: 'rgba(124,58,237,0.16)', borderColor: '#9f67ff', color: '#ddd6fe', bold: true, fontSize: 15, borderWidth: 2 }
  }]
}

function addPostit() {
  const id = `postit-${Date.now()}`
  const offset = nodes.value.filter(n => n.type === 'postit').length
  nodes.value = [...nodes.value, {
    id,
    type: 'postit',
    position: { x: 80 + offset * 170, y: 300 },
    style: { width: '150px', height: '110px' },
    data: { label: 'Post-it...', postitColor: 'yellow' }
  }]
}

// ── Group selected nodes ───────────────────────────────
function groupSelected() {
  const selected = nodes.value.filter(n => n.selected && n.type !== 'group')
  if (selected.length < 1) {
    alert('Selecione pelo menos 1 nó para agrupar.')
    return
  }

  const xs = selected.map(n => n.position.x)
  const ys = selected.map(n => n.position.y)
  const x  = Math.min(...xs) - 30
  const y  = Math.min(...ys) - 40
  const maxX = Math.max(...xs) + 180
  const maxY = Math.max(...ys) + 100
  const w  = maxX - x
  const h  = maxY - y

  const groupId = `group-${Date.now()}`
  const groupNode = {
    id: groupId,
    type: 'group',
    position: { x, y },
    style: { width: `${w}px`, height: `${h}px` },
    data: { label: 'Grupo', groupColor: '#34d399' },
    zIndex: -1,
  }

  // Move nodes to be relative to group
  nodes.value = [
    groupNode,
    ...nodes.value.map(n =>
      selected.find(s => s.id === n.id)
        ? { ...n, parentNode: groupId, extent: 'parent', position: { x: n.position.x - x, y: n.position.y - y } }
        : n
    )
  ]

  selectedNodeId.value = groupId
}

// ── Duplicate selected ────────────────────────────────
function duplicateSelected() {
  const sel = nodes.value.filter(n => n.selected)
  if (!sel.length) return
  const newNodes = sel.map(n => ({
    ...n,
    id: `${n.id}-copy-${Date.now()}`,
    position: { x: n.position.x + 30, y: n.position.y + 30 },
    selected: false,
  }))
  nodes.value = [...nodes.value, ...newNodes]
}

// ── Delete selected ────────────────────────────────────
function deleteSelected() {
  const selIds = new Set(nodes.value.filter(n => n.selected).map(n => n.id))
  if (!selIds.size) return
  nodes.value = nodes.value.filter(n => !selIds.has(n.id))
  edges.value = edges.value.filter(e => !selIds.has(e.source) && !selIds.has(e.target))
}

// ── Auto-layout ────────────────────────────────────────
function autoLayout(mode) {
  const nonGroup = nodes.value.filter(n => n.type !== 'group' && !n.parentNode)
  if (!nonGroup.length) return

  const cols = Math.ceil(Math.sqrt(nonGroup.length))
  nodes.value = nodes.value.map(n => {
    if (n.type === 'group' || n.parentNode) return n
    const idx = nonGroup.findIndex(m => m.id === n.id)
    let pos
    if (mode === 'grid') {
      const col = idx % cols
      const row = Math.floor(idx / cols)
      pos = { x: 80 + col * 220, y: 80 + row * 140 }
    } else {
      // Simple binary-tree-like layout
      const level  = Math.floor(Math.log2(idx + 1))
      const posInLevel = idx + 1 - Math.pow(2, level)
      const totalInLevel = Math.pow(2, level)
      pos = {
        x: ((posInLevel + 0.5) / totalInLevel) * (totalInLevel * 200 + 100),
        y: 80 + level * 140,
      }
    }
    return { ...n, position: pos }
  })
}

// ── Export PNG ─────────────────────────────────────────
async function exportPng() {
  try {
    const { toPng } = await import('html-to-image').catch(() => null) || {}
    if (!toPng) { alert('Instale html-to-image para exportar.'); return }
    const el = document.querySelector('.mb-canvas')
    if (!el) return
    const dataUrl = await toPng(el)
    const a = document.createElement('a')
    a.href = dataUrl
    a.download = 'quadro.png'
    a.click()
  } catch (e) {
    console.error('Export PNG error:', e)
    alert('Erro ao exportar. Verifique o console.')
  }
}

// ── Reset ────────────────────────────────────────────
function resetBoard() {
  if (!confirm('Limpar o quadro atual?')) return
  nodes.value = []
  edges.value = []
  selectedNodeId.value = null
}

// ── Keyboard shortcuts ────────────────────────────────
function onKeydown(e) {
  if (e.ctrlKey && e.key === 'g') { e.preventDefault(); groupSelected() }
  if (e.ctrlKey && e.key === 'd') { e.preventDefault(); duplicateSelected() }
  if (e.key === 'n' && !e.ctrlKey && document.activeElement === e.currentTarget) addBox()
}

// ── Changes callbacks ─────────────────────────────────
function onNodesChange() { /* handled by v-model */ }
function onEdgesChange() { /* handled by v-model */ }
function onNodeMoved()   { /* position already reactive */ }

// ── Minimap color ──────────────────────────────────────
function minimapColor(node) {
  if (node.type === 'postit') return '#fbbf24'
  if (node.type === 'group')  return '#34d399'
  return node.data?.bgColor || '#9f67ff'
}

// ── Shape definitions ──────────────────────────────────
const shapes = [
  { value: 'rect',     label: 'Retângulo', vb: '0 0 48 32', path: 'M4 4 H44 V28 H4 Z',                rx: '4' },
  { value: 'pill',     label: 'Pílula',    vb: '0 0 48 32', path: 'M16 4 H32 Q44 4 44 16 Q44 28 32 28 H16 Q4 28 4 16 Q4 4 16 4 Z' },
  { value: 'ellipse',  label: 'Elipse',    vb: '0 0 48 32', path: 'M24 4 Q44 4 44 16 Q44 28 24 28 Q4 28 4 16 Q4 4 24 4 Z' },
  { value: 'diamond',  label: 'Losango',   vb: '0 0 48 32', path: 'M24 3 L45 16 L24 29 L3 16 Z' },
  { value: 'hex',      label: 'Hexágono',  vb: '0 0 48 32', path: 'M14 4 H34 L44 16 L34 28 H14 L4 16 Z' },
  { value: 'para',     label: 'Paralelgr.', vb: '0 0 48 32', path: 'M10 4 H44 L38 28 H4 Z' },
  { value: 'cylinder', label: 'Cilindro',  vb: '0 0 48 32', path: 'M4 8 Q4 4 24 4 Q44 4 44 8 L44 24 Q44 28 24 28 Q4 28 4 24 Z M4 8 Q4 12 24 12 Q44 12 44 8' },
]

// ── Postit colors ──────────────────────────────────────
const postitColors = [
  { id: 'yellow', label: 'Amarelo', bg: '#fef9c3', border: '#fde047' },
  { id: 'amber',  label: 'Âmbar',  bg: '#fef3c7', border: '#fbbf24' },
  { id: 'lime',   label: 'Verde',  bg: '#ecfccb', border: '#bef264' },
  { id: 'cyan',   label: 'Ciano',  bg: '#cffafe', border: '#67e8f9' },
  { id: 'pink',   label: 'Rosa',   bg: '#fce7f3', border: '#f9a8d4' },
  { id: 'purple', label: 'Roxo',   bg: '#f3e8ff', border: '#d8b4fe' },
]

// ── Group colors ───────────────────────────────────────
const groupColors = [
  { value: '#34d399' }, { value: '#60a5fa' }, { value: '#f87171' },
  { value: '#fbbf24' }, { value: '#a78bfa' }, { value: '#f472b6' },
]
</script>

<style scoped>
.mb-wrap {
  display: flex;
  flex-direction: column;
  height: 100%;
  background: var(--surface, #0d0d1a);
  border: 1px solid var(--border-soft);
  border-radius: var(--radius-lg, 12px);
  overflow: hidden;
  outline: none;
}

/* ── Toolbar ── */
.mb-toolbar {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 8px 12px;
  border-bottom: 1px solid var(--border-soft);
  background: rgba(124,58,237,0.05);
  flex-shrink: 0;
  flex-wrap: wrap;
}

.mb-toolbar-group { display: flex; gap: 4px; align-items: center; }
.mb-toolbar-sep { width: 1px; height: 20px; background: var(--border-soft); margin: 0 4px; flex-shrink: 0; }

.mb-btn {
  display: inline-flex;
  align-items: center;
  gap: 5px;
  padding: 5px 10px;
  border-radius: 7px;
  border: 1px solid var(--border-soft);
  background: var(--surface);
  color: var(--text-2);
  font-size: 11.5px;
  font-weight: 500;
  font-family: inherit;
  cursor: pointer;
  transition: all 0.14s ease;
  white-space: nowrap;
}
.mb-btn:hover { background: var(--bg); border-color: var(--border); color: var(--text); }
.mb-btn:disabled { opacity: 0.35; cursor: not-allowed; }

.mb-btn--primary {
  background: rgba(99,102,241,0.14);
  border-color: rgba(99,102,241,0.35);
  color: #a78bfa;
}
.mb-btn--primary:hover { background: rgba(99,102,241,0.24); }

.mb-btn--postit {
  background: rgba(251,191,36,0.1);
  border-color: rgba(251,191,36,0.3);
  color: #fbbf24;
}
.mb-btn--postit:hover { background: rgba(251,191,36,0.18); }

.mb-btn--group {
  background: rgba(52,211,153,0.1);
  border-color: rgba(52,211,153,0.3);
  color: #34d399;
}
.mb-btn--group:hover { background: rgba(52,211,153,0.18); }

.mb-btn--danger { color: #f87171; }
.mb-btn--danger:hover { background: rgba(248,113,113,0.1); border-color: rgba(248,113,113,0.35); }

.mb-btn--export { color: #60a5fa; }
.mb-btn--export:hover { background: rgba(96,165,250,0.1); border-color: rgba(96,165,250,0.3); }

.mb-hint {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 10.5px;
  color: var(--text-3);
}
.mb-hint-sep { opacity: 0.4; }

/* ── Body ── */
.mb-body {
  display: flex;
  flex: 1;
  overflow: hidden;
  position: relative;
}

/* ── Canvas ── */
.mb-canvas {
  flex: 1;
  height: 100%;
  background: radial-gradient(circle at 1px 1px, rgba(159,103,255,0.15) 1px, transparent 0);
  background-size: 24px 24px;
}

/* ── Inspector ── */
.mb-inspector {
  width: 240px;
  flex-shrink: 0;
  background: var(--panel, #12121f);
  border-left: 1px solid var(--border-soft);
  display: flex;
  flex-direction: column;
  overflow-y: auto;
  scrollbar-width: thin;
  scrollbar-color: rgba(255,255,255,0.07) transparent;
}

.insp-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 12px 14px 10px;
  border-bottom: 1px solid var(--border-soft);
  flex-shrink: 0;
  background: linear-gradient(180deg, rgba(99,102,241,0.07) 0%, transparent 100%);
}
.insp-title { font-size: 12px; font-weight: 700; color: var(--text-2); text-transform: uppercase; letter-spacing: 0.06em; }
.insp-close { border: none; background: none; color: var(--text-3); cursor: pointer; font-size: 13px; padding: 2px 5px; border-radius: 5px; }
.insp-close:hover { background: rgba(248,113,113,0.1); color: #f87171; }

.insp-section {
  padding: 10px 14px;
  border-bottom: 1px solid rgba(255,255,255,0.04);
}

.insp-label {
  display: block;
  font-size: 10.5px;
  font-weight: 600;
  color: var(--text-3);
  text-transform: uppercase;
  letter-spacing: 0.07em;
  margin-bottom: 6px;
}

.insp-textarea {
  width: 100%;
  background: var(--bg);
  border: 1px solid var(--border);
  border-radius: 7px;
  padding: 7px 9px;
  font-size: 12.5px;
  color: var(--text);
  font-family: inherit;
  resize: vertical;
  min-height: 48px;
  box-sizing: border-box;
  outline: none;
}
.insp-textarea:focus { border-color: #6366f1; box-shadow: 0 0 0 2px rgba(99,102,241,0.15); }

.insp-row {
  display: flex;
  align-items: center;
  gap: 6px;
  flex-wrap: wrap;
}

.insp-fmt-btn {
  width: 26px; height: 26px;
  border-radius: 6px;
  border: 1px solid var(--border-soft);
  background: var(--bg);
  color: var(--text-2);
  font-size: 12px;
  display: flex; align-items: center; justify-content: center;
  cursor: pointer;
  transition: all 0.12s;
  font-family: inherit;
}
.insp-fmt-btn:hover { background: var(--surface); border-color: var(--border); }
.insp-fmt-btn.active { background: rgba(99,102,241,0.2); border-color: #6366f1; color: #a78bfa; }

.insp-divider { width: 1px; height: 18px; background: var(--border-soft); }

.insp-number {
  width: 52px;
  background: var(--bg);
  border: 1px solid var(--border);
  border-radius: 6px;
  padding: 4px 6px;
  font-size: 12px;
  color: var(--text);
  outline: none;
  font-family: inherit;
}
.insp-number:focus { border-color: #6366f1; }

.insp-color {
  width: 30px; height: 26px;
  border-radius: 6px;
  border: 1px solid var(--border);
  padding: 1px;
  cursor: pointer;
  background: transparent;
}

.insp-select {
  flex: 1;
  background: var(--bg);
  border: 1px solid var(--border);
  border-radius: 6px;
  padding: 4px 6px;
  font-size: 11.5px;
  color: var(--text);
  outline: none;
  font-family: inherit;
  cursor: pointer;
}
.insp-select:focus { border-color: #6366f1; }

.insp-align-btns { display: flex; gap: 2px; }

/* Shapes grid */
.insp-shapes-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 4px;
}
.insp-shape-btn {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 3px;
  padding: 5px 2px;
  border-radius: 7px;
  border: 1px solid var(--border-soft);
  background: var(--bg);
  color: var(--text-3);
  cursor: pointer;
  font-size: 9px;
  transition: all 0.12s;
}
.insp-shape-btn:hover { background: var(--surface); border-color: var(--border); color: var(--text-2); }
.insp-shape-btn.active { background: rgba(99,102,241,0.15); border-color: #6366f1; color: #a78bfa; }
.insp-shape-btn svg { opacity: 0.7; }
.insp-shape-btn.active svg { opacity: 1; }

/* Post-it swatches */
.insp-postit-colors {
  display: flex;
  gap: 6px;
  flex-wrap: wrap;
}
.insp-postit-swatch {
  width: 24px;
  height: 24px;
  border-radius: 6px;
  border: 2px solid;
  cursor: pointer;
  transition: transform 0.12s, box-shadow 0.12s;
}
.insp-postit-swatch:hover { transform: scale(1.15); }
.insp-postit-swatch.active { box-shadow: 0 0 0 2px #fff, 0 0 0 4px #6366f1; transform: scale(1.1); }

/* Action button */
.insp-action-btn {
  display: flex;
  align-items: center;
  gap: 6px;
  width: 100%;
  padding: 7px 10px;
  border-radius: 8px;
  border: 1px solid rgba(251,191,36,0.3);
  background: rgba(251,191,36,0.07);
  color: #fbbf24;
  font-size: 11.5px;
  font-weight: 500;
  font-family: inherit;
  cursor: pointer;
  transition: all 0.14s;
}
.insp-action-btn:hover { background: rgba(251,191,36,0.14); }

/* ── Inspector slide transition ── */
.insp-enter-active, .insp-leave-active { transition: all 0.22s ease; }
.insp-enter-from, .insp-leave-to { opacity: 0; transform: translateX(20px); width: 0; }

/* ── Vue Flow global overrides ── */
:deep(.vue-flow__node) { cursor: pointer; }
:deep(.vue-flow__node.selected .box-inner) { box-shadow: 0 0 0 2px #6366f1; }
:deep(.vue-flow__edge-path) { transition: stroke 0.2s; }
:deep(.vue-flow__controls) {
  background: rgba(12,12,22,0.9);
  border: 1px solid rgba(255,255,255,0.07);
  border-radius: 10px;
  overflow: hidden;
}
:deep(.vue-flow__controls button) {
  background: transparent;
  border: none;
  color: var(--text-3, #94a3b8);
  padding: 6px;
}
:deep(.vue-flow__controls button:hover) { background: rgba(255,255,255,0.06); color: white; }
</style>
