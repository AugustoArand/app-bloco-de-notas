<template>
  <div class="home-view">
    <!-- ── Cover Banner ── -->
    <div class="cover-banner" :style="coverStyle" @click="triggerCoverPick">
      <div class="cover-overlay">
        <svg width="18" height="22" fill="none" stroke="currentColor" stroke-width="1.8" viewBox="0 0 24 24">
          <path d="M23 19a2 2 0 0 1-2 2H3a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h4l2-3h6l2 3h4a2 2 0 0 1 2 2z"/>
          <circle cx="12" cy="13" r="4"/>
        </svg>
        <span>{{ coverImage ? 'Alterar capa' : 'Adicionar capa' }}</span>
        <button v-if="coverImage" class="cover-remove" @click.stop="removeCover" title="Remover capa">
          <svg width="13" height="13" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
            <line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/>
          </svg>
        </button>
      </div>
      <input
        ref="coverInput"
        type="file"
        accept="image/*"
        class="cover-file-input"
        @change="onCoverSelected"
      />
    </div>

    <!-- ── Header ── -->
    <div class="home-header">
      <div class="header-left">
        <p class="greeting-label">{{ greeting }}</p>
        <h1 class="user-name">{{ firstName }} <span class="wave">👋</span></h1>
        <p class="home-subtitle">O que vamos anotar hoje?</p>
      </div>
      <div class="header-right">
        <div class="stats-row">
          <div class="stat-pill">
            <span class="stat-icon purple">
              <svg width="13" height="13" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                <path d="M2 3h6a4 4 0 0 1 4 4v14a3 3 0 0 0-3-3H2z"/><path d="M22 3h-6a4 4 0 0 0-4 4v14a3 3 0 0 1 3-3h7z"/>
              </svg>
            </span>
            <span class="stat-value">{{ notebooks.notebooks.length }}</span>
            <span class="stat-label">cadernos</span>
          </div>
          <div class="stat-pill">
            <span class="stat-icon blue">
              <svg width="13" height="13" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                <path d="M14.5 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V7.5L14.5 2z"/>
                <polyline points="14,2 14,8 20,8"/>
              </svg>
            </span>
            <span class="stat-value">{{ totalNotes }}</span>
            <span class="stat-label">notas</span>
          </div>
          <div class="stat-pill">
            <span class="stat-icon amber">
              <svg width="13" height="13" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                <path d="M20.59 13.41l-7.17 7.17a2 2 0 0 1-2.83 0L2 12V2h10l8.59 8.59a2 2 0 0 1 0 2.82z"/>
                <line x1="7" y1="7" x2="7.01" y2="7"/>
              </svg>
            </span>
            <span class="stat-value">{{ tagsStore.tags.length }}</span>
            <span class="stat-label">tags</span>
          </div>
        </div>
      </div>
    </div>

    <!-- ── Recentes ── -->
    <section class="home-section">
      <div class="section-head">
        <div class="section-title-row">
          <span class="section-dot recent"></span>
          <h2 class="section-heading">Acessadas Recentemente</h2>
        </div>

        <!-- Tag filter -->
        <div class="tag-filter" v-if="tagsStore.tags.length">
          <button
            class="filter-chip"
            :class="{ active: !activeTagFilter }"
            @click="activeTagFilter = null"
          >Todas</button>
          <button
            v-for="tag in tagsStore.tags"
            :key="tag.id"
            class="filter-chip"
            :class="{ active: activeTagFilter === tag.id }"
            @click="activeTagFilter = activeTagFilter === tag.id ? null : tag.id"
          >
            <span class="chip-dot" :style="{ background: tagDotColor(tag.color) }"></span>
            {{ tag.name }}
          </button>
        </div>
      </div>

      <!-- Notes grid -->
      <div v-if="notesStore.recentNotes.length === 0 && !notesStore.loading" class="empty-recent">
        <div class="empty-icon">
          <svg width="48" height="48" fill="none" stroke="currentColor" stroke-width="1" viewBox="0 0 24 24">
            <path d="M12 2L2 7l10 5 10-5-10-5z"/>
            <path d="M2 17l10 5 10-5"/>
            <path d="M2 12l10 5 10-5"/>
          </svg>
        </div>
        <p class="empty-title">Nenhuma nota acessada ainda</p>
        <p class="empty-sub">Abra uma nota nos cadernos para ela aparecer aqui</p>
      </div>

      <div v-else class="notes-grid">
        <NoteCard
          v-for="note in filteredRecent"
          :key="note.id"
          :note="note"
          @open="openNote"
        />
        <div v-if="filteredRecent.length === 0 && activeTagFilter" class="empty-filter">
          <p>Nenhuma nota recente com essa tag</p>
        </div>
      </div>
    </section>

    <!-- ── Cadernos ── -->
    <section class="home-section" v-if="notebooks.notebooks.length > 0">
      <div class="section-head">
        <div class="section-title-row">
          <span class="section-dot notebooks"></span>
          <h2 class="section-heading">Seus Cadernos</h2>
        </div>
      </div>

      <div class="notebooks-grid">
        <div
          v-for="nb in notebooks.notebooks"
          :key="nb.id"
          class="nb-card"
          @click="openNotebook(nb)"
        >
          <button
            class="nb-favorite"
            :class="{ active: nb.favorite }"
            :title="nb.favorite ? 'Remover dos favoritos' : 'Favoritar caderno'"
            @click.stop="toggleFavorite(nb.id)"
          >
            <svg width="14" height="14" viewBox="0 0 24 24" fill="currentColor">
              <path d="M12 17.27L18.18 21l-1.64-7.03L22 9.24l-7.19-.61L12 2 9.19 8.63 2 9.24l5.46 4.73L5.82 21z"/>
            </svg>
          </button>
          <div class="nb-icon">
            <svg width="20" height="20" fill="none" stroke="currentColor" stroke-width="1.5" viewBox="0 0 24 24">
              <path d="M2 3h6a4 4 0 0 1 4 4v14a3 3 0 0 0-3-3H2z"/>
              <path d="M22 3h-6a4 4 0 0 0-4 4v14a3 3 0 0 1 3-3h7z"/>
            </svg>
          </div>
          <div class="nb-info">
            <h3 class="nb-name">{{ nb.name }}</h3>
            <p class="nb-count">{{ nb.notes_count }} {{ nb.notes_count === 1 ? 'nota' : 'notas' }}</p>
          </div>
          <div class="nb-date">{{ formatDate(nb.updated_at) }}</div>
          <div class="nb-arrow">
            <svg width="14" height="14" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
              <polyline points="9 18 15 12 9 6"/>
            </svg>
          </div>
        </div>
      </div>
    </section>

    <!-- ── Kanban Board ── -->
    <section class="home-section home-section--kanban">
      <HomeKanban />
    </section>

    <!-- ── Empty (zero cadernos) ── -->
    <div v-if="notebooks.notebooks.length === 0 && !notebooks.loading" class="empty-home">
      <div class="empty-illustration">
        <svg width="72" height="72" fill="none" stroke="currentColor" stroke-width="1" viewBox="0 0 24 24">
          <path d="M14.5 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V7.5L14.5 2z"/>
          <polyline points="14,2 14,8 20,8"/>
          <line x1="16" y1="13" x2="8" y2="13"/>
          <line x1="16" y1="17" x2="8" y2="17"/>
        </svg>
      </div>
      <h2 class="empty-title">Comece criando um caderno</h2>
      <p class="empty-sub">Organize suas ideias em cadernos temáticos</p>
    </div>

    <!-- TagManager modal -->
    <TagManager v-if="showTagManager" @close="showTagManager = false" />
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import { useNotebooksStore } from '@/stores/notebooks'
import { useNotesStore } from '@/stores/notes'
import { useTagsStore } from '@/stores/tags'
import NoteCard from '@/components/NoteCard.vue'
import TagManager from '@/components/TagManager.vue'
import HomeKanban from '@/components/HomeKanban.vue'

