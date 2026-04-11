<template>
  <aside class="sidebar" :class="{ collapsed }">

    <!-- ===== HEADER ===== -->
    <div class="sidebar-header">
      <!-- Collapsed state -->
      <template v-if="collapsed">
        <button class="btn-icon" @click="collapsed = false" title="Expandir">
          <svg width="18" height="18" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
            <line x1="3" y1="12" x2="21" y2="12"/><line x1="3" y1="6" x2="21" y2="6"/><line x1="3" y1="18" x2="21" y2="18"/>
          </svg>
        </button>
      </template>

      <!-- Notebooks view header -->
      <template v-else-if="sidebarView === 'notebooks'">
        <div class="logo">
          <div class="logo-icon">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <path d="M14.5 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V7.5L14.5 2z"/>
              <polyline points="14,2 14,8 20,8"/>
            </svg>
          </div>
          <span class="logo-text">Duck Notes</span>
        </div>
        <button class="btn-icon collapse-btn" @click="collapsed = !collapsed" title="Recolher">
          <svg width="16" height="16" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
            <line x1="3" y1="12" x2="21" y2="12"/><line x1="3" y1="6" x2="21" y2="6"/><line x1="3" y1="18" x2="21" y2="18"/>
          </svg>
        </button>
      </template>

      <!-- Notes view header -->
      <template v-else>
        <button class="btn-icon back-btn" @click="goBackToNotebooks" title="Voltar para cadernos">
          <svg width="16" height="16" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
            <polyline points="15 18 9 12 15 6"/>
          </svg>
        </button>
        <div class="notes-header-breadcrumb">
          <svg width="13" height="13" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
            <path d="M2 3h6a4 4 0 0 1 4 4v14a3 3 0 0 0-3-3H2z"/><path d="M22 3h-6a4 4 0 0 0-4 4v14a3 3 0 0 1 3-3h7z"/>
          </svg>
          <span class="notes-header-name">{{ activeNotebookName }}</span>
        </div>
        <button id="btn-new-note" class="btn-icon" title="Nova nota" @click="createNote">
          <svg width="15" height="15" fill="none" stroke="currentColor" stroke-width="2.5" viewBox="0 0 24 24">
            <line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/>
          </svg>
        </button>
      </template>
    </div>

    <!-- ===== COLLAPSED ICONS ===== -->
    <template v-if="collapsed">
      <div class="collapsed-icons">
        <button class="btn-icon" title="Cadernos" @click="collapsed = false">
          <svg width="18" height="18" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
            <path d="M2 3h6a4 4 0 0 1 4 4v14a3 3 0 0 0-3-3H2z"/><path d="M22 3h-6a4 4 0 0 0-4 4v14a3 3 0 0 1 3-3h7z"/>
          </svg>
        </button>
      </div>
    </template>

    <!-- ===== MAIN CONTENT ===== -->
    <template v-else>
      <Transition :name="slideDirection" mode="out-in">

        <!-- VIEW: NOTEBOOKS -->
        <div v-if="sidebarView === 'notebooks'" key="notebooks" class="sidebar-body">
          <!-- Home -->
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

          <!-- Notebooks list -->
          <div class="sidebar-section notebooks-section">
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
                @click="selectNotebook(nb)"
              >
                <!-- Icon -->
                <div class="notebook-icon-wrap">
                  <svg width="14" height="14" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                    <path d="M2 3h6a4 4 0 0 1 4 4v14a3 3 0 0 0-3-3H2z"/>
                    <path d="M22 3h-6a4 4 0 0 0-4 4v14a3 3 0 0 1 3-3h7z"/>
                  </svg>
                </div>

                <!-- Name + count stacked -->
                <div class="notebook-info">
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
                  <span class="notebook-meta">
                    {{ nb.notes_count }} {{ nb.notes_count === 1 ? 'nota' : 'notas' }}
                  </span>
                </div>

                <!-- Actions (appear on hover) -->
                <div class="notebook-actions">
                  <button
                    class="btn-icon tiny"
                    :class="{ favored: nb.favorite }"
                    @click.stop="toggleFavorite(nb.id)"
                    :title="nb.favorite ? 'Desfavoritar' : 'Favoritar'"
                  >
                    <svg width="11" height="11" viewBox="0 0 24 24" fill="currentColor">
                      <path d="M12 17.27L18.18 21l-1.64-7.03L22 9.24l-7.19-.61L12 2 9.19 8.63 2 9.24l5.46 4.73L5.82 21z"/>
                    </svg>
                  </button>
                  <button class="btn-icon tiny" @click.stop="startEditNotebook(nb)" title="Renomear">
                    <svg width="11" height="11" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>
                  </button>
                  <button class="btn-icon tiny danger" @click.stop="deleteNotebook(nb.id)" title="Excluir">
                    <svg width="11" height="11" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><polyline points="3,6 5,6 21,6"/><path d="M19,6l-1,14H6L5,6"/><path d="M10,11v6"/><path d="M14,11v6"/><path d="M9,6V4h6v2"/></svg>
                  </button>
                </div>

                <!-- Drill-in arrow -->
                <svg class="notebook-arrow" width="12" height="12" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                  <polyline points="9 18 15 12 9 6"/>
                </svg>
              </div>

              <div v-if="!notebooks.notebooks.length" class="empty-notebooks">
                <p>Nenhum caderno ainda</p>
                <button class="btn btn-ghost" @click="createNotebook">+ Criar caderno</button>
              </div>
            </div>
          </div>

          <!-- Tags -->
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
        </div>

        <!-- VIEW: NOTES -->
        <div v-else key="notes" class="sidebar-body notes-body">
          <!-- Search -->
          <div class="sidebar-search">
            <div class="search-wrap">
              <svg class="search-icon" width="14" height="14" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                <circle cx="11" cy="11" r="8"/><path d="m21 21-4.35-4.35"/>
              </svg>
              <input
                v-model="searchQuery"
                type="text"
                class="search-input"
                placeholder="Buscar neste caderno..."
                @input="handleSearch"
              />
            </div>
          </div>

          <!-- Notes list -->
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
              <div class="note-item-left">
                <svg width="12" height="12" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                  <path d="M14.5 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V7.5L14.5 2z"/>
                  <polyline points="14,2 14,8 20,8"/>
                </svg>
                <div class="note-item-info">
                  <span class="note-title">{{ note.title || 'Sem título' }}</span>
                  <span class="note-date">{{ formatDate(note.updated_at) }}</span>
                </div>
              </div>
            </router-link>

            <div v-if="!notesStore.notes.length" class="empty-notes">
              <svg width="28" height="28" fill="none" stroke="currentColor" stroke-width="1.5" viewBox="0 0 24 24" style="opacity:0.3">
                <path d="M14.5 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V7.5L14.5 2z"/>
                <polyline points="14,2 14,8 20,8"/>
              </svg>
              <p>Nenhuma nota neste caderno</p>
              <button class="btn btn-ghost" @click="createNote">+ Nova nota</button>
            </div>
          </div>
        </div>

      </Transition>
    </template>

    <!-- ===== FOOTER ===== -->
    <div class="sidebar-footer" v-if="!collapsed">
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

  </aside>

  <!-- Tag Manager Modal -->
  <TagManager v-if="showTagManager" @close="closeTagManager" />
