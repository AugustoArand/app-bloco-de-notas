<template>
  <div class="app-layout">
    <AppSidebar />
    <main class="app-main">
      <router-view v-slot="{ Component }">
        <transition name="fade" mode="out-in">
          <component :is="Component" />
        </transition>
      </router-view>
    </main>
  </div>
</template>

<script setup>
import { onMounted } from 'vue'
import AppSidebar from '@/components/AppSidebar.vue'
import { useNotebooksStore } from '@/stores/notebooks'

const notebooks = useNotebooksStore()
onMounted(() => notebooks.fetch())
</script>

<style scoped>
.app-layout {
  display: flex;
  height: 100vh;
  width: 100%;
  overflow: hidden;
}
.app-main {
  flex: 1;
  overflow: hidden;
  display: flex;
  flex-direction: column;
}
</style>
