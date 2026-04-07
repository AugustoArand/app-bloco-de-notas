import { defineStore } from 'pinia'
import api from '@/services/api'

export const useTagsStore = defineStore('tags', {
  state: () => ({
    tags: [],
    loading: false
  }),

  actions: {
    async fetch() {
      this.loading = true
      try {
        const res = await api.get('/api/v1/tags')
        this.tags = res.data
      } finally {
        this.loading = false
      }
    },

    async create(name, color) {
      const res = await api.post('/api/v1/tags', { tag: { name, color } })
      this.tags.push(res.data)
      this.tags.sort((a, b) => a.name.localeCompare(b.name))
      return res.data
    },

    async update(id, data) {
      const res = await api.patch(`/api/v1/tags/${id}`, { tag: data })
      const idx = this.tags.findIndex(t => t.id === id)
      if (idx !== -1) this.tags[idx] = res.data
      return res.data
    },

    async remove(id) {
      await api.delete(`/api/v1/tags/${id}`)
      this.tags = this.tags.filter(t => t.id !== id)
    }
  }
})
