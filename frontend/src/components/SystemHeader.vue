<template>
  <header class="system-header" :class="{ compact }">
    <router-link to="/" class="brand">Duck Notes</router-link>

    <nav class="system-nav">
      <router-link to="/about" class="nav-link">Sobre</router-link>
      <router-link to="/contact" class="nav-link">Contato</router-link>
    </nav>
  </header>
</template>

<script setup>
defineProps({
  compact: {
    type: Boolean,
    default: false
  }
})
</script>

<style scoped>
.system-header {
  width: 100%;
  height: 58px;
  border-bottom: 1px solid var(--border-soft);
  background: linear-gradient(90deg, rgba(124, 58, 237, 0.08), rgba(124, 58, 237, 0.03));
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 20px;
}

.system-header.compact {
  height: 52px;
  border-bottom: none;
  background: transparent;
  padding: 10px 0;
}

.brand {
  font-size: 15px;
  font-weight: 700;
  letter-spacing: 0.02em;
  color: var(--text);
}

.system-nav {
  display: inline-flex;
  gap: 8px;
}

.nav-link {
  font-size: 12.5px;
  color: var(--text-2);
  border: 1px solid var(--border);
  border-radius: 99px;
  padding: 5px 11px;
  transition: all var(--transition);
}

.nav-link:hover,
.nav-link.router-link-active {
  color: var(--text);
  border-color: var(--purple-1);
  background: var(--purple-dim);
}
</style>
