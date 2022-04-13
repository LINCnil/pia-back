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
    @pia_name = params[:pia] ? params[:pia].name : ''
    @evaluator = params[:evaluator]

    mail(to: @evaluator.email, subject: I18n.t('section_ready_for_evaluation.subject'))
  end

  def section_ready_for_validation
    @pia_name = params[:pia] ? params[:pia].name : ''
    @validator = params[:validator]

    mail(to: @validator.email, subject: I18n.t('section_ready_for_validation.subject'))
  end
end
