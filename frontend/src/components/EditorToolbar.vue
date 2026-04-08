<template>
  <div class="editor-toolbar" v-if="editor">
    <!-- Text style -->
    <div class="toolbar-group">
      <select id="toolbar-heading" class="heading-select" @change="applyHeading($event.target.value)">
        <option value="0" :selected="editor.isActive('paragraph')">Parágrafo</option>
        <option value="1" :selected="editor.isActive('heading', { level: 1 })">Título 1</option>
        <option value="2" :selected="editor.isActive('heading', { level: 2 })">Título 2</option>
        <option value="3" :selected="editor.isActive('heading', { level: 3 })">Título 3</option>
      </select>
    </div>

    <div class="toolbar-divider"></div>

    <!-- Marks -->
    <div class="toolbar-group">
      <button
        id="toolbar-bold"
        class="tool-btn"
        :class="{ active: editor.isActive('bold') }"
        @click="editor.chain().focus().toggleBold().run()"
        title="Negrito (Ctrl+B)"
      >
        <svg width="14" height="14" fill="currentColor" viewBox="0 0 24 24"><path d="M6 4h8a4 4 0 0 1 4 4 4 4 0 0 1-4 4H6z"/><path d="M6 12h9a4 4 0 0 1 4 4 4 4 0 0 1-4 4H6z"/></svg>
      </button>
      <button
        id="toolbar-italic"
        class="tool-btn"
        :class="{ active: editor.isActive('italic') }"
        @click="editor.chain().focus().toggleItalic().run()"
        title="Itálico (Ctrl+I)"
      >
        <svg width="14" height="14" fill="none" stroke="currentColor" stroke-width="2.5" viewBox="0 0 24 24"><line x1="19" y1="4" x2="10" y2="4"/><line x1="14" y1="20" x2="5" y2="20"/><line x1="15" y1="4" x2="9" y2="20"/></svg>
      </button>
      <button
        id="toolbar-underline"
        class="tool-btn"
        :class="{ active: editor.isActive('underline') }"
        @click="editor.chain().focus().toggleUnderline().run()"
        title="Sublinhado (Ctrl+U)"
      >
        <svg width="14" height="14" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path d="M6 3v7a6 6 0 0 0 6 6 6 6 0 0 0 6-6V3"/><line x1="4" y1="21" x2="20" y2="21"/></svg>
      </button>
      <button
        id="toolbar-highlight"
        class="tool-btn"
        :class="{ active: editor.isActive('highlight') }"
        @click="editor.chain().focus().toggleHighlight({ color: '#7c3aed33' }).run()"
        title="Destaque"
      >
        <svg width="14" height="14" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path d="M12 20h9"/><path d="M16.5 3.5a2.121 2.121 0 0 1 3 3L7 19l-4 1 1-4L16.5 3.5z"/></svg>
      </button>
      <button
        v-for="color in highlightColors"
        :key="color"
        class="highlight-swatch"
        :style="{ backgroundColor: color }"
        @click="applyHighlight(color)"
        :title="`Aplicar destaque ${color}`"
      ></button>
      <button
        class="tool-btn"
        @click="editor.chain().focus().unsetHighlight().run()"
        title="Remover destaque"
      >
        <svg width="14" height="14" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
      </button>
    </div>

    <div class="toolbar-divider"></div>

    <!-- Lists -->
    <div class="toolbar-group">
      <button
        id="toolbar-bullet"
        class="tool-btn"
        :class="{ active: editor.isActive('bulletList') }"
        @click="editor.chain().focus().toggleBulletList().run()"
        title="Lista"
      >
        <svg width="14" height="14" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><line x1="9" y1="6" x2="20" y2="6"/><line x1="9" y1="12" x2="20" y2="12"/><line x1="9" y1="18" x2="20" y2="18"/><circle cx="4" cy="6" r="1" fill="currentColor"/><circle cx="4" cy="12" r="1" fill="currentColor"/><circle cx="4" cy="18" r="1" fill="currentColor"/></svg>
      </button>
      <button
        id="toolbar-ordered"
        class="tool-btn"
        :class="{ active: editor.isActive('orderedList') }"
        @click="editor.chain().focus().toggleOrderedList().run()"
        title="Lista numerada"
      >
        <svg width="14" height="14" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><line x1="10" y1="6" x2="21" y2="6"/><line x1="10" y1="12" x2="21" y2="12"/><line x1="10" y1="18" x2="21" y2="18"/><path d="M4 6h1v4"/><path d="M4 10h2"/><path d="M6 18H4c0-1 2-2 2-3s-1-1.5-2-1"/></svg>
      </button>
      <button
        id="toolbar-task"
        class="tool-btn"
        :class="{ active: editor.isActive('taskList') }"
        @click="editor.chain().focus().toggleTaskList().run()"
        title="Lista de tarefas"
      >
        <svg width="14" height="14" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><polyline points="9 11 12 14 22 4"/><path d="M21 12v7a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11"/></svg>
      </button>
    </div>

    <div class="toolbar-divider"></div>

    <!-- Alignment -->
    <div class="toolbar-group">
      <button class="tool-btn" :class="{ active: editor.isActive({ textAlign: 'left' }) }"
        @click="editor.chain().focus().setTextAlign('left').run()" title="Alinhar à esquerda">
        <svg width="14" height="14" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><line x1="17" y1="10" x2="3" y2="10"/><line x1="21" y1="6" x2="3" y2="6"/><line x1="21" y1="14" x2="3" y2="14"/><line x1="17" y1="18" x2="3" y2="18"/></svg>
      </button>
      <button class="tool-btn" :class="{ active: editor.isActive({ textAlign: 'center' }) }"
        @click="editor.chain().focus().setTextAlign('center').run()" title="Centralizar">
        <svg width="14" height="14" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><line x1="18" y1="10" x2="6" y2="10"/><line x1="21" y1="6" x2="3" y2="6"/><line x1="21" y1="14" x2="3" y2="14"/><line x1="18" y1="18" x2="6" y2="18"/></svg>
      </button>
    </div>

    <div class="toolbar-divider"></div>

    <!-- Code / Quote -->
    <div class="toolbar-group">
      <button
        id="toolbar-code"
        class="tool-btn"
        :class="{ active: editor.isActive('code') }"
        @click="editor.chain().focus().toggleCode().run()"
        title="Código inline"
      >
        <svg width="14" height="14" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><polyline points="16 18 22 12 16 6"/><polyline points="8 6 2 12 8 18"/></svg>
      </button>
      <button
        id="toolbar-codeblock"
        class="tool-btn"
        :class="{ active: editor.isActive('codeBlock') }"
        @click="editor.chain().focus().toggleCodeBlock().run()"
        title="Bloco de código"
      >
        <svg width="14" height="14" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><rect x="2" y="3" width="20" height="14" rx="2"/><line x1="8" y1="21" x2="16" y2="21"/><line x1="12" y1="17" x2="12" y2="21"/></svg>
      </button>
      <button
        id="toolbar-blockquote"
        class="tool-btn"
        :class="{ active: editor.isActive('blockquote') }"
        @click="editor.chain().focus().toggleBlockquote().run()"
        title="Citação"
      >
        <svg width="14" height="14" fill="currentColor" viewBox="0 0 24 24"><path d="M3 21c3 0 7-1 7-8V5c0-1.25-.756-2.017-2-2H4c-1.25 0-2 .75-2 1.972V11c0 1.25.75 2 2 2 1 0 1 0 1 1v1c0 1-1 2-2 2s-1 .008-1 1.031V20c0 1 0 1 1 1zm12 0c3 0 7-1 7-8V5c0-1.25-.757-2.017-2-2h-4c-1.25 0-2 .75-2 1.972V11c0 1.25.75 2 2 2h.75c0 2.25.25 4-2.75 4v3c0 1 0 1 1 1z"/></svg>
      </button>
    </div>

    <div class="toolbar-divider"></div>

    <!-- Image -->
    <div class="toolbar-group">
      <label id="toolbar-image" class="tool-btn" title="Inserir imagem" style="cursor:pointer;">
        <svg width="14" height="14" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><rect x="3" y="3" width="18" height="18" rx="2"/><circle cx="8.5" cy="8.5" r="1.5"/><polyline points="21 15 16 10 5 21"/></svg>
        <input type="file" accept="image/*" style="display:none" @change="insertImage" />
      </label>
    </div>

    <!-- Save indicator -->
    <div class="toolbar-right">
      <button
        id="toolbar-export-pdf"
        class="tool-btn export-btn"
        @click="$emit('export-pdf')"
        title="Exportar para PDF"
      >
        <svg width="14" height="14" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><path d="M8 13h3"/><path d="M8 17h8"/></svg>
        <span class="export-label">PDF</span>
      </button>

      <span v-if="saving" class="save-indicator saving">
        <div class="spinner" style="width:12px;height:12px;border-width:1.5px"></div>
        Salvando...
      </span>
      <span v-else-if="lastSaved" class="save-indicator saved">
        <svg width="12" height="12" fill="none" stroke="currentColor" stroke-width="2.5" viewBox="0 0 24 24"><polyline points="20 6 9 17 4 12"/></svg>
        Salvo
      </span>
    </div>
  </div>
