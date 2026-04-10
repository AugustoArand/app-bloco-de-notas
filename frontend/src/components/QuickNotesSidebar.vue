<template>
  <!-- Toggle button (sempre visível) -->
  <button class="qn-toggle" :class="{ active: store.isOpen }" @click="store.toggle()" title="Anotações rápidas">
    <svg width="18" height="18" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
      <path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/>
      <path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/>
    </svg>
    <span class="qn-count" v-if="store.notes.length">{{ store.notes.length }}</span>
  </button>

  <!-- Painel lateral -->
  <aside class="qn-sidebar" :class="{ open: store.isOpen }">
    <div class="qn-header">
      <span class="qn-title">Anotações rápidas</span>
      <div class="qn-header-actions">
        <button class="qn-add-btn" @click="createNote" title="Nova anotação">
          <svg width="14" height="14" fill="none" stroke="currentColor" stroke-width="2.5" viewBox="0 0 24 24">
            <line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/>
          </svg>
        </button>
        <button class="qn-close-btn" @click="store.close()" title="Fechar">
          <svg width="14" height="14" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
            <line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/>
          </svg>
        </button>
      </div>
    </div>

    <div class="qn-list">
      <div v-if="store.loading" class="qn-loading">
        <div class="spinner"></div>
      </div>

      <div
        v-else-if="!store.notes.length"
        class="qn-empty"
      >
        <svg width="32" height="32" fill="none" stroke="currentColor" stroke-width="1.5" viewBox="0 0 24 24">
          <path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/>
          <path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/>
        </svg>
        <p>Nenhuma anotação ainda</p>
        <button class="qn-add-btn-empty" @click="createNote">+ Nova anotação</button>
      </div>

      <div
        v-for="note in store.notes"
        :key="note.id"
        class="qn-card"
        :class="note.color"
        @click="openModal(note)"
      >
        <div class="qn-card-header">
          <span class="qn-card-title">{{ note.title || 'Sem título' }}</span>
          <button class="qn-card-delete" @click.stop="store.remove(note.id)" title="Excluir">
            <svg width="11" height="11" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
              <line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/>
            </svg>
          </button>
        </div>
        <p class="qn-card-preview">{{ note.text || 'Clique para editar...' }}</p>
        <span class="qn-card-date">{{ formatDate(note.updatedAt) }}</span>
      </div>
    </div>
  </aside>

  <!-- Modal de edição -->
  <Teleport to="body">
    <div class="qn-overlay" v-if="activeNote" @click.self="closeModal">
      <div class="qn-modal">
        <div class="qn-modal-header">
          <input
            v-model="activeNote.title"
            class="qn-modal-title-input"
            placeholder="Título da anotação..."
            @input="saveActive"
          />
          <div class="qn-modal-actions">
            <!-- Cores -->
            <div class="qn-colors">
              <button
                v-for="c in colors"
                :key="c.key"
                class="qn-color-dot"
                :class="{ selected: activeNote.color === c.key }"
                :style="{ background: c.bg, borderColor: c.border }"
                @click="setColor(c.key)"
                :title="c.label"
              ></button>
            </div>
            <button class="qn-modal-delete" @click="deleteActive" title="Excluir anotação">
              <svg width="14" height="14" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                <polyline points="3,6 5,6 21,6"/>
                <path d="M19,6l-1,14H6L5,6"/>
                <path d="M10,11v6"/><path d="M14,11v6"/>
                <path d="M9,6V4h6v2"/>
              </svg>
            </button>
            <button class="qn-modal-close" @click="closeModal" title="Fechar">
              <svg width="14" height="14" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                <line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/>
              </svg>
            </button>
          </div>
        </div>

        <div
          ref="editorRef"
          class="qn-modal-editor"
          contenteditable="true"
          :data-placeholder="'Escreva sua anotação rápida...'"
          @input="onEditorInput"
        ></div>

        <!-- Barra de formatação -->
        <div class="qn-format-bar">
          <button class="qn-fmt-btn" @mousedown.prevent="fmt('bold')"       title="Negrito (Ctrl+B)">
            <b>B</b>
          </button>
          <button class="qn-fmt-btn" @mousedown.prevent="fmt('italic')"     title="Itálico (Ctrl+I)">
            <i>I</i>
          </button>
          <button class="qn-fmt-btn" @mousedown.prevent="fmt('underline')"  title="Sublinhado (Ctrl+U)">
            <u>U</u>
          </button>
          <div class="qn-fmt-divider"></div>
          <button class="qn-fmt-btn" @mousedown.prevent="fmtHighlight"      title="Marcador de texto">
            <svg width="13" height="13" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
              <path d="M12 20h9"/><path d="M16.5 3.5a2.121 2.121 0 0 1 3 3L7 19l-4 1 1-4L16.5 3.5z"/>
            </svg>
          </button>
          <div class="qn-fmt-divider"></div>
          <button class="qn-fmt-btn" @mousedown.prevent="insertList(false)" title="Lista com marcadores">
            <svg width="13" height="13" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
              <line x1="9" y1="6" x2="20" y2="6"/><line x1="9" y1="12" x2="20" y2="12"/><line x1="9" y1="18" x2="20" y2="18"/>
              <circle cx="4" cy="6" r="1" fill="currentColor"/><circle cx="4" cy="12" r="1" fill="currentColor"/><circle cx="4" cy="18" r="1" fill="currentColor"/>
            </svg>
          </button>
          <button class="qn-fmt-btn" @mousedown.prevent="insertList(true)"  title="Lista numerada">
            <svg width="13" height="13" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
              <line x1="10" y1="6" x2="21" y2="6"/><line x1="10" y1="12" x2="21" y2="12"/><line x1="10" y1="18" x2="21" y2="18"/>
              <path d="M4 6h1v4"/><path d="M4 10h2"/><path d="M6 18H4c0-1 2-2 2-3s-1-1.5-2-1"/>
            </svg>
          </button>
          <button class="qn-fmt-btn" @mousedown.prevent="insertChecklist"   title="Checklist">
            <svg width="13" height="13" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
              <polyline points="9 11 12 14 22 4"/><path d="M21 12v7a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11"/>
            </svg>
          </button>
          <div class="qn-fmt-spacer"></div>
          <span class="qn-modal-footer-date">{{ formatDate(activeNote.updated_at) }}</span>
          <span class="qn-saved-hint" v-if="saved">Salvo ✓</span>
        </div>
      </div>
    </div>
  </Teleport>
