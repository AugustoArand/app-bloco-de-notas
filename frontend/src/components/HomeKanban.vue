<template>
  <section class="hk-section">
    <!-- Header -->
    <div class="hk-header">
      <div class="hk-header-left">
        <div class="hk-title-row">
          <span class="hk-dot"></span>
          <h2 class="hk-heading">Quadro de Tarefas</h2>
          <span class="hk-badge" v-if="kanban.totalTasks">{{ kanban.totalTasks }} tarefa{{ kanban.totalTasks === 1 ? '' : 's' }}</span>
        </div>
        <p class="hk-sub">Gerencie seu fluxo de trabalho visualmente</p>
      </div>

      <div class="hk-header-actions">
        <!-- Progress pill -->
        <div class="hk-progress-pill" v-if="kanban.boards.length >= 2">
          <span class="hk-progress-label">Progresso</span>
          <div class="hk-progress-track">
            <div class="hk-progress-fill" :style="{ width: progressPercent + '%' }"></div>
          </div>
          <span class="hk-progress-pct">{{ progressPercent }}%</span>
        </div>

        <button class="hk-btn-archive" @click="openArchivedModal" title="Ver arquivadas">
          <svg width="13" height="13" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
            <polyline points="21 8 21 21 3 21 3 8"/><rect x="1" y="3" width="22" height="5" rx="1"/>
            <line x1="10" y1="12" x2="14" y2="12"/>
          </svg>
          Arquivadas
          <span v-if="archivedCount" class="hk-archive-count">{{ archivedCount }}</span>
        </button>

        <button class="hk-btn-new-board" @click="openCreateBoardModal">
          <svg width="13" height="13" fill="none" stroke="currentColor" stroke-width="2.5" viewBox="0 0 24 24">
            <line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/>
          </svg>
          Novo Board
        </button>
      </div>
    </div>

    <!-- Loading -->
    <div v-if="kanban.loading" class="hk-loading">
      <div class="hk-spinner"></div>
      <span>Carregando boards...</span>
    </div>

    <!-- Empty -->
    <div v-else-if="!kanban.boards.length" class="hk-empty">
      <div class="hk-empty-icon">
        <svg width="48" height="48" fill="none" stroke="currentColor" stroke-width="1.2" viewBox="0 0 24 24">
          <rect x="3" y="3" width="5" height="18" rx="1.5"/><rect x="9.5" y="3" width="5" height="12" rx="1.5"/>
          <rect x="16" y="3" width="5" height="8" rx="1.5"/>
        </svg>
      </div>
      <p class="hk-empty-title">Nenhum board criado ainda</p>
      <p class="hk-empty-sub">Crie seu primeiro board para organizar suas tarefas</p>
      <button class="hk-btn-primary" @click="openCreateBoardModal">Criar primeiro board</button>
    </div>

    <!-- Board columns -->
    <div v-else class="hk-board-wrap" @dragover.prevent>
      <div class="hk-columns">
        <div
          v-for="(board, boardIndex) in kanban.boards"
          :key="board.id"
          class="hk-col"
          :class="{
            'hk-col--drop': dragState.hoverBoardId === board.id,
            'hk-col--last': boardIndex === kanban.boards.length - 1
          }"
          :style="{ '--col-accent': boardAccent(boardIndex) }"
          @dragover.prevent="onBoardDragOver(board.id)"
          @dragleave="onBoardDragLeave(board.id)"
          @drop.prevent="onBoardDrop(board.id)"
        >
          <!-- Column header -->
          <div class="hk-col-header">
            <div class="hk-col-title-wrap">
              <span class="hk-col-accent-bar"></span>
              <div>
                <h3 class="hk-col-title">{{ board.title }}</h3>
                <span class="hk-col-count">{{ board.cards.length }} tarefa{{ board.cards.length === 1 ? '' : 's' }}</span>
              </div>
            </div>
            <div class="hk-col-actions">
              <button class="hk-icon-btn" @click="openCreateTaskModal(board.id)" title="Nova tarefa">
                <svg width="11" height="11" fill="none" stroke="currentColor" stroke-width="2.5" viewBox="0 0 24 24">
                  <line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/>
                </svg>
              </button>
              <button class="hk-icon-btn" @click="openEditBoardModal(board)" title="Renomear board">
                <svg width="11" height="11" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                  <path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/>
                  <path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/>
                </svg>
              </button>
              <button
                class="hk-icon-btn hk-icon-btn--danger"
                @click="removeBoard(board.id)"
                :disabled="kanban.boards.length <= 1"
                title="Excluir board"
              >
                <svg width="11" height="11" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                  <polyline points="3,6 5,6 21,6"/><path d="M19,6l-1,14H6L5,6"/><path d="M9,6V4h6v2"/>
                </svg>
              </button>
            </div>
          </div>

          <!-- Column progress bar -->
          <div class="hk-col-progress-wrap">
            <div class="hk-col-progress" :style="{ width: colProgress(boardIndex) + '%' }"></div>
          </div>

          <!-- Cards list -->
          <div class="hk-cards">
            <div
              v-for="(task, taskIndex) in board.cards"
              :key="task.id"
              class="hk-card"
              :class="{
                'hk-card--dragging': dragState.taskId === task.id,
                'hk-card--drop-before': dragState.hoverBoardId === board.id && dragState.hoverIndex === taskIndex
              }"
              draggable="true"
              @dragstart="onTaskDragStart(task.id, board.id)"
              @dragend="resetDrag"
              @dragover.prevent="onTaskDragOver(board.id, taskIndex)"
              @drop.prevent="onTaskDrop(board.id, taskIndex)"
            >
              <!-- Priority chip (clickable quick-change) -->
              <div class="hk-card-top">
                <div class="hk-priority-wrap" @click.stop>
                  <button
                    class="hk-priority"
                    :class="priorityClass(task.priority)"
                    @click="togglePriorityMenu(task.id)"
                    :title="'Prioridade: ' + priorityLabel(task.priority)"
                  >
                    <span class="hk-priority-dot"></span>
                    {{ priorityLabel(task.priority) }}
                    <svg width="8" height="8" fill="none" stroke="currentColor" stroke-width="2.5" viewBox="0 0 24 24" style="opacity:0.7"><polyline points="6 9 12 15 18 9"/></svg>
                  </button>
                  <div v-if="priorityMenuTaskId === task.id" class="hk-priority-menu">
                    <button
                      v-for="p in PRIORITIES"
                      :key="p.value"
                      class="hk-priority-option"
                      :class="{ 'hk-priority-option--active': task.priority === p.value }"
                      @click="setTaskPriority(board.id, task, p.value)"
                    >
                      <span class="hk-priority-option-dot" :style="{ background: p.color }"></span>
                      {{ p.label }}
                      <svg v-if="task.priority === p.value" width="10" height="10" fill="none" stroke="currentColor" stroke-width="2.5" viewBox="0 0 24 24" style="margin-left:auto"><polyline points="20 6 9 17 4 12"/></svg>
                    </button>
                  </div>
                </div>
                <span class="hk-card-board-tag">{{ board.title }}</span>
              </div>

              <h4 class="hk-card-title">{{ task.title }}</h4>
              <p v-if="task.description" class="hk-card-desc">{{ task.description }}</p>

              <!-- Footer -->
              <div class="hk-card-footer">
                <div class="hk-card-btns">
                  <button class="hk-card-edit" @click="openEditTaskModal(board.id, task)">Editar</button>
                  <button
                    v-if="boardIndex < kanban.boards.length - 1"
                    class="hk-card-advance"
                    @click="moveToNext(board.id, task.id, boardIndex)"
                    :title="'Mover para ' + kanban.boards[boardIndex + 1]?.title"
                  >
                    Avançar
                    <svg width="11" height="11" fill="none" stroke="currentColor" stroke-width="2.5" viewBox="0 0 24 24">
                      <polyline points="9 18 15 12 9 6"/>
                    </svg>
                  </button>
                  <button
                    v-else
                    class="hk-card-done"
                    @click="archiveTask(task.id)"
                    title="Concluir e arquivar"
                  >
                    <svg width="11" height="11" fill="none" stroke="currentColor" stroke-width="2.5" viewBox="0 0 24 24">
                      <polyline points="20 6 9 17 4 12"/>
                    </svg>
                    Concluir
                  </button>
                </div>
                <button class="hk-card-del" @click="removeTask(board.id, task.id)" title="Excluir">
                  <svg width="11" height="11" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                    <line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/>
                  </svg>
                </button>
              </div>
            </div>

            <!-- Drop zone at end of column -->
            <div
              class="hk-drop-zone"
              :class="{ active: dragState.hoverBoardId === board.id && dragState.hoverIndex === board.cards.length }"
              @dragover.prevent="onTaskDragOver(board.id, board.cards.length)"
              @drop.prevent="onTaskDrop(board.id, board.cards.length)"
            >
              <svg width="14" height="14" fill="none" stroke="currentColor" stroke-width="1.8" viewBox="0 0 24 24">
                <line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/>
              </svg>
              Soltar aqui
            </div>

            <!-- Quick add button -->
            <button class="hk-quick-add" @click="openCreateTaskModal(board.id)">
              <svg width="12" height="12" fill="none" stroke="currentColor" stroke-width="2.5" viewBox="0 0 24 24">
                <line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/>
              </svg>
              Adicionar tarefa
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- ── Modals ── -->
    <Teleport to="body">
      <!-- Board modal -->
      <div v-if="showBoardModal" class="hk-overlay" @click.self="closeBoardModal">
        <div class="hk-modal" role="dialog" aria-modal="true">
          <header class="hk-modal-header">
            <div class="hk-modal-icon">
              <svg width="16" height="16" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                <rect x="3" y="3" width="5" height="18" rx="1.5"/><rect x="9.5" y="3" width="5" height="12" rx="1.5"/>
                <rect x="16" y="3" width="5" height="8" rx="1.5"/>
              </svg>
            </div>
            <h3>{{ boardModalMode === 'create' ? 'Novo board' : 'Editar board' }}</h3>
            <button class="hk-modal-close" @click="closeBoardModal">
              <svg width="14" height="14" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                <line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/>
              </svg>
            </button>
          </header>
          <form class="hk-modal-form" @submit.prevent="submitBoardModal">
            <label class="hk-label" for="hk-board-title">Nome do board</label>
            <input
              id="hk-board-title"
              v-model="boardTitle"
              class="hk-input"
              type="text"
              maxlength="80"
              placeholder="Ex.: Em andamento"
              autofocus
            />
            <p class="hk-error" v-if="boardError">{{ boardError }}</p>
            <footer class="hk-modal-footer">
              <button type="button" class="hk-btn-secondary" @click="closeBoardModal">Cancelar</button>
              <button type="submit" class="hk-btn-primary">
                {{ boardModalMode === 'create' ? 'Criar board' : 'Salvar' }}
              </button>
            </footer>
          </form>
        </div>
      </div>

      <!-- Task modal -->
      <div v-if="showTaskModal" class="hk-overlay" @click.self="closeTaskModal">
        <div class="hk-modal" role="dialog" aria-modal="true">
          <header class="hk-modal-header">
            <div class="hk-modal-icon hk-modal-icon--task">
              <svg width="16" height="16" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                <path d="M14.5 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V7.5L14.5 2z"/>
                <polyline points="14,2 14,8 20,8"/>
              </svg>
            </div>
            <h3>{{ taskModalMode === 'create' ? 'Nova tarefa' : 'Editar tarefa' }}</h3>
            <button class="hk-modal-close" @click="closeTaskModal">
              <svg width="14" height="14" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                <line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/>
              </svg>
            </button>
          </header>

          <form class="hk-modal-form" @submit.prevent="submitTaskModal">
            <label class="hk-label" for="hk-task-title">Título</label>
            <input
              id="hk-task-title"
              v-model="taskTitle"
              class="hk-input"
              type="text"
              maxlength="120"
              placeholder="Ex.: Implementar endpoint de autenticação"
              autofocus
            />

            <label class="hk-label" for="hk-task-desc">Descrição <span class="hk-optional">(opcional)</span></label>
            <textarea
              id="hk-task-desc"
              v-model="taskDescription"
              class="hk-textarea"
              rows="4"
              maxlength="420"
              placeholder="Descreva os detalhes, critérios de aceite, observações..."
            ></textarea>

            <!-- Priority selector -->
            <div>
              <label class="hk-label">Prioridade</label>
              <div class="hk-priority-picker">
                <button
                  v-for="p in PRIORITIES"
                  :key="p.value"
                  type="button"
                  class="hk-priority-pick-btn"
                  :class="{ 'hk-priority-pick-btn--active': taskPriority === p.value }"
                  :style="taskPriority === p.value ? { borderColor: p.color, color: p.color, background: p.color + '22' } : {}"
                  @click="taskPriority = p.value"
                >
                  <span class="hk-priority-option-dot" :style="{ background: p.color }"></span>
                  {{ p.label }}
                </button>
              </div>
            </div>

            <!-- Board selector (when creating from section header) -->
            <div v-if="taskModalMode === 'create' && kanban.boards.length > 1">
              <label class="hk-label" for="hk-task-board">Board de destino</label>
              <select id="hk-task-board" v-model="taskBoardId" class="hk-select">
                <option v-for="b in kanban.boards" :key="b.id" :value="b.id">{{ b.title }}</option>
              </select>
            </div>

            <p class="hk-error" v-if="taskError">{{ taskError }}</p>

            <footer class="hk-modal-footer">
              <button type="button" class="hk-btn-secondary" @click="closeTaskModal">Cancelar</button>
              <button type="submit" class="hk-btn-primary">
                {{ taskModalMode === 'create' ? 'Criar tarefa' : 'Salvar alterações' }}
              </button>
            </footer>
          </form>
        </div>
      </div>

      <!-- Archived modal -->
      <div v-if="showArchivedModal" class="hk-overlay" @click.self="closeArchivedModal">
        <div class="hk-modal hk-modal--wide" role="dialog" aria-modal="true">
          <header class="hk-modal-header">
            <div class="hk-modal-icon hk-modal-icon--archive">
              <svg width="16" height="16" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                <polyline points="21 8 21 21 3 21 3 8"/><rect x="1" y="3" width="22" height="5" rx="1"/>
                <line x1="10" y1="12" x2="14" y2="12"/>
              </svg>
            </div>
            <h3>Tarefas arquivadas</h3>
            <button class="hk-modal-close" @click="closeArchivedModal">
              <svg width="14" height="14" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                <line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/>
              </svg>
            </button>
          </header>

          <div class="hk-archived-list">
            <div v-if="kanban.archivedTasks.length === 0" class="hk-archived-empty">
              <svg width="36" height="36" fill="none" stroke="currentColor" stroke-width="1.2" viewBox="0 0 24 24">
                <polyline points="21 8 21 21 3 21 3 8"/><rect x="1" y="3" width="22" height="5" rx="1"/>
              </svg>
              <p>Nenhuma tarefa arquivada ainda.</p>
            </div>

            <article v-for="task in kanban.archivedTasks" :key="task.id" class="hk-archived-item">
              <div class="hk-archived-head">
                <div>
                  <h4>{{ task.title }}</h4>
                  <p v-if="task.description" class="hk-archived-desc">{{ task.description }}</p>
                </div>
                <button class="hk-restore-btn" @click="restoreTask(task.id)">
                  <svg width="12" height="12" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                    <polyline points="1 4 1 10 7 10"/><path d="M3.51 15a9 9 0 1 0 .49-3.09"/>
                  </svg>
                  Restaurar
                </button>
              </div>
              <div class="hk-archived-meta">
                <span class="hk-archived-board">{{ task.kanban_board_title || 'Board' }}</span>
                <span>Arquivada em {{ formatDate(task.archived_at) }}</span>
              </div>
            </article>
          </div>
        </div>
      </div>
    </Teleport>
  </section>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { useKanbanStore } from '@/stores/kanban'

