<template>
  <div class="note-editor-view" v-if="note">
    <!-- Toolbar -->
    <EditorToolbar
      :editor="editor"
      :saving="notesStore.saving"
      :last-saved="lastSaved"
      @insert-image="handleImageUpload"
    />

    <!-- Main editor area -->
    <div class="editor-body">
      <!-- Content -->
      <div class="editor-content-area">
        <!-- Title input -->
        <div class="title-area">
          <input
            id="note-title"
            v-model="noteTitle"
            class="title-input"
            placeholder="Título da nota..."
            @input="debounceSave"
          />
          <div class="note-meta">
            <span class="meta-item">
              <svg width="12" height="12" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><rect x="3" y="4" width="18" height="18" rx="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
              {{ formatDate(note.updated_at) }}
            </span>
            <span class="meta-item" v-if="wordCount > 0">
              {{ wordCount }} palavras
            </span>
          </div>

          <!-- Tags panel -->
          <div class="note-tags-panel">
            <TagBadge
              v-for="tag in note.tags"
              :key="tag.id"
              :tag="tag"
              :removable="true"
              @remove="removeTagFromNote(tag)"
            />
            <div class="tag-add-wrap" v-if="availableTags.length">
              <button class="tag-add-btn" @click="showTagPicker = !showTagPicker" id="btn-add-tag">
                <svg width="11" height="11" fill="none" stroke="currentColor" stroke-width="2.5" viewBox="0 0 24 24">
                  <line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/>
                </svg>
                Tag
              </button>
              <div class="tag-picker" v-if="showTagPicker">
                <div
                  v-for="tag in availableTags"
                  :key="tag.id"
                  class="picker-item"
                  @click="addTagToNote(tag)"
                >
                  <TagBadge :tag="tag" />
                </div>
                <p v-if="!availableTags.length" class="picker-empty">Todas as tags já adicionadas</p>
              </div>
            </div>
          </div>
        </div>

        <!-- Tiptap editor -->
        <editor-content :editor="editor" class="tiptap-content" />
      </div>

      <!-- Table of Contents -->
      <TableOfContents :editor="editor" />
    </div>
  </div>

  <!-- Loading state -->
  <div v-else-if="notesStore.loading" class="editor-loading">
    <div class="spinner" style="width:32px;height:32px;border-width:3px"></div>
    <p>Carregando nota...</p>
  </div>

  <!-- Empty state -->
  <div v-else class="editor-empty">
    <div class="empty-icon">
      <svg width="48" height="48" fill="none" stroke="currentColor" stroke-width="1.5" viewBox="0 0 24 24">
        <path d="M14.5 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V7.5L14.5 2z"/>
        <polyline points="14,2 14,8 20,8"/>
        <line x1="16" y1="13" x2="8" y2="13"/>
        <line x1="16" y1="17" x2="8" y2="17"/>
      </svg>
    </div>
    <h2>Selecione uma nota</h2>
    <p>Escolha uma nota na sidebar ou crie uma nova</p>
  </div>
</template>

<script setup>
import { ref, watch, onMounted, onBeforeUnmount, computed, onUnmounted } from 'vue'
import { useRoute } from 'vue-router'
import { useEditor, EditorContent } from '@tiptap/vue-3'
import StarterKit from '@tiptap/starter-kit'
import Image from '@tiptap/extension-image'
import Placeholder from '@tiptap/extension-placeholder'
import Underline from '@tiptap/extension-underline'
import Highlight from '@tiptap/extension-highlight'
import TextAlign from '@tiptap/extension-text-align'
import TaskList from '@tiptap/extension-task-list'
import TaskItem from '@tiptap/extension-task-item'
import CharacterCount from '@tiptap/extension-character-count'

import EditorToolbar from '@/components/EditorToolbar.vue'
import TableOfContents from '@/components/TableOfContents.vue'
import TagBadge from '@/components/TagBadge.vue'
import { useNotesStore } from '@/stores/notes'
import { useTagsStore } from '@/stores/tags'

const route = useRoute()
const notesStore = useNotesStore()
const tagsStore = useTagsStore()

const note = ref(null)
const noteTitle = ref('')
const lastSaved = ref(false)
const showTagPicker = ref(false)
let saveTimeout = null

const availableTags = computed(() => {
  if (!note.value) return []
  const noteTIds = new Set((note.value.tags || []).map(t => t.id))
  return tagsStore.tags.filter(t => !noteTIds.has(t.id))
})

function sanitizeEditorContent(html) {
  if (!html) return ''

  // Remove image tags that use unsupported/local-only URL schemes.
  return html.replace(/<img\b[^>]*\bsrc=["'](attachment:|blob:)[^"']*["'][^>]*>/gi, '')
}

async function addTagToNote(tag) {
  if (!note.value) return
  const currentIds = (note.value.tags || []).map(t => t.id)
  const newIds = [...currentIds, tag.id]
  const updated = await notesStore.save(note.value.id, {
    title: noteTitle.value,
    content: editor.value?.getHTML() || '',
    tag_ids: newIds
  })
  note.value = updated
  showTagPicker.value = false
}