</template>

<script setup>
import { ref, watch, nextTick } from 'vue'
import { useQuickNotesStore } from '@/stores/quickNotes'

const store = useQuickNotesStore()

// Remove dados legados do localStorage (migração para backend)
localStorage.removeItem('quick_notes')

// Carrega do backend ao abrir o painel pela primeira vez
watch(() => store.isOpen, (open) => {
  if (open && !store.notes.length && !store.loading) store.fetch()
})

const activeNote = ref(null)
const editorRef  = ref(null)
const saved = ref(false)
let saveTimer = null

const colors = [
  { key: 'default', bg: 'var(--surface)',      border: 'var(--border)',             label: 'Padrão'  },
  { key: 'purple',  bg: 'rgba(124,58,237,.25)', border: 'rgba(124,58,237,.5)',       label: 'Roxo'    },
  { key: 'green',   bg: 'rgba(34,197,94,.2)',   border: 'rgba(34,197,94,.5)',        label: 'Verde'   },
  { key: 'amber',   bg: 'rgba(245,158,11,.2)',  border: 'rgba(245,158,11,.5)',       label: 'Âmbar'   },
  { key: 'rose',    bg: 'rgba(244,63,94,.2)',   border: 'rgba(244,63,94,.5)',        label: 'Rosa'    },
  { key: 'blue',    bg: 'rgba(59,130,246,.2)',  border: 'rgba(59,130,246,.5)',       label: 'Azul'    },
]

async function createNote() {
  const note = await store.add()
  openModal(note)
}

function openModal(note) {
  activeNote.value = { ...note }
  nextTick(() => {
    if (editorRef.value) {
      editorRef.value.innerHTML = note.text || ''
      editorRef.value.focus()
    }
  })
}

