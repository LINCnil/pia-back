class ApplicationMailer < ActionMailer::Base
  default from: Rails.application.credentials.email_from
  layout 'mailer'
end
