<template>
  <!-- Overlay -->
  <Teleport to="body">
    <div class="modal-overlay" @click.self="$emit('close')">
      <div class="modal" role="dialog" aria-modal="true">
        <!-- Header -->
        <div class="modal-header">
          <h2 class="modal-title">
            <svg width="16" height="16" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
              <path d="M20.59 13.41l-7.17 7.17a2 2 0 0 1-2.83 0L2 12V2h10l8.59 8.59a2 2 0 0 1 0 2.82z"/>
              <line x1="7" y1="7" x2="7.01" y2="7"/>
            </svg>
            Gerenciar Tags
          </h2>
          <button class="btn-icon" @click="$emit('close')">
            <svg width="16" height="16" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
              <line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/>
            </svg>
          </button>
        </div>

        <!-- Create form -->
        <div class="create-form">
          <div class="form-row">
            <input
              id="tag-name-input"
              v-model="newName"
              type="text"
              class="tag-input"
              placeholder="Nome da tag..."
              @keyup.enter="createTag"
              maxlength="30"
            />
            <button id="btn-create-tag" class="btn btn-primary" @click="createTag" :disabled="!newName.trim()">
              Criar
            </button>
          </div>
          <div class="color-picker">
            <button
              v-for="c in COLORS"
              :key="c.key"
              class="color-btn"
              :class="{ active: selectedColor === c.key }"
              :style="{ '--c': c.dot }"
              :title="c.label"
              @click="selectedColor = c.key"
            ></button>
          </div>
          <p v-if="error" class="form-error">{{ error }}</p>
        </div>

        <!-- Tag list -->
        <div class="tag-list">
          <div v-if="tags.loading" class="loading-row">
            <div class="spinner"></div>
          </div>

          <div v-else-if="!tags.tags.length" class="empty-tags">
            <p>Nenhuma tag criada ainda.<br>Crie a primeira acima!</p>
          </div>

          <div
            v-for="tag in tags.tags"
            :key="tag.id"
            class="tag-row"
          >
            <template v-if="editingId !== tag.id">
              <TagBadge :tag="tag" />
              <span class="tag-count">{{ tag.notes_count }} nota{{ tag.notes_count === 1 ? '' : 's' }}</span>
              <div class="tag-actions">
                <button class="btn-icon tiny" @click="startEdit(tag)" title="Editar">
                  <svg width="12" height="12" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                    <path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/>
                    <path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/>
                  </svg>
                </button>
                <button class="btn-icon tiny danger" @click="removeTag(tag.id)" title="Excluir">
                  <svg width="12" height="12" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                    <polyline points="3,6 5,6 21,6"/><path d="M19,6l-1,14H6L5,6"/>
                    <path d="M10,11v6"/><path d="M14,11v6"/><path d="M9,6V4h6v2"/>
                  </svg>
                </button>
              </div>
            </template>

            <template v-else>
              <input
                v-model="editName"
                class="tag-input edit"
                @keyup.enter="saveEdit(tag.id)"
                @keyup.escape="editingId = null"
                ref="editInput"
              />
              <div class="color-picker small">
                <button
                  v-for="c in COLORS" :key="c.key"
                  class="color-btn"
                  :class="{ active: editColor === c.key }"
                  :style="{ '--c': c.dot }"
                  @click="editColor = c.key"
                ></button>
              </div>
              <button class="btn btn-primary tiny-btn" @click="saveEdit(tag.id)">✓</button>
              <button class="btn btn-ghost tiny-btn" @click="editingId = null">✕</button>
            </template>
          </div>
        </div>
      </div>
    </div>
  </Teleport>
</template>

<script setup>
import { ref, nextTick } from 'vue'
import { useTagsStore } from '@/stores/tags'
import TagBadge from '@/components/TagBadge.vue'

defineEmits(['close'])

const tags = useTagsStore()
const newName = ref('')
const selectedColor = ref('purple')
const editingId = ref(null)
const editName = ref('')
const editColor = ref('purple')
const editInput = ref(null)
const error = ref('')

