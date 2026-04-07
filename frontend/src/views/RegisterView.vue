<template>
  <div class="auth-page">
    <div class="orb orb-1"></div>
    <div class="orb orb-2"></div>

    <div class="auth-card">
      <div class="auth-logo">
        <div class="logo-icon">
          <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M14.5 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V7.5L14.5 2z"/>
            <polyline points="14,2 14,8 20,8"/>
            <line x1="16" y1="13" x2="8" y2="13"/>
            <line x1="16" y1="17" x2="8" y2="17"/>
            <line x1="10" y1="9" x2="8" y2="9"/>
          </svg>
        </div>
        <span class="logo-text">NoteVault</span>
      </div>

      <h1 class="auth-title">Criar conta</h1>
      <p class="auth-subtitle">Comece a organizar suas ideias agora</p>

      <form class="auth-form" @submit.prevent="handleRegister">
        <div class="field">
          <label class="field-label">Seu nome</label>
          <input id="reg-name" v-model="name" type="text" class="input" placeholder="Como quer ser chamado?" required />
        </div>
        <div class="field">
          <label class="field-label">E-mail</label>
          <input id="reg-email" v-model="email" type="email" class="input" placeholder="seu@email.com" required />
        </div>
        <div class="field">
          <label class="field-label">Senha</label>
          <input id="reg-password" v-model="password" type="password" class="input" placeholder="Mínimo 6 caracteres" required />
        </div>

        <p v-if="auth.error" class="error-msg">{{ auth.error }}</p>

        <button id="btn-register" type="submit" class="btn btn-primary full" :disabled="auth.loading">
          <span v-if="auth.loading" class="spinner"></span>
          <span v-else>Criar conta</span>
        </button>
      </form>

      <p class="auth-switch">
        Já tem conta?
        <router-link to="/login">Entrar</router-link>
      </p>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

const auth = useAuthStore()
const router = useRouter()
const name = ref('')
const email = ref('')
const password = ref('')

async function handleRegister() {
  const ok = await auth.register(name.value, email.value, password.value)
  if (ok) router.push('/')
}
</script>

<style scoped>
/* reuse auth-page styles from LoginView */
.auth-page {
  min-height: 100vh;
  width: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  background: var(--bg);
  position: relative;
  overflow: hidden;
}
.orb {
  position: absolute;
  border-radius: 50%;
  filter: blur(80px);
  pointer-events: none;
}
.orb-1 {
  width: 400px; height: 400px;
  background: radial-gradient(circle, rgba(124,58,237,0.25) 0%, transparent 70%);
  bottom: -100px; right: -100px;
  animation: float 8s ease-in-out infinite;
}
.orb-2 {
  width: 300px; height: 300px;
  background: radial-gradient(circle, rgba(159,103,255,0.15) 0%, transparent 70%);
  top: -80px; left: -80px;
  animation: float 12s ease-in-out infinite reverse;
}
@keyframes float {
  0%, 100% { transform: translateY(0); }
  50% { transform: translateY(-30px); }
}
.auth-card {
  background: var(--surface);
  border: 1px solid var(--border);
  border-radius: var(--radius-xl);
  padding: 40px;
  width: 100%;
  max-width: 420px;
  position: relative;
  z-index: 1;
  box-shadow: var(--shadow-lg), 0 0 60px rgba(124,58,237,0.08);
}
.auth-logo {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-bottom: 28px;
}
.logo-icon {
  width: 44px; height: 44px;
  background: linear-gradient(135deg, var(--purple-1), var(--purple-2));
  border-radius: var(--radius);
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  box-shadow: 0 4px 16px var(--purple-glow);
}
.logo-text {
  font-size: 20px;
  font-weight: 700;
  background: linear-gradient(to right, var(--purple-2), var(--purple-3));
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
}
.auth-title { font-size: 22px; font-weight: 700; margin-bottom: 6px; }
.auth-subtitle { color: var(--text-2); font-size: 13.5px; margin-bottom: 28px; }
.auth-form { display: flex; flex-direction: column; gap: 16px; }
.field { display: flex; flex-direction: column; gap: 6px; }
.field-label { font-size: 13px; font-weight: 500; color: var(--text-2); }
.error-msg {
  color: var(--red); font-size: 13px;
  background: rgba(244,63,94,0.08); padding: 10px 12px;
  border-radius: var(--radius-sm); border: 1px solid rgba(244,63,94,0.2);
}
.full { width: 100%; justify-content: center; padding: 12px; font-size: 14.5px; }
.auth-switch { text-align: center; margin-top: 20px; font-size: 13.5px; color: var(--text-2); }
.auth-switch a { color: var(--purple-2); font-weight: 500; }
</style>
