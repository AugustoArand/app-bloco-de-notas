<template>
  <aside class="sidebar" :class="{ collapsed }">
    <!-- Header -->
    <div class="sidebar-header">
      <div class="logo" v-if="!collapsed">
        <div class="logo-icon">
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M14.5 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V7.5L14.5 2z"/>
            <polyline points="14,2 14,8 20,8"/>
          </svg>
        </div>
        <span class="logo-text">NoteVault</span>
      </div>
      <button class="btn-icon collapse-btn" @click="collapsed = !collapsed" title="Recolher">
        <svg width="16" height="16" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
          <line x1="3" y1="12" x2="21" y2="12"/><line x1="3" y1="6" x2="21" y2="6"/><line x1="3" y1="18" x2="21" y2="18"/>
        </svg>
      </button>
    </div>

    <template v-if="!collapsed">
      <!-- Home link -->
      <div class="sidebar-nav">
        <router-link to="/" class="nav-home" :class="{ active: $route.path === '/' }">
          <svg width="14" height="14" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
            <path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/>
            <polyline points="9 22 9 12 15 12 15 22"/>
          </svg>
          <span>Início</span>
        </router-link>
      </div>

      <!-- Search -->
      <div class="sidebar-search">
        <div class="search-wrap">
          <svg class="search-icon" width="14" height="14" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
            <circle cx="11" cy="11" r="8"/><path d="m21 21-4.35-4.35"/>
          </svg>
          <input
            id="sidebar-search"
            v-model="searchQuery"
            type="text"
            class="search-input"
            placeholder="Buscar notas..."
            @input="handleSearch"
          />
        </div>
      </div>

      <!-- Notebooks -->
      <div class="sidebar-section">
        <div class="section-header">
          <span class="section-title">Cadernos</span>
          <button id="btn-new-notebook" class="btn-icon" title="Novo caderno" @click="createNotebook">
            <svg width="14" height="14" fill="none" stroke="currentColor" stroke-width="2.5" viewBox="0 0 24 24">
              <line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/>
            </svg>
          </button>
        </div>

        <div v-if="notebooks.loading" class="loading-row">
          <div class="spinner"></div>
        </div>

        <div v-else class="notebook-list">
          <div
            v-for="nb in notebooks.notebooks"
            :key="nb.id"
            class="notebook-item"
            :class="{ active: activeNotebook === nb.id }"
            @click="selectNotebook(nb.id)"
          >
            <div class="notebook-left">
              <svg width="14" height="14" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                <path d="M2 3h6a4 4 0 0 1 4 4v14a3 3 0 0 0-3-3H2z"/><path d="M22 3h-6a4 4 0 0 0-4 4v14a3 3 0 0 1 3-3h7z"/>
              </svg>
              <span class="notebook-name" v-if="editingNotebook !== nb.id">{{ nb.name }}</span>
              <input
                v-else
                v-model="editName"
                class="notebook-edit-input"
                @blur="saveNotebookName(nb.id)"
                @keyup.enter="saveNotebookName(nb.id)"
                @click.stop
                ref="editInput"
              />
            </div>
            <div class="notebook-actions">
              <span class="note-count">{{ nb.notes_count }}</span>
              <button class="btn-icon tiny" @click.stop="startEditNotebook(nb)" title="Renomear">
                <svg width="11" height="11" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>
              </button>
              <button class="btn-icon tiny danger" @click.stop="deleteNotebook(nb.id)" title="Excluir">
                <svg width="11" height="11" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><polyline points="3,6 5,6 21,6"/><path d="M19,6l-1,14H6L5,6"/><path d="M10,11v6"/><path d="M14,11v6"/><path d="M9,6V4h6v2"/></svg>
              </button>
            </div>
          </div>

          <div v-if="!notebooks.notebooks.length" class="empty-notebooks">
            <p>Nenhum caderno ainda</p>
            <button class="btn btn-ghost" @click="createNotebook">+ Criar caderno</button>
          </div>
        </div>
      </div>

      <!-- Notes list -->
      <div class="sidebar-section notes-section" v-if="activeNotebook">
        <div class="section-header">
          <span class="section-title">Notas</span>
          <button id="btn-new-note" class="btn-icon" title="Nova nota" @click="createNote">
            <svg width="14" height="14" fill="none" stroke="currentColor" stroke-width="2.5" viewBox="0 0 24 24">
              <line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/>
            </svg>
          </button>
        </div>

        <div v-if="notesStore.loading" class="loading-row">
          <div class="spinner"></div>
        </div>

        <div v-else class="note-list">
          <router-link
            v-for="note in notesStore.notes"
            :key="note.id"
            :to="`/notes/${note.id}`"
            class="note-item"
            :class="{ active: $route.params.id == note.id }"
          >
            <span class="note-title">{{ note.title || 'Sem título' }}</span>
            <span class="note-date">{{ formatDate(note.updated_at) }}</span>
          </router-link>

          <div v-if="!notesStore.notes.length" class="empty-notes">
            <p>Nenhuma nota neste caderno</p>
          </div>
        </div>
      </div>

      <!-- Tags section -->
      <div class="sidebar-section tags-section">
        <div class="section-header">
          <span class="section-title">Tags</span>
          <button id="btn-manage-tags" class="btn-icon" title="Gerenciar tags" @click="showTagManager = true">
            <svg width="13" height="13" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
              <circle cx="12" cy="12" r="3"/>
              <path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1-2.83 2.83l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-4 0v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83-2.83l.06-.06A1.65 1.65 0 0 0 4.68 15a1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1 0-4h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 2.83-2.83l.06.06A1.65 1.65 0 0 0 9 4.68a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 4 0v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 2.83l-.06.06A1.65 1.65 0 0 0 19.4 9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 0 4h-.09a1.65 1.65 0 0 0-1.51 1z"/>
            </svg>
          </button>
        </div>
        <div class="tag-chips">
          <div v-if="!tagsStore.tags.length" class="empty-tags-hint">Nenhuma tag</div>
          <button
            v-for="tag in tagsStore.tags"
            :key="tag.id"
            class="tag-chip-btn"
            :title="tag.name"
          >
            <span class="chip-dot-sm" :style="{ background: tagDotColor(tag.color) }"></span>
            <span class="chip-label">{{ tag.name }}</span>
            <span class="chip-count">{{ tag.notes_count }}</span>
          </button>
        </div>
      </div>

      <!-- User -->
      <div class="sidebar-footer">
        <div class="user-info">
          <div class="user-avatar">{{ userInitials }}</div>
          <div class="user-details">
            <span class="user-name">{{ auth.user?.name }}</span>
            <span class="user-email">{{ auth.user?.email }}</span>
          </div>
        </div>
        <button id="btn-logout" class="btn-icon" title="Sair" @click="handleLogout">
          <svg width="15" height="15" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
            <path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/><polyline points="16 17 21 12 16 7"/><line x1="21" y1="12" x2="9" y2="12"/>
          </svg>
        </button>
      </div>
    </template>

    <!-- Collapsed icons -->
    <template v-else>
      <div class="collapsed-icons">
        <button class="btn-icon" title="Cadernos" @click="collapsed = false">
          <svg width="18" height="18" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
            <path d="M2 3h6a4 4 0 0 1 4 4v14a3 3 0 0 0-3-3H2z"/><path d="M22 3h-6a4 4 0 0 0-4 4v14a3 3 0 0 1 3-3h7z"/>
          </svg>
        </button>
      </div>
    </template>
  </aside>

  <!-- Tag Manager Modal -->
  <TagManager v-if="showTagManager" @close="closeTagManager" />
</template>

<script setup>
import { ref, computed, watch, nextTick } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import { useNotebooksStore } from '@/stores/notebooks'
import { useNotesStore } from '@/stores/notes'
import { useTagsStore } from '@/stores/tags'
import TagManager from '@/components/TagManager.vue'

const auth = useAuthStore()
const notebooks = useNotebooksStore()
const notesStore = useNotesStore()
const tagsStore = useTagsStore()
const router = useRouter()
const route = useRoute()

const collapsed = ref(false)
const activeNotebook = ref(null)
const searchQuery = ref('')
const editingNotebook = ref(null)
const editName = ref('')
const editInput = ref(null)
const showTagManager = ref(false)

const COLOR_DOTS = {
  purple: '#8b5cf6', blue: '#3b82f6', green: '#22c55e', amber: '#f59e0b',
  rose: '#f43f5e', cyan: '#06b6d4', orange: '#f97316', pink: '#ec4899',
  teal: '#14b8a6', indigo: '#6366f1', lime: '#84cc16', slate: '#64748b'
}

function tagDotColor(colorKey) {
  return COLOR_DOTS[colorKey] || COLOR_DOTS.purple
}

async function closeTagManager() {
  showTagManager.value = false
  await tagsStore.fetch()
}

const userInitials = computed(() => {
  const name = auth.user?.name || 'U'
  return name.split(' ').map(w => w[0]).join('').toUpperCase().slice(0, 2)
})

function selectNotebook(id) {
  activeNotebook.value = id
  notesStore.fetchByNotebook(id)
}

async function createNotebook() {
  const name = prompt('Nome do caderno:')
  if (!name) return
  const nb = await notebooks.create(name)
  selectNotebook(nb.id)
}

function startEditNotebook(nb) {
  editingNotebook.value = nb.id
  editName.value = nb.name
  nextTick(() => editInput.value?.focus())
}

async function saveNotebookName(id) {
  if (editName.value.trim()) {
    await notebooks.rename(id, editName.value.trim())
  }
  editingNotebook.value = null
}

async function deleteNotebook(id) {
  if (!confirm('Excluir este caderno e todas as notas?')) return
  await notebooks.remove(id)
  if (activeNotebook.value === id) {
    activeNotebook.value = null
    notesStore.notes = []
  }
}

async function createNote() {
  if (!activeNotebook.value) return
  const note = await notesStore.create(activeNotebook.value)
  router.push(`/notes/${note.id}`)
}

async function handleSearch() {
  if (activeNotebook.value) {
    notesStore.fetchByNotebook(activeNotebook.value, searchQuery.value)
  }
}

async function handleLogout() {
  await auth.logout()
  router.replace('/login')
}

function formatDate(dateStr) {
  if (!dateStr) return ''
  const d = new Date(dateStr)
  return d.toLocaleDateString('pt-BR', { day: '2-digit', month: 'short' })
}

// Auto-open first notebook
watch(() => notebooks.notebooks, (nbs) => {
  if (nbs.length && !activeNotebook.value) {
    selectNotebook(nbs[0].id)
  }
}, { immediate: true })

// Load tags on mount
watch(() => auth.isLoggedIn, (v) => { if (v) tagsStore.fetch() }, { immediate: true })
</script>

<style scoped>
.sidebar {
  width: var(--sidebar-w);
  background: var(--panel);
  border-right: 1px solid var(--border-soft);
  display: flex;
  flex-direction: column;
  height: 100vh;
  transition: width var(--transition-slow);
  overflow: hidden;
  flex-shrink: 0;
}
.sidebar.collapsed { width: 52px; }

.sidebar-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 14px 14px 10px;
  border-bottom: 1px solid var(--border-soft);
  min-height: 56px;
}

.logo { display: flex; align-items: center; gap: 8px; }
.logo-icon {
  width: 32px; height: 32px;
  background: linear-gradient(135deg, var(--purple-1), var(--purple-2));
  border-radius: 8px;
  display: flex; align-items: center; justify-content: center;
  color: white;
  flex-shrink: 0;
}
.logo-text {
  font-size: 15px; font-weight: 700;
  background: linear-gradient(to right, var(--purple-2), var(--purple-3));
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
}

.sidebar-search {
  padding: 10px 12px;
}
.search-wrap {
  position: relative;
}
.search-icon {
  position: absolute;
  left: 10px; top: 50%;
  transform: translateY(-50%);
  color: var(--text-3);
  pointer-events: none;
}
.search-input {
  width: 100%;
  background: var(--surface);
  border: 1px solid var(--border);
  border-radius: var(--radius-sm);
  color: var(--text);
  font-size: 13px;
  padding: 7px 10px 7px 30px;
  outline: none;
  transition: border-color var(--transition);
}
.search-input:focus {
  border-color: var(--purple-1);
}
.search-input::placeholder { color: var(--text-3); }

.sidebar-section {
  display: flex;
  flex-direction: column;
  padding: 8px 0;
  overflow: hidden;
}

.notes-section {
  flex: 1;
  overflow: hidden;
  border-top: 1px solid var(--border-soft);
}

.section-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 6px 14px;
}
.section-title {
  font-size: 11px;
  font-weight: 600;
  color: var(--text-3);
  text-transform: uppercase;
  letter-spacing: 0.06em;
}

.notebook-list, .note-list {
  overflow-y: auto;
  max-height: 200px;
  padding: 0 6px;
}
.notes-section .note-list {
  max-height: none;
  flex: 1;
}

.notebook-item {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 7px 10px;
  border-radius: var(--radius-sm);
  cursor: pointer;
  transition: background var(--transition);
  gap: 6px;
}
.notebook-item:hover { background: var(--panel-hover); }
.notebook-item.active {
  background: var(--purple-dim);
  border: 1px solid rgba(124,58,237,0.2);
}

.notebook-left {
  display: flex;
  align-items: center;
  gap: 7px;
  flex: 1;
  min-width: 0;
  color: var(--text-2);
}
.notebook-item.active .notebook-left { color: var(--purple-3); }
.notebook-name { font-size: 13px; font-weight: 500; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }

.notebook-edit-input {
  background: var(--surface);
  border: 1px solid var(--purple-1);
  border-radius: 4px;
  color: var(--text);
  font-size: 13px;
  padding: 2px 6px;
  width: 100%;
  outline: none;
}

.notebook-actions {
  display: flex;
  align-items: center;
  gap: 2px;
  opacity: 0;
  transition: opacity var(--transition);
}
.notebook-item:hover .notebook-actions { opacity: 1; }
.note-count {
  font-size: 10px;
  color: var(--text-3);
  background: var(--surface);
  padding: 1px 5px;
  border-radius: 99px;
}

.btn-icon.tiny { padding: 3px; }
.btn-icon.danger:hover { color: var(--red); background: rgba(244,63,94,0.1); }

.note-item {
  display: flex;
  flex-direction: column;
  gap: 2px;
  padding: 9px 10px;
  border-radius: var(--radius-sm);
  cursor: pointer;
  transition: background var(--transition);
  text-decoration: none;
  color: inherit;
  border: 1px solid transparent;
}
.note-item:hover { background: var(--panel-hover); }
.note-item.active {
  background: var(--purple-dim);
  border-color: rgba(124,58,237,0.2);
}
.note-title { font-size: 13px; font-weight: 500; color: var(--text); overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.note-item.active .note-title { color: var(--purple-3); }
.note-date { font-size: 11px; color: var(--text-3); }

.loading-row {
  display: flex;
  justify-content: center;
  padding: 16px;
}

.empty-notebooks, .empty-notes {
  text-align: center;
  padding: 20px 12px;
  color: var(--text-3);
  font-size: 12.5px;
  display: flex;
  flex-direction: column;
  gap: 10px;
  align-items: center;
}

.sidebar-footer {
  margin-top: auto;
  padding: 12px;
  border-top: 1px solid var(--border-soft);
  display: flex;
  align-items: center;
  gap: 8px;
}
.user-info { display: flex; align-items: center; gap: 8px; flex: 1; min-width: 0; }
.user-avatar {
  width: 30px; height: 30px;
  background: linear-gradient(135deg, var(--purple-1), var(--purple-2));
  border-radius: 50%;
  display: flex; align-items: center; justify-content: center;
  font-size: 11px; font-weight: 700; color: white;
  flex-shrink: 0;
}
.user-details { display: flex; flex-direction: column; min-width: 0; }
.user-name { font-size: 12.5px; font-weight: 600; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.user-email { font-size: 10.5px; color: var(--text-3); overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }

.collapsed-icons {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 10px 0;
  gap: 8px;
}

/* Home nav link */
.sidebar-nav {
  padding: 6px 8px 2px;
}
.nav-home {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 7px 10px;
  border-radius: var(--radius-sm);
  font-size: 13px;
  font-weight: 500;
  color: var(--text-2);
  text-decoration: none;
  transition: all var(--transition);
}
.nav-home:hover { background: var(--panel-hover); color: var(--text); }
.nav-home.active {
  background: var(--purple-dim);
  color: var(--purple-3);
  border: 1px solid rgba(124,58,237,0.2);
}

/* Tags section */
.tags-section { border-top: 1px solid var(--border-soft); }
.tag-chips {
  padding: 4px 8px 8px;
  display: flex;
  flex-direction: column;
  gap: 2px;
}
.empty-tags-hint {
  font-size: 11.5px;
  color: var(--text-3);
  padding: 4px 6px;
}
.tag-chip-btn {
  display: flex;
  align-items: center;
  gap: 7px;
  padding: 5px 8px;
  border-radius: var(--radius-sm);
  background: none;
  border: none;
  cursor: pointer;
  color: var(--text-2);
  font-size: 12.5px;
  text-align: left;
  transition: background var(--transition);
  width: 100%;
}
.tag-chip-btn:hover { background: var(--panel-hover); }
.chip-dot-sm {
  width: 7px; height: 7px;
  border-radius: 50%;
  flex-shrink: 0;
}
.chip-label {
  flex: 1;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
.chip-count {
  font-size: 10px;
  color: var(--text-3);
  background: var(--surface);
  padding: 1px 5px;
  border-radius: 99px;
  flex-shrink: 0;
}
</style>
