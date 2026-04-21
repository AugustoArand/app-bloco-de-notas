import { defineStore } from 'pinia'
import { ref } from 'vue'

export const useMentionsStore = defineStore('mentions', () => {
  // Each item: { label, from, to, count }
  const list = ref([])

  // Non-reactive function set by the editor component
  let _jumpFn = null

  function setList(items) {
    list.value = items
  }

  function registerJump(fn) {
    _jumpFn = fn
  }

  function jump(mention) {
    _jumpFn?.(mention)
  }

  function clear() {
    list.value = []
    _jumpFn = null
  }

  return { list, setList, registerJump, jump, clear }
})
