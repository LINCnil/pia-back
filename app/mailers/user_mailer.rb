class UserMailer < ApplicationMailer
  def uuid_created
    @user = params[:user]

    mail(to: @user.email, subject: I18n.t('email_new_account_uuid.subject'))
  end

  def uuid_updated
    @user = params[:user]

    mail(to: @user.email, subject: I18n.t('email_recover_account_uuid.subject'))
  end

  def section_ready_for_evaluation
    @evaluator = params[:evaluator]

    mail(to: @evaluator.email, subject: I18n.t('email_section_ready_for_evaluation.subject'))
  end
end