function closeModal() {
  activeNote.value = null
  saved.value = false
}

function onEditorInput() {
  if (!activeNote.value) return
  activeNote.value.text = editorRef.value?.innerHTML || ''
  saveActive()
}

function saveActive() {
  if (!activeNote.value) return
  clearTimeout(saveTimer)
  saved.value = false
  saveTimer = setTimeout(async () => {
    const updated = await store.update(activeNote.value.id, {
      title: activeNote.value.title,
      text:  activeNote.value.text,
      color: activeNote.value.color,
    })
    if (updated) activeNote.value.updated_at = updated.updated_at
    saved.value = true
    setTimeout(() => { saved.value = false }, 2000)
  }, 600)
}

function setColor(colorKey) {
  if (!activeNote.value) return
  activeNote.value.color = colorKey
  saveActive()
}

function deleteActive() {
  if (!activeNote.value) return
  store.remove(activeNote.value.id)
  closeModal()
}

// Formatação via Selection API
function wrapSelection(tag, attrs = {}) {
  editorRef.value?.focus()
  const sel = window.getSelection()
  if (!sel?.rangeCount) return
  const range = sel.getRangeAt(0)
  const el = document.createElement(tag)
  Object.entries(attrs).forEach(([k, v]) => el.setAttribute(k, v))
  try {
    range.surroundContents(el)
  } catch {
    const frag = range.extractContents()
    el.appendChild(frag)
    range.insertNode(el)
  }
  onEditorInput()
}

function fmt(command) {
  const map = { bold: 'strong', italic: 'em', underline: 'u' }
  wrapSelection(map[command])
}

function fmtHighlight() {
  wrapSelection('mark', { style: 'background:rgba(124,58,237,0.28);border-radius:3px;padding:0 2px' })
}

function insertList(ordered) {
  editorRef.value?.focus()
  const sel = window.getSelection()
  if (!sel?.rangeCount) return
  const range = sel.getRangeAt(0)
  const list = document.createElement(ordered ? 'ol' : 'ul')
  list.style.cssText = 'padding-left:20px;margin:4px 0'
  const li = document.createElement('li')
  const frag = range.extractContents()
  li.appendChild(frag.textContent ? frag : document.createTextNode('\u200B'))
  list.appendChild(li)
  range.insertNode(list)
  // posiciona cursor dentro do li
  const newRange = document.createRange()
  newRange.setStart(li, li.childNodes.length)
  newRange.collapse(true)
  sel.removeAllRanges()
  sel.addRange(newRange)
  onEditorInput()
}

function insertChecklist() {
  editorRef.value?.focus()
  const sel = window.getSelection()
  if (!sel?.rangeCount) return
  const range = sel.getRangeAt(0)
  const div = document.createElement('div')
  div.style.cssText = 'display:flex;align-items:center;gap:6px;margin:2px 0'
  const cb = document.createElement('input')
  cb.type = 'checkbox'
  cb.style.cssText = 'accent-color:#7c3aed;width:14px;height:14px;flex-shrink:0'
  const span = document.createElement('span')
  span.appendChild(document.createTextNode('\u200B'))
  div.appendChild(cb)
  div.appendChild(span)
  range.deleteContents()
  range.insertNode(div)
  const newRange = document.createRange()
  newRange.setStart(span, 1)
  newRange.collapse(true)
  sel.removeAllRanges()
  sel.addRange(newRange)
  onEditorInput()
}

function formatDate(dateStr) {
  if (!dateStr) return ''
  const d = new Date(dateStr)
  const now = new Date()
  const diffMs = now - d
  const diffMin = Math.floor(diffMs / 60000)
  if (diffMin < 1)  return 'agora'
  if (diffMin < 60) return `${diffMin}min atrás`
  const diffH = Math.floor(diffMin / 60)
  if (diffH < 24)   return `${diffH}h atrás`
  return d.toLocaleDateString('pt-BR', { day: '2-digit', month: 'short' })
}
</script>