</template>

<script setup>
const props = defineProps({
  editor: Object,
  saving: Boolean,
  lastSaved: Boolean
})

const emit = defineEmits(['insert-image', 'export-pdf'])
const highlightColors = ['#7c3aed33', '#22c55e33', '#f59e0b33', '#3b82f633']

function applyHeading(level) {
  if (level === '0') {
    props.editor.chain().focus().setParagraph().run()
  } else {
    props.editor.chain().focus().toggleHeading({ level: parseInt(level) }).run()
  }
}

function insertImage(event) {
  const file = event.target.files[0]
  if (file) emit('insert-image', file)
  event.target.value = ''
}

function applyHighlight(color) {
  props.editor.chain().focus().setHighlight({ color }).run()
}
</script>

<style scoped>
.editor-toolbar {
  display: flex;
  align-items: center;
  gap: 2px;
  padding: 8px 16px;
  background: var(--surface);
  border-bottom: 1px solid var(--border-soft);
  flex-wrap: wrap;
  min-height: 48px;
  position: sticky;
  top: 0;
  z-index: 10;
}

.toolbar-group { display: flex; align-items: center; gap: 1px; }

.toolbar-divider {
  width: 1px;
  height: 20px;
  background: var(--border);
  margin: 0 4px;
}

.tool-btn {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 30px; height: 30px;
  border: none;
  background: transparent;
  color: var(--text-2);
  border-radius: var(--radius-sm);
  cursor: pointer;
  transition: all var(--transition);
  font-size: 13px;
}
.tool-btn:hover {
  background: var(--panel-hover);
  color: var(--text);
}
.tool-btn.active {
  background: var(--purple-dim);
  color: var(--purple-2);
}