const kanban = useKanbanStore()

onMounted(() => kanban.init())

// ── Board modal ──
const showBoardModal = ref(false)
const boardModalMode = ref('create')
const boardTitle = ref('')
const boardError = ref('')
const editingBoardId = ref(null)

function openCreateBoardModal() {
  boardModalMode.value = 'create'
  boardTitle.value = ''
  boardError.value = ''
  editingBoardId.value = null
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
}

async function submitBoardModal() {
  const parsed = boardTitle.value.trim()
  if (!parsed) { boardError.value = 'Informe um nome para o board.'; return }
  try {
    if (boardModalMode.value === 'create') await kanban.createBoard(parsed)
    else if (editingBoardId.value) await kanban.renameBoard(editingBoardId.value, parsed)
    closeBoardModal()
  } catch { boardError.value = 'Não foi possível salvar o board.' }
}

async function removeBoard(boardId) {
  if (kanban.boards.length <= 1) return
  if (!confirm('Excluir este board? As tarefas serão movidas para o board anterior.')) return
  await kanban.removeBoard(boardId)
}

// ── Task modal ──
const showTaskModal = ref(false)
const taskModalMode = ref('create')
const taskTitle = ref('')
const taskDescription = ref('')
const taskPriority = ref('normal')
const taskError = ref('')
const taskBoardId = ref(null)
const editingTaskId = ref(null)