</template>

<script setup>
import { ref, computed, watch, nextTick } from 'vue'
import { useRouter } from 'vue-router'
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

const collapsed = ref(false)
const sidebarView = ref('notebooks') // 'notebooks' | 'notes'
const slideDirection = ref('slide-left')
const activeNotebook = ref(null)
const activeNotebookName = ref('')
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

function selectNotebook(nb) {
  activeNotebook.value = nb.id
  activeNotebookName.value = nb.name
  searchQuery.value = ''
  notesStore.fetchByNotebook(nb.id)
  slideDirection.value = 'slide-left'
  sidebarView.value = 'notes'
}

function goBackToNotebooks() {
  slideDirection.value = 'slide-right'
  sidebarView.value = 'notebooks'
  searchQuery.value = ''
}

async function createNotebook() {
  const name = prompt('Nome do caderno:')
  if (!name) return
  const nb = await notebooks.create(name)
  selectNotebook(nb)
}

function startEditNotebook(nb) {
  editingNotebook.value = nb.id
  editName.value = nb.name
  nextTick(() => editInput.value?.focus())
}

async function saveNotebookName(id) {
  if (editName.value.trim()) {
    await notebooks.rename(id, editName.value.trim())
    if (activeNotebook.value === id) {
      activeNotebookName.value = editName.value.trim()
    }
  }
  editingNotebook.value = null
}

async function deleteNotebook(id) {
  if (!confirm('Excluir este caderno e todas as notas?')) return
  await notebooks.remove(id)
  if (activeNotebook.value === id) {
    activeNotebook.value = null
    activeNotebookName.value = ''
    notesStore.notes = []
    goBackToNotebooks()
  }
}

