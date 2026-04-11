<template>
  <nav class="toc" v-if="headings.length > 0">
    <p class="toc-title">
      <svg width="13" height="13" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
        <line x1="3" y1="6" x2="21" y2="6"/><line x1="3" y1="12" x2="15" y2="12"/><line x1="3" y1="18" x2="18" y2="18"/>
      </svg>
      Sumário
    </p>
    <ul class="toc-list">
      <li
        v-for="item in headings"
        :key="item.id"
        :class="['toc-item', `level-${item.level}`, { active: activeId === item.id }]"
        @click="scrollTo(item)"
      >
        {{ item.text }}
      </li>
    </ul>
  </nav>
</template>

<script setup>
import { ref, watch } from 'vue'

const props = defineProps({
  editor: Object
})

const headings = ref([])
const activeId = ref(null)

function extractHeadings() {
  if (!props.editor) return
  const items = []
  props.editor.state.doc.descendants((node, pos) => {
    if (node.type.name === 'heading') {
      const text = node.textContent
      const id = text.toLowerCase().replace(/\s+/g, '-').replace(/[^a-z0-9-]/g, '')
      items.push({ id, text, level: node.attrs.level, pos })
    }
  })
  headings.value = items
}

function scrollTo(item) {
  if (!props.editor || !item) return

  const targetPos = Math.max(item.pos + 1, 1)
  props.editor.chain().focus().setTextSelection(targetPos).scrollIntoView().run()
  activeId.value = item.id
}

watch(() => props.editor?.state, () => {
  extractHeadings()
}, { deep: true, immediate: true })
</script>

<style scoped>
.toc {
  width: var(--toc-w);
  border-left: 1px solid var(--border-soft);
  padding: 20px 12px 20px 14px;
  overflow-y: auto;
  flex-shrink: 0;
  background: var(--panel);
}

.toc-title {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 10.5px;
  font-weight: 700;
  color: var(--text-3);
  text-transform: uppercase;
  letter-spacing: 0.08em;
  margin-bottom: 14px;
  padding-left: 6px;
}

.toc-list {
  list-style: none;
  display: flex;
  flex-direction: column;
  gap: 1px;
}

/* ── Base item ── */
.toc-item {
  cursor: pointer;
  border-radius: 6px;
  transition: all 0.15s ease;
  line-height: 1.35;
  border-left: 2px solid transparent;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.toc-item:hover { background: var(--panel-hover); }

/* ── H1 — máximo destaque ── */
.toc-item.level-1 {
  font-size: 12.5px;
  font-weight: 650;
  color: var(--text);
  padding: 6px 8px 6px 10px;
  letter-spacing: 0.01em;
  margin-top: 4px;
}
.toc-item.level-1:first-child { margin-top: 0; }

.toc-item.level-1.active {
  color: var(--purple-3);
  border-left-color: var(--purple-2);
  background: var(--purple-dim);
  font-weight: 700;
}

/* ── H2 — destaque médio ── */
.toc-item.level-2 {
  font-size: 12px;
  font-weight: 500;
  color: var(--text-2);
  padding: 5px 8px 5px 20px;
}

.toc-item.level-2.active {
  color: var(--purple-2);
  border-left-color: rgba(124, 58, 237, 0.55);
  background: rgba(124, 58, 237, 0.07);
}

/* ── H3 — destaque leve ── */
.toc-item.level-3 {
  font-size: 11.5px;
  font-weight: 400;
  color: var(--text-3);
  padding: 4px 8px 4px 32px;
}

.toc-item.level-3.active {
  color: var(--text-2);
  border-left-color: rgba(124, 58, 237, 0.3);
  background: rgba(124, 58, 237, 0.04);
}

/* ── H4+ — mínimo ── */
.toc-item.level-4,
.toc-item.level-5,
.toc-item.level-6 {
  font-size: 11px;
  font-weight: 400;
  color: var(--text-3);
  opacity: 0.7;
  padding: 3px 8px 3px 42px;
}

.toc-item.level-4.active,
.toc-item.level-5.active,
.toc-item.level-6.active {
  color: var(--text-3);
  border-left-color: rgba(124, 58, 237, 0.2);
  opacity: 1;
}
</style>
