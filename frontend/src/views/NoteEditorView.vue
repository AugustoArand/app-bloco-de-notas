<template>
  <div class="note-editor-view" v-if="note">
    <!-- Toolbar -->
    <EditorToolbar
      :editor="editor"
      :saving="notesStore.saving"
      :last-saved="lastSaved"
      @insert-image="handleImageUpload"
      @export-pdf="handleExportPdf"
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

          <div class="editor-modes">
            <button
              class="mode-btn"
              :class="{ active: editorMode === 'text' }"
              @click="editorMode = 'text'"
            >
              Texto
            </button>
            <button
              class="mode-btn"
              :class="{ active: editorMode === 'board' }"
              @click="editorMode = 'board'"
            >
              Quadro
            </button>
          </div>

          <div class="ai-actions" v-if="editorMode === 'text'">
            <input
              v-model="aiQuestion"
              class="ai-question-input"
              :disabled="aiLoading"
              placeholder="Pergunta para 'Gerar texto IA' (opcional para os outros botoes)"
            />
            <button
              class="ai-btn"
              :disabled="aiLoading || !aiQuestion.trim()"
              @click="generateTextWithAi"
            >
              {{ aiLoading && aiMode === 'generate' ? 'Gerando...' : 'Gerar texto IA' }}
            </button>
            <button
              class="ai-btn"
              :disabled="aiLoading"
              @click="summarizeWithAi('bullet')"
            >
              {{ aiLoading && aiMode === 'summary' ? 'Resumindo...' : 'Resumo IA' }}
            </button>
            <button
              class="ai-btn"
              :disabled="aiLoading"
              @click="translateTextWithAi"
            >
              {{ aiLoading && aiMode === 'translate-text' ? 'Traduzindo texto...' : 'Traduzir texto IA' }}
            </button>
            <button
              class="ai-btn"
              :disabled="aiLoading"
              @click="translateTermsWithAi"
            >
              {{ aiLoading && aiMode === 'translate-terms' ? 'Traduzindo termos...' : 'Traduzir termos IA' }}
            </button>
            <button
              v-if="aiResult"
              class="ai-btn secondary"
              :disabled="aiLoading"
              @click="insertAiResultInEditor"
            >
              Inserir no texto
            </button>
          </div>

          <p class="ai-help" v-if="editorMode === 'text'">
            Use "Traduzir texto IA" para traduzir o conteudo completo da nota e "Traduzir termos IA" para glossario tecnico.
          </p>

          <p v-if="aiError" class="ai-error">{{ aiError }}</p>
          <div v-if="aiResult" class="ai-result">
            <h4>{{ aiResultTitle }}</h4>
            <pre>{{ aiResult }}</pre>
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
        <editor-content v-if="editorMode === 'text'" :editor="editor" class="tiptap-content" />
        <MindMapBoard
          v-else
          v-model="diagramData"
          @update:model-value="handleDiagramUpdate"
        />
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
import { ref, watch, onMounted, onBeforeUnmount, computed } from 'vue'
import { useRoute } from 'vue-router'
import DOMPurify from 'dompurify'
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
import { jsPDF } from 'jspdf'

import EditorToolbar from '@/components/EditorToolbar.vue'
import TableOfContents from '@/components/TableOfContents.vue'
import TagBadge from '@/components/TagBadge.vue'
import MindMapBoard from '@/components/MindMapBoard.vue'
import { useNotesStore } from '@/stores/notes'
import { useTagsStore } from '@/stores/tags'
import api from '@/services/api'

const route = useRoute()
const notesStore = useNotesStore()
const tagsStore = useTagsStore()

const note = ref(null)
const noteTitle = ref('')
const lastSaved = ref(false)
const showTagPicker = ref(false)
const editorMode = ref('text')
const diagramData = ref({ nodes: [], edges: [] })
const aiLoading = ref(false)
const aiMode = ref('')
const aiResult = ref('')
const aiError = ref('')
const aiQuestion = ref('')
let saveTimeout = null
let diagramSaveTimeout = null

const availableTags = computed(() => {
  if (!note.value) return []
  const noteTIds = new Set((note.value.tags || []).map(t => t.id))
  return tagsStore.tags.filter(t => !noteTIds.has(t.id))
})

const aiResultTitle = computed(() => {
  if (aiMode.value === 'summary') return 'Resultado IA - Resumo'
  if (aiMode.value === 'translate-text') return 'Resultado IA - Traducao de texto'
  if (aiMode.value === 'translate-terms') return 'Resultado IA - Traducao de termos'
  if (aiMode.value === 'generate') return 'Resultado IA - Texto gerado'
  return 'Resultado IA'
})

