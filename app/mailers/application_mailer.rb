class ApplicationMailer < ActionMailer::Base
  default from: Rails.application.credentials.email_from || 'noreply@example.com'
  layout 'mailer'
end
