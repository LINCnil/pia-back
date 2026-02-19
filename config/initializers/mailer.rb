ActionMailer::Base.smtp_settings = {
	address: ENV.fetch("SMTP_ADDRESS", "localhost"),
	port: ENV.fetch("SMTP_PORT", 587),
	openssl_verify_mode: 'none',
	user_name: ENV.fetch("SMTP_USERNAME", nil),
	password: ENV.fetch("SMTP_PASSWORD", nil),
	domain: ENV.fetch("SMTP_DOMAIN", nil),
	# enable_starttls_auto: Rails.application.credentials.smtp_enable_starttls_auto,
	# authentication: :plain,
}