async function removeTagFromNote(tag) {
  if (!note.value) return
  const newIds = (note.value.tags || []).filter(t => t.id !== tag.id).map(t => t.id)
  const updated = await notesStore.save(note.value.id, {
    title: noteTitle.value,
    content: editor.value?.getHTML() || '',
    tag_ids: newIds
  })
  note.value = updated
}

// Close picker when clicking outside
function handleClickOutside(e) {
  if (!e.target.closest('.tag-add-wrap')) showTagPicker.value = false
}

const editor = useEditor({
  extensions: [
    StarterKit,
    Image.configure({ HTMLAttributes: { class: 'editor-img' } }),
    Placeholder.configure({ placeholder: 'Escreva algo incrível...' }),
    Underline,
    Highlight.configure({ multicolor: false }),
    TextAlign.configure({ types: ['heading', 'paragraph'] }),
    TaskList,
    TaskItem.configure({ nested: true }),
    CharacterCount
  ],
  content: '',
  editorProps: {
    attributes: {
      class: 'tiptap-editor',
      spellcheck: 'true'
    }
  },
  onUpdate() {
    debounceSave()
  }
})

const wordCount = computed(() => {
  if (!editor.value) return 0
  return editor.value.storage.characterCount.words()
})

async function loadNote(id) {
  note.value = null
  showTagPicker.value = false
  const data = await notesStore.fetchOne(id)
  note.value = data
  noteTitle.value = data.title || ''
  if (editor.value) {
    editor.value.commands.setContent(sanitizeEditorContent(data.content || ''))
  }
  lastSaved.value = false
  if (!tagsStore.tags.length) tagsStore.fetch()
}

function debounceSave() {
  clearTimeout(saveTimeout)
  lastSaved.value = false
  saveTimeout = setTimeout(async () => {
    if (!note.value) return
    const safeContent = sanitizeEditorContent(editor.value?.getHTML() || '')
    await notesStore.save(note.value.id, {
      title: noteTitle.value,
      content: safeContent
    })
    lastSaved.value = true
    setTimeout(() => { lastSaved.value = false }, 3000)
  }, 1200)
}

async function handleImageUpload(file) {
  if (!note.value) return
  try {
    const url = await notesStore.uploadImage(note.value.id, file)
    editor.value?.chain().focus().setImage({ src: url }).run()
  } catch (e) {
    console.error('Erro ao fazer upload da imagem', e)
  }
}

function formatDate(dateStr) {
  if (!dateStr) return ''
  return new Date(dateStr).toLocaleDateString('pt-BR', {
    day: '2-digit', month: 'long', year: 'numeric',
    hour: '2-digit', minute: '2-digit'
  })
}

watch(() => route.params.id, (id) => {
  if (id) loadNote(id)
}, { immediate: true })

onMounted(() => document.addEventListener('click', handleClickOutside))
onBeforeUnmount(() => {
  clearTimeout(saveTimeout)
  editor.value?.destroy()
  document.removeEventListener('click', handleClickOutside)
})
</script>

<style scoped>
.note-editor-view {
  display: flex;
  flex-direction: column;
  height: 100%;
  overflow: hidden;
  background: var(--bg);
}

.editor-body {
  display: flex;
  flex: 1;
  overflow: hidden;
}

.editor-content-area {
  flex: 1;
  overflow-y: auto;
  padding: 40px 60px;
  max-width: 860px;
  margin: 0 auto;
  width: 100%;
}

.title-area {
  margin-bottom: 24px;
  padding-bottom: 16px;
  border-bottom: 1px solid var(--border-soft);
}

/* Tags panel */
.note-tags-panel {
  display: flex;
  align-items: center;
  flex-wrap: wrap;
  gap: 6px;
  margin-top: 10px;
}
.tag-add-wrap { position: relative; }
.tag-add-btn {
  display: inline-flex;
  align-items: center;
  gap: 5px;
  padding: 3px 10px;
  border-radius: 99px;
  font-size: 11.5px;
  font-weight: 500;
  background: var(--surface);
  border: 1px dashed var(--border);
  color: var(--text-3);
  cursor: pointer;
  transition: all var(--transition);
}
.tag-add-btn:hover { border-color: var(--purple-1); color: var(--purple-3); }
.tag-picker {
  position: absolute;
  top: calc(100% + 6px);
  left: 0;
  background: var(--panel);
  border: 1px solid var(--border);
  border-radius: var(--radius);
  padding: 6px;
  z-index: 50;
  min-width: 160px;
  box-shadow: 0 8px 24px rgba(0,0,0,0.25);
  display: flex;
  flex-direction: column;
  gap: 2px;
}
.picker-item {
  padding: 5px 8px;
  border-radius: var(--radius-sm);
  cursor: pointer;
  transition: background var(--transition);
}
.picker-item:hover { background: var(--surface); }
.picker-empty { font-size: 12px; color: var(--text-3); text-align: center; padding: 8px; margin: 0; }

