class UsersController < ApplicationController
  before_action :authorize_user, except: :check_uuid

  def index
    users = []
    User.all.find_each do |user|
      users << serialize(user)
    end
    render json: users
  end

  def create
    user = User.new(user_params)
    password = SecureRandom.hex(16)

    user.password = password
    user.password_confirmation = password

    if params["user"]["access_type"]
      user.is_technical_admin = params["user"]["access_type"].include? "technical"
      user.is_functional_admin = params["user"]["access_type"].include? "functional"
      user.is_user = params["user"]["access_type"].include? "user"
    end

    if user.valid?
      user.lock_access!
      user.save
      UserMailer.with(user: user).uuid_created.deliver_now
    else
      return head 406 # Not acceptable
    end

    render json: serialize(user)
  end

  def update
    user = User.find(params[:id])
    user.update(user_params)

    if params["user"]["access_type"]
      user.is_technical_admin = params["user"]["access_type"].include? "technical"
      user.is_functional_admin = params["user"]["access_type"].include? "functional"
      user.is_user = params["user"]["access_type"].include? "user"
    end

    if user.valid?
      user.save
    else
      return head 406 # Not acceptable
    end
    render json: serialize(user)
  end

  def check_uuid
    user = User.find_by(uuid: params[:uuid])
    return head 401 unless user

    user.unlock_access!
    user.generate_uuid()

    if user.valid?
      user.save
      render json: serialize(user)
    else
      return head 406 # Not acceptable
    end
  end

  def update_uuid
    user = User.find_by(email: params[:email])
    return head 404 unless user

    user.generate_uuid()
    
    if user.valid?
      user.save
      UserMailer.with(user: user).uuid_updated.deliver_now
      render json: serialize(user)
    else
      return head 406 # Not acceptable
    end
  end

  def change_password
    user = User.find(params[:id])
    return head 404 unless user

    if user.valid_password?(params[:password])
      return head 200
    else
      return head 500
    end
  end

  def destroy
    user = User.find(params[:id])
    user.destroy
    head 204
  end

  private

  def authorize_user
    authorize User
  end

  def serialize(user)
    UserSerializer.new(user).serializable_hash.dig(:data, :attributes)
  end

  def user_params
    params.require(:user).permit(:firstname, :lastname, :email, :password, :password_confirmation, :uuid)
  end
end
