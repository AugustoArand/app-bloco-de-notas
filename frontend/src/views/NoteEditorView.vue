<template>
  <div class="note-editor-view" v-if="note">
    <!-- Toolbar -->
    <EditorToolbar
      :editor="editor"
      :saving="notesStore.saving"
      :last-saved="lastSaved"
      @insert-image="handleImageUpload"
      @export-pdf="handleExportPdf"
      @delete-note="handleDeleteNote"
    />

    <!-- Main editor area -->
    <div class="editor-body">
      <!-- Content -->
      <div class="editor-content-area">
        <!-- Breadcrumb -->
        <nav class="note-breadcrumb" v-if="note">
          <router-link to="/" class="breadcrumb-link">
            <svg width="12" height="12" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
              <path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/>
              <polyline points="9 22 9 12 15 12 15 22"/>
            </svg>
            Duck Notes
          </router-link>
          <svg class="breadcrumb-sep" width="12" height="12" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
            <polyline points="9 18 15 12 9 6"/>
          </svg>
          <span class="breadcrumb-segment">
            <svg width="12" height="12" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
              <path d="M2 3h6a4 4 0 0 1 4 4v14a3 3 0 0 0-3-3H2z"/><path d="M22 3h-6a4 4 0 0 0-4 4v14a3 3 0 0 1 3-3h7z"/>
            </svg>
            {{ note.notebook_name }}
          </span>
          <svg class="breadcrumb-sep" width="12" height="12" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
            <polyline points="9 18 15 12 9 6"/>
          </svg>
          <span class="breadcrumb-segment breadcrumb-current">{{ noteTitle || 'Sem título' }}</span>
        </nav>

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

          <!-- AI Panel -->
          <div class="ai-panel" v-if="editorMode === 'text'">
            <button class="ai-toggle" :class="{ open: aiPanelOpen }" @click="aiPanelOpen = !aiPanelOpen">
              <svg width="13" height="13" viewBox="0 0 24 24" fill="currentColor" style="color: var(--purple-2)">
                <path d="M12 2l1.09 6.26L19 7l-3.55 4.87L21 14l-5.55 2.13L19 21l-6.91-5.74L12 22l-1.09-6.26L5 17l3.55-4.87L3 10l5.55-2.13L5 3l6.91 5.74L12 2z"/>
              </svg>
              <span>Assistente IA</span>
              <svg class="ai-chevron" width="13" height="13" fill="none" stroke="currentColor" stroke-width="2.5" viewBox="0 0 24 24">
                <polyline points="6 9 12 15 18 9"/>
              </svg>
            </button>

            <Transition name="ai-slide">
              <div class="ai-panel-body" v-if="aiPanelOpen">

                <!-- Loading -->
                <div class="ai-loading-row" v-if="aiLoading">
                  <div class="spinner" style="width:13px;height:13px;border-width:1.5px;flex-shrink:0"></div>
                  <span class="ai-loading-label">{{ aiModeLoadingLabel }}</span>
                  <button class="ai-cancel-btn" @click="cancelAi">
                    <svg width="11" height="11" fill="none" stroke="currentColor" stroke-width="2.5" viewBox="0 0 24 24">
                      <line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/>
                    </svg>
                    Cancelar
                  </button>
                </div>

                <!-- Input + chips -->
                <template v-else>
                  <div class="ai-input-row">
                    <input
                      v-model="aiQuestion"
                      class="ai-question-input"
                      placeholder="Descreva o que a IA deve gerar..."
                    />
                    <button class="ai-submit-btn" :disabled="!aiQuestion.trim()" @click="generateTextWithAi" title="Gerar">
                      <svg width="14" height="14" fill="none" stroke="currentColor" stroke-width="2.5" viewBox="0 0 24 24">
                        <line x1="5" y1="12" x2="19" y2="12"/><polyline points="12 5 19 12 12 19"/>
                      </svg>
                    </button>
                  </div>

                  <div class="ai-chips-row">
                    <button class="ai-chip" @click="summarizeWithAi('bullet')">
                      <svg width="12" height="12" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                        <line x1="9" y1="6" x2="20" y2="6"/><line x1="9" y1="12" x2="20" y2="12"/><line x1="9" y1="18" x2="20" y2="18"/>
                        <circle cx="4" cy="6" r="1" fill="currentColor"/><circle cx="4" cy="12" r="1" fill="currentColor"/><circle cx="4" cy="18" r="1" fill="currentColor"/>
                      </svg>
                      Resumo
                    </button>
                    <button class="ai-chip" @click="translateTextWithAi">
                      <svg width="12" height="12" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                        <path d="m5 8 6 6"/><path d="m4 14 6-6 2-3"/><path d="M2 5h12"/><path d="M7 2h1"/><path d="m22 22-5-10-5 10"/><path d="M14 18h6"/>
                      </svg>
                      Traduzir texto
                    </button>
                    <button class="ai-chip" @click="translateTermsWithAi">
                      <svg width="12" height="12" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                        <path d="M4 7V4h16v3"/><path d="M9 20h6"/><path d="M12 4v16"/>
                      </svg>
                      Glossário
                    </button>
                  </div>
                </template>

                <p class="ai-error" v-if="aiError">{{ aiError }}</p>
              </div>
            </Transition>
          </div>

          <!-- AI Result panel -->
          <Transition name="ai-result-fade">
            <div class="ai-result-panel" v-if="aiResult">
              <div class="ai-result-header">
                <span class="ai-result-label">{{ aiResultTitle }}</span>
                <div class="ai-result-actions">
                  <button class="ai-result-insert" @click="insertAiResultInEditor">
                    <svg width="12" height="12" fill="none" stroke="currentColor" stroke-width="2.5" viewBox="0 0 24 24">
                      <polyline points="9 10 4 15 9 20"/><path d="M20 4v7a4 4 0 0 1-4 4H4"/>
                    </svg>
                    Inserir
                  </button>
                  <button class="ai-result-close" @click="aiResult = ''; aiError = ''" title="Fechar">
                    <svg width="13" height="13" fill="none" stroke="currentColor" stroke-width="2.5" viewBox="0 0 24 24">
                      <line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/>
                    </svg>
                  </button>
                </div>
              </div>
              <pre class="ai-result-content">{{ aiResult }}</pre>
            </div>
          </Transition>

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

        <!-- Quadros -->
        <div v-else class="boards-container">
          <div class="boards-tabs">
            <div
              v-for="board in boards"
              :key="board.id"
              class="board-tab"
              :class="{ active: activeBoardId === board.id }"
              @click="selectBoard(board.id)"
            >
              <span
                v-if="editingBoardId !== board.id"
                class="board-tab-name"
                @dblclick.stop="startEditBoardTitle(board)"
                :title="'Duplo clique para renomear'"
              >{{ board.title }}</span>
              <input
                v-else
                v-model="editingBoardTitle"
                class="board-tab-input"
                ref="boardTitleInput"
                @blur="saveBoardTitle(board.id)"
                @keyup.enter="saveBoardTitle(board.id)"
                @click.stop
              />
              <button
                v-if="boards.length > 1"
                class="board-tab-close"
                @click.stop="removeBoard(board.id)"
                title="Remover quadro"
              >×</button>
            </div>
            <button class="board-tab-add" @click="addBoard" title="Novo quadro">
              <svg width="12" height="12" fill="none" stroke="currentColor" stroke-width="2.5" viewBox="0 0 24 24">
                <line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/>
              </svg>
              Quadro
            </button>
          </div>

          <MindMapBoard
            v-if="activeBoard"
            :key="activeBoardId"
            :model-value="{ nodes: activeBoard.nodes, edges: activeBoard.edges }"
            @update:model-value="handleBoardUpdate"
          />
        </div>
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
import { ref, watch, onMounted, onBeforeUnmount, computed, nextTick } from 'vue'
import { useRoute, useRouter } from 'vue-router'
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
import CloudBlock from '@/extensions/CloudBlock'
import MentionMark from '@/extensions/MentionMark'
import ArrowShortcut from '@/extensions/ArrowShortcut'