.highlight-swatch {
  width: 14px;
  height: 14px;
  border-radius: 50%;
  border: 1px solid rgba(226, 228, 240, 0.35);
  cursor: pointer;
  margin: 0 1px;
  transition: transform var(--transition), border-color var(--transition);
}

.highlight-swatch:hover {
  transform: scale(1.1);
  border-color: rgba(226, 228, 240, 0.8);
}

.heading-select {
  background: var(--surface);
  border: 1px solid var(--border);
  border-radius: var(--radius-sm);
  color: var(--text-2);
  font-size: 12.5px;
  font-family: 'Inter', sans-serif;
  padding: 5px 8px;
  cursor: pointer;
  outline: none;
  transition: border-color var(--transition);
}
.heading-select:hover, .heading-select:focus {
  border-color: var(--purple-1);
  color: var(--text);
}

.toolbar-right {
  margin-left: auto;
  display: flex;
  align-items: center;
  gap: 8px;
}

.export-btn {
  width: auto;
  padding: 0 10px;
  gap: 6px;
  color: var(--purple-3);
  border: 1px solid rgba(124, 58, 237, 0.4);
  background: rgba(124, 58, 237, 0.12);
}

.export-btn:hover {
  background: rgba(124, 58, 237, 0.2);
  color: #ddd6fe;
}

.export-label {
  font-size: 11px;
  font-weight: 700;
  letter-spacing: 0.04em;
}

.save-indicator {
  display: flex;
  align-items: center;
  gap: 5px;
  font-size: 12px;
  color: var(--text-3);
}
.save-indicator.saved { color: var(--green); }
.save-indicator.saving { color: var(--purple-2); }
</style>
