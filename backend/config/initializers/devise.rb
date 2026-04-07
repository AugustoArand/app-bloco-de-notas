Devise.setup do |config|
  config.mailer_sender = "notevault@example.com"
  require "devise/orm/active_record"
  config.case_insensitive_keys = [:email]
  config.strip_whitespace_keys = [:email]
  config.skip_session_storage = [:http_auth, :token_auth]
  config.stretches = Rails.env.test? ? 1 : 12
  config.expire_all_remember_me_on_sign_out = true
  config.password_length = 6..128
  config.email_regexp = /\A[^@\s]+@[^@\s]+\z/
  config.reset_password_within = 6.hours
  config.sign_out_via = :delete

  config.jwt do |jwt|
    jwt.secret = Rails.application.credentials.secret_key_base
    jwt.dispatch_requests = [
      ["POST", %r{^/auth/sign_in$}]
    ]
    jwt.revocation_requests = [
      ["DELETE", %r{^/auth/sign_out$}]
    ]
    jwt.expiration_time = 7.days.to_i
  end

  config.navigational_formats = []
  config.responder.error_status = :unprocessable_content
  config.responder.redirect_status = :see_other
end