import EditorToolbar from '@/components/EditorToolbar.vue'
import TableOfContents from '@/components/TableOfContents.vue'
import TagBadge from '@/components/TagBadge.vue'
import MindMapBoard from '@/components/MindMapBoard.vue'
import { useNotesStore } from '@/stores/notes'
import { useTagsStore } from '@/stores/tags'
import { useMentionsStore } from '@/stores/mentions'
import api from '@/services/api'

const route = useRoute()
const router = useRouter()
const notesStore = useNotesStore()
const tagsStore = useTagsStore()
const mentionsStore = useMentionsStore()

const note = ref(null)
const noteTitle = ref('')
const lastSaved = ref(false)
const showTagPicker = ref(false)
const editorMode = ref('text')
const boards = ref([{ id: 'board-1', title: 'Quadro 1', nodes: [], edges: [] }])
const activeBoardId = ref('board-1')
const editingBoardId = ref(null)
const editingBoardTitle = ref('')
const boardTitleInput = ref(null)

const activeBoard = computed(() => boards.value.find(b => b.id === activeBoardId.value))
const aiLoading = ref(false)
const aiPanelOpen = ref(false)
const aiMode = ref('')
const aiResult = ref('')
const aiError = ref('')
const aiQuestion = ref('')
let saveTimeout = null
let diagramSaveTimeout = null
let aiController = null

