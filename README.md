# NoteVault 🗒️

> Seu bloco de notas personalizado. Inspirado no Notion e Obsidian, com a sua cara.

**Stack:** Ruby on Rails 8 (API) + Vue.js 3 + Vite

**Paleta:** Preto profundo + Roxo vibrante

---

## ✨ Funcionalidades

- **Editor Rico** com Tiptap: Títulos (H1/H2/H3), negrito, itálico, sublinhado, destaque
- **Listas** com marcadores, numeradas e **lista de tarefas** com checkboxes
- **Blocos de código** com destaque e citações (blockquote)
- **Sumário Automático** gerado em tempo real a partir dos headings
- **Upload de Imagens** por drag-and-drop ou botão na toolbar
- **Autosave** — salva automaticamente 1,2s após parar de digitar
- **Cadernos** para organizar suas notas por tema
- **Busca** full-text por título e conteúdo
- **Autenticação** com JWT (login e cadastro)
- Design responsivo e animações suaves

---

## 🚀 Rodando o projeto

### Backend (Rails API)

```bash
cd backend
bundle install
rails db:migrate
rails db:seed   # cria usuário de teste
rails server    # http://localhost:3000
```

**Usuário de teste:** `teste@notevault.com` / `123456`

### Frontend (Vue.js)

```bash
cd frontend
npm install
npm run dev     # http://localhost:5173
```

---

## 📁 Estrutura

```
app-bloco-notas/
├── backend/              # Rails 8 API
│   ├── app/
│   │   ├── controllers/
│   │   │   ├── api/v1/   # Notebooks, Notes, Users
│   │   │   └── users/    # Devise Sessions/Registrations
│   │   └── models/       # User, Notebook, Note
│   ├── config/
│   │   ├── routes.rb
│   │   └── initializers/ # Devise JWT, CORS
│   └── db/
└── frontend/             # Vue.js 3 + Vite
    └── src/
        ├── assets/       # Design system (main.css)
        ├── components/   # AppSidebar, EditorToolbar, TableOfContents
        ├── views/        # Login, Register, Home, NoteEditor
        ├── stores/       # Auth, Notebooks, Notes (Pinia)
        ├── services/     # Axios instance
        └── router/       # Vue Router + guards
```

---

## 🎨 Design System

| Token | Valor |
|---|---|
| `--bg` | `#0a0a0f` (preto profundo) |
| `--surface` | `#11111a` |
| `--panel` | `#17172a` |
| `--purple-1` | `#7c3aed` (roxo primário) |
| `--purple-2` | `#9f67ff` |
| `--purple-3` | `#c4b5fd` |

**Fontes:** Inter (UI) + JetBrains Mono (código)
