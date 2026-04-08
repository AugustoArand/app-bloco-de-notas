<template>
  <div class="auth-page">
    <div class="auth-topbar">
      <SystemHeader compact />
    </div>

    <div class="orb orb-1"></div>
    <div class="orb orb-2"></div>
    <div class="grid-lines"></div>

    <div class="floating-card card-a"><span class="dot"></span>Cadernos inteligentes</div>
    <div class="floating-card card-b"><span class="dot"></span>Exporte suas notas em PDF</div>

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
        <span class="logo-text">Duck Notes</span>
      </div>

      <h1 class="auth-title">Bem-vindo de volta</h1>
      <p class="auth-subtitle">Entre na sua conta para acessar suas notas</p>

      <form class="auth-form" @submit.prevent="handleLogin">
        <div class="field">
          <label class="field-label">E-mail</label>
          <input
            id="login-email"
            v-model="email"
            type="email"
            class="input"
            placeholder="seu@email.com"
            required
            autocomplete="email"
          />
        </div>

        <div class="field">
          <label class="field-label">Senha</label>
          <div class="input-wrap">
            <input
              id="login-password"
              v-model="password"
              :type="showPass ? 'text' : 'password'"
              class="input"
              placeholder="••••••••"
              required
              autocomplete="current-password"
            />
            <button type="button" class="btn-icon eye-btn" @click="showPass = !showPass">
              <svg v-if="!showPass" width="16" height="16" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>
              <svg v-else width="16" height="16" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24"/><line x1="1" y1="1" x2="23" y2="23"/></svg>
            </button>
          </div>
        </div>

        <p v-if="auth.error" class="error-msg">{{ auth.error }}</p>

        <button id="btn-login" type="submit" class="btn btn-primary full" :disabled="auth.loading">
          <span v-if="auth.loading" class="spinner"></span>
          <span v-else>Entrar</span>
        </button>
      </form>

      <p class="auth-switch">
        Nao tem conta?
        <router-link to="/register">Criar conta</router-link>
      </p>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import SystemHeader from '@/components/SystemHeader.vue'

const auth = useAuthStore()
const router = useRouter()
const email = ref('')
const password = ref('')
const showPass = ref(false)

async function handleLogin() {
  const ok = await auth.login(email.value, password.value)
  if (ok) router.push('/')
}
</script>

<style scoped>
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

.auth-topbar {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  z-index: 5;
  padding: 0 20px;
}

.grid-lines {
  position: absolute;
  inset: 0;
  background-image:
    linear-gradient(rgba(255, 255, 255, 0.02) 1px, transparent 1px),
    linear-gradient(90deg, rgba(255, 255, 255, 0.02) 1px, transparent 1px);
  background-size: 42px 42px;
  mask-image: radial-gradient(circle at center, black 48%, transparent 100%);
}

.orb {
  position: absolute;
  border-radius: 50%;
  filter: blur(80px);
  pointer-events: none;
}

.orb-1 {
  width: 400px;
  height: 400px;
  background: radial-gradient(circle, rgba(124, 58, 237, 0.25) 0%, transparent 70%);
  top: -100px;
  left: -100px;
  animation: float 8s ease-in-out infinite;
}

.orb-2 {
  width: 350px;
  height: 350px;
  background: radial-gradient(circle, rgba(159, 103, 255, 0.15) 0%, transparent 70%);
  bottom: -80px;
  right: -80px;
  animation: float 10s ease-in-out infinite reverse;
}

@keyframes float {
  0%, 100% { transform: translateY(0); }
  50% { transform: translateY(-30px); }
}

.floating-card {
  position: absolute;
  z-index: 2;
  border: 1px solid var(--border);
  background: rgba(23, 23, 42, 0.75);
  backdrop-filter: blur(8px);
  color: var(--text-2);
  padding: 10px 14px;
  border-radius: 999px;
  font-size: 12px;
  letter-spacing: 0.02em;
  animation: drift 7s ease-in-out infinite;
}

.dot {
  width: 7px;
  height: 7px;
  background: var(--purple-2);
  border-radius: 50%;
  display: inline-block;
  margin-right: 8px;
  box-shadow: 0 0 10px var(--purple-glow);
}

.card-a {
  top: 24%;
  left: 8%;
}

.card-b {
  bottom: 20%;
  right: 8%;
  animation-delay: -2s;
}

@keyframes drift {
  0%, 100% { transform: translateY(0px); }
  50% { transform: translateY(-12px); }
}

.auth-card {
  background: var(--surface);
  border: 1px solid var(--border);
  border-radius: var(--radius-xl);
  padding: 40px;
  width: 100%;
  max-width: 420px;
  position: relative;
  z-index: 3;
  box-shadow: var(--shadow-lg), 0 0 60px rgba(124, 58, 237, 0.08);
}

.auth-logo {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-bottom: 28px;
}

.logo-icon {
  width: 44px;
  height: 44px;
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
  background-clip: text;
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
}

.auth-title {
  font-size: 22px;
  font-weight: 700;
  margin-bottom: 6px;
}

.auth-subtitle {
  color: var(--text-2);
  font-size: 13.5px;
  margin-bottom: 28px;
}

.auth-form {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.field {
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.field-label {
  font-size: 13px;
  font-weight: 500;
  color: var(--text-2);
}

.input-wrap {
  position: relative;
}

.input-wrap .input {
  padding-right: 42px;
}

.eye-btn {
  position: absolute;
  right: 10px;
  top: 50%;
  transform: translateY(-50%);
  padding: 4px;
}

.error-msg {
  color: var(--red);
  font-size: 13px;
  background: rgba(244, 63, 94, 0.08);
  padding: 10px 12px;
  border-radius: var(--radius-sm);
  border: 1px solid rgba(244, 63, 94, 0.2);
}

.full {
  width: 100%;
  justify-content: center;
  padding: 12px;
  font-size: 14.5px;
}

.auth-switch {
  text-align: center;
  margin-top: 20px;
  font-size: 13.5px;
  color: var(--text-2);
}

.auth-switch a {
  color: var(--purple-2);
  font-weight: 500;
}

.auth-switch a:hover {
  color: var(--purple-3);
}

@media (max-width: 900px) {
  .floating-card {
    display: none;
  }

  .auth-card {
    margin-top: 42px;
  }
}
</style>