const router = useRouter()
const auth = useAuthStore()
const notebooks = useNotebooksStore()
const notesStore = useNotesStore()
const tagsStore = useTagsStore()

const activeTagFilter = ref(null)
const showTagManager = ref(false)

// ── Cover banner ──
const coverInput = ref(null)
const coverImage = ref(null)

const coverStyle = computed(() => {
  if (coverImage.value) {
    return { backgroundImage: `url(${coverImage.value})`, backgroundSize: 'cover', backgroundPosition: 'center' }
  }
  return { background: 'linear-gradient(135deg, #1a1208 0%, #2d1f0a 40%, #1c1410 70%, #100e08 100%)' }
})

function triggerCoverPick() {
  coverInput.value?.click()
}

function onCoverSelected(e) {
  const file = e.target.files?.[0]
  if (!file) return

  const preview = URL.createObjectURL(file)
  coverImage.value = preview

  auth.uploadCover(file)
    .then((url) => {
      coverImage.value = url
      URL.revokeObjectURL(preview)
    })
    .catch(() => {
      coverImage.value = auth.user?.cover_image_url || null
      URL.revokeObjectURL(preview)
    })

  e.target.value = ''
}

function removeCover() {
  auth.removeCover()
    .then(() => {
      coverImage.value = null
    })
    .catch(() => {
      // keep current cover when remove request fails
    })
}

