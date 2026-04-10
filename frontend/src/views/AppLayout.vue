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
    <QuickNotesSidebar />
  </div>
</template>

<script setup>
import { onMounted, watch } from 'vue'
import { useRouter } from 'vue-router'
import AppSidebar from '@/components/AppSidebar.vue'
import QuickNotesSidebar from '@/components/QuickNotesSidebar.vue'
import { useAuthStore } from '@/stores/auth'
import { useNotebooksStore } from '@/stores/notebooks'

const router = useRouter()
const auth = useAuthStore()
const notebooks = useNotebooksStore()

watch(
  () => auth.isLoggedIn,
  (isLoggedIn) => {
    if (!isLoggedIn) {
      router.replace('/login')
    }
  },
  { immediate: true }
)

onMounted(() => {
  if (auth.isLoggedIn) {
    auth.refreshProfile()
    notebooks.fetch()
  }
})
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
