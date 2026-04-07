<template>
  <div class="note-card" @click="$emit('open', note)">
    <div class="card-header">
      <h3 class="card-title">{{ note.title || 'Sem título' }}</h3>
      <span class="card-time">{{ timeAgo(note.accessed_at || note.updated_at) }}</span>
    </div>

    <p v-if="note.excerpt" class="card-excerpt">{{ note.excerpt }}</p>

    <div class="card-footer">
      <div class="card-notebook">
        <svg width="11" height="11" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
          <path d="M2 3h6a4 4 0 0 1 4 4v14a3 3 0 0 0-3-3H2z"/><path d="M22 3h-6a4 4 0 0 0-4 4v14a3 3 0 0 1 3-3h7z"/>
        </svg>
        <span>{{ note.notebook_name }}</span>
      </div>

      <div class="card-tags" v-if="note.tags?.length">
        <TagBadge
          v-for="tag in note.tags.slice(0, 3)"
          :key="tag.id"
          :tag="tag"
        />
        <span v-if="note.tags.length > 3" class="tag-more">+{{ note.tags.length - 3 }}</span>
      </div>
    </div>
  </div>
</template>

<script setup>
import TagBadge from './TagBadge.vue'

defineProps({
  note: { type: Object, required: true }
})
defineEmits(['open'])

function timeAgo(dateStr) {
  if (!dateStr) return ''
  const diff = Date.now() - new Date(dateStr)
  const mins = Math.floor(diff / 60000)
  if (mins < 1) return 'agora'
  if (mins < 60) return `${mins}min atrás`
  const hours = Math.floor(mins / 60)
  if (hours < 24) return `${hours}h atrás`
  const days = Math.floor(hours / 24)
  if (days < 7) return `${days}d atrás`
  return new Date(dateStr).toLocaleDateString('pt-BR', { day: '2-digit', month: 'short' })
}
</script>

<style scoped>
.note-card {
  background: var(--surface);
  border: 1px solid var(--border-soft);
  border-radius: var(--radius-lg);
  padding: 18px 20px;
  cursor: pointer;
  display: flex;
  flex-direction: column;
  gap: 10px;
  transition: all var(--transition);
  min-height: 130px;
}
.note-card:hover {
  border-color: var(--purple-1);
  box-shadow: var(--shadow-purple);
  transform: translateY(-2px);
}
.card-header {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: 10px;
}
.card-title {
  font-size: 14px;
  font-weight: 600;
  color: var(--text);
  margin: 0;
  overflow: hidden;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  line-height: 1.4;
}
.card-time {
  font-size: 11px;
  color: var(--text-3);
  flex-shrink: 0;
  white-space: nowrap;
}
.card-excerpt {
  font-size: 12.5px;
  color: var(--text-2);
  line-height: 1.5;
  margin: 0;
  overflow: hidden;
  display: -webkit-box;
  -webkit-line-clamp: 3;
  -webkit-box-orient: vertical;
  flex: 1;
}
.card-footer {
  display: flex;
  flex-direction: column;
  gap: 8px;
  margin-top: auto;
}
.card-notebook {
  display: flex;
  align-items: center;
  gap: 5px;
  font-size: 11.5px;
  color: var(--text-3);
}
.card-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 4px;
  align-items: center;
}
.tag-more {
  font-size: 10px;
  color: var(--text-3);
  padding: 2px 6px;
  background: var(--surface);
  border-radius: 99px;
}
</style>