async function toggleFavorite(notebookId) {
  await notebooks.toggleFavorite(notebookId)
}



const COLOR_DOTS = {
  purple: '#8b5cf6', blue: '#3b82f6', green: '#22c55e', amber: '#f59e0b',
  rose: '#f43f5e', cyan: '#06b6d4', orange: '#f97316', pink: '#ec4899',
  teal: '#14b8a6', indigo: '#6366f1', lime: '#84cc16', slate: '#64748b'
}

const greeting = computed(() => {
  const h = new Date().getHours()
  if (h < 12) return 'Bom dia,'
  if (h < 18) return 'Boa tarde,'
  return 'Boa noite,'
})

const firstName = computed(() => auth.user?.name?.split(' ')[0] || '')

const totalNotes = computed(() =>
  notebooks.notebooks.reduce((sum, nb) => sum + (nb.notes_count || 0), 0)
)

const filteredRecent = computed(() => {
  if (!activeTagFilter.value) return notesStore.recentNotes
  return notesStore.recentNotes.filter(n =>
    n.tags?.some(t => t.id === activeTagFilter.value)
  )
})

function tagDotColor(colorKey) {
  return COLOR_DOTS[colorKey] || COLOR_DOTS.purple
}

function openNote(note) {
  router.push(`/notes/${note.id}`)
}

function formatDate(dateStr) {
  if (!dateStr) return ''
  return new Date(dateStr).toLocaleDateString('pt-BR', { day: '2-digit', month: 'short' })
}

function openNotebook(nb) {
  // Navigate to the notebook — sidebar will highlight it
  // For now just push to home with a query param the sidebar can react to
  router.push({ query: { notebook: nb.id } })
}

onMounted(async () => {
  await auth.refreshProfile()

  await Promise.all([
    notesStore.fetchRecent(),
    tagsStore.fetch()
  ])

  coverImage.value = auth.user?.cover_image_url || null
})
</script>

<style scoped>
.home-view {
  padding: 0;
  overflow-y: auto;
  height: 100%;
  background: var(--bg);
  display: flex;
  flex-direction: column;
  gap: 0;
}