// Priority quick-change menu
const priorityMenuTaskId = ref(null)

const PRIORITIES = [
  { value: 'high',   label: 'Alta',   color: '#f87171' },
  { value: 'mid',    label: 'Média',  color: '#fbbf24' },
  { value: 'normal', label: 'Normal', color: '#60a5fa' },
]

function togglePriorityMenu(taskId) {
  priorityMenuTaskId.value = priorityMenuTaskId.value === taskId ? null : taskId
}

async function setTaskPriority(boardId, task, priority) {
  priorityMenuTaskId.value = null
  if (task.priority === priority) return
  await kanban.updateTask(boardId, task.id, { title: task.title, description: task.description || '', priority })
}

// Close priority menu when clicking outside
if (typeof window !== 'undefined') {
  window.addEventListener('click', () => { priorityMenuTaskId.value = null })
}

function openCreateTaskModal(boardId) {
  taskModalMode.value = 'create'
  taskTitle.value = ''
  taskDescription.value = ''
  taskPriority.value = 'normal'
  taskError.value = ''
  taskBoardId.value = boardId
  editingTaskId.value = null
  showTaskModal.value = true
}

function openEditTaskModal(boardId, task) {
  taskModalMode.value = 'edit'
  taskBoardId.value = boardId
  editingTaskId.value = task.id
  taskTitle.value = task.title
  taskDescription.value = task.description || ''
  taskPriority.value = task.priority || 'normal'
  taskError.value = ''
  showTaskModal.value = true
}

