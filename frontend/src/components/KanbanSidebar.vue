<template>
  <button
    class="kb-toggle"
    :class="{ active: kanban.isOpen }"
    @click="kanban.toggle()"
    title="Kanban"
    aria-label="Abrir kanban"
  >
    <svg width="18" height="18" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
      <rect x="3" y="4" width="6" height="16" rx="1.6"/>
      <rect x="10.5" y="4" width="4.8" height="10" rx="1.6"/>
      <rect x="16" y="4" width="5" height="6" rx="1.6"/>
    </svg>
    <span class="kb-count" v-if="kanban.totalTasks">{{ kanban.totalTasks }}</span>
  </button>

  <aside class="kb-sidebar" :class="{ open: kanban.isOpen }">
    <div class="kb-header">
      <div>
        <p class="kb-eyebrow">Fluxo visual</p>
        <h2 class="kb-title">Kanban</h2>
      </div>
      <div class="kb-header-actions">
        <button class="kb-btn-icon" @click="openArchivedModal" title="Ver arquivadas">
          <svg width="14" height="14" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
            <polyline points="21 8 21 21 3 21 3 8"/>
            <rect x="1" y="3" width="22" height="5" rx="1"/>
            <line x1="10" y1="12" x2="14" y2="12"/>
          </svg>
        </button>
        <button class="kb-btn-icon" @click="expandAllBoards" title="Expandir todos os boards">
          <svg width="14" height="14" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
            <polyline points="7 15 12 10 17 15"/>
            <polyline points="7 21 12 16 17 21"/>
          </svg>
        </button>
        <button class="kb-btn-icon" @click="openCreateBoardModal" title="Novo board">
          <svg width="14" height="14" fill="none" stroke="currentColor" stroke-width="2.3" viewBox="0 0 24 24">
            <line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/>
          </svg>
        </button>
        <button class="kb-btn-icon" @click="kanban.close()" title="Fechar">
          <svg width="14" height="14" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
            <line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/>
          </svg>
        </button>
      </div>
    </div>

    <div class="kb-body" @dragover.prevent>
      <div v-if="!kanban.boards.length" class="kb-empty">
        <p>Nenhum board criado.</p>
        <button class="kb-primary" @click="openCreateBoardModal">Criar primeiro board</button>
      </div>

      <div v-else class="kb-boards">
        <section
          v-for="(board, boardIndex) in kanban.boards"
          :key="board.id"
          class="kb-board"
          :class="{ 'drop-target': dragState.hoverBoardId === board.id, collapsed: isBoardCollapsed(board.id) }"
          @dragover.prevent="onBoardDragOver(board.id)"
          @dragleave="onBoardDragLeave(board.id)"
          @drop.prevent="onBoardDrop(board.id)"
        >
          <header class="kb-board-header">
            <div>
              <h3 class="kb-board-title">{{ board.title }}</h3>
              <span class="kb-board-count">{{ board.cards.length }} tarefa{{ board.cards.length === 1 ? '' : 's' }}</span>
            </div>
            <div class="kb-board-actions">
              <button
                class="kb-mini"
                @click="toggleBoardCollapsed(board.id)"
                :title="isBoardCollapsed(board.id) ? 'Expandir board' : 'Minimizar board'"
              >
                <svg width="12" height="12" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                  <polyline v-if="isBoardCollapsed(board.id)" points="6 9 12 15 18 9"/>
                  <polyline v-else points="6 15 12 9 18 15"/>
                </svg>
              </button>
              <button class="kb-mini" @click="openCreateTaskModal(board.id)" title="Nova tarefa">
                <svg width="12" height="12" fill="none" stroke="currentColor" stroke-width="2.2" viewBox="0 0 24 24">
                  <line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/>
                </svg>
              </button>
              <button class="kb-mini" @click="openEditBoardModal(board)" title="Editar board">
                <svg width="11" height="11" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                  <path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/>
                  <path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/>
                </svg>
              </button>
              <button
                class="kb-mini danger"
                @click="removeBoard(board.id)"
                :disabled="kanban.boards.length <= 1"
                :title="kanban.boards.length <= 1 ? 'Mantenha ao menos um board' : 'Excluir board'"
              >
                <svg width="11" height="11" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                  <polyline points="3,6 5,6 21,6"/>
                  <path d="M19,6l-1,14H6L5,6"/>
                  <path d="M10,11v6"/><path d="M14,11v6"/>
                  <path d="M9,6V4h6v2"/>
                </svg>
              </button>
            </div>
          </header>

          <div v-if="isBoardCollapsed(board.id)" class="kb-collapsed-hint">
            {{ board.cards.length }} tarefa{{ board.cards.length === 1 ? '' : 's' }} oculta{{ board.cards.length === 1 ? '' : 's' }}
          </div>

          <div v-else class="kb-cards">
            <article
              v-for="(task, taskIndex) in board.cards"
              :key="task.id"
              class="kb-card"
              :class="{ 'dragging': isDragging(task.id), 'drop-before': shouldShowDropBefore(board.id, taskIndex) }"
              draggable="true"
              @dragstart="onTaskDragStart(task.id, board.id)"
              @dragend="onTaskDragEnd"
              @dragover.prevent="onTaskDragOver(board.id, taskIndex)"
              @drop.prevent="onTaskDrop(board.id, taskIndex)"
            >
              <div class="kb-card-head">
                <h4 class="kb-card-title">{{ task.title }}</h4>
                <button class="kb-card-delete" @click="removeTask(board.id, task.id)" title="Excluir tarefa">
                  <svg width="10" height="10" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                    <line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/>
                  </svg>
                </button>
              </div>

              <p v-if="task.description" class="kb-card-desc">{{ task.description }}</p>

              <div class="kb-card-actions">
                <button class="kb-ghost" @click="openEditTaskModal(board.id, task)" title="Editar tarefa">Editar</button>
                <button
                  v-if="boardIndex === kanban.boards.length - 1"
                  class="kb-archive"
                  @click="archiveTask(task.id)"
                  title="Arquivar tarefa concluida"
                >
                  Arquivar
                </button>
                <button
                  v-else
                  class="kb-next"
                  @click="moveToNext(board.id, task.id, boardIndex)"
                  :disabled="boardIndex === kanban.boards.length - 1"
                  :title="boardIndex === kanban.boards.length - 1 ? 'Ultimo board' : 'Mover para proximo board'"
                >
                  Proximo
                  <svg width="12" height="12" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                    <polyline points="9 18 15 12 9 6"/>
                  </svg>
                </button>
              </div>
            </article>

            <div
              class="kb-drop-end"
              :class="{ active: shouldShowDropAtEnd(board.id) }"
              @dragover.prevent="onTaskDragOver(board.id, board.cards.length)"
              @drop.prevent="onTaskDrop(board.id, board.cards.length)"
            >
              Soltar aqui
            </div>
          </div>
        </section>
      </div>
    </div>
  </aside>

  <Teleport to="body">
    <div v-if="showBoardModal" class="kb-overlay" @click.self="closeBoardModal">
      <div class="kb-modal" role="dialog" aria-modal="true">
        <header class="kb-modal-header">
          <h3>{{ boardModalMode === 'create' ? 'Novo board' : 'Editar board' }}</h3>
          <button class="kb-btn-icon" @click="closeBoardModal" title="Fechar">
            <svg width="14" height="14" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
              <line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/>
            </svg>
          </button>
        </header>

        <form class="kb-modal-form" @submit.prevent="submitBoardModal">
          <label class="kb-label" for="board-title">Titulo do board</label>
          <input id="board-title" v-model="boardTitle" class="kb-input" type="text" maxlength="80" placeholder="Ex.: Revisao" />
          <p class="kb-error" v-if="boardError">{{ boardError }}</p>

          <footer class="kb-modal-footer">
            <button type="button" class="kb-secondary" @click="closeBoardModal">Cancelar</button>
            <button type="submit" class="kb-primary">{{ boardModalMode === 'create' ? 'Criar board' : 'Salvar' }}</button>
          </footer>
        </form>
      </div>
    </div>
  </Teleport>

  <Teleport to="body">
    <div v-if="showTaskModal" class="kb-overlay" @click.self="closeTaskModal">
      <div class="kb-modal" role="dialog" aria-modal="true">
        <header class="kb-modal-header">
          <h3>{{ taskModalMode === 'create' ? 'Nova tarefa' : 'Editar tarefa' }}</h3>
          <button class="kb-btn-icon" @click="closeTaskModal" title="Fechar">
            <svg width="14" height="14" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
              <line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/>
            </svg>
          </button>
        </header>

        <form class="kb-modal-form" @submit.prevent="submitTaskModal">
          <label class="kb-label" for="task-title">Titulo da tarefa</label>
          <input id="task-title" v-model="taskTitle" class="kb-input" type="text" maxlength="120" placeholder="Ex.: Ajustar endpoint" />

          <label class="kb-label" for="task-description">Descricao</label>
          <textarea
            id="task-description"
            v-model="taskDescription"
            class="kb-textarea"
            rows="4"
            maxlength="420"
            placeholder="Detalhes da tarefa"
          ></textarea>

          <p class="kb-error" v-if="taskError">{{ taskError }}</p>

          <footer class="kb-modal-footer">
            <button type="button" class="kb-secondary" @click="closeTaskModal">Cancelar</button>
            <button type="submit" class="kb-primary">{{ taskModalMode === 'create' ? 'Criar tarefa' : 'Salvar' }}</button>
          </footer>
        </form>
      </div>
    </div>
  </Teleport>

  <Teleport to="body">
    <div v-if="showArchivedModal" class="kb-overlay" @click.self="closeArchivedModal">
      <div class="kb-modal" role="dialog" aria-modal="true">
        <header class="kb-modal-header">
          <h3>Tarefas arquivadas</h3>
          <button class="kb-btn-icon" @click="closeArchivedModal" title="Fechar">
            <svg width="14" height="14" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
              <line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/>
            </svg>
          </button>
        </header>

        <div class="kb-archived-list">
          <div v-if="kanban.archivedTasks.length === 0" class="kb-archived-empty">
            Nenhuma tarefa arquivada.
          </div>

          <article v-for="task in kanban.archivedTasks" :key="task.id" class="kb-archived-item">
            <div class="kb-archived-head">
              <h4>{{ task.title }}</h4>
              <button class="kb-restore" @click="restoreTask(task.id)">Restaurar</button>
            </div>
            <p v-if="task.description" class="kb-archived-desc">{{ task.description }}</p>
            <div class="kb-archived-meta">
              <span>{{ task.kanban_board_title || 'Board' }}</span>
              <span>Arquivada em {{ formatDate(task.archived_at) }}</span>
            </div>
          </article>
        </div>
      </div>
    </div>
  </Teleport>
