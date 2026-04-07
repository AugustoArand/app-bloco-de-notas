Rails.application.configure do
  config.cache_classes = false
  config.eager_load = false
  config.consider_all_requests_local = true
  config.server_timing = true
  config.action_mailer.default_url_options = { host: "localhost", port: 3000 }

  # ActiveStorage: usa Cloudflare R2 em todos os ambientes
  config.active_storage.service = :cloudflare_r2
end