function closeTaskModal() { showTaskModal.value = false }

async function submitTaskModal() {
  const parsed = taskTitle.value.trim()
  if (!parsed) { taskError.value = 'A tarefa precisa de um título.'; return }
  if (!taskBoardId.value) { taskError.value = 'Selecione um board.'; return }
  try {
    if (taskModalMode.value === 'create') {
      await kanban.createTask(taskBoardId.value, { title: parsed, description: taskDescription.value, priority: taskPriority.value })
    } else {
      await kanban.updateTask(taskBoardId.value, editingTaskId.value, { title: parsed, description: taskDescription.value, priority: taskPriority.value })
    }
    closeTaskModal()
  } catch { taskError.value = 'Não foi possível salvar a tarefa.' }
}

async function removeTask(boardId, taskId) { await kanban.removeTask(boardId, taskId) }

async function moveToNext(boardId, taskId, boardIndex) {
  if (boardIndex >= kanban.boards.length - 1) return
  await kanban.moveTaskToNextBoard(taskId, boardId)
}

async function archiveTask(taskId) { await kanban.archiveTask(taskId) }

// ── Archived modal ──
const showArchivedModal = ref(false)
const archivedCount = ref(0)

async function openArchivedModal() {
  await kanban.fetchArchivedTasks()
  archivedCount.value = kanban.archivedTasks.length
  showArchivedModal.value = true
}
function closeArchivedModal() { showArchivedModal.value = false }

async function restoreTask(taskId) {
  const targetBoardId = kanban.boards[0]?.id || null
  await kanban.restoreTask(taskId, targetBoardId)
  archivedCount.value = kanban.archivedTasks.length
}

// ── Drag & Drop ──
const dragState = reactive({ taskId: null, fromBoardId: null, hoverBoardId: null, hoverIndex: null })

function onTaskDragStart(taskId, fromBoardId) {
  dragState.taskId = taskId
  dragState.fromBoardId = fromBoardId
}

function onBoardDragOver(boardId) { dragState.hoverBoardId = boardId }
function onBoardDragLeave(boardId) {
  if (dragState.hoverBoardId === boardId && dragState.hoverIndex === null) dragState.hoverBoardId = null
}
function onTaskDragOver(boardId, taskIndex) {
  dragState.hoverBoardId = boardId
  dragState.hoverIndex = taskIndex
}

async function onBoardDrop(boardId) {
  if (!dragState.taskId) return
  await kanban.moveTask(dragState.taskId, dragState.fromBoardId, boardId)
  resetDrag()
}

async function onTaskDrop(boardId, taskIndex) {
  if (!dragState.taskId) return
  await kanban.moveTask(dragState.taskId, dragState.fromBoardId, boardId, taskIndex)
  resetDrag()
}

function resetDrag() {
  dragState.taskId = null
  dragState.fromBoardId = null
  dragState.hoverBoardId = null
  dragState.hoverIndex = null
}