/* ── Cover Banner ── */
.cover-banner {
  position: relative;
  width: 100%;
  height: 180px;
  flex-shrink: 0;
  cursor: pointer;
  overflow: hidden;
  transition: filter 0.2s;
}
.cover-banner:hover .cover-overlay {
  opacity: 1;
}
.cover-overlay {
  position: absolute;
  inset: 0;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  background: rgba(0, 0, 0, 0.45);
  backdrop-filter: blur(2px);
  color: rgba(255, 255, 255, 0.9);
  font-size: 13px;
  font-weight: 500;
  opacity: 0;
  transition: opacity 0.2s;
  letter-spacing: 0.02em;
}
.cover-remove {
  position: absolute;
  top: 12px;
  right: 14px;
  background: rgba(0,0,0,0.55);
  border: 1px solid rgba(255,255,255,0.2);
  border-radius: 6px;
  color: white;
  padding: 4px 6px;
  cursor: pointer;
  display: flex;
  align-items: center;
  transition: background 0.15s;
}
.cover-remove:hover { background: rgba(220,38,38,0.7); }
.cover-file-input {
  display: none;
}

/* Padding wrapper for the rest of the content */
.home-view > *:not(.cover-banner) {
  padding-left: 56px;
  padding-right: 56px;
}
.home-view > .home-header { padding-top: 32px; }
.home-view > .home-section:first-of-type { padding-top: 44px; }
.home-view > .home-section { padding-bottom: 44px; }
.home-view > .home-section--kanban { padding-bottom: 56px; }
.home-view > .empty-home { padding-bottom: 60px; }

/* ── Header ── */
.home-header {
  display: flex;
  align-items: flex-end;
  justify-content: space-between;
  gap: 24px;
  flex-wrap: wrap;
}
.greeting-label {
  font-size: 13px;
  color: var(--text-2);
  margin: 0 0 2px;
  font-weight: 400;
}
.user-name {
  font-size: 32px;
  font-weight: 700;
  margin: 0 0 4px;
  color: var(--text);
  line-height: 1.2;
}
.wave { display: inline-block; animation: wave 2s ease-in-out infinite; transform-origin: 70% 70%; }
@keyframes wave {
  0%, 60%, 100% { transform: rotate(0deg) }
  10%, 30% { transform: rotate(14deg) }
  20% { transform: rotate(-8deg) }
  40% { transform: rotate(14deg) }
  50% { transform: rotate(10deg) }
}
.home-subtitle { font-size: 13.5px; color: var(--text-2); margin: 0; }