</template>

<script setup>
import { onMounted, reactive, ref } from 'vue'
import { useKanbanStore } from '@/stores/kanban'

const kanban = useKanbanStore()
onMounted(() => {
  kanban.init()
})

const showBoardModal = ref(false)
const boardModalMode = ref('create')
const boardTitle = ref('')
const boardError = ref('')
const editingBoardId = ref(null)

const showTaskModal = ref(false)
const taskModalMode = ref('create')
const taskTitle = ref('')
const taskDescription = ref('')
const taskError = ref('')
const taskBoardId = ref(null)
const editingTaskId = ref(null)
const collapsedBoards = ref({})
const showArchivedModal = ref(false)

const dragState = reactive({
  taskId: null,
  fromBoardId: null,
  hoverBoardId: null,
  hoverIndex: null
})

function resetBoardModal() {
  boardTitle.value = ''
  boardError.value = ''
  editingBoardId.value = null
}

function openCreateBoardModal() {
  boardModalMode.value = 'create'
  resetBoardModal()
  showBoardModal.value = true
}

function openEditBoardModal(board) {
  boardModalMode.value = 'edit'
  boardTitle.value = board.title
  boardError.value = ''
  editingBoardId.value = board.id
  showBoardModal.value = true
}

function closeBoardModal() {
  showBoardModal.value = false
  resetBoardModal()
}

