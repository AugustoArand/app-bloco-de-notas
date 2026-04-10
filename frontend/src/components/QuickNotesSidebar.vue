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
      <div
        v-if="!store.notes.length"
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

        <textarea
          v-model="activeNote.text"
          class="qn-modal-textarea"
          placeholder="Escreva sua anotação rápida..."
          @input="saveActive"
        ></textarea>

        <div class="qn-modal-footer">
          <span>{{ formatDate(activeNote.updatedAt) }}</span>
          <span class="qn-saved-hint" v-if="saved">Salvo ✓</span>
        </div>
      </div>
    </div>
  </Teleport>
</template>

<script setup>
import { ref } from 'vue'
import { useQuickNotesStore } from '@/stores/quickNotes'

const store = useQuickNotesStore()

const activeNote = ref(null)
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

function createNote() {
  const note = store.add()
  openModal(note)
}

function openModal(note) {
  activeNote.value = { ...note }
}

function closeModal() {
  activeNote.value = null
  saved.value = false
}

function saveActive() {
  if (!activeNote.value) return
  clearTimeout(saveTimer)
  saved.value = false
  saveTimer = setTimeout(() => {
    store.update(activeNote.value.id, {
      title: activeNote.value.title,
      text: activeNote.value.text,
      color: activeNote.value.color,
    })
    // sync local copy's updatedAt
    const stored = store.notes.find(n => n.id === activeNote.value.id)
    if (stored) activeNote.value.updatedAt = stored.updatedAt
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
  width: 36px;
  height: 56px;
  background: var(--panel);
  border: 1px solid var(--border);
  border-right: none;
  border-radius: var(--radius-sm) 0 0 var(--radius-sm);
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 4px;
  color: var(--text-3);
  cursor: pointer;
  transition: all var(--transition);
}
.qn-toggle:hover,
.qn-toggle.active {
  color: var(--purple-2);
  background: var(--purple-dim);
  border-color: rgba(124, 58, 237, 0.4);
}
.qn-count {
  font-size: 10px;
  font-weight: 700;
  color: var(--purple-3);
  background: var(--purple-dim);
  border-radius: 99px;
  padding: 0 4px;
  min-width: 14px;
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
  padding: 14px 14px 10px;
  border-bottom: 1px solid var(--border-soft);
  min-height: 52px;
}
.qn-title {
  font-size: 12px;
  font-weight: 700;
  color: var(--text-3);
  text-transform: uppercase;
  letter-spacing: 0.06em;
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
