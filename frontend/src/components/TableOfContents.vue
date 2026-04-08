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
  padding: 20px 16px;
  overflow-y: auto;
  flex-shrink: 0;
  background: var(--panel);
}

.toc-title {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 11px;
  font-weight: 600;
  color: var(--text-3);
  text-transform: uppercase;
  letter-spacing: 0.06em;
  margin-bottom: 12px;
}

.toc-list { list-style: none; display: flex; flex-direction: column; gap: 2px; }

.toc-item {
  font-size: 12.5px;
  color: var(--text-2);
  cursor: pointer;
  padding: 5px 8px;
  border-radius: var(--radius-sm);
  transition: all var(--transition);
  line-height: 1.4;
  border-left: 2px solid transparent;
}
.toc-item:hover {
  color: var(--text);
  background: var(--panel-hover);
}
.toc-item.active {
  color: var(--purple-2);
  border-left-color: var(--purple-1);
  background: var(--purple-dim);
}

.toc-item.level-1 { padding-left: 8px; font-weight: 500; }
.toc-item.level-2 { padding-left: 18px; }
.toc-item.level-3 { padding-left: 28px; font-size: 12px; color: var(--text-3); }
</style>