async function submitBoardModal() {
  const parsed = boardTitle.value.trim()
  if (!parsed) {
    boardError.value = 'Informe um titulo para o board.'
    return
  }

  try {
    if (boardModalMode.value === 'create') {
      await kanban.createBoard(parsed)
    } else if (editingBoardId.value) {
      await kanban.renameBoard(editingBoardId.value, parsed)
    }

    closeBoardModal()
  } catch {
    boardError.value = 'Nao foi possivel salvar o board.'
  }
}

async function removeBoard(boardId) {
  if (kanban.boards.length <= 1) return
  if (!confirm('Excluir este board? As tarefas serao movidas para o board anterior.')) return
  await kanban.removeBoard(boardId)
}

function resetTaskModal() {
  taskTitle.value = ''
  taskDescription.value = ''
  taskError.value = ''
  taskBoardId.value = null
  editingTaskId.value = null
}

function openCreateTaskModal(boardId) {
  taskModalMode.value = 'create'
  resetTaskModal()
  taskBoardId.value = boardId
  showTaskModal.value = true
}

function openEditTaskModal(boardId, task) {
  taskModalMode.value = 'edit'
  taskBoardId.value = boardId
  editingTaskId.value = task.id
  taskTitle.value = task.title
  taskDescription.value = task.description || ''
  taskError.value = ''
  showTaskModal.value = true
}