function sanitizeEditorContent(html) {
  if (!html) return ''
  return DOMPurify.sanitize(html, {
    USE_PROFILES: { html: true },
    FORBID_ATTR: ['onerror', 'onload', 'onclick', 'onmouseover'],
  })
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
    Highlight.configure({ multicolor: true }),
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
  diagramData.value = data.diagram_data || { nodes: [], edges: [] }
  editorMode.value = 'text'
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
      content: safeContent,
      diagram_data: diagramData.value
    })
    lastSaved.value = true
    setTimeout(() => { lastSaved.value = false }, 3000)
  }, 1200)
}

function handleDiagramUpdate(value) {
  diagramData.value = value
  debounceDiagramSave()
}

function debounceDiagramSave() {
  clearTimeout(diagramSaveTimeout)
  diagramSaveTimeout = setTimeout(async () => {
    if (!note.value) return
    const safeContent = sanitizeEditorContent(editor.value?.getHTML() || '')
    await notesStore.save(note.value.id, {
      title: noteTitle.value,
      content: safeContent,
      diagram_data: diagramData.value
    })
    lastSaved.value = true
    setTimeout(() => { lastSaved.value = false }, 3000)
  }, 900)
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

function stripHtml(html) {
  const parser = new DOMParser()
  const doc = parser.parseFromString(html || '', 'text/html')
  return doc.body.textContent || ''
}

function handleExportPdf() {
  if (!note.value) return

  const pdf = new jsPDF({
    unit: 'pt',
    format: 'a4'
  })

  const marginX = 48
  const pageWidth = 595.28
  const maxTextWidth = pageWidth - marginX * 2

  const title = noteTitle.value?.trim() || 'Sem titulo'
  const bodyText = stripHtml(editor.value?.getHTML() || '')

  pdf.setFont('helvetica', 'bold')
  pdf.setFontSize(18)
  pdf.text(title, marginX, 60)

  pdf.setFont('helvetica', 'normal')
  pdf.setFontSize(11)
  pdf.setTextColor(90, 93, 112)
  pdf.text(`Exportado em ${new Date().toLocaleString('pt-BR')}`, marginX, 80)

  pdf.setTextColor(20, 20, 24)
  pdf.setFontSize(12)
  const lines = pdf.splitTextToSize(bodyText, maxTextWidth)

  let y = 110
  const lineHeight = 16
  const pageHeight = 841.89

  lines.forEach((line) => {
    if (y > pageHeight - 60) {
      pdf.addPage()
      y = 60
    }
    pdf.text(line, marginX, y)
    y += lineHeight
  })

  const filename = `${title.replace(/[^a-z0-9-_]+/gi, '_') || 'nota'}.pdf`
  pdf.save(filename)
}

function getNotePlainText() {
  return stripHtml(editor.value?.getHTML() || '')
}

function escapeHtml(value) {
  return value
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#39;')
}

async function summarizeWithAi(style = 'bullet') {
  if (!note.value || aiLoading.value) return

  const content = getNotePlainText().trim()
  if (!content) {
    aiError.value = 'Escreva algum conteudo antes de usar o resumo IA.'
    return
  }

  aiLoading.value = true
  aiMode.value = 'summary'
  aiError.value = ''
  aiResult.value = ''

  try {
    const { data } = await api.post('/api/v1/ai/summarize', {
      title: noteTitle.value,
      content,
      style
    })
    aiResult.value = data.result || ''
  } catch (error) {
    aiError.value = error.response?.data?.error || 'Falha ao gerar resumo com IA.'
  } finally {
    aiLoading.value = false
  }
}

async function translateTermsWithAi() {
  if (!note.value || aiLoading.value) return

  const content = getNotePlainText().trim()
  if (!content) {
    aiError.value = 'Escreva algum conteudo antes de traduzir termos.'
    return
  }

  aiLoading.value = true
  aiMode.value = 'translate-terms'
  aiError.value = ''
  aiResult.value = ''

  try {
    const { data } = await api.post('/api/v1/ai/translate_terms', {
      content,
      limit: 12
    })
    aiResult.value = data.result || ''
  } catch (error) {
    aiError.value = error.response?.data?.error || 'Falha ao traduzir termos com IA.'
  } finally {
    aiLoading.value = false
  }
}

async function translateTextWithAi() {
  if (!note.value || aiLoading.value) return

  const content = getNotePlainText().trim()
  if (!content) {
    aiError.value = 'Escreva algum conteudo antes de traduzir o texto.'
    return
  }

  aiLoading.value = true
  aiMode.value = 'translate-text'
  aiError.value = ''
  aiResult.value = ''

  try {
    const { data } = await api.post('/api/v1/ai/translate_text', {
      content,
      target_language: 'ingles'
    })
    aiResult.value = data.result || ''
  } catch (error) {
    aiError.value = error.response?.data?.error || 'Falha ao traduzir o texto com IA.'
  } finally {
    aiLoading.value = false
  }
}

async function generateTextWithAi() {
  if (!note.value || aiLoading.value) return

  const question = aiQuestion.value.trim()
  if (!question) {
    aiError.value = 'Digite uma pergunta para gerar texto com IA.'
    return
  }

  aiLoading.value = true
  aiMode.value = 'generate'
  aiError.value = ''
  aiResult.value = ''

  try {
    const { data } = await api.post('/api/v1/ai/generate_text', {
      question,
      context: getNotePlainText().trim()
    })
    aiResult.value = data.result || ''
  } catch (error) {
    aiError.value = error.response?.data?.error || 'Falha ao gerar texto com IA.'
  } finally {
    aiLoading.value = false
  }
}

function insertAiResultInEditor() {
  if (!editor.value || !aiResult.value) return

  const lines = aiResult.value
    .split('\n')
    .map(line => line.trim())
    .filter(Boolean)

  if (!lines.length) return

  const html = lines.map(line => `<p>${escapeHtml(line)}</p>`).join('')
  editor.value.chain().focus().insertContent(html).run()
  debounceSave()
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
  clearTimeout(diagramSaveTimeout)
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

.editor-modes {
  display: flex;
  gap: 8px;
  margin-top: 12px;
}

.ai-actions {
  display: flex;
  gap: 8px;
  flex-wrap: wrap;
  margin-top: 10px;
}

.ai-question-input {
  flex: 1;
  min-width: 260px;
  border: 1px solid var(--border);
  background: var(--surface);
  color: var(--text);
  border-radius: 10px;
  padding: 6px 10px;
  font-size: 12px;
  outline: none;
}

.ai-question-input:focus {
  border-color: var(--purple-1);
}

.ai-help {
  margin: 8px 0 0;
  color: var(--text-3);
  font-size: 12px;
}

.ai-btn {
  border: 1px solid var(--border);
  background: var(--surface);
  color: var(--text-2);
  border-radius: 99px;
  padding: 5px 12px;
  font-size: 12px;
  cursor: pointer;
  transition: all var(--transition);
}

.ai-btn:hover:not(:disabled) {
  border-color: var(--purple-1);
  color: var(--text);
}

.ai-btn:disabled {
  opacity: 0.65;
  cursor: not-allowed;
}

.ai-btn.secondary {
  border-style: dashed;
}

.ai-error {
  margin: 10px 0 0;
  font-size: 12px;
  color: #ef4f4f;
}

.ai-result {
  margin-top: 10px;
  border: 1px solid var(--border);
  background: var(--panel);
  border-radius: var(--radius-sm);
  padding: 10px 12px;
}

.ai-result h4 {
  margin: 0 0 8px;
  font-size: 12px;
  color: var(--text-2);
  text-transform: uppercase;
  letter-spacing: 0.05em;
}

.ai-result pre {
  margin: 0;
  white-space: pre-wrap;
  word-break: break-word;
  font-family: 'JetBrains Mono', monospace;
  font-size: 12px;
  line-height: 1.5;
  color: var(--text);
}

.mode-btn {
  border: 1px solid var(--border);
  background: var(--surface);
  color: var(--text-2);
  border-radius: 99px;
  padding: 5px 12px;
  font-size: 12px;
  cursor: pointer;
  transition: all var(--transition);
}

.mode-btn:hover {
  border-color: var(--purple-1);
  color: var(--text);
}

.mode-btn.active {
  border-color: var(--purple-1);
  background: var(--purple-dim);
  color: var(--purple-3);
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
  list-style: none !important;
  padding: 0 !important;
  display: flex;
  flex-direction: column;
  gap: 2px;
}
.tiptap-content :deep(li[data-type="taskItem"]) {
  display: flex !important;
  flex-direction: row !important;
  align-items: center !important;
  gap: 8px;
  padding: 3px 0;
}
.tiptap-content :deep(li[data-type="taskItem"] > label) {
  display: flex !important;
  align-items: center !important;
  flex-shrink: 0;
  cursor: pointer;
  margin: 0;
  padding: 0;
  line-height: 1;
}
.tiptap-content :deep(li[data-type="taskItem"] > label input[type="checkbox"]) {
  accent-color: var(--purple-1);
  width: 15px;
  height: 15px;
  cursor: pointer;
  margin: 0;
  display: block;
}
.tiptap-content :deep(li[data-type="taskItem"] > div) {
  flex: 1;
  min-width: 0;
}
.tiptap-content :deep(li[data-type="taskItem"] > div > p) {
  margin: 0;
  line-height: 1.5;
}
.tiptap-content :deep(li[data-type="taskItem"][data-checked="true"] > div) {
  text-decoration: line-through;
  color: var(--text-3);
}
.tiptap-content :deep(li[data-type="taskItem"][data-checked="true"] > div p) {
  color: var(--text-3);
  text-decoration: line-through;
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
  background: rgba(124, 58, 237, 0.12);
  color: var(--text);
  border: 1px solid rgba(226, 228, 240, 0.22);
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
