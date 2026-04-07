import { defineStore } from 'pinia'
import api from '@/services/api'

export const useNotesStore = defineStore('notes', {
  state: () => ({
    notes: [],
    recentNotes: [],
    currentNote: null,
    loading: false,
    saving: false
  }),

  actions: {
    async fetchByNotebook(notebookId, query = '') {
      this.loading = true
      try {
        const params = query ? { q: query } : {}
        const res = await api.get(`/api/v1/notebooks/${notebookId}/notes`, { params })
        this.notes = res.data
      } finally {
        this.loading = false
      }
    },

    async fetchRecent() {
      try {
        const res = await api.get('/api/v1/notes/recent')
        this.recentNotes = res.data
      } catch (e) {
        this.recentNotes = []
      }
    },

    async fetchOne(noteId) {
      this.loading = true
      try {
        const res = await api.get(`/api/v1/notes/${noteId}`)
        this.currentNote = res.data
        return res.data
      } finally {
        this.loading = false
      }
    },

    async create(notebookId, title = 'Nova Nota') {
      const res = await api.post(`/api/v1/notebooks/${notebookId}/notes`, {
        note: { title, content: '' }
      })
      this.notes.unshift(res.data)
      this.currentNote = res.data
      return res.data
    },

    async save(noteId, data) {
      this.saving = true
      try {
        const res = await api.patch(`/api/v1/notes/${noteId}`, { note: data })
        this.currentNote = res.data
        const idx = this.notes.findIndex(n => n.id === noteId)
        if (idx !== -1) this.notes[idx] = { ...this.notes[idx], ...res.data }
        return res.data
      } finally {
        this.saving = false
      }
    },

    async remove(noteId) {
      await api.delete(`/api/v1/notes/${noteId}`)
      this.notes = this.notes.filter(n => n.id !== noteId)
      if (this.currentNote?.id === noteId) this.currentNote = null
    },

    async uploadImage(noteId, file) {
      const form = new FormData()
      form.append('image', file)
      const res = await api.post(`/api/v1/notes/${noteId}/upload_image`, form, {
        headers: { 'Content-Type': 'multipart/form-data' }
      })
      return res.data.url
    }
  }
})