// ── Computed ──
const progressPercent = computed(() => {
  if (kanban.boards.length < 2) return 0
  const lastBoard = kanban.boards[kanban.boards.length - 1]
  const total = kanban.boards.reduce((s, b) => s + b.cards.length, 0)
  if (!total) return 0
  return Math.round((lastBoard.cards.length / total) * 100)
})

function colProgress(boardIndex) {
  const total = kanban.boards.reduce((s, b) => s + b.cards.length, 0)
  if (!total) return 0
  const board = kanban.boards[boardIndex]
  return Math.round((board.cards.length / total) * 100)
}

// Column accent colors per index
const ACCENTS = ['#c084fc', '#60a5fa', '#34d399', '#fbbf24', '#f87171', '#a78bfa']
function boardAccent(i) { return ACCENTS[i % ACCENTS.length] }

// Priority label/class based on task.priority field
function priorityLabel(priority) {
  if (priority === 'high') return 'Alta'
  if (priority === 'mid') return 'Média'
  return 'Normal'
}
function priorityClass(priority) {
  if (priority === 'high') return 'hk-priority--high'
  if (priority === 'mid') return 'hk-priority--mid'
  return 'hk-priority--low'
}

function formatDate(dateStr) {
  if (!dateStr) return ''
  return new Date(dateStr).toLocaleDateString('pt-BR', { day: '2-digit', month: '2-digit', year: 'numeric' })
}
</script>

