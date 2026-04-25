<template>
  <Teleport to="body">
    <!-- Floating trigger button -->
    <div class="sh-wrap" :class="{ 'sh-wrap--open': open }">
      <!-- Panel -->
      <Transition name="sh-panel">
        <div v-if="open" class="sh-panel" role="dialog" aria-label="Atalhos do editor">
          <header class="sh-panel-header">
            <div class="sh-panel-icon">
              <svg width="15" height="15" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                <rect x="2" y="6" width="20" height="13" rx="2"/>
                <path d="M6 10h.01M10 10h.01M14 10h.01M18 10h.01M8 14h.01M12 14h.01M16 14h.01M6 14h.01"/>
              </svg>
            </div>
            <div>
              <h3 class="sh-panel-title">Atalhos do Sistema</h3>
              <p class="sh-panel-sub">Guia de referência rápida</p>
            </div>
            <button class="sh-close-btn" @click="open = false" title="Fechar">
              <svg width="13" height="13" fill="none" stroke="currentColor" stroke-width="2.5" viewBox="0 0 24 24">
                <line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/>
              </svg>
            </button>
          </header>

          <!-- Tab nav -->
          <div class="sh-tabs">
            <button
              v-for="tab in tabs"
              :key="tab.id"
              class="sh-tab"
              :class="{ 'sh-tab--active': activeTab === tab.id }"
              @click="activeTab = tab.id"
            >
              <span v-html="tab.icon" class="sh-tab-icon"></span>
              {{ tab.label }}
            </button>
          </div>

          <!-- Content -->
          <div class="sh-content">
            <template v-for="tab in tabs" :key="tab.id">
              <div v-if="activeTab === tab.id" class="sh-section-list">
                <div
                  v-for="section in tab.sections"
                  :key="section.title"
                  class="sh-section"
                >
                  <p class="sh-section-title">{{ section.title }}</p>
                  <div class="sh-rows">
                    <div
                      v-for="item in section.items"
                      :key="item.label"
                      class="sh-row"
                    >
                      <span class="sh-label">{{ item.label }}</span>
                      <div class="sh-keys">
                        <template v-for="(part, i) in item.keys" :key="i">
                          <kbd v-if="part !== '+' && part !== '/' && part !== '→'" class="sh-kbd">{{ part }}</kbd>
                          <span v-else class="sh-sep">{{ part }}</span>
                        </template>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </template>
          </div>

          <!-- Footer tip -->
          <footer class="sh-panel-footer">
            <svg width="11" height="11" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
              <circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/>
            </svg>
            Pressione <kbd class="sh-kbd sh-kbd--inline">?</kbd> para abrir / fechar
          </footer>
        </div>
      </Transition>

      <!-- FAB button -->
      <button
        class="sh-fab"
        :class="{ 'sh-fab--active': open }"
        @click="open = !open"
        :title="open ? 'Fechar atalhos' : 'Ver atalhos do sistema'"
        aria-label="Atalhos do sistema"
      >
        <Transition name="sh-icon" mode="out-in">
          <svg v-if="!open" key="kbd" width="18" height="18" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
            <rect x="2" y="6" width="20" height="13" rx="2"/>
            <path d="M6 10h.01M10 10h.01M14 10h.01M18 10h.01M8 14h.01M12 14h.01M16 14h.01M6 14h.01"/>
          </svg>
          <svg v-else key="x" width="16" height="16" fill="none" stroke="currentColor" stroke-width="2.5" viewBox="0 0 24 24">
            <line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/>
          </svg>
        </Transition>
        <span class="sh-fab-label">?</span>
      </button>
    </div>
  </Teleport>
</template>

<script setup>
import { ref, onMounted, onBeforeUnmount } from 'vue'

const open = ref(false)
const activeTab = ref('editor')

