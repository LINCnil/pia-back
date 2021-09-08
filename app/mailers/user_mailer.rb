class UserMailer < ApplicationMailer
    def uuid_created
      @user = params[:user]
  
      mail(to: @user.email, subject: "Votre compte Pia à été créé")
    end
end