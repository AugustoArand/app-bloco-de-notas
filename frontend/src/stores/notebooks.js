import { defineStore } from 'pinia'
import api from '@/services/api'

export const useNotebooksStore = defineStore('notebooks', {
  state: () => ({
    notebooks: [],
    loading: false,
    error: null
  }),

  actions: {
    async fetch() {
      this.loading = true
      try {
        const res = await api.get('/api/v1/notebooks')
        this.notebooks = res.data
      } catch (e) {
        this.error = 'Erro ao carregar cadernos.'
      } finally {
        this.loading = false
      }
    },

    async create(name) {
      const res = await api.post('/api/v1/notebooks', { notebook: { name } })
      this.notebooks = [res.data, ...this.notebooks]
      return res.data
    },

    async rename(id, name) {
      const res = await api.patch(`/api/v1/notebooks/${id}`, { notebook: { name } })
      const idx = this.notebooks.findIndex(n => n.id === id)
      if (idx !== -1) this.notebooks[idx] = res.data
      return res.data
    },

    async remove(id) {
      await api.delete(`/api/v1/notebooks/${id}`)
      this.notebooks = this.notebooks.filter(n => n.id !== id)
    },

    async toggleFavorite(id) {
      const nb = this.notebooks.find(n => n.id === id)
      if (!nb) return

      const res = await api.patch(`/api/v1/notebooks/${id}`, {
        notebook: { favorite: !nb.favorite }
      })

      this.notebooks = this.notebooks
        .map(n => (n.id === id ? res.data : n))
        .sort((a, b) => {
          if (a.favorite === b.favorite) {
            return new Date(b.updated_at) - new Date(a.updated_at)
          }
          return a.favorite ? -1 : 1
        })

      return res.data
    }
  }
})
