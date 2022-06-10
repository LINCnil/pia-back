class UsersController < ApplicationController
  before_action :authorize_user, except: %i[check_uuid password_forgotten change_password]

  def index
    users = []
    User.all.find_each do |user|
      users << serialize(user)
    end
    render json: users
  end

  def create
    user = User.new(user_params)

    password = [*'0'..'9', *'a'..'z', *'A'..'Z', *'!'..'?'].sample(16).join
    user.password = password
    user.password_confirmation = password

    if params['user']['access_type']
      user.is_technical_admin = params['user']['access_type'].include? 'technical'
      user.is_functional_admin = params['user']['access_type'].include? 'functional'
      user.is_user = params['user']['access_type'].include? 'user'
    end

    if user.valid? # change uuid
      user.lock_access! # save user
      UserMailer.with(user: user).uuid_created.deliver_now
      render json: serialize(user)
    else
      render json: user.errors.to_json, status: :not_acceptable
    end
  end

  def update
    user = User.find(params[:id])
    email = user.email
    user.update(user_params)

    if params['user']['access_type']
      user.is_technical_admin = params['user']['access_type'].include? 'technical'
      user.is_functional_admin = params['user']['access_type'].include? 'functional'
      user.is_user = params['user']['access_type'].include? 'user'
    end

    if user.valid? # change uuid
      user.save
      UserMailer.with(user: user).uuid_updated.deliver_now if user.access_locked? && user.email != email # send email for to locked users
      render json: serialize(user)
    else
      render json: user.errors.to_json, status: :not_acceptable
    end
  end

  def check_uuid
    user = User.find_by(uuid: params[:uuid])
    return head :not_found unless user

    # render user data
    render json: serialize(user)
  end

  def password_forgotten
    user = User.find_by(email: params[:email])

    if user.present?
      if user.access_locked?
        render json: {}, status: :locked
      elsif user.valid?
        user.save
        UserMailer.with(user: user).uuid_updated.deliver_now
        render json: {} # change uuid
      else
        render json: {}, status: :not_acceptable # Not acceptable
      end
    else
      render json: {}, status: :not_found
    end
  end

  def change_password
    user = User.find_by(id: params[:id], uuid: params[:uuid])
    return head :not_found unless user

    user.password = params['password']
    user.password_confirmation = params['password_confirmation']

    if user.valid? # change uuid
      user.unlock_access! # save user
      head :no_content
    else
      render json: {}, status: :not_acceptable
    end
  end

  def destroy
    user = User.find(params[:id])
    user.destroy
    head :no_content
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
          .except('access_type')
  end
end