function closeTaskModal() {
  showTaskModal.value = false
  resetTaskModal()
}

async function submitTaskModal() {
  const parsed = taskTitle.value.trim()
  if (!parsed) {
    taskError.value = 'A tarefa precisa de um titulo.'
    return
  }

  if (!taskBoardId.value) {
    taskError.value = 'Selecione um board.'
    return
  }

  try {
    if (taskModalMode.value === 'create') {
      await kanban.createTask(taskBoardId.value, {
        title: parsed,
        description: taskDescription.value
      })
    } else {
      await kanban.updateTask(taskBoardId.value, editingTaskId.value, {
        title: parsed,
        description: taskDescription.value
      })
    }

    closeTaskModal()
  } catch {
    taskError.value = 'Nao foi possivel salvar a tarefa.'
  }
}

async function removeTask(boardId, taskId) {
  await kanban.removeTask(boardId, taskId)
}

async function moveToNext(boardId, taskId, boardIndex) {
  if (boardIndex >= kanban.boards.length - 1) return
  await kanban.moveTaskToNextBoard(taskId, boardId)
}

async function archiveTask(taskId) {
  await kanban.archiveTask(taskId)
}

async function openArchivedModal() {
  await kanban.fetchArchivedTasks()
  showArchivedModal.value = true
}

function closeArchivedModal() {
  showArchivedModal.value = false
}

async function restoreTask(taskId) {
  const targetBoardId = kanban.boards[0]?.id || null
  await kanban.restoreTask(taskId, targetBoardId)
}

function formatDate(dateStr) {
  if (!dateStr) return ''
  return new Date(dateStr).toLocaleDateString('pt-BR', { day: '2-digit', month: '2-digit', year: 'numeric' })
}

function onTaskDragStart(taskId, fromBoardId) {
  dragState.taskId = taskId
  dragState.fromBoardId = fromBoardId
}

function onTaskDragEnd() {
  resetDrag()
}

function onBoardDragOver(boardId) {
  dragState.hoverBoardId = boardId
}

function onBoardDragLeave(boardId) {
  if (dragState.hoverBoardId === boardId && dragState.hoverIndex === null) {
    dragState.hoverBoardId = null
  }
}

function onTaskDragOver(boardId, taskIndex) {
  dragState.hoverBoardId = boardId
  dragState.hoverIndex = taskIndex
}