.stats-row {
  display: flex;
  gap: 10px;
  flex-wrap: wrap;
}
.stat-pill {
  display: flex;
  align-items: center;
  gap: 7px;
  background: var(--surface);
  border: 1px solid var(--border-soft);
  border-radius: 99px;
  padding: 8px 14px;
  transition: border-color var(--transition);
}
.stat-pill:hover { border-color: var(--border); }
.stat-icon {
  width: 22px; height: 22px;
  border-radius: 50%;
  display: flex; align-items: center; justify-content: center;
  flex-shrink: 0;
}
.stat-icon.purple { background: var(--purple-dim); color: var(--purple-2); }
.stat-icon.blue  { background: rgba(45,212,191,0.12); color: #2dd4bf; }
.stat-icon.amber { background: rgba(251,146,60,0.12); color: #fb923c; }
.stat-value { font-size: 15px; font-weight: 700; color: var(--text); }
.stat-label { font-size: 12px; color: var(--text-3); }

/* ── Sections ── */
.home-section { display: flex; flex-direction: column; gap: 18px; }

.section-head {
  display: flex;
  align-items: center;
  justify-content: space-between;
  flex-wrap: wrap;
  gap: 12px;
}
.section-title-row {
  display: flex;
  align-items: center;
  gap: 8px;
}
.section-dot {
  width: 8px; height: 8px;
  border-radius: 50%;
  flex-shrink: 0;
}
.section-dot.recent   { background: var(--purple-2); box-shadow: 0 0 8px rgba(217,119,6,0.5); }
.section-dot.notebooks { background: #2dd4bf; box-shadow: 0 0 8px rgba(45,212,191,0.4); }
.section-heading {
  font-size: 13px;
  font-weight: 700;
  color: var(--text-2);
  text-transform: uppercase;
  letter-spacing: 0.07em;
  margin: 0;
}

/* ── Tag filter ── */
.tag-filter {
  display: flex;
  align-items: center;
  gap: 6px;
  flex-wrap: wrap;
}
.filter-chip {
  display: inline-flex;
  align-items: center;
  gap: 5px;
  padding: 4px 12px;
  border-radius: 99px;
  font-size: 12px;
  font-weight: 500;
  background: var(--surface);
  border: 1px solid var(--border-soft);
  color: var(--text-2);
  cursor: pointer;
  transition: all var(--transition);
}
.filter-chip:hover { border-color: var(--purple-1); color: var(--text); }
.filter-chip.active {
  background: var(--purple-dim);
  border-color: var(--purple-1);
  color: var(--purple-3);
}
.chip-dot {
  width: 6px; height: 6px;
  border-radius: 50%;
  flex-shrink: 0;
}

/* ── Notes grid ── */
.notes-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(220px, 1fr));
  gap: 14px;
}

/* ── Notebooks grid ── */
.notebooks-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(240px, 1fr));
  gap: 12px;
}
.nb-card {
  background: var(--surface);
  border: 1px solid var(--border-soft);
  border-radius: var(--radius-lg);
  padding: 16px 18px;
  cursor: pointer;
  transition: all var(--transition);
  display: flex;
  align-items: center;
  gap: 12px;
  position: relative;
}
.nb-card:hover {
  border-color: rgba(217,119,6,0.4);
  box-shadow: 0 0 0 3px rgba(217,119,6,0.08);
  transform: translateY(-1px);
}
.nb-icon {
  width: 36px; height: 36px;
  background: rgba(217,119,6,0.1);
  border-radius: var(--radius);
  display: flex; align-items: center; justify-content: center;
  color: var(--purple-2);
  flex-shrink: 0;
}
.nb-info { flex: 1; min-width: 0; }
.nb-name { font-size: 13.5px; font-weight: 600; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; margin: 0 0 2px; }
.nb-count { font-size: 11.5px; color: var(--text-3); margin: 0; }
.nb-date { font-size: 11px; color: var(--text-3); flex-shrink: 0; }
.nb-arrow { color: var(--text-3); flex-shrink: 0; opacity: 0; transition: opacity var(--transition), transform var(--transition); }
.nb-card:hover .nb-arrow { opacity: 1; transform: translateX(2px); }

.nb-favorite {
  position: absolute;
  right: 8px;
  top: 8px;
  width: 24px;
  height: 24px;
  border: none;
  border-radius: 999px;
  background: rgba(255, 255, 255, 0.02);
  color: var(--text-3);
  display: inline-flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: all var(--transition);
}

.nb-favorite:hover {
  color: #fbbf24;
  background: rgba(251, 191, 36, 0.1);
}

.nb-favorite.active {
  color: #fbbf24;
  background: rgba(251, 191, 36, 0.16);
}

/* ── Empty states ── */
.empty-recent, .empty-home {
  text-align: center;
  padding: 48px 20px;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 12px;
}
.empty-icon { color: var(--border); animation: pulse 3s ease-in-out infinite; }
@keyframes pulse { 0%,100%{opacity:0.3} 50%{opacity:0.7} }
.empty-title { font-size: 16px; font-weight: 600; color: var(--text-2); margin: 0; }
.empty-sub { font-size: 13px; color: var(--text-3); margin: 0; }

.empty-filter {
  grid-column: 1 / -1;
  text-align: center;
  padding: 32px;
  color: var(--text-3);
  font-size: 13px;
}
</style>
