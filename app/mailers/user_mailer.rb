class UserMailer < ApplicationMailer
    def uuid_created
      @user = params[:user]
  
      mail(to: @user.email, subject: I18n.t 'mail.subject')
    end
end