class UuidMailer < ApplicationMailer
    def send_email
      @user = params[:user]
  
      mail(to: @user.email, subject: "Votre compte Pia à été créé")
    end
end