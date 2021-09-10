class UserMailer < ApplicationMailer
  def uuid_created
    @user = params[:user]

    mail(to: @user.email, subject: I18n.t('email_new_account_uuid.subject'))
  end
end