async function createNote() {
  if (!activeNotebook.value) return
  const note = await notesStore.create(activeNotebook.value)
  router.push(`/notes/${note.id}`)
}

async function toggleFavorite(id) {
  await notebooks.toggleFavorite(id)
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

watch(() => auth.isLoggedIn, (v) => { if (v) tagsStore.fetch() }, { immediate: true })
</script>

<style scoped>
/* ===== LAYOUT ===== */
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

/* ===== HEADER ===== */
.sidebar-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 14px 12px 10px;
  border-bottom: 1px solid var(--border-soft);
  min-height: 56px;
  flex-shrink: 0;
  gap: 6px;
}

.logo { display: flex; align-items: center; gap: 8px; }
.logo-icon {
  width: 32px; height: 32px;
  background: linear-gradient(135deg, var(--purple-1), var(--purple-2));
  border-radius: 8px;
  display: flex; align-items: center; justify-content: center;
  color: white; flex-shrink: 0;
}
.logo-text {
  font-size: 15px; font-weight: 700;
  background: linear-gradient(to right, var(--purple-2), var(--purple-3));
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
}

/* Notes view header */
.back-btn { flex-shrink: 0; }
.notes-header-breadcrumb {
  display: flex;
  align-items: center;
  gap: 6px;
  flex: 1;
  min-width: 0;
  color: var(--text-2);
}
.notes-header-name {
  font-size: 13px;
  font-weight: 600;
  color: var(--text);
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

/* ===== BODY (scrollable content) ===== */
.sidebar-body {
  flex: 1;
  overflow: hidden;
  display: flex;
  flex-direction: column;
  min-height: 0;
}

.notes-body { overflow: hidden; }

/* ===== HOME NAV ===== */
.sidebar-nav { padding: 8px 8px 4px; flex-shrink: 0; }
.nav-home {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 7px 10px;
  border-radius: var(--radius-sm);
  font-size: 13px; font-weight: 500;
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

/* ===== SEARCH ===== */
.sidebar-search { padding: 8px 12px; flex-shrink: 0; }
.search-wrap { position: relative; }
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
  box-sizing: border-box;
}
.search-input:focus { border-color: var(--purple-1); }
.search-input::placeholder { color: var(--text-3); }

/* ===== SECTIONS ===== */
.sidebar-section {
  display: flex;
  flex-direction: column;
  padding: 4px 0;
  flex-shrink: 0;
}

.notebooks-section {
  flex: 1;
  overflow: hidden;
  display: flex;
  flex-direction: column;
}

.section-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 8px 14px 4px;
  flex-shrink: 0;
}
.section-title {
  font-size: 10.5px;
  font-weight: 700;
  color: var(--text-3);
  text-transform: uppercase;
  letter-spacing: 0.08em;
}

/* ===== NOTEBOOKS LIST ===== */
.notebook-list {
  overflow-y: auto;
  flex: 1;
  padding: 2px 8px 8px;
  display: flex;
  flex-direction: column;
  gap: 1px;
}

.notebook-item {
  display: flex;
  align-items: center;
  padding: 7px 8px 7px 6px;
  border-radius: 8px;
  cursor: pointer;
  transition: background var(--transition), border-color var(--transition);
  gap: 9px;
  border: 1px solid transparent;
  position: relative;
}
.notebook-item:hover { background: var(--panel-hover); }
.notebook-item:hover .notebook-arrow { opacity: 1; transform: translateX(2px); }
.notebook-item:hover .notebook-actions { opacity: 1; }
.notebook-item.active {
  background: var(--purple-dim);
  border-color: rgba(124, 58, 237, 0.18);
}

/* Icon container */
.notebook-icon-wrap {
  width: 30px;
  height: 30px;
  border-radius: 7px;
  background: var(--surface);
  border: 1px solid var(--border-soft);
  display: flex;
  align-items: center;
  justify-content: center;
  color: var(--text-3);
  flex-shrink: 0;
  transition: all var(--transition);
}
.notebook-item:hover .notebook-icon-wrap {
  background: rgba(124, 58, 237, 0.1);
  border-color: rgba(124, 58, 237, 0.25);
  color: var(--purple-2);
}
.notebook-item.active .notebook-icon-wrap {
  background: rgba(124, 58, 237, 0.15);
  border-color: rgba(124, 58, 237, 0.3);
  color: var(--purple-2);
}