const availableTags = computed(() => {
  if (!note.value) return []
  const noteTIds = new Set((note.value.tags || []).map(t => t.id))
  return tagsStore.tags.filter(t => !noteTIds.has(t.id))
})

const aiResultTitle = computed(() => {
  if (aiMode.value === 'summary') return 'Resumo'
  if (aiMode.value === 'translate-text') return 'Tradução'
  if (aiMode.value === 'translate-terms') return 'Glossário'
  if (aiMode.value === 'generate') return 'Texto gerado'
  return 'Resultado'
})

const aiModeLoadingLabel = computed(() => {
  if (aiMode.value === 'summary') return 'Resumindo...'
  if (aiMode.value === 'translate-text') return 'Traduzindo...'
  if (aiMode.value === 'translate-terms') return 'Traduzindo termos...'
  if (aiMode.value === 'generate') return 'Gerando...'
  return 'Processando...'
})

function cancelAi() {
  if (aiController) {
    aiController.abort()
    aiController = null
  }
  aiLoading.value = false
  aiMode.value = ''
}

function sanitizeEditorContent(html) {
  if (!html) return ''
  return DOMPurify.sanitize(html, {
    USE_PROFILES: { html: true },
    FORBID_ATTR: ['onerror', 'onload', 'onclick', 'onmouseover'],
  })
}

function normalizedTitle() {
  const title = noteTitle.value?.trim()
  if (title) return title
  return note.value?.title?.trim() || 'Nova Nota'
}

function buildSavePayload(extra = {}) {
  return {
    title: normalizedTitle(),
    content: sanitizeEditorContent(editor.value?.getHTML() || ''),
    ...extra
  }
}

async function saveNoteWithFeedback(payload) {
  if (!note.value) return null
  try {
    const updated = await notesStore.save(note.value.id, payload)
    note.value = updated
    if (!noteTitle.value?.trim()) noteTitle.value = updated.title || 'Nova Nota'
    return updated
  } catch (error) {
    const apiErrors = error?.response?.data?.errors
    const message = Array.isArray(apiErrors) ? apiErrors.join(', ') : error?.message
    console.warn('Falha ao salvar nota:', message)
    return null
  }
}

async function addTagToNote(tag) {
  if (!note.value) return
  const currentIds = (note.value.tags || []).map(t => t.id)
  const newIds = [...currentIds, tag.id]
  const updated = await saveNoteWithFeedback(buildSavePayload({
    tag_ids: newIds
  }))
  if (!updated) return
  showTagPicker.value = false
}

async function removeTagFromNote(tag) {
  if (!note.value) return
  const newIds = (note.value.tags || []).filter(t => t.id !== tag.id).map(t => t.id)
  const updated = await saveNoteWithFeedback(buildSavePayload({
    tag_ids: newIds
  }))
  if (!updated) return
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
    CharacterCount,
    CloudBlock,
    MentionMark,
    ArrowShortcut
  ],
  content: '',
  editorProps: {
    attributes: {
      class: 'tiptap-editor',
      spellcheck: 'true'
    },
    handlePaste(view, event) {
      const types = Array.from(event.clipboardData?.types || [])
      const hasHtml = types.includes('text/html')
      const hasText = types.includes('text/plain')
      if (hasHtml && hasText) {
        const text = event.clipboardData.getData('text/plain')
        if (text) {
          event.preventDefault()
          view.dispatch(view.state.tr.insertText(text))
          return true
        }
      }
      return false
    }
  },
  onUpdate() {
    debounceSave()
    extractMentions()
  }
})

const wordCount = computed(() => {
  if (!editor.value) return 0
  return editor.value.storage.characterCount.words()
})

function extractMentions() {
  if (!editor.value) return
  const map = new Map()
  editor.value.state.doc.descendants((node, pos) => {
    if (!node.isText) return
    node.marks.forEach(mark => {
      if (mark.type.name === 'mention') {
        const { label } = mark.attrs
        if (!map.has(label)) {
          map.set(label, { label, from: pos, to: pos + node.nodeSize, count: 1 })
        } else {
          map.get(label).count++
        }
      }
    })
  })
  mentionsStore.setList([...map.values()])
}

mentionsStore.registerJump(mention => {
  if (!editor.value) return
  editor.value.chain().focus().setTextSelection({ from: mention.from, to: mention.to }).scrollIntoView().run()
})