const COLORS = [
  { key: 'purple', dot: '#8b5cf6', label: 'Roxo' },
  { key: 'blue',   dot: '#3b82f6', label: 'Azul' },
  { key: 'cyan',   dot: '#06b6d4', label: 'Ciano' },
  { key: 'teal',   dot: '#14b8a6', label: 'Teal' },
  { key: 'green',  dot: '#22c55e', label: 'Verde' },
  { key: 'lime',   dot: '#84cc16', label: 'Lima' },
  { key: 'amber',  dot: '#f59e0b', label: 'Âmbar' },
  { key: 'orange', dot: '#f97316', label: 'Laranja' },
  { key: 'rose',   dot: '#f43f5e', label: 'Rosa' },
  { key: 'pink',   dot: '#ec4899', label: 'Pink' },
  { key: 'indigo', dot: '#6366f1', label: 'Índigo' },
  { key: 'slate',  dot: '#64748b', label: 'Cinza' }
]

async function createTag() {
  if (!newName.value.trim()) return
  error.value = ''
  try {
    await tags.create(newName.value.trim(), selectedColor.value)
    newName.value = ''
  } catch (e) {
    error.value = e.response?.data?.errors?.[0] || 'Erro ao criar tag'
  }
}

function startEdit(tag) {
  editingId.value = tag.id
  editName.value = tag.name
  editColor.value = tag.color
  nextTick(() => editInput.value?.[0]?.focus())
}

async function saveEdit(id) {
  if (!editName.value.trim()) return
  await tags.update(id, { name: editName.value.trim(), color: editColor.value })
  editingId.value = null
}

async function removeTag(id) {
  if (!confirm('Excluir esta tag? Ela será removida de todas as notas.')) return
  await tags.remove(id)
}
</script>

<style scoped>
.modal-overlay {
  position: fixed;
  inset: 0;
  background: rgba(0,0,0,0.6);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
  backdrop-filter: blur(4px);
  animation: fadeIn 0.15s ease;
}
@keyframes fadeIn { from { opacity: 0 } to { opacity: 1 } }

.modal {
  background: var(--panel);
  border: 1px solid var(--border);
  border-radius: 16px;
  width: 460px;
  max-width: 95vw;
  max-height: 85vh;
  display: flex;
  flex-direction: column;
  overflow: hidden;
  animation: slideUp 0.2s ease;
  box-shadow: 0 20px 60px rgba(0,0,0,0.4);
}
@keyframes slideUp { from { transform: translateY(20px); opacity: 0 } to { transform: translateY(0); opacity: 1 } }

.modal-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 18px 20px;
  border-bottom: 1px solid var(--border-soft);
}
.modal-title {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 15px;
  font-weight: 600;
  margin: 0;
  color: var(--text);
}

.create-form {
  padding: 16px 20px;
  border-bottom: 1px solid var(--border-soft);
  display: flex;
  flex-direction: column;
  gap: 10px;
}
.form-row {
  display: flex;
  gap: 8px;
}
.tag-input {
  flex: 1;
  background: var(--surface);
  border: 1px solid var(--border);
  border-radius: var(--radius-sm);
  color: var(--text);
  font-size: 13px;
  padding: 8px 12px;
  outline: none;
  transition: border-color var(--transition);
}
.tag-input:focus { border-color: var(--purple-1); }
.tag-input::placeholder { color: var(--text-3); }
.tag-input.edit { flex: 1; }

.color-picker {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}
.color-picker.small { gap: 6px; }

.color-btn {
  width: 20px; height: 20px;
  border-radius: 50%;
  border: 2px solid transparent;
  background: var(--c);
  cursor: pointer;
  transition: transform 0.15s, border-color 0.15s;
  padding: 0;
}
.color-btn:hover { transform: scale(1.15); }
.color-btn.active {
  border-color: white;
  box-shadow: 0 0 0 2px var(--c);
  transform: scale(1.1);
}

.form-error { font-size: 12px; color: var(--red); margin: 0; }

.tag-list {
  overflow-y: auto;
  flex: 1;
  padding: 8px 12px;
}

.empty-tags {
  text-align: center;
  padding: 40px 20px;
  color: var(--text-3);
  font-size: 13px;
  line-height: 1.6;
}

.tag-row {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 8px;
  border-radius: var(--radius-sm);
  transition: background var(--transition);
}
.tag-row:hover { background: var(--surface); }

.tag-count {
  font-size: 11px;
  color: var(--text-3);
  margin-left: auto;
}

.tag-actions {
  display: flex;
  gap: 4px;
  opacity: 0;
  transition: opacity var(--transition);
}
.tag-row:hover .tag-actions { opacity: 1; }

.tiny-btn {
  padding: 4px 10px;
  font-size: 12px;
  min-width: unset;
}

.loading-row {
  display: flex;
  justify-content: center;
  padding: 24px;
}
</style>