/* Name + meta stacked */
.notebook-info {
  display: flex;
  flex-direction: column;
  gap: 2px;
  flex: 1;
  min-width: 0;
}

.notebook-name {
  font-size: 12.5px;
  font-weight: 500;
  color: var(--text-2);
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  line-height: 1.3;
  letter-spacing: 0.01em;
}
.notebook-item.active .notebook-name { color: var(--text); }

.notebook-meta {
  font-size: 10.5px;
  color: var(--text-3);
  line-height: 1;
  letter-spacing: 0.01em;
}
.notebook-item.active .notebook-meta { color: rgba(167, 139, 250, 0.75); }

.notebook-edit-input {
  background: var(--surface);
  border: 1px solid var(--purple-1);
  border-radius: 4px;
  color: var(--text);
  font-size: 12.5px;
  padding: 2px 6px;
  width: 100%;
  outline: none;
}

.notebook-actions {
  display: flex;
  align-items: center;
  gap: 1px;
  opacity: 0;
  transition: opacity var(--transition);
  flex-shrink: 0;
}

.notebook-arrow {
  color: var(--text-3);
  opacity: 0;
  transition: opacity var(--transition), transform var(--transition);
  flex-shrink: 0;
}

/* ===== NOTES LIST ===== */
.note-list {
  flex: 1;
  overflow-y: auto;
  padding: 0 6px 6px;
  display: flex;
  flex-direction: column;
  gap: 2px;
}

.note-item {
  display: flex;
  align-items: center;
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

.note-item-left {
  display: flex;
  align-items: flex-start;
  gap: 8px;
  flex: 1;
  min-width: 0;
  color: var(--text-3);
}
.note-item-left svg { flex-shrink: 0; margin-top: 2px; }

.note-item-info {
  display: flex;
  flex-direction: column;
  gap: 2px;
  min-width: 0;
}

.note-title {
  font-size: 13px; font-weight: 500;
  color: var(--text);
  overflow: hidden; text-overflow: ellipsis; white-space: nowrap;
}
.note-item.active .note-title { color: var(--purple-3); }
.note-date { font-size: 11px; color: var(--text-3); }

/* ===== TAGS SECTION ===== */
.tags-section { border-top: 1px solid var(--border-soft); }
.tag-chips {
  padding: 4px 8px 8px;
  display: flex;
  flex-direction: column;
  gap: 2px;
}
.empty-tags-hint { font-size: 11.5px; color: var(--text-3); padding: 4px 6px; }
.tag-chip-btn {
  display: flex;
  align-items: center;
  gap: 7px;
  padding: 5px 8px;
  border-radius: var(--radius-sm);
  background: none; border: none;
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
  overflow: hidden; text-overflow: ellipsis; white-space: nowrap;
}
.chip-count {
  font-size: 10px; color: var(--text-3);
  background: var(--surface);
  padding: 1px 5px;
  border-radius: 99px;
  flex-shrink: 0;
}

/* ===== UTILITIES ===== */
.btn-icon.tiny { padding: 3px; }
.btn-icon.tiny.favored { color: #fbbf24; background: rgba(251, 191, 36, 0.15); }
.btn-icon.danger:hover { color: var(--red); background: rgba(244,63,94,0.1); }

.loading-row {
  display: flex;
  justify-content: center;
  padding: 24px;
}

.empty-notebooks, .empty-notes {
  text-align: center;
  padding: 28px 12px;
  color: var(--text-3);
  font-size: 12.5px;
  display: flex;
  flex-direction: column;
  gap: 10px;
  align-items: center;
}

.collapsed-icons {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 10px 0;
  gap: 8px;
}

/* ===== FOOTER ===== */
.sidebar-footer {
  padding: 12px;
  border-top: 1px solid var(--border-soft);
  display: flex;
  align-items: center;
  gap: 8px;
  flex-shrink: 0;
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

/* ===== SLIDE TRANSITIONS ===== */
.slide-left-enter-active,
.slide-left-leave-active,
.slide-right-enter-active,
.slide-right-leave-active {
  transition: all 0.22s cubic-bezier(0.4, 0, 0.2, 1);
}

.slide-left-enter-from { transform: translateX(24px); opacity: 0; }
.slide-left-leave-to  { transform: translateX(-24px); opacity: 0; }

.slide-right-enter-from { transform: translateX(-24px); opacity: 0; }
.slide-right-leave-to  { transform: translateX(24px); opacity: 0; }
</style>