async function onBoardDrop(boardId) {
  if (!dragState.taskId || !dragState.fromBoardId) return
  await kanban.moveTask(dragState.taskId, dragState.fromBoardId, boardId)
  resetDrag()
}

async function onTaskDrop(boardId, taskIndex) {
  if (!dragState.taskId || !dragState.fromBoardId) return
  await kanban.moveTask(dragState.taskId, dragState.fromBoardId, boardId, taskIndex)
  resetDrag()
}

function isDragging(taskId) {
  return dragState.taskId === taskId
}

function shouldShowDropBefore(boardId, taskIndex) {
  return dragState.hoverBoardId === boardId && dragState.hoverIndex === taskIndex
}

function shouldShowDropAtEnd(boardId) {
  return dragState.hoverBoardId === boardId && dragState.hoverIndex === kanban.boards.find((b) => b.id === boardId)?.cards.length
}

function resetDrag() {
  dragState.taskId = null
  dragState.fromBoardId = null
  dragState.hoverBoardId = null
  dragState.hoverIndex = null
}

function isBoardCollapsed(boardId) {
  return Boolean(collapsedBoards.value[boardId])
}

function toggleBoardCollapsed(boardId) {
  collapsedBoards.value = {
    ...collapsedBoards.value,
    [boardId]: !collapsedBoards.value[boardId]
  }
}

function expandAllBoards() {
  collapsedBoards.value = {}
}
</script>

