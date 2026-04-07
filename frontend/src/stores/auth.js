import { defineStore } from 'pinia'
import api from '@/services/api'

export const useAuthStore = defineStore('auth', {
  state: () => ({
    user: JSON.parse(localStorage.getItem('user') || 'null'),
    token: localStorage.getItem('token') || null,
    loading: false,
    error: null
  }),

  getters: {
    isLoggedIn: (state) => !!state.token && !!state.user
  },

  actions: {
    async login(email, password) {
      this.loading = true
      this.error = null
      try {
        const res = await api.post('/auth/sign_in', { user: { email, password } })
        const token = res.headers['authorization']?.replace('Bearer ', '')
        this.token = token
        this.user = res.data.user
        localStorage.setItem('token', token)
        localStorage.setItem('user', JSON.stringify(res.data.user))
        return true
      } catch (e) {
        this.error = e.response?.data?.error || 'Credenciais inválidas.'
        return false
      } finally {
        this.loading = false
      }
    },

    async register(name, email, password) {
      this.loading = true
      this.error = null
      try {
        await api.post('/auth/sign_up', { user: { name, email, password, password_confirmation: password } })
        return await this.login(email, password)
      } catch (e) {
        this.error = e.response?.data?.errors?.join(', ') || 'Erro ao criar conta.'
        return false
      } finally {
        this.loading = false
      }
    },

    async logout() {
      try {
        await api.delete('/auth/sign_out')
      } finally {
        this.token = null
        this.user = null
        localStorage.removeItem('token')
        localStorage.removeItem('user')
      }
    }
  }
})