async function loadNote(id) {
  note.value = null
  showTagPicker.value = false
  const data = await notesStore.fetchOne(id)
  note.value = data
  noteTitle.value = data.title || ''
  const raw = data.diagram_data
  if (Array.isArray(raw) && raw.length > 0) {
    boards.value = raw
    activeBoardId.value = raw[0].id
  } else if (raw?.nodes) {
    boards.value = [{ id: 'board-1', title: 'Quadro 1', nodes: raw.nodes, edges: raw.edges || [] }]
    activeBoardId.value = 'board-1'
  } else {
    boards.value = [{ id: 'board-1', title: 'Quadro 1', nodes: [], edges: [] }]
    activeBoardId.value = 'board-1'
  }
  editorMode.value = 'text'
  if (editor.value) {
    editor.value.commands.setContent(sanitizeEditorContent(data.content || ''))
    nextTick(() => extractMentions())
  }
  lastSaved.value = false
  if (!tagsStore.tags.length) tagsStore.fetch()
}

function debounceSave() {
  clearTimeout(saveTimeout)
  lastSaved.value = false
  saveTimeout = setTimeout(async () => {
    if (!note.value) return
    const updated = await saveNoteWithFeedback(buildSavePayload({
      diagram_data: boards.value
    }))
    if (!updated) return
    lastSaved.value = true
    setTimeout(() => { lastSaved.value = false }, 3000)
  }, 1200)
}

function handleBoardUpdate(value) {
  const board = boards.value.find(b => b.id === activeBoardId.value)
  if (board) {
    board.nodes = value.nodes
    board.edges = value.edges
  }
  debounceDiagramSave()
}

function addBoard() {
  const id = `board-${Date.now()}`
  boards.value.push({ id, title: `Quadro ${boards.value.length + 1}`, nodes: [], edges: [] })
  activeBoardId.value = id
  debounceDiagramSave()
}

function removeBoard(id) {
  if (boards.value.length <= 1) return
  if (!confirm('Excluir este quadro e todos os seus nós?')) return
  const idx = boards.value.findIndex(b => b.id === id)
  boards.value = boards.value.filter(b => b.id !== id)
  if (activeBoardId.value === id) {
    activeBoardId.value = boards.value[Math.max(0, idx - 1)].id
  }
  debounceDiagramSave()
}

function selectBoard(id) {
  activeBoardId.value = id
}

function startEditBoardTitle(board) {
  editingBoardId.value = board.id
  editingBoardTitle.value = board.title
  nextTick(() => boardTitleInput.value?.[0]?.focus())
}

function saveBoardTitle(id) {
  const board = boards.value.find(b => b.id === id)
  if (board && editingBoardTitle.value.trim()) {
    board.title = editingBoardTitle.value.trim()
  }
  editingBoardId.value = null
  debounceDiagramSave()
}