<style scoped>
.kb-toggle {
  position: fixed;
  right: 0;
  top: calc(50% + 78px);
  transform: translateY(-50%);
  z-index: 201;
  width: 42px;
  height: 64px;
  border: 0;
  border-radius: 10px 0 0 10px;
  background: linear-gradient(165deg, #1f2937, #111827 65%);
  color: #f8fafc;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 4px;
  cursor: pointer;
  transition: all var(--transition);
  box-shadow: -4px 0 20px rgba(0, 0, 0, 0.35);
}
.kb-toggle:hover {
  width: 46px;
  box-shadow: -6px 0 24px rgba(0, 0, 0, 0.45);
}
.kb-toggle.active {
  background: linear-gradient(165deg, #0f172a, #0b1325);
}
.kb-count {
  min-width: 16px;
  padding: 1px 5px;
  border-radius: 999px;
  text-align: center;
  font-size: 10px;
  font-weight: 800;
  line-height: 1.5;
  background: rgba(248, 250, 252, 0.25);
}

.kb-sidebar {
  position: fixed;
  right: 0;
  top: 0;
  width: 380px;
  height: 100vh;
  z-index: 195;
  background: linear-gradient(180deg, #0b1325 0%, #0f172a 100%);
  border-left: 1px solid rgba(148, 163, 184, 0.2);
  display: flex;
  flex-direction: column;
  transform: translateX(100%);
  transition: transform var(--transition-slow);
  box-shadow: -12px 0 36px rgba(0, 0, 0, 0.4);
}
.kb-sidebar.open { transform: translateX(0); }

.kb-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 14px;
  border-bottom: 1px solid rgba(148, 163, 184, 0.2);
  background: linear-gradient(120deg, rgba(14, 116, 144, 0.28), transparent 60%);
}
.kb-eyebrow {
  margin: 0;
  font-size: 10px;
  letter-spacing: 0.14em;
  text-transform: uppercase;
  color: #7dd3fc;
}
.kb-title {
  margin: 2px 0 0;
  font-size: 18px;
  font-weight: 700;
  color: #f8fafc;
}
.kb-header-actions {
  display: flex;
  align-items: center;
  gap: 6px;
}
.kb-btn-icon {
  width: 28px;
  height: 28px;
  border: 1px solid rgba(148, 163, 184, 0.3);
  border-radius: 8px;
  background: rgba(15, 23, 42, 0.75);
  color: #e2e8f0;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
}
.kb-btn-icon:hover { border-color: rgba(125, 211, 252, 0.6); color: #7dd3fc; }

.kb-body {
  flex: 1;
  overflow: auto;
  padding: 12px;
}
.kb-empty {
  margin-top: 20px;
  border: 1px dashed rgba(125, 211, 252, 0.45);
  border-radius: 12px;
  text-align: center;
  padding: 24px 16px;
  color: #cbd5e1;
}

.kb-boards {
  display: flex;
  flex-direction: column;
  gap: 10px;
}
.kb-board {
  border: 1px solid rgba(148, 163, 184, 0.28);
  border-radius: 12px;
  background: rgba(15, 23, 42, 0.6);
  padding: 10px;
  transition: border-color var(--transition), box-shadow var(--transition);
}
.kb-board.collapsed {
  background: rgba(15, 23, 42, 0.5);
}
.kb-board.drop-target {
  border-color: rgba(125, 211, 252, 0.65);
  box-shadow: 0 0 0 2px rgba(125, 211, 252, 0.2);
}
.kb-board-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 8px;
  margin-bottom: 10px;
}
.kb-board-title {
  margin: 0;
  font-size: 14px;
  color: #f8fafc;
  font-weight: 650;
}
.kb-board-count {
  font-size: 11px;
  color: #94a3b8;
}
.kb-board-actions {
  display: flex;
  gap: 4px;
}
.kb-mini {
  width: 24px;
  height: 24px;
  border-radius: 7px;
  border: 1px solid rgba(148, 163, 184, 0.32);
  background: rgba(15, 23, 42, 0.85);
  color: #cbd5e1;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
}
.kb-mini:hover { color: #7dd3fc; border-color: rgba(125, 211, 252, 0.7); }
.kb-mini.danger:hover { color: #fda4af; border-color: rgba(251, 113, 133, 0.6); }
.kb-mini:disabled { opacity: 0.4; cursor: not-allowed; }

.kb-cards {
  display: flex;
  flex-direction: column;
  gap: 8px;
}
.kb-collapsed-hint {
  border: 1px dashed rgba(148, 163, 184, 0.45);
  border-radius: 8px;
  padding: 8px 10px;
  font-size: 11px;
  color: #94a3b8;
  background: rgba(2, 6, 23, 0.4);
}
.kb-card {
  border: 1px solid rgba(148, 163, 184, 0.3);
  border-radius: 10px;
  background: rgba(2, 6, 23, 0.65);
  padding: 10px;
  cursor: grab;
}
.kb-card.dragging {
  opacity: 0.55;
  cursor: grabbing;
}
.kb-card.drop-before {
  box-shadow: inset 0 3px 0 rgba(125, 211, 252, 0.95);
}
.kb-card-head {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: 10px;
}
.kb-card-title {
  margin: 0;
  font-size: 13px;
  color: #f8fafc;
  font-weight: 600;
}
.kb-card-delete {
  width: 20px;
  height: 20px;
  border: 0;
  border-radius: 6px;
  background: transparent;
  color: #94a3b8;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
}
.kb-card-delete:hover { color: #fda4af; background: rgba(190, 24, 93, 0.12); }
.kb-card-desc {
  margin: 8px 0;
  font-size: 12px;
  color: #cbd5e1;
  line-height: 1.45;
  white-space: pre-wrap;
}
.kb-card-actions {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
.kb-ghost,
.kb-next {
  border: 1px solid rgba(148, 163, 184, 0.35);
  border-radius: 8px;
  background: rgba(15, 23, 42, 0.72);
  color: #e2e8f0;
  font-size: 11px;
  padding: 4px 7px;
  display: inline-flex;
  align-items: center;
  gap: 4px;
  cursor: pointer;
}
.kb-next {
  border-color: rgba(125, 211, 252, 0.42);
  color: #7dd3fc;
}
.kb-archive {
  border: 1px solid rgba(74, 222, 128, 0.45);
  border-radius: 8px;
  background: rgba(20, 83, 45, 0.28);
  color: #86efac;
  font-size: 11px;
  padding: 4px 8px;
  cursor: pointer;
}
.kb-next:disabled {
  opacity: 0.45;
  cursor: not-allowed;
}
.kb-drop-end {
  border: 1px dashed transparent;
  border-radius: 8px;
  color: transparent;
  text-align: center;
  font-size: 11px;
  padding: 6px;
}
.kb-drop-end.active {
  color: #7dd3fc;
  border-color: rgba(125, 211, 252, 0.55);
  background: rgba(14, 116, 144, 0.12);
}

.kb-overlay {
  position: fixed;
  inset: 0;
  z-index: 210;
  background: rgba(2, 6, 23, 0.62);
  backdrop-filter: blur(2px);
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 16px;
}
.kb-modal {
  width: min(520px, 100%);
  border-radius: 14px;
  border: 1px solid rgba(148, 163, 184, 0.25);
  background: #0b1325;
  color: #f8fafc;
  box-shadow: 0 24px 40px rgba(0, 0, 0, 0.5);
}
.kb-modal-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 8px;
  padding: 12px 14px;
  border-bottom: 1px solid rgba(148, 163, 184, 0.2);
}
.kb-modal-header h3 {
  margin: 0;
  font-size: 15px;
}
.kb-modal-form {
  display: flex;
  flex-direction: column;
  gap: 8px;
  padding: 14px;
}
.kb-label {
  font-size: 12px;
  color: #94a3b8;
}
.kb-input,
.kb-textarea {
  width: 100%;
  border-radius: 10px;
  border: 1px solid rgba(148, 163, 184, 0.35);
  background: rgba(15, 23, 42, 0.9);
  color: #f8fafc;
  font-size: 13px;
  padding: 10px;
  outline: none;
}
.kb-input:focus,
.kb-textarea:focus {
  border-color: rgba(125, 211, 252, 0.8);
  box-shadow: 0 0 0 2px rgba(125, 211, 252, 0.2);
}
.kb-textarea { resize: vertical; min-height: 90px; }
.kb-error {
  margin: 0;
  font-size: 12px;
  color: #fda4af;
}
.kb-modal-footer {
  margin-top: 6px;
  display: flex;
  justify-content: flex-end;
  gap: 8px;
}
.kb-primary,
.kb-secondary {
  border-radius: 9px;
  border: 1px solid transparent;
  padding: 8px 12px;
  font-size: 12px;
  font-weight: 600;
  cursor: pointer;
}
.kb-primary {
  background: linear-gradient(120deg, #0369a1, #0e7490);
  color: #ecfeff;
}
.kb-secondary {
  background: rgba(15, 23, 42, 0.8);
  color: #e2e8f0;
  border-color: rgba(148, 163, 184, 0.3);
}

.kb-archived-list {
  max-height: min(60vh, 520px);
  overflow-y: auto;
  padding: 12px;
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.kb-archived-empty {
  border: 1px dashed rgba(148, 163, 184, 0.45);
  border-radius: 10px;
  padding: 18px;
  text-align: center;
  color: #94a3b8;
  font-size: 12px;
}

.kb-archived-item {
  border: 1px solid rgba(148, 163, 184, 0.25);
  border-radius: 10px;
  background: rgba(15, 23, 42, 0.7);
  padding: 10px;
}

.kb-archived-head {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 8px;
}

.kb-archived-head h4 {
  margin: 0;
  font-size: 13px;
  color: #f8fafc;
}

.kb-restore {
  border: 1px solid rgba(125, 211, 252, 0.45);
  border-radius: 8px;
  background: rgba(14, 116, 144, 0.22);
  color: #7dd3fc;
  font-size: 11px;
  padding: 4px 8px;
  cursor: pointer;
}

.kb-archived-desc {
  margin: 8px 0 6px;
  font-size: 12px;
  color: #cbd5e1;
  line-height: 1.4;
}

.kb-archived-meta {
  display: flex;
  justify-content: space-between;
  gap: 8px;
  font-size: 10.5px;
  color: #94a3b8;
}

@media (max-width: 720px) {
  .kb-toggle {
    top: auto;
    bottom: 84px;
    transform: none;
  }
  .kb-sidebar {
    width: min(100vw, 420px);
  }
}
</style>