<style scoped>
/* ── Section wrapper ── */
.hk-section {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

/* ── Header ── */
.hk-header {
  display: flex;
  align-items: flex-end;
  justify-content: space-between;
  flex-wrap: wrap;
  gap: 16px;
}

.hk-header-left { display: flex; flex-direction: column; gap: 4px; }

.hk-title-row {
  display: flex;
  align-items: center;
  gap: 10px;
}

.hk-dot {
  width: 8px; height: 8px;
  border-radius: 50%;
  background: #60a5fa;
  box-shadow: 0 0 8px rgba(96,165,250,0.55);
  flex-shrink: 0;
}

.hk-heading {
  font-size: 13px;
  font-weight: 700;
  color: var(--text-2);
  text-transform: uppercase;
  letter-spacing: 0.07em;
  margin: 0;
}

.hk-badge {
  display: inline-flex;
  align-items: center;
  padding: 2px 8px;
  border-radius: 99px;
  font-size: 11px;
  font-weight: 600;
  background: rgba(96,165,250,0.12);
  border: 1px solid rgba(96,165,250,0.3);
  color: #60a5fa;
}

.hk-sub {
  font-size: 12px;
  color: var(--text-3);
  margin: 0;
}

.hk-header-actions {
  display: flex;
  align-items: center;
  gap: 10px;
  flex-wrap: wrap;
}

/* Progress pill */
.hk-progress-pill {
  display: flex;
  align-items: center;
  gap: 8px;
  background: var(--surface);
  border: 1px solid var(--border-soft);
  border-radius: 99px;
  padding: 6px 14px;
}
.hk-progress-label { font-size: 11.5px; color: var(--text-3); }
.hk-progress-track {
  width: 80px; height: 5px;
  background: var(--border);
  border-radius: 99px;
  overflow: hidden;
}
.hk-progress-fill {
  height: 100%;
  background: linear-gradient(90deg, #60a5fa, #a78bfa);
  border-radius: 99px;
  transition: width 0.5s cubic-bezier(0.4, 0, 0.2, 1);
}
.hk-progress-pct { font-size: 11.5px; font-weight: 700; color: var(--text-2); min-width: 28px; }

/* Header buttons */
.hk-btn-archive {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  padding: 7px 14px;
  border-radius: 8px;
  font-size: 12.5px;
  font-weight: 500;
  background: var(--surface);
  border: 1px solid var(--border-soft);
  color: var(--text-2);
  cursor: pointer;
  transition: all var(--transition);
  position: relative;
}
.hk-btn-archive:hover { border-color: var(--border); color: var(--text); }

.hk-archive-count {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  min-width: 18px;
  height: 18px;
  padding: 0 4px;
  border-radius: 99px;
  font-size: 10px;
  font-weight: 700;
  background: rgba(248, 113, 113, 0.18);
  color: #f87171;
  border: 1px solid rgba(248, 113, 113, 0.3);
}

.hk-btn-new-board {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  padding: 7px 16px;
  border-radius: 8px;
  font-size: 12.5px;
  font-weight: 600;
  background: linear-gradient(135deg, #60a5fa 0%, #a78bfa 100%);
  border: none;
  color: white;
  cursor: pointer;
  transition: all var(--transition);
  box-shadow: 0 2px 12px rgba(96,165,250,0.25);
}
.hk-btn-new-board:hover {
  transform: translateY(-1px);
  box-shadow: 0 4px 18px rgba(96,165,250,0.4);
}

/* ── Loading ── */
.hk-loading {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 24px 0;
  color: var(--text-3);
  font-size: 13px;
}
.hk-spinner {
  width: 20px; height: 20px;
  border: 2px solid var(--border);
  border-top-color: #60a5fa;
  border-radius: 50%;
  animation: hk-spin 0.8s linear infinite;
}
@keyframes hk-spin { to { transform: rotate(360deg); } }

/* ── Empty ── */
.hk-empty {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 12px;
  padding: 60px 20px;
  border: 1.5px dashed var(--border);
  border-radius: 16px;
  text-align: center;
}
.hk-empty-icon { color: var(--border); opacity: 0.6; }
.hk-empty-title { font-size: 15px; font-weight: 600; color: var(--text-2); margin: 0; }
.hk-empty-sub { font-size: 13px; color: var(--text-3); margin: 0; }

/* ── Board wrap (horizontal scroll) ── */
.hk-board-wrap {
  overflow-x: auto;
  padding-bottom: 8px;
  /* custom scrollbar */
  scrollbar-width: thin;
  scrollbar-color: var(--border) transparent;
}
.hk-board-wrap::-webkit-scrollbar { height: 5px; }
.hk-board-wrap::-webkit-scrollbar-track { background: transparent; }
.hk-board-wrap::-webkit-scrollbar-thumb { background: var(--border); border-radius: 99px; }

.hk-columns {
  display: flex;
  gap: 16px;
  min-width: max-content;
  align-items: flex-start;
}

/* ── Column ── */
.hk-col {
  width: 290px;
  display: flex;
  flex-direction: column;
  gap: 0;
  background: var(--surface);
  border: 1px solid var(--border-soft);
  border-radius: 14px;
  overflow: hidden;
  transition: border-color 0.2s, box-shadow 0.2s;
  flex-shrink: 0;
}
.hk-col--drop {
  border-color: var(--col-accent, #60a5fa);
  box-shadow: 0 0 0 3px color-mix(in srgb, var(--col-accent, #60a5fa) 18%, transparent);
}
.hk-col--last {
  border-color: rgba(52, 211, 153, 0.35);
}

/* Column header */
.hk-col-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 14px 14px 10px;
}

.hk-col-title-wrap {
  display: flex;
  align-items: center;
  gap: 10px;
}

.hk-col-accent-bar {
  width: 3px;
  height: 32px;
  border-radius: 99px;
  background: var(--col-accent, #60a5fa);
  flex-shrink: 0;
}

.hk-col-title {
  margin: 0 0 2px;
  font-size: 13.5px;
  font-weight: 650;
  color: var(--text);
  line-height: 1;
}
.hk-col-count {
  font-size: 11px;
  color: var(--text-3);
}

.hk-col-actions {
  display: flex;
  gap: 4px;
}

.hk-icon-btn {
  width: 24px; height: 24px;
  border-radius: 7px;
  border: 1px solid var(--border-soft);
  background: transparent;
  color: var(--text-3);
  display: inline-flex; align-items: center; justify-content: center;
  cursor: pointer;
  transition: all var(--transition);
}
.hk-icon-btn:hover { border-color: var(--border); color: var(--text-2); background: var(--bg); }
.hk-icon-btn--danger:hover { border-color: rgba(248,113,113,0.45); color: #f87171; background: rgba(248,113,113,0.07); }
.hk-icon-btn:disabled { opacity: 0.3; cursor: not-allowed; }

/* Column progress bar */
.hk-col-progress-wrap {
  height: 3px;
  background: var(--border-soft);
  margin: 0 14px 10px;
  border-radius: 99px;
  overflow: hidden;
}
.hk-col-progress {
  height: 100%;
  background: var(--col-accent, #60a5fa);
  border-radius: 99px;
  transition: width 0.5s ease;
  opacity: 0.7;
}

/* ── Cards ── */
.hk-cards {
  display: flex;
  flex-direction: column;
  gap: 8px;
  padding: 0 10px 12px;
}

.hk-card {
  background: var(--bg);
  border: 1px solid var(--border-soft);
  border-radius: 10px;
  padding: 12px;
  cursor: grab;
  transition: all 0.18s ease;
  position: relative;
}
.hk-card:hover {
  border-color: var(--border);
  box-shadow: 0 4px 18px rgba(0,0,0,0.08);
  transform: translateY(-1px);
}
.hk-card--dragging {
  opacity: 0.45;
  cursor: grabbing;
  transform: scale(0.97);
}
.hk-card--drop-before {
  box-shadow: inset 0 3px 0 #60a5fa;
}

/* Card top row (priority + board tag) */
.hk-card-top {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 8px;
}

/* Priority wrap for relative positioning */
.hk-priority-wrap {
  position: relative;
}

.hk-priority {
  display: inline-flex;
  align-items: center;
  gap: 4px;
  padding: 2px 6px 2px 5px;
  border-radius: 5px;
  font-size: 10.5px;
  font-weight: 700;
  letter-spacing: 0.04em;
  cursor: pointer;
  border: 1px solid transparent;
  background: transparent;
  font-family: inherit;
  transition: all 0.15s ease;
}
.hk-priority:hover { filter: brightness(1.15); transform: scale(1.03); }

.hk-priority-dot {
  width: 6px; height: 6px;
  border-radius: 50%;
  flex-shrink: 0;
  background: currentColor;
  opacity: 0.85;
}

.hk-priority--high {
  background: rgba(248,113,113,0.14);
  color: #f87171;
  border-color: rgba(248,113,113,0.28);
}
.hk-priority--mid {
  background: rgba(251,191,36,0.12);
  color: #fbbf24;
  border-color: rgba(251,191,36,0.25);
}
.hk-priority--low {
  background: rgba(96,165,250,0.1);
  color: #60a5fa;
  border-color: rgba(96,165,250,0.22);
}

/* Priority dropdown menu */
.hk-priority-menu {
  position: absolute;
  top: calc(100% + 5px);
  left: 0;
  z-index: 200;
  background: var(--panel, #1a1a2e);
  border: 1px solid var(--border);
  border-radius: 10px;
  padding: 5px;
  min-width: 130px;
  box-shadow: 0 8px 32px rgba(0,0,0,0.35);
  display: flex;
  flex-direction: column;
  gap: 2px;
  animation: hk-fadeIn 0.1s ease;
}

.hk-priority-option {
  display: flex;
  align-items: center;
  gap: 7px;
  padding: 7px 9px;
  border-radius: 7px;
  border: none;
  background: transparent;
  color: var(--text-2);
  font-size: 12px;
  font-weight: 500;
  font-family: inherit;
  cursor: pointer;
  transition: all 0.12s ease;
  text-align: left;
  width: 100%;
}
.hk-priority-option:hover { background: var(--surface); color: var(--text); }
.hk-priority-option--active { color: var(--text); font-weight: 600; }

.hk-priority-option-dot {
  width: 8px; height: 8px;
  border-radius: 50%;
  flex-shrink: 0;
}

/* Priority picker (inside modal) */
.hk-priority-picker {
  display: flex;
  gap: 8px;
  flex-wrap: wrap;
}

.hk-priority-pick-btn {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  padding: 6px 12px;
  border-radius: 8px;
  border: 1px solid var(--border);
  background: var(--bg);
  color: var(--text-2);
  font-size: 12.5px;
  font-weight: 500;
  font-family: inherit;
  cursor: pointer;
  transition: all 0.15s ease;
  flex: 1;
  justify-content: center;
}
.hk-priority-pick-btn:hover { border-color: var(--border); color: var(--text); background: var(--surface); }
.hk-priority-pick-btn--active { font-weight: 700; }

.hk-card-board-tag {
  font-size: 10px;
  color: var(--text-3);
  background: var(--surface);
  border: 1px solid var(--border-soft);
  border-radius: 5px;
  padding: 1px 6px;
  max-width: 80px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.hk-card-title {
  margin: 0 0 6px;
  font-size: 13px;
  font-weight: 600;
  color: var(--text);
  line-height: 1.4;
}

.hk-card-desc {
  margin: 0 0 10px;
  font-size: 12px;
  color: var(--text-3);
  line-height: 1.5;
  display: -webkit-box;
  -webkit-line-clamp: 3;
  line-clamp: 3;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.hk-card-footer {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 6px;
}

.hk-card-btns {
  display: flex;
  gap: 6px;
  flex-wrap: wrap;
}

.hk-card-edit,
.hk-card-advance,
.hk-card-done {
  display: inline-flex;
  align-items: center;
  gap: 4px;
  padding: 4px 8px;
  border-radius: 7px;
  font-size: 11.5px;
  font-weight: 500;
  cursor: pointer;
  transition: all var(--transition);
}

.hk-card-edit {
  background: var(--surface);
  border: 1px solid var(--border-soft);
  color: var(--text-2);
}
.hk-card-edit:hover { border-color: var(--border); color: var(--text); }

.hk-card-advance {
  background: rgba(96,165,250,0.08);
  border: 1px solid rgba(96,165,250,0.28);
  color: #60a5fa;
}
.hk-card-advance:hover { background: rgba(96,165,250,0.16); }

.hk-card-done {
  background: rgba(52,211,153,0.1);
  border: 1px solid rgba(52,211,153,0.3);
  color: #34d399;
}
.hk-card-done:hover { background: rgba(52,211,153,0.18); }

.hk-card-del {
  width: 24px; height: 24px;
  border: none;
  border-radius: 7px;
  background: transparent;
  color: var(--text-3);
  display: inline-flex; align-items: center; justify-content: center;
  cursor: pointer;
  flex-shrink: 0;
  transition: all var(--transition);
}
.hk-card-del:hover { background: rgba(248,113,113,0.1); color: #f87171; }

/* Drop zone */
.hk-drop-zone {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 6px;
  height: 40px;
  border: 1.5px dashed transparent;
  border-radius: 8px;
  font-size: 12px;
  color: transparent;
  transition: all 0.15s ease;
}
.hk-drop-zone.active {
  border-color: #60a5fa;
  color: #60a5fa;
  background: rgba(96,165,250,0.06);
}

/* Quick add */
.hk-quick-add {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 7px;
  width: 100%;
  padding: 8px;
  border-radius: 8px;
  border: 1.5px dashed var(--border-soft);
  background: transparent;
  color: var(--text-3);
  font-size: 12px;
  cursor: pointer;
  transition: all var(--transition);
}
.hk-quick-add:hover {
  border-color: var(--col-accent, #60a5fa);
  color: var(--col-accent, #60a5fa);
  background: color-mix(in srgb, var(--col-accent, #60a5fa) 6%, transparent);
}

/* ── Modals ── */
.hk-overlay {
  position: fixed;
  inset: 0;
  z-index: 300;
  background: rgba(0, 0, 0, 0.55);
  backdrop-filter: blur(4px);
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 20px;
  animation: hk-fadeIn 0.15s ease;
}
@keyframes hk-fadeIn { from { opacity: 0; } to { opacity: 1; } }

.hk-modal {
  width: 100%;
  max-width: 440px;
  background: var(--panel, #1a1a2e);
  border: 1px solid var(--border);
  border-radius: 16px;
  overflow: hidden;
  box-shadow: 0 24px 64px rgba(0,0,0,0.45);
  animation: hk-slideUp 0.2s cubic-bezier(0.34, 1.56, 0.64, 1);
}
.hk-modal--wide { max-width: 560px; }
@keyframes hk-slideUp { from { transform: translateY(20px); opacity: 0; } to { transform: translateY(0); opacity: 1; } }

.hk-modal-header {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 18px 20px 14px;
  border-bottom: 1px solid var(--border-soft);
}
.hk-modal-header h3 {
  flex: 1;
  margin: 0;
  font-size: 15px;
  font-weight: 700;
  color: var(--text);
}

.hk-modal-icon {
  width: 32px; height: 32px;
  border-radius: 8px;
  background: rgba(96,165,250,0.14);
  border: 1px solid rgba(96,165,250,0.25);
  color: #60a5fa;
  display: flex; align-items: center; justify-content: center;
  flex-shrink: 0;
}
.hk-modal-icon--task {
  background: rgba(167,139,250,0.14);
  border-color: rgba(167,139,250,0.25);
  color: #a78bfa;
}
.hk-modal-icon--archive {
  background: rgba(251,191,36,0.12);
  border-color: rgba(251,191,36,0.25);
  color: #fbbf24;
}

.hk-modal-close {
  width: 28px; height: 28px;
  border: 1px solid var(--border-soft);
  border-radius: 8px;
  background: transparent;
  color: var(--text-3);
  display: inline-flex; align-items: center; justify-content: center;
  cursor: pointer;
  transition: all var(--transition);
}
.hk-modal-close:hover { background: rgba(248,113,113,0.1); color: #f87171; border-color: rgba(248,113,113,0.3); }

.hk-modal-form { padding: 18px 20px; display: flex; flex-direction: column; gap: 12px; }

.hk-label {
  font-size: 12px;
  font-weight: 600;
  color: var(--text-2);
  margin-bottom: 2px;
  display: block;
}
.hk-optional { font-weight: 400; color: var(--text-3); }

.hk-input,
.hk-select,
.hk-textarea {
  width: 100%;
  background: var(--bg);
  border: 1px solid var(--border);
  border-radius: 9px;
  padding: 10px 12px;
  font-size: 13.5px;
  color: var(--text);
  font-family: inherit;
  box-sizing: border-box;
  outline: none;
  transition: border-color var(--transition);
}
.hk-input:focus,
.hk-select:focus,
.hk-textarea:focus { border-color: #60a5fa; box-shadow: 0 0 0 3px rgba(96,165,250,0.12); }
.hk-textarea { resize: vertical; min-height: 90px; line-height: 1.55; }
.hk-select { cursor: pointer; }

.hk-error {
  margin: 0;
  font-size: 12px;
  color: #f87171;
  background: rgba(248,113,113,0.1);
  border: 1px solid rgba(248,113,113,0.25);
  border-radius: 7px;
  padding: 7px 10px;
}

.hk-modal-footer {
  display: flex;
  justify-content: flex-end;
  gap: 8px;
  padding-top: 4px;
}

.hk-btn-primary {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  padding: 9px 18px;
  border-radius: 9px;
  font-size: 13px;
  font-weight: 600;
  background: linear-gradient(135deg, #60a5fa 0%, #a78bfa 100%);
  border: none;
  color: white;
  cursor: pointer;
  transition: all var(--transition);
  box-shadow: 0 2px 10px rgba(96,165,250,0.22);
}
.hk-btn-primary:hover { transform: translateY(-1px); box-shadow: 0 4px 16px rgba(96,165,250,0.35); }

.hk-btn-secondary {
  padding: 9px 16px;
  border-radius: 9px;
  font-size: 13px;
  font-weight: 500;
  background: var(--surface);
  border: 1px solid var(--border);
  color: var(--text-2);
  cursor: pointer;
  transition: all var(--transition);
}
.hk-btn-secondary:hover { border-color: var(--border); color: var(--text); }

/* ── Archived list ── */
.hk-archived-list {
  padding: 16px 20px 20px;
  display: flex;
  flex-direction: column;
  gap: 10px;
  max-height: 420px;
  overflow-y: auto;
}

.hk-archived-empty {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 10px;
  padding: 32px;
  color: var(--text-3);
  text-align: center;
  font-size: 13px;
}

.hk-archived-item {
  background: var(--surface);
  border: 1px solid var(--border-soft);
  border-radius: 10px;
  padding: 12px;
}

.hk-archived-head {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: 10px;
}
.hk-archived-head h4 {
  margin: 0 0 4px;
  font-size: 13px;
  font-weight: 600;
  color: var(--text);
}
.hk-archived-desc { margin: 0; font-size: 12px; color: var(--text-3); }

.hk-restore-btn {
  display: inline-flex;
  align-items: center;
  gap: 5px;
  padding: 5px 10px;
  border-radius: 7px;
  font-size: 11.5px;
  font-weight: 500;
  background: rgba(52,211,153,0.1);
  border: 1px solid rgba(52,211,153,0.28);
  color: #34d399;
  cursor: pointer;
  white-space: nowrap;
  transition: all var(--transition);
  flex-shrink: 0;
}
.hk-restore-btn:hover { background: rgba(52,211,153,0.18); }

.hk-archived-meta {
  display: flex;
  gap: 10px;
  margin-top: 8px;
  font-size: 11px;
  color: var(--text-3);
}
.hk-archived-board {
  background: rgba(96,165,250,0.1);
  border: 1px solid rgba(96,165,250,0.22);
  color: #60a5fa;
  border-radius: 5px;
  padding: 1px 6px;
}
</style>
