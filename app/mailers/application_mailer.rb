class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("EMAIL_FROM", nil)
  layout 'mailer'
end
