import { defineStore } from 'pinia'

function load() {
  try { return JSON.parse(localStorage.getItem('quick_notes') || '[]') } catch { return [] }
}

export const useQuickNotesStore = defineStore('quickNotes', {
  state: () => ({
    notes: load(),
    isOpen: false
  }),

  actions: {
    toggle() { this.isOpen = !this.isOpen },
    open()   { this.isOpen = true },
    close()  { this.isOpen = false },

    add() {
      const note = {
        id: Date.now(),
        title: '',
        text: '',
        color: 'default',
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString()
      }
      this.notes.unshift(note)
      this._persist()
      return note
    },

    update(id, data) {
      const idx = this.notes.findIndex(n => n.id === id)
      if (idx !== -1) {
        this.notes[idx] = { ...this.notes[idx], ...data, updatedAt: new Date().toISOString() }
        this._persist()
      }
    },

    remove(id) {
      this.notes = this.notes.filter(n => n.id !== id)
      this._persist()
    },

    _persist() {
      localStorage.setItem('quick_notes', JSON.stringify(this.notes))
    }
  }
})
