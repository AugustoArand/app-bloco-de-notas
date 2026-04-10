import { defineStore } from 'pinia'
import api from '@/services/api'

export const useQuickNotesStore = defineStore('quickNotes', {
  state: () => ({
    notes: [],
    loading: false,
    isOpen: false
  }),

  actions: {
    toggle() { this.isOpen = !this.isOpen },
    open()   { this.isOpen = true },
    close()  { this.isOpen = false },

    async fetch() {
      this.loading = true
      try {
        const { data } = await api.get('/api/v1/quick_notes')
        this.notes = data
      } finally {
        this.loading = false
      }
    },

    async add() {
      const { data } = await api.post('/api/v1/quick_notes', {
        quick_note: { title: '', text: '', color: 'default', position: 0 }
      })
      this.notes.unshift(data)
      return data
    },

    async update(id, fields) {
      const { data } = await api.patch(`/api/v1/quick_notes/${id}`, {
        quick_note: fields
      })
      const idx = this.notes.findIndex(n => n.id === id)
      if (idx !== -1) this.notes[idx] = data
      return data
    },

    async remove(id) {
      await api.delete(`/api/v1/quick_notes/${id}`)
      this.notes = this.notes.filter(n => n.id !== id)
    }
  }
})
