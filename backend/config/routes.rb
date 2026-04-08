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

      resources :tags

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

  # Handle CORS preflight for all routes
  match '*path', via: :options, to: proc { |env|
    origin = env['HTTP_ORIGIN'] || '*'
    [200, {
      'Access-Control-Allow-Origin'   => origin,
      'Access-Control-Allow-Methods'  => 'GET, POST, PUT, PATCH, DELETE, OPTIONS, HEAD',
      'Access-Control-Allow-Headers'  => 'Content-Type, Authorization, Accept',
      'Access-Control-Expose-Headers' => 'Authorization',
      'Access-Control-Max-Age'        => '600',
      'Content-Type'                  => 'text/plain'
    }, ['']]
  }

  # Health check
  get "up", to: "rails/health#show", as: :rails_health_check
end
