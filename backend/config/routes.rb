Rails.application.routes.draw do
  devise_for :users,
    controllers: {
      sessions: "users/sessions",
      registrations: "users/registrations"
    },
    path: "auth",
    path_names: {
      sign_in: "sign_in",
      sign_out: "sign_out",
      registration: "sign_up"
    }

  namespace :api do
    namespace :v1 do
      get "me", to: "users#me"
      post "users/cover", to: "users#upload_cover"
      delete "users/cover", to: "users#remove_cover"
      post "ai/summarize", to: "ai#summarize"
      post "ai/translate_text", to: "ai#translate_text"
      post "ai/translate_terms", to: "ai#translate_terms"
      post "ai/generate_text", to: "ai#generate_text"

      resources :tags
      resources :quick_notes
      resources :kanban_boards, only: [:index, :create, :update, :destroy] do
        resources :kanban_tasks, only: [:create], shallow: true
      end
      resources :kanban_tasks, only: [:update, :destroy]

      # Recent and global search (must come BEFORE the shallow notes resources)
      get "notes/recent", to: "notes#recent"
      get "notes/search", to: "notes#search"

      resources :notebooks do
        resources :notes, shallow: true do
          post "upload_image", on: :member
        end
      end
    end
  end

  # Health check
  get "up", to: "rails/health#show", as: :rails_health_check
end
