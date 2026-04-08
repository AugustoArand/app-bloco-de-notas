import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import { fileURLToPath, URL } from 'node:url'

const backendTarget = process.env.VITE_BACKEND_URL || 'http://localhost:8080'

export default defineConfig({
  plugins: [vue()],
  resolve: {
    alias: {
      '@': fileURLToPath(new URL('./src', import.meta.url))
    }
  },
  server: {
    port: 5173,
    proxy: {
      '/auth': {
        target: backendTarget,
        changeOrigin: true
      },
      '/api': {
        target: backendTarget,
        changeOrigin: true
      },
      '/rails': {
        target: backendTarget,
        changeOrigin: true
      }
    }
  }
})