const tabs = [
  {
    id: 'editor',
    label: 'Editor',
    icon: '<svg width="12" height="12" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>',
    sections: [
      {
        title: 'Formatação de texto',
        items: [
          { label: 'Negrito', keys: ['Ctrl', '+', 'B'] },
          { label: 'Itálico', keys: ['Ctrl', '+', 'I'] },
          { label: 'Sublinhado', keys: ['Ctrl', '+', 'U'] },
          { label: 'Tachado', keys: ['Ctrl', '+', 'Shift', '+', 'S'] },
          { label: 'Destaque (highlight)', keys: ['Ctrl', '+', 'Shift', '+', 'H'] },
          { label: 'Código inline', keys: ['Ctrl', '+', 'E'] },
        ]
      },
      {
        title: 'Títulos — digite no início da linha',
        items: [
          { label: 'Título H1', keys: ['#', '+', 'Espaço'] },
          { label: 'Título H2', keys: ['##', '+', 'Espaço'] },
          { label: 'Título H3', keys: ['###', '+', 'Espaço'] },
          { label: 'Citação (blockquote)', keys: ['>', '+', 'Espaço'] },
          { label: 'Divisor horizontal', keys: ['---', '+', 'Enter'] },
          { label: 'Bloco de código', keys: ['```', '+', 'Enter'] },
        ]
      },
      {
        title: 'Listas',
        items: [
          { label: 'Lista com marcadores', keys: ['-', '+', 'Espaço'] },
          { label: 'Lista ordenada', keys: ['1.', '+', 'Espaço'] },
          { label: 'Lista de tarefas (checkbox)', keys: ['[ ]', '+', 'Espaço'] },
          { label: 'Indentar item', keys: ['Tab'] },
          { label: 'Desindenter item', keys: ['Shift', '+', 'Tab'] },
        ]
      },
      {
        title: 'Alinhamento',
        items: [
          { label: 'Esquerda', keys: ['Ctrl', '+', 'Shift', '+', 'L'] },
          { label: 'Centralizado', keys: ['Ctrl', '+', 'Shift', '+', 'E'] },
          { label: 'Direita', keys: ['Ctrl', '+', 'Shift', '+', 'R'] },
          { label: 'Justificado', keys: ['Ctrl', '+', 'Shift', '+', 'J'] },
        ]
      },
      {
        title: 'Edição geral',
        items: [
          { label: 'Desfazer', keys: ['Ctrl', '+', 'Z'] },
          { label: 'Refazer', keys: ['Ctrl', '+', 'Shift', '+', 'Z'] },
          { label: 'Selecionar tudo', keys: ['Ctrl', '+', 'A'] },
        ]
      },
    ]
  },
  {
    id: 'triggers',
    label: 'Gatilhos',
    icon: '<svg width="12" height="12" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><polygon points="13 2 3 14 12 14 11 22 21 10 12 10 13 2"/></svg>',
    sections: [
      {
        title: 'Menções',
        items: [
          { label: 'Menção simples', keys: ['@', '+', 'palavra', '+', 'Espaço'] },
          { label: 'Menção composta', keys: ['@[', '+', 'texto', '+', ']'] },
        ]
      },
      {
        title: 'Tipografia automática',
        items: [
          { label: 'Seta para direita (→)', keys: ['-', '+', '>'] },
        ]
      },
      {
        title: 'Bloco especial',
        items: [
          { label: 'Envolver em nuvem', keys: ['Ctrl', '+', 'Shift', '+', 'C'] },
        ]
      },
    ]
  },
  {
    id: 'nav',
    label: 'Interface',
    icon: '<svg width="12" height="12" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/></svg>',
    sections: [
      {
        title: 'Nota',
        items: [
          { label: 'Salvar (automático)', keys: ['1.2s', 'após digitação'] },
          { label: 'Exportar PDF', keys: ['Toolbar', '→', 'PDF'] },
          { label: 'Excluir nota', keys: ['Toolbar', '→', '🗑'] },
          { label: 'Adicionar tag', keys: ['+', 'Tag'] },
        ]
      },
      {
        title: 'Modo de visualização',
        items: [
          { label: 'Modo texto (editor)', keys: ['Clique', 'Texto'] },
          { label: 'Modo quadro (mindmap)', keys: ['Clique', 'Quadro'] },
          { label: 'Novo quadro (mindmap)', keys: ['+', 'Quadro'] },
          { label: 'Renomear quadro', keys: ['Duplo clique', 'na aba'] },
        ]
      },
      {
        title: 'Assistente IA',
        items: [
          { label: 'Abrir painel IA', keys: ['Clique', 'Assistente IA'] },
          { label: 'Resumo em tópicos', keys: ['Resumo'] },
          { label: 'Traduzir nota', keys: ['Traduzir texto'] },
          { label: 'Glossário técnico', keys: ['Glossário'] },
          { label: 'Gerar texto livre', keys: ['Descreva', '→', 'Enviar'] },
        ]
      },
      {
        title: 'Painel de atalhos',
        items: [
          { label: 'Abrir / fechar atalhos', keys: ['?'] },
          { label: 'Fechar painel', keys: ['Esc'] },
        ]
      },
    ]
  }
]

