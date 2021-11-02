class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable, :rememberable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :secure_validatable, :lockable
  validates :uuid, presence: true
  
  validates :password, confirmation: true
  validates :password_confirmation, presence: true, on: :create
  validates :password_confirmation, presence: true, on: :update, unless: lambda { |user| user.password.blank? }


  before_validation :generate_uuid
  # after_update :generate_uuid, if: self.changed.include?("password")

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
end
