ActionMailer::Base.smtp_settings = {
  address: Rails.application.credentials.smtp_address,
  port: Rails.application.credentials.smtp_port,
  domain: Rails.application.credentials.smtp_domain,
  user_name: Rails.application.credentials.smtp_user_name,
  password: Rails.application.credentials.smtp_password,
  authentication: Rails.application.credentials.smtp_authentication,
  enable_starttls_auto: Rails.application.credentials.smtp_enable_starttls_auto
}