.title-input {
  width: 100%;
  background: transparent;
  border: none;
  outline: none;
  font-family: 'Inter', sans-serif;
  font-size: 32px;
  font-weight: 700;
  color: var(--text);
  line-height: 1.2;
  margin-bottom: 8px;
}
.title-input::placeholder { color: var(--text-3); }

.note-meta {
  display: flex;
  align-items: center;
  gap: 16px;
}
.meta-item {
  display: flex;
  align-items: center;
  gap: 5px;
  font-size: 12px;
  color: var(--text-3);
}

/* Tiptap content area */
.tiptap-content :deep(.tiptap-editor) {
  outline: none;
  min-height: 60vh;
  font-size: 15px;
  line-height: 1.75;
  color: var(--text);
}

/* Headings */
.tiptap-content :deep(h1) {
  font-size: 28px;
  font-weight: 700;
  color: var(--text);
  margin: 28px 0 12px;
  padding-bottom: 8px;
  border-bottom: 1px solid var(--border-soft);
}
.tiptap-content :deep(h2) {
  font-size: 22px;
  font-weight: 600;
  color: var(--text);
  margin: 24px 0 10px;
}
.tiptap-content :deep(h3) {
  font-size: 18px;
  font-weight: 600;
  color: var(--purple-3);
  margin: 20px 0 8px;
}

/* Lists */
.tiptap-content :deep(ul), .tiptap-content :deep(ol) {
  padding-left: 20px;
  margin: 10px 0;
  display: flex;
  flex-direction: column;
  gap: 4px;
}

/* Task list */
.tiptap-content :deep(ul[data-type="taskList"]) {
  list-style: none;
  padding: 0;
}
.tiptap-content :deep(li[data-type="taskItem"]) {
  display: flex;
  align-items: flex-start;
  gap: 8px;
  padding: 3px 0;
}
.tiptap-content :deep(li[data-type="taskItem"] > label) {
  margin-top: 2px;
}
.tiptap-content :deep(li[data-type="taskItem"] > label input[type="checkbox"]) {
  accent-color: var(--purple-1);
  width: 16px; height: 16px;
  cursor: pointer;
}

/* Code inline */
.tiptap-content :deep(code) {
  background: var(--panel);
  border: 1px solid var(--border);
  border-radius: 4px;
  padding: 1px 6px;
  font-family: 'JetBrains Mono', monospace;
  font-size: 13px;
  color: var(--purple-3);
}

/* Code block */
.tiptap-content :deep(pre) {
  background: var(--panel);
  border: 1px solid var(--border);
  border-radius: var(--radius);
  padding: 16px 20px;
  overflow-x: auto;
  margin: 16px 0;
}
.tiptap-content :deep(pre code) {
  background: transparent;
  border: none;
  padding: 0;
  color: var(--purple-3);
  font-size: 13.5px;
}

/* Blockquote */
.tiptap-content :deep(blockquote) {
  border-left: 3px solid var(--purple-1);
  padding: 10px 16px;
  margin: 16px 0;
  background: var(--purple-dim);
  border-radius: 0 var(--radius-sm) var(--radius-sm) 0;
  color: var(--text-2);
  font-style: italic;
}

/* Highlight */
.tiptap-content :deep(mark) {
  background: rgba(124, 58, 237, 0.25);
  color: var(--purple-3);
  border-radius: 3px;
  padding: 0 3px;
}

/* Image */
.tiptap-content :deep(.editor-img) {
  max-width: 100%;
  border-radius: var(--radius);
  margin: 16px 0;
  box-shadow: var(--shadow);
  cursor: pointer;
  border: 2px solid transparent;
  transition: border-color var(--transition);
}
.tiptap-content :deep(.editor-img:hover) {
  border-color: var(--purple-1);
}
.tiptap-content :deep(.editor-img.ProseMirror-selectednode) {
  border-color: var(--purple-1);
  box-shadow: 0 0 0 3px var(--purple-dim);
}

/* Horizontal rule */
.tiptap-content :deep(hr) {
  border: none;
  border-top: 1px solid var(--border);
  margin: 24px 0;
}

/* Placeholder */
.tiptap-content :deep(.is-editor-empty:first-child::before) {
  content: attr(data-placeholder);
  color: var(--text-3);
  pointer-events: none;
  float: left;
  height: 0;
}

/* Empty / Loading states */
.editor-loading, .editor-empty {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  height: 100%;
  gap: 16px;
  color: var(--text-3);
}

.empty-icon {
  color: var(--border);
  animation: pulse 2s ease-in-out infinite;
}
@keyframes pulse { 0%,100%{opacity:0.4} 50%{opacity:0.8} }

.editor-empty h2 {
  font-size: 20px;
  color: var(--text-2);
  font-weight: 600;
}
.editor-empty p { font-size: 14px; }
</style>