// Global keyboard shortcut: ? opens the panel
function handleKeydown(e) {
  if (
    e.key === '?' &&
    !['INPUT', 'TEXTAREA'].includes(document.activeElement?.tagName) &&
    !document.activeElement?.isContentEditable
  ) {
    e.preventDefault()
    open.value = !open.value
  }
  if (e.key === 'Escape' && open.value) {
    open.value = false
  }
}

onMounted(() => document.addEventListener('keydown', handleKeydown))
onBeforeUnmount(() => document.removeEventListener('keydown', handleKeydown))
</script>

<style scoped>
/* ── Wrapper ── */
.sh-wrap {
  position: fixed;
  bottom: 28px;
  right: 28px;
  z-index: 9000;
  display: flex;
  flex-direction: column;
  align-items: flex-end;
  gap: 10px;
  pointer-events: none;
}
.sh-wrap > * { pointer-events: auto; }

/* ── FAB button ── */
.sh-fab {
  width: 46px;
  height: 46px;
  border-radius: 14px;
  border: none;
  background: linear-gradient(135deg, #6366f1 0%, #a78bfa 100%);
  color: white;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 0;
  cursor: pointer;
  box-shadow:
    0 4px 20px rgba(99, 102, 241, 0.45),
    0 1px 4px rgba(0,0,0,0.25),
    inset 0 1px 0 rgba(255,255,255,0.15);
  transition: all 0.22s cubic-bezier(0.34, 1.56, 0.64, 1);
  position: relative;
  flex-shrink: 0;
  overflow: hidden;
}
.sh-fab::after {
  content: '';
  position: absolute;
  inset: 0;
  border-radius: inherit;
  background: linear-gradient(180deg, rgba(255,255,255,0.12) 0%, transparent 60%);
  pointer-events: none;
}
.sh-fab:hover {
  transform: translateY(-3px) scale(1.06);
  box-shadow:
    0 8px 28px rgba(99, 102, 241, 0.6),
    0 2px 6px rgba(0,0,0,0.25),
    inset 0 1px 0 rgba(255,255,255,0.15);
}
.sh-fab--active {
  background: linear-gradient(135deg, #4f46e5 0%, #7c3aed 100%);
  transform: scale(0.95);
  box-shadow: 0 2px 12px rgba(99, 102, 241, 0.4);
}

.sh-fab-label {
  font-size: 11px;
  font-weight: 700;
  opacity: 0.8;
  line-height: 1;
  font-family: 'SF Mono', 'Fira Mono', monospace;
  margin-top: -2px;
}

/* ── Icon transition ── */
.sh-icon-enter-active,
.sh-icon-leave-active { transition: all 0.15s ease; }
.sh-icon-enter-from { opacity: 0; transform: rotate(-90deg) scale(0.6); }
.sh-icon-leave-to { opacity: 0; transform: rotate(90deg) scale(0.6); }

/* ── Panel ── */
.sh-panel {
  width: 368px;
  max-height: min(75vh, 580px);
  background: var(--panel, #12121f);
  border: 1px solid rgba(255,255,255,0.07);
  border-radius: 18px;
  box-shadow:
    0 32px 80px rgba(0,0,0,0.6),
    0 8px 24px rgba(0,0,0,0.3),
    inset 0 1px 0 rgba(255,255,255,0.05);
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

/* ── Panel transition ── */
.sh-panel-enter-active { animation: sh-panel-in 0.3s cubic-bezier(0.34, 1.56, 0.64, 1); }
.sh-panel-leave-active { animation: sh-panel-out 0.18s ease forwards; }
@keyframes sh-panel-in {
  from { opacity: 0; transform: translateY(18px) scale(0.93); }
  to   { opacity: 1; transform: translateY(0) scale(1); }
}
@keyframes sh-panel-out {
  to { opacity: 0; transform: translateY(12px) scale(0.94); }
}

/* ── Header ── */
.sh-panel-header {
  display: flex;
  align-items: center;
  gap: 11px;
  padding: 16px 18px 12px;
  border-bottom: 1px solid rgba(255,255,255,0.05);
  flex-shrink: 0;
  background: linear-gradient(180deg, rgba(99,102,241,0.06) 0%, transparent 100%);
}
.sh-panel-icon {
  width: 36px;
  height: 36px;
  border-radius: 10px;
  background: linear-gradient(135deg, rgba(99,102,241,0.3) 0%, rgba(167,139,250,0.3) 100%);
  border: 1px solid rgba(99,102,241,0.4);
  color: #a78bfa;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
  box-shadow: 0 0 12px rgba(99,102,241,0.2);
}
.sh-panel-title {
  margin: 0 0 2px;
  font-size: 14px;
  font-weight: 700;
  color: var(--text, #e2e8f0);
  line-height: 1;
}
.sh-panel-sub {
  margin: 0;
  font-size: 11px;
  color: var(--text-3, #64748b);
}
.sh-close-btn {
  margin-left: auto;
  width: 26px; height: 26px;
  border-radius: 8px;
  border: 1px solid rgba(255,255,255,0.07);
  background: transparent;
  color: var(--text-3, #64748b);
  display: flex; align-items: center; justify-content: center;
  cursor: pointer;
  transition: all 0.15s ease;
  flex-shrink: 0;
}
.sh-close-btn:hover {
  background: rgba(248,113,113,0.1);
  color: #f87171;
  border-color: rgba(248,113,113,0.3);
}

/* ── Tabs ── */
.sh-tabs {
  display: flex;
  gap: 2px;
  padding: 8px 10px;
  border-bottom: 1px solid rgba(255,255,255,0.05);
  flex-shrink: 0;
}
.sh-tab {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 5px;
  padding: 6px 8px;
  border-radius: 8px;
  border: none;
  background: transparent;
  color: var(--text-3, #64748b);
  font-size: 11.5px;
  font-weight: 500;
  font-family: inherit;
  cursor: pointer;
  transition: all 0.15s ease;
}
.sh-tab:hover {
  background: rgba(255,255,255,0.05);
  color: var(--text-2, #94a3b8);
}
.sh-tab--active {
  background: rgba(99,102,241,0.15);
  color: #a78bfa;
  font-weight: 650;
}
.sh-tab-icon {
  display: flex;
  align-items: center;
}

/* ── Content area ── */
.sh-content {
  flex: 1;
  overflow-y: auto;
  padding: 10px 12px 6px;
  scrollbar-width: thin;
  scrollbar-color: rgba(255,255,255,0.08) transparent;
}
.sh-content::-webkit-scrollbar { width: 4px; }
.sh-content::-webkit-scrollbar-thumb {
  background: rgba(255,255,255,0.08);
  border-radius: 99px;
}

.sh-section-list {
  display: flex;
  flex-direction: column;
  gap: 14px;
  padding-bottom: 4px;
}

.sh-section-title {
  margin: 0 0 5px;
  font-size: 9.5px;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.08em;
  color: var(--text-3, #475569);
  padding-left: 6px;
  display: flex;
  align-items: center;
  gap: 6px;
}
.sh-section-title::after {
  content: '';
  flex: 1;
  height: 1px;
  background: rgba(255,255,255,0.05);
  border-radius: 99px;
}

.sh-rows {
  display: flex;
  flex-direction: column;
  gap: 1px;
}

.sh-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 8px;
  padding: 5px 7px;
  border-radius: 8px;
  transition: background 0.12s ease;
}
.sh-row:hover { background: rgba(255,255,255,0.04); }

.sh-label {
  font-size: 12px;
  color: var(--text-2, #94a3b8);
  flex: 1;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.sh-keys {
  display: flex;
  align-items: center;
  gap: 3px;
  flex-shrink: 0;
  flex-wrap: nowrap;
}

.sh-kbd {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  min-width: 22px;
  height: 20px;
  padding: 0 5px;
  border-radius: 5px;
  font-size: 10px;
  font-weight: 600;
  font-family: 'SF Mono', 'Fira Mono', 'Consolas', monospace;
  background: rgba(255,255,255,0.07);
  border: 1px solid rgba(255,255,255,0.12);
  border-bottom: 2px solid rgba(0,0,0,0.3);
  color: var(--text, #e2e8f0);
  line-height: 1;
  white-space: nowrap;
  box-shadow: inset 0 1px 0 rgba(255,255,255,0.08);
}
.sh-kbd--inline {
  font-size: 9.5px;
  height: 17px;
  min-width: 16px;
  padding: 0 4px;
  vertical-align: middle;
  margin: 0 2px;
}

.sh-sep {
  font-size: 10px;
  color: var(--text-3, #475569);
  padding: 0 1px;
  user-select: none;
}

/* ── Footer ── */
.sh-panel-footer {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 9px 16px;
  border-top: 1px solid rgba(255,255,255,0.05);
  font-size: 11px;
  color: var(--text-3, #475569);
  flex-shrink: 0;
  background: rgba(0,0,0,0.18);
}
.sh-panel-footer svg {
  flex-shrink: 0;
  color: #6366f1;
  opacity: 0.8;
}
</style>
