class UsersController < ApplicationController
  before_action :authorize_user

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
    user.uuid = SecureRandom.uuid

    if params["user"]["access_type"]
      user.is_technical_admin = params["user"]["access_type"].include? "technical"
      user.is_functional_admin = params["user"]["access_type"].include? "functional"
      user.is_user = params["user"]["access_type"].include? "user"
    end

    if user.valid?
      user.lock_access!
      user.save
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
    user = User.find(params[:id])
    if user && user.uuid == params[:uuid]
      user.unlock_access!
      return head 200
    else
      return head 401
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