<style scoped>
/* ── Toggle button ── */
.qn-toggle {
  position: fixed;
  right: 0;
  top: 50%;
  transform: translateY(-50%);
  z-index: 200;
  width: 42px;
  height: 64px;
  background: linear-gradient(160deg, var(--purple-1), #5b21b6);
  border: none;
  border-radius: var(--radius-sm) 0 0 var(--radius-sm);
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 5px;
  color: #fff;
  cursor: pointer;
  transition: all var(--transition);
  box-shadow: -4px 0 20px rgba(124, 58, 237, 0.45);
}
.qn-toggle::before {
  content: '';
  position: absolute;
  inset: 0;
  border-radius: inherit;
  background: linear-gradient(160deg, rgba(255,255,255,0.12), transparent);
  pointer-events: none;
}
.qn-toggle:hover {
  width: 46px;
  box-shadow: -6px 0 28px rgba(124, 58, 237, 0.65);
  background: linear-gradient(160deg, var(--purple-2), var(--purple-1));
}
.qn-toggle.active {
  background: linear-gradient(160deg, #4c1d95, var(--purple-1));
  box-shadow: -4px 0 24px rgba(124, 58, 237, 0.5);
}
.qn-count {
  font-size: 10px;
  font-weight: 800;
  color: #fff;
  background: rgba(255, 255, 255, 0.25);
  border-radius: 99px;
  padding: 1px 5px;
  min-width: 16px;
  text-align: center;
  line-height: 1.6;
}

/* ── Sidebar panel ── */
.qn-sidebar {
  position: fixed;
  right: 0;
  top: 0;
  height: 100vh;
  width: 280px;
  background: var(--panel);
  border-left: 1px solid var(--border-soft);
  display: flex;
  flex-direction: column;
  z-index: 190;
  transform: translateX(100%);
  transition: transform var(--transition-slow);
  box-shadow: -8px 0 32px rgba(0, 0, 0, 0.4);
}
.qn-sidebar.open {
  transform: translateX(0);
}

.qn-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 14px 14px 12px;
  border-bottom: 1px solid var(--border-soft);
  min-height: 56px;
  background: linear-gradient(135deg, rgba(124, 58, 237, 0.12), transparent);
}
.qn-title {
  font-size: 13px;
  font-weight: 700;
  background: linear-gradient(to right, var(--purple-2), var(--purple-3));
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
  letter-spacing: 0.04em;
}
.qn-header-actions {
  display: flex;
  align-items: center;
  gap: 4px;
}
.qn-add-btn,
.qn-close-btn {
  width: 26px; height: 26px;
  display: flex; align-items: center; justify-content: center;
  background: transparent;
  border: none;
  border-radius: var(--radius-sm);
  color: var(--text-3);
  cursor: pointer;
  transition: all var(--transition);
}
.qn-add-btn:hover { background: var(--purple-dim); color: var(--purple-2); }
.qn-close-btn:hover { background: var(--panel-hover); color: var(--text); }

/* ── List ── */
.qn-list {
  flex: 1;
  overflow-y: auto;
  padding: 8px;
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.qn-loading {
  display: flex;
  justify-content: center;
  padding: 32px;
}

.qn-empty {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 10px;
  padding: 40px 16px;
  color: var(--text-3);
  text-align: center;
  font-size: 13px;
}
.qn-add-btn-empty {
  padding: 6px 14px;
  border-radius: 99px;
  border: 1px dashed var(--border);
  background: transparent;
  color: var(--text-3);
  font-size: 12px;
  cursor: pointer;
  transition: all var(--transition);
}
.qn-add-btn-empty:hover { border-color: var(--purple-1); color: var(--purple-2); }

/* ── Card ── */
.qn-card {
  padding: 10px 12px;
  border-radius: var(--radius-sm);
  background: var(--surface);
  border: 1px solid var(--border-soft);
  cursor: pointer;
  transition: all var(--transition);
  display: flex;
  flex-direction: column;
  gap: 4px;
  position: relative;
}
.qn-card:hover { border-color: var(--purple-1); background: var(--panel-hover); }
.qn-card:hover .qn-card-delete { opacity: 1; }

.qn-card.purple { background: rgba(124,58,237,.1); border-color: rgba(124,58,237,.25); }
.qn-card.green  { background: rgba(34,197,94,.08); border-color: rgba(34,197,94,.25);  }
.qn-card.amber  { background: rgba(245,158,11,.08); border-color: rgba(245,158,11,.25);}
.qn-card.rose   { background: rgba(244,63,94,.08);  border-color: rgba(244,63,94,.25); }
.qn-card.blue   { background: rgba(59,130,246,.08); border-color: rgba(59,130,246,.25);}

.qn-card-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 6px;
}
.qn-card-title {
  font-size: 12.5px;
  font-weight: 600;
  color: var(--text);
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  flex: 1;
}
.qn-card-delete {
  opacity: 0;
  width: 20px; height: 20px;
  display: flex; align-items: center; justify-content: center;
  background: transparent;
  border: none;
  border-radius: 4px;
  color: var(--text-3);
  cursor: pointer;
  transition: all var(--transition);
  flex-shrink: 0;
}
.qn-card-delete:hover { background: rgba(244,63,94,.15); color: var(--red); }

.qn-card-preview {
  font-size: 12px;
  color: var(--text-3);
  overflow: hidden;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  line-height: 1.4;
}
.qn-card-date {
  font-size: 10.5px;
  color: var(--text-3);
}

/* ── Modal overlay ── */
.qn-overlay {
  position: fixed;
  inset: 0;
  z-index: 300;
  background: rgba(0, 0, 0, 0.55);
  backdrop-filter: blur(3px);
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 20px;
}

.qn-modal {
  background: var(--panel);
  border: 1px solid var(--border);
  border-radius: var(--radius-lg);
  width: 100%;
  max-width: 560px;
  max-height: 80vh;
  display: flex;
  flex-direction: column;
  box-shadow: 0 24px 64px rgba(0, 0, 0, 0.6);
  animation: modalIn 0.18s ease;
}
@keyframes modalIn {
  from { opacity: 0; transform: scale(0.96) translateY(8px); }
  to   { opacity: 1; transform: scale(1)    translateY(0);    }
}

.qn-modal-header {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 16px 16px 10px;
  border-bottom: 1px solid var(--border-soft);
}
.qn-modal-title-input {
  flex: 1;
  background: transparent;
  border: none;
  outline: none;
  font-family: 'Inter', sans-serif;
  font-size: 16px;
  font-weight: 600;
  color: var(--text);
}
.qn-modal-title-input::placeholder { color: var(--text-3); }

.qn-modal-actions {
  display: flex;
  align-items: center;
  gap: 6px;
  flex-shrink: 0;
}

.qn-colors {
  display: flex;
  gap: 4px;
}
.qn-color-dot {
  width: 14px; height: 14px;
  border-radius: 50%;
  border: 2px solid transparent;
  cursor: pointer;
  transition: transform var(--transition), border-color var(--transition);
}
.qn-color-dot:hover { transform: scale(1.2); }
.qn-color-dot.selected { transform: scale(1.25); border-color: var(--text-2) !important; }

.qn-modal-delete,
.qn-modal-close {
  width: 28px; height: 28px;
  display: flex; align-items: center; justify-content: center;
  background: transparent;
  border: none;
  border-radius: var(--radius-sm);
  color: var(--text-3);
  cursor: pointer;
  transition: all var(--transition);
}
.qn-modal-delete:hover { color: var(--red); background: rgba(244,63,94,.1); }
.qn-modal-close:hover  { color: var(--text); background: var(--panel-hover); }

.qn-modal-textarea {
  flex: 1;
  min-height: 280px;
  background: transparent;
  border: none;
  outline: none;
  resize: none;
  padding: 16px;
  font-family: 'Inter', sans-serif;
  font-size: 14px;
  line-height: 1.7;
  color: var(--text);
}
.qn-modal-textarea::placeholder { color: var(--text-3); }

.qn-modal-footer {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 10px 16px;
  border-top: 1px solid var(--border-soft);
  font-size: 11.5px;
  color: var(--text-3);
}
.qn-saved-hint { color: var(--green); }
</style>