function debounceDiagramSave() {
  clearTimeout(diagramSaveTimeout)
  diagramSaveTimeout = setTimeout(async () => {
    if (!note.value) return
    const updated = await saveNoteWithFeedback(buildSavePayload({
      diagram_data: boards.value
    }))
    if (!updated) return
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

  const pdf = new jsPDF({ unit: 'pt', format: 'a4' })
  const marginX = 48
  const pageWidth = 595.28
  const pageHeight = 841.89

  let y = 60

  function checkNewPage(h) {
    if (y + h > pageHeight - 48) {
      pdf.addPage()
      y = 60
    }
  }

  function renderSimpleText(text, { size = 12, style = 'normal', color = [20, 20, 24], indent = 0 } = {}) {
    if (!text.trim()) return
    pdf.setFont('helvetica', style)
    pdf.setFontSize(size)
    pdf.setTextColor(...color)
    const lh = size * 1.4
    const lines = pdf.splitTextToSize(text.trim(), pageWidth - marginX * 2 - indent)
    lines.forEach((line) => {
      checkNewPage(lh)
      pdf.text(line, marginX + indent, y)
      y += lh
    })
  }

  function getInlineSegments(node, bold = false, italic = false) {
    const out = []
    node.childNodes.forEach((child) => {
      if (child.nodeType === 3) {
        if (child.textContent) out.push({ t: child.textContent, bold, italic })
      } else if (child.nodeType === 1) {
        const tag = child.tagName.toLowerCase()
        out.push(
          ...getInlineSegments(
            child,
            bold || tag === 'strong' || tag === 'b',
            italic || tag === 'em' || tag === 'i',
          ),
        )
      }
    })
    return out
  }

  function renderInline(segments, { size = 12, base = 'normal', color = [20, 20, 24], indent = 0 } = {}) {
    if (!segments.length) return
    const lh = size * 1.4

    const chunks = []
    segments.forEach(({ t, bold, italic }) => {
      const style = bold && italic ? 'bolditalic' : bold ? 'bold' : italic ? 'italic' : base
      if (chunks.length && chunks[chunks.length - 1].style === style) {
        chunks[chunks.length - 1].text += t
      } else {
        chunks.push({ text: t, style })
      }
    })

    if (chunks.length === 1) {
      renderSimpleText(chunks[0].text, { size, style: chunks[0].style, color, indent })
      return
    }

    let x = marginX + indent
    for (const chunk of chunks) {
      pdf.setFont('helvetica', chunk.style)
      pdf.setFontSize(size)
      pdf.setTextColor(...color)

      const tokens = chunk.text.split(/(\s+)/)
      for (const token of tokens) {
        if (!token) continue
        const tw = pdf.getTextWidth(token)
        if (token.trim() === '') {
          x += tw
          continue
        }
        if (x + tw > pageWidth - marginX && x > marginX + indent) {
          y += lh
          checkNewPage(lh)
          x = marginX + indent
          pdf.setFont('helvetica', chunk.style)
          pdf.setFontSize(size)
        }
        checkNewPage(lh)
        pdf.text(token, x, y)
        x += tw
      }
    }
    y += lh
  }

  function processBlock(node) {
    if (node.nodeType !== 1) return
    const tag = node.tagName.toLowerCase()

    if (tag === 'ul' || tag === 'ol') {
      node.querySelectorAll(':scope > li').forEach((li, i) => {
        const bullet = tag === 'ul' ? '•' : `${i + 1}.`
        const lh = 12 * 1.4
        checkNewPage(lh)
        pdf.setFont('helvetica', 'normal')
        pdf.setFontSize(12)
        pdf.setTextColor(20, 20, 24)
        pdf.text(bullet, marginX + 8, y)
        renderInline(getInlineSegments(li), { size: 12, indent: 24 })
      })
      y += 2
      return
    }

    if (tag === 'hr') {
      y += 6
      checkNewPage(8)
      pdf.setDrawColor(200, 200, 200)
      pdf.line(marginX, y, pageWidth - marginX, y)
      y += 10
      return
    }

    const segs = getInlineSegments(node)
    const hasContent = segs.some((s) => s.t.trim())

    switch (tag) {
      case 'h1':
        if (!hasContent) return
        y += 8
        renderInline(segs, { size: 20, base: 'bold' })
        y += 4
        break
      case 'h2':
        if (!hasContent) return
        y += 6
        renderInline(segs, { size: 16, base: 'bold' })
        y += 2
        break
      case 'h3':
        if (!hasContent) return
        y += 4
        renderInline(segs, { size: 13, base: 'bold' })
        y += 2
        break
      case 'p':
        if (!hasContent) {
          y += 8
          return
        }
        renderInline(segs, { size: 12 })
        y += 2
        break
      case 'blockquote':
        if (!hasContent) return
        y += 4
        renderInline(segs, { size: 12, base: 'italic', color: [80, 80, 80], indent: 24 })
        y += 4
        break
      case 'pre':
      case 'code':
        renderSimpleText(node.textContent || '', { size: 10, color: [60, 60, 60], indent: 16 })
        y += 4
        break
      default:
        if (hasContent) renderInline(segs, { size: 12 })
    }
  }

  const title = noteTitle.value?.trim() || 'Sem titulo'
  renderSimpleText(title, { size: 20, style: 'bold' })
  y += 2
  renderSimpleText(`Exportado em ${new Date().toLocaleString('pt-BR')}`, { size: 10, color: [90, 93, 112] })
  y += 14

  const html = editor.value?.getHTML() || ''
  const parser = new DOMParser()
  const doc = parser.parseFromString(html, 'text/html')
  doc.body.childNodes.forEach((node) => processBlock(node))

  pdf.save(`${title.replace(/[^a-z0-9-_]+/gi, '_') || 'nota'}.pdf`)
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
  if (!content) { aiError.value = 'Escreva algum conteúdo antes de resumir.'; return }

  aiController = new AbortController()
  aiLoading.value = true
  aiMode.value = 'summary'
  aiError.value = ''
  aiResult.value = ''
  try {
    const { data } = await api.post('/api/v1/ai/summarize',
      { title: noteTitle.value, content, style },
      { signal: aiController.signal }
    )
    aiResult.value = data.result || ''
  } catch (error) {
    if (error.code !== 'ERR_CANCELED') aiError.value = error.response?.data?.error || 'Falha ao gerar resumo.'
  } finally {
    aiLoading.value = false
    aiController = null
  }
}

async function translateTermsWithAi() {
  if (!note.value || aiLoading.value) return
  const content = getNotePlainText().trim()
  if (!content) { aiError.value = 'Escreva algum conteúdo antes de traduzir termos.'; return }

  aiController = new AbortController()
  aiLoading.value = true
  aiMode.value = 'translate-terms'
  aiError.value = ''
  aiResult.value = ''
  try {
    const { data } = await api.post('/api/v1/ai/translate_terms',
      { content, limit: 12 },
      { signal: aiController.signal }
    )
    aiResult.value = data.result || ''
  } catch (error) {
    if (error.code !== 'ERR_CANCELED') aiError.value = error.response?.data?.error || 'Falha ao traduzir termos.'
  } finally {
    aiLoading.value = false
    aiController = null
  }
}

async function translateTextWithAi() {
  if (!note.value || aiLoading.value) return
  const content = getNotePlainText().trim()
  if (!content) { aiError.value = 'Escreva algum conteúdo antes de traduzir.'; return }

  aiController = new AbortController()
  aiLoading.value = true
  aiMode.value = 'translate-text'
  aiError.value = ''
  aiResult.value = ''
  try {
    const { data } = await api.post('/api/v1/ai/translate_text',
      { content, target_language: 'ingles' },
      { signal: aiController.signal }
    )
    aiResult.value = data.result || ''
  } catch (error) {
    if (error.code !== 'ERR_CANCELED') aiError.value = error.response?.data?.error || 'Falha ao traduzir o texto.'
  } finally {
    aiLoading.value = false
    aiController = null
  }
}

async function generateTextWithAi() {
  if (!note.value || aiLoading.value) return
  const question = aiQuestion.value.trim()
  if (!question) { aiError.value = 'Digite uma instrução para gerar texto.'; return }

  aiController = new AbortController()
  aiLoading.value = true
  aiMode.value = 'generate'
  aiError.value = ''
  aiResult.value = ''
  try {
    const { data } = await api.post('/api/v1/ai/generate_text',
      { question, context: getNotePlainText().trim() },
      { signal: aiController.signal }
    )
    aiResult.value = data.result || ''
  } catch (error) {
    if (error.code !== 'ERR_CANCELED') aiError.value = error.response?.data?.error || 'Falha ao gerar texto.'
  } finally {
    aiLoading.value = false
    aiController = null
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

async function handleDeleteNote() {
  if (!note.value) return
  if (!confirm(`Excluir a nota "${noteTitle.value || 'Sem título'}"? Esta ação não pode ser desfeita.`)) return
  await notesStore.remove(note.value.id)
  router.push('/')
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
  mentionsStore.clear()
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

/* ── Múltiplos quadros ── */
.boards-container {
  flex: 1;
  display: flex;
  flex-direction: column;
  overflow: hidden;
  padding: 0;
}

.boards-tabs {
  display: flex;
  align-items: center;
  gap: 2px;
  padding: 8px 12px 0;
  border-bottom: 1px solid var(--border-soft);
  background: var(--panel);
  flex-shrink: 0;
  overflow-x: auto;
  scrollbar-width: none;
}
.boards-tabs::-webkit-scrollbar { display: none; }

.board-tab {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 6px 12px;
  border-radius: 6px 6px 0 0;
  border: 1px solid transparent;
  border-bottom: none;
  font-size: 12.5px;
  font-weight: 500;
  color: var(--text-3);
  cursor: pointer;
  transition: all var(--transition);
  white-space: nowrap;
  position: relative;
  bottom: -1px;
  user-select: none;
}
.board-tab:hover { color: var(--text-2); background: var(--surface); }
.board-tab.active {
  color: var(--purple-2);
  background: var(--surface);
  border-color: var(--border-soft);
  border-bottom-color: var(--surface);
}

.board-tab-name { cursor: pointer; }

.board-tab-input {
  background: transparent;
  border: none;
  outline: none;
  font-size: 12.5px;
  font-weight: 500;
  color: var(--text);
  font-family: inherit;
  width: 90px;
  padding: 0;
}

.board-tab-close {
  background: none;
  border: none;
  color: var(--text-3);
  cursor: pointer;
  font-size: 14px;
  line-height: 1;
  padding: 0 2px;
  border-radius: 3px;
  transition: all var(--transition);
  display: flex;
  align-items: center;
}
.board-tab-close:hover { color: var(--red); background: rgba(244,63,94,0.12); }

.board-tab-add {
  display: flex;
  align-items: center;
  gap: 5px;
  padding: 6px 10px;
  border-radius: 6px 6px 0 0;
  border: 1px dashed var(--border);
  border-bottom: none;
  background: transparent;
  color: var(--text-3);
  font-size: 12px;
  cursor: pointer;
  transition: all var(--transition);
  white-space: nowrap;
  position: relative;
  bottom: -1px;
}
.board-tab-add:hover { color: var(--purple-2); border-color: var(--purple-1); }

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

/* Breadcrumb */
.note-breadcrumb {
  display: flex;
  align-items: center;
  gap: 5px;
  margin-bottom: 20px;
  flex-wrap: wrap;
}

.breadcrumb-link {
  display: flex;
  align-items: center;
  gap: 5px;
  font-size: 12px;
  color: var(--text-3);
  text-decoration: none;
  transition: color var(--transition);
  font-weight: 500;
}
.breadcrumb-link:hover { color: var(--purple-3); }

.breadcrumb-sep { color: var(--border); flex-shrink: 0; }

.breadcrumb-segment {
  display: flex;
  align-items: center;
  gap: 5px;
  font-size: 12px;
  color: var(--text-3);
  font-weight: 500;
}

.breadcrumb-current {
  color: var(--text-2);
  max-width: 280px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

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

/* ===== AI PANEL ===== */
.ai-panel {
  margin-top: 12px;
  border: 1px solid var(--border-soft);
  border-radius: 10px;
  overflow: hidden;
  background: rgba(255, 255, 255, 0.012);
}

.ai-toggle {
  display: flex;
  align-items: center;
  gap: 7px;
  width: 100%;
  padding: 9px 13px;
  background: none;
  border: none;
  color: var(--text-2);
  font-size: 12.5px;
  font-weight: 500;
  font-family: 'Inter', sans-serif;
  cursor: pointer;
  text-align: left;
  transition: color var(--transition);
}
.ai-toggle:hover { color: var(--text); }
.ai-toggle.open { color: var(--purple-3); }

.ai-chevron {
  margin-left: auto;
  color: var(--text-3);
  transition: transform 0.2s ease;
}
.ai-toggle.open .ai-chevron { transform: rotate(180deg); }

.ai-panel-body {
  border-top: 1px solid var(--border-soft);
  padding: 10px 12px 12px;
  display: flex;
  flex-direction: column;
  gap: 9px;
}

/* Loading row */
.ai-loading-row {
  display: flex;
  align-items: center;
  gap: 9px;
  padding: 2px 0;
}
.ai-loading-label {
  font-size: 12.5px;
  color: var(--purple-3);
  flex: 1;
}
.ai-cancel-btn {
  display: flex;
  align-items: center;
  gap: 5px;
  padding: 4px 11px;
  border-radius: 99px;
  border: 1px solid rgba(244, 63, 94, 0.3);
  background: rgba(244, 63, 94, 0.07);
  color: var(--red);
  font-size: 11.5px;
  font-family: 'Inter', sans-serif;
  cursor: pointer;
  transition: all var(--transition);
}
.ai-cancel-btn:hover {
  background: rgba(244, 63, 94, 0.14);
  border-color: rgba(244, 63, 94, 0.5);
}

/* Input row */
.ai-input-row {
  display: flex;
  gap: 6px;
}
.ai-question-input {
  flex: 1;
  background: var(--surface);
  border: 1px solid var(--border);
  border-radius: 8px;
  color: var(--text);
  font-size: 12.5px;
  font-family: 'Inter', sans-serif;
  padding: 7px 10px;
  outline: none;
  transition: border-color var(--transition);
}
.ai-question-input:focus { border-color: var(--purple-1); }
.ai-question-input::placeholder { color: var(--text-3); }

.ai-submit-btn {
  width: 32px;
  height: 32px;
  border-radius: 8px;
  border: none;
  background: var(--purple-dim);
  color: var(--purple-2);
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  flex-shrink: 0;
  transition: all var(--transition);
}
.ai-submit-btn:hover:not(:disabled) {
  background: rgba(124, 58, 237, 0.22);
  color: var(--purple-3);
}
.ai-submit-btn:disabled { opacity: 0.35; cursor: not-allowed; }

/* Chips */
.ai-chips-row {
  display: flex;
  gap: 6px;
  flex-wrap: wrap;
}
.ai-chip {
  display: flex;
  align-items: center;
  gap: 5px;
  padding: 5px 11px;
  border-radius: 99px;
  border: 1px solid var(--border);
  background: var(--surface);
  color: var(--text-2);
  font-size: 11.5px;
  font-family: 'Inter', sans-serif;
  cursor: pointer;
  transition: all var(--transition);
}
.ai-chip:hover {
  border-color: rgba(124, 58, 237, 0.45);
  color: var(--purple-3);
  background: var(--purple-dim);
}

/* Error inside panel */
.ai-error {
  margin: 0;
  font-size: 12px;
  color: var(--red);
  background: rgba(244, 63, 94, 0.07);
  border: 1px solid rgba(244, 63, 94, 0.2);
  border-radius: 6px;
  padding: 7px 10px;
}

/* ===== AI RESULT PANEL ===== */
.ai-result-panel {
  margin-top: 10px;
  border: 1px solid var(--border-soft);
  border-radius: 10px;
  overflow: hidden;
  background: var(--panel);
}
.ai-result-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 8px 12px;
  border-bottom: 1px solid var(--border-soft);
  background: rgba(124, 58, 237, 0.04);
}
.ai-result-label {
  font-size: 10.5px;
  font-weight: 700;
  color: var(--purple-3);
  text-transform: uppercase;
  letter-spacing: 0.08em;
}
.ai-result-actions {
  display: flex;
  align-items: center;
  gap: 6px;
}
.ai-result-insert {
  display: flex;
  align-items: center;
  gap: 5px;
  padding: 4px 11px;
  border-radius: 99px;
  border: 1px solid rgba(124, 58, 237, 0.35);
  background: var(--purple-dim);
  color: var(--purple-3);
  font-size: 11.5px;
  font-family: 'Inter', sans-serif;
  cursor: pointer;
  transition: all var(--transition);
}
.ai-result-insert:hover { background: rgba(124, 58, 237, 0.2); }
.ai-result-close {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 24px;
  height: 24px;
  border-radius: 6px;
  border: none;
  background: none;
  color: var(--text-3);
  cursor: pointer;
  transition: all var(--transition);
}
.ai-result-close:hover { background: rgba(244, 63, 94, 0.1); color: var(--red); }

.ai-result-content {
  margin: 0;
  padding: 14px;
  white-space: pre-wrap;
  word-break: break-word;
  font-family: 'JetBrains Mono', monospace;
  font-size: 12px;
  line-height: 1.65;
  color: var(--text);
  max-height: 300px;
  overflow-y: auto;
}

/* Transitions */
.ai-slide-enter-active,
.ai-slide-leave-active {
  transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
  overflow: hidden;
}
.ai-slide-enter-from,
.ai-slide-leave-to {
  opacity: 0;
  max-height: 0 !important;
  padding-top: 0 !important;
  padding-bottom: 0 !important;
}
.ai-slide-enter-to,
.ai-slide-leave-from {
  max-height: 200px;
}

.ai-result-fade-enter-active,
.ai-result-fade-leave-active {
  transition: all 0.2s ease;
}
.ai-result-fade-enter-from,
.ai-result-fade-leave-to {
  opacity: 0;
  transform: translateY(-6px);
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

/* Task list — estilos globais em main.css (NodeView gerado via JS) */

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

/* ── Bloco de Destaque ── */
.tiptap-content :deep(.cloud-block) {
  position: relative;
  margin: 20px 0;
  padding: 16px 20px 16px 52px;
  border-radius: 10px;
  border: 1px solid rgba(217, 119, 6, 0.25);
  background: linear-gradient(
    120deg,
    rgba(217, 119, 6, 0.09) 0%,
    rgba(251, 191, 36, 0.05) 50%,
    rgba(217, 119, 6, 0.09) 100%
  );
  background-size: 200% 100%;
  color: #e8dfd4;
  line-height: 1.8;
  animation: highlightSweep 5s ease-in-out infinite;
  transition: border-color 0.3s ease;
}

/* Ícone de destaque à esquerda */
.tiptap-content :deep(.cloud-block::before) {
  content: '✦';
  position: absolute;
  left: 18px;
  top: 50%;
  transform: translateY(-50%);
  font-size: 15px;
  color: #f59e0b;
  animation: iconPulse 2.5s ease-in-out infinite;
  line-height: 1;
}

.tiptap-content :deep(.cloud-block > *) {
  color: #e8dfd4;
  margin: 0;
}

/* Cursor dentro do bloco */
.tiptap-content :deep(.cloud-active) {
  border-color: rgba(217, 119, 6, 0.6) !important;
  box-shadow:
    0 0 0 3px rgba(217, 119, 6, 0.08),
    0 4px 24px rgba(217, 119, 6, 0.12);
}

/* Animação de sweep do gradiente */
@keyframes highlightSweep {
  0%        { background-position: 100% 0; border-color: rgba(217, 119, 6, 0.2); }
  50%       { background-position:   0% 0; border-color: rgba(251, 191, 36, 0.45); }
  100%      { background-position: 100% 0; border-color: rgba(217, 119, 6, 0.2); }
}

/* Pulsação do ícone */
@keyframes iconPulse {
  0%, 100% { opacity: 0.5; transform: translateY(-50%) scale(1);    }
  50%       { opacity: 1;   transform: translateY(-50%) scale(1.25); }
}

/* Highlight */
.tiptap-content :deep(mark) {
  background: rgba(124, 58, 237, 0.12);
  color: var(--text);
  border: 1px solid rgba(226, 228, 240, 0.22);
  border-radius: 3px;
  padding: 0 3px;
}

/* Mention mark */
.tiptap-content :deep(.mention) {
  color: var(--purple-2);
  background: rgba(245, 158, 11, 0.12);
  border: 1px solid rgba(245, 158, 11, 0.28);
  border-radius: 4px;
  padding: 1px 5px;
  font-weight: 500;
  font-size: 0.93em;
  cursor: default;
  transition: background 0.15s ease;
}
.tiptap-content :deep(.mention:hover) {
  background: rgba(245, 158, 11, 0.22);
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
