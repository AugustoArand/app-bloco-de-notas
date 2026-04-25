import { defineStore } from 'pinia'
import api from '@/services/api'

export const useKanbanStore = defineStore('kanban', {
    state: () => ({
        isOpen: false,
        initialized: false,
        loading: false,
        boards: [],
        archivedTasks: []
    }),

    getters: {
        totalTasks: (state) => state.boards.reduce((sum, board) => sum + board.cards.length, 0)
    },

    actions: {
        async init() {
            if (this.initialized) return

            await this.fetchBoards()
            this.initialized = true
        },

        async fetchBoards() {
            this.loading = true
            try {
                const { data } = await api.get('/api/v1/kanban_boards')
                this.boards = Array.isArray(data) ? data : []
            } finally {
                this.loading = false
            }
        },

        async fetchArchivedTasks() {
            const { data } = await api.get('/api/v1/kanban_tasks/archived')
            this.archivedTasks = Array.isArray(data) ? data : []
            return this.archivedTasks
        },

        async toggle() {
            await this.init()
            this.isOpen = !this.isOpen
        },

        async open() {
            await this.init()
            this.isOpen = true
        },

        close() {
            this.isOpen = false
        },

        async createBoard(title) {
            const parsedTitle = String(title || '').trim()
            if (!parsedTitle) return null

            const { data } = await api.post('/api/v1/kanban_boards', {
                kanban_board: { title: parsedTitle }
            })

            await this.fetchBoards()
            return data
        },

        async renameBoard(boardId, title) {
            const parsedTitle = String(title || '').trim()
            if (!parsedTitle) return false

            await api.patch(`/api/v1/kanban_boards/${boardId}`, {
                kanban_board: { title: parsedTitle }
            })

            await this.fetchBoards()
            return true
        },

        async removeBoard(boardId) {
            await api.delete(`/api/v1/kanban_boards/${boardId}`)
            await this.fetchBoards()
            return true
        },

        async createTask(boardId, payload) {
            const title = String(payload?.title || '').trim()
            if (!title) return null

            const { data } = await api.post(`/api/v1/kanban_boards/${boardId}/kanban_tasks`, {
                kanban_task: {
                    title,
                    description: String(payload?.description || ''),
                    priority: payload?.priority || 'normal'
                }
            })

            await this.fetchBoards()
            return data
        },

        async updateTask(boardId, taskId, payload) {
            const parsedTitle = String(payload?.title || '').trim()
            if (!parsedTitle) return false

            await api.patch(`/api/v1/kanban_tasks/${taskId}`, {
                kanban_task: {
                    title: parsedTitle,
                    description: String(payload?.description || ''),
                    priority: payload?.priority || 'normal',
                    kanban_board_id: boardId
                }
            })

            await this.fetchBoards()
            return true
        },

        async removeTask(_boardId, taskId) {
            await api.delete(`/api/v1/kanban_tasks/${taskId}`)
            await this.fetchBoards()
            return true
        },

        async moveTask(taskId, _fromBoardId, toBoardId, toIndex = null) {
            await api.patch(`/api/v1/kanban_tasks/${taskId}`, {
                kanban_task: {
                    kanban_board_id: toBoardId,
                    position: typeof toIndex === 'number' ? toIndex : 9999
                }
            })

            await this.fetchBoards()
            return true
        },

        async moveTaskToNextBoard(taskId, currentBoardId) {
            const boardIndex = this.boards.findIndex((item) => item.id === currentBoardId)
            if (boardIndex === -1 || boardIndex >= this.boards.length - 1) return false

            const nextBoard = this.boards[boardIndex + 1]
            return this.moveTask(taskId, currentBoardId, nextBoard.id, 9999)
        },

        async archiveTask(taskId) {
            await api.patch(`/api/v1/kanban_tasks/${taskId}/archive`)
            await Promise.all([this.fetchBoards(), this.fetchArchivedTasks()])
            return true
        },

        async restoreTask(taskId, boardId = null) {
            const payload = boardId ? { kanban_task: { kanban_board_id: boardId } } : {}
            await api.patch(`/api/v1/kanban_tasks/${taskId}/restore`, payload)
            await Promise.all([this.fetchBoards(), this.fetchArchivedTasks()])
            return true
        }
    }
})
