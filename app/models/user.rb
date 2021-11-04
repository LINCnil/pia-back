class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable, :rememberable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :secure_validatable, :lockable
  validates :uuid, presence: true
  
  validates :password, confirmation: true
  validates :password_confirmation, presence: true, on: :create
  validates :password_confirmation, presence: true, on: :update, unless: lambda { |user| user.password.blank? }

  before_validation :generate_uuid
  after_commit :update_user_pias_infos, on: :update

  has_many :access_grants,
           class_name: 'Doorkeeper::AccessGrant',
           foreign_key: :resource_owner_id,
           dependent: :destroy

  has_many :access_tokens,
           class_name: 'Doorkeeper::AccessToken',
           foreign_key: :resource_owner_id,
           dependent: :destroy

  def generate_uuid
    self.uuid = SecureRandom.uuid
  end

  def update_user_pias_infos
    user_pias = UserPia.where({user: self.id})

    user_pias.each do |user_pia|
      new_value = "#{self.firstname} #{self.lastname}"
      case user_pia.role
      when "author"
        user_pia.pia.author_name = new_value
      when "evaluator"
        user_pia.pia.evaluator_name = new_value
      when "validator"
        user_pia.pia.validator_name = new_value
      end
      user_pia.save
    end
  end
end
