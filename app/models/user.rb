class User < ApplicationRecord
  has_many :user_pias, dependent: :destroy
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable, :rememberable and :omniauthable

  devise :database_authenticatable, :registerable, :recoverable, :secure_validatable, :lockable
  validates :uuid, presence: true
  validates :password, confirmation: true
  validates :password_confirmation, presence: true, on: :create
  validates :password_confirmation, presence: true, on: :update, unless: ->(user) { user.password.blank? }

  before_validation :generate_uuid
  after_commit :update_user_pias_infos, on: :update

  # validates uniqueness of login only if is present
  validate :validate_login_uniqueness, if: ->(user) { user.login.present? }

  has_many :access_grants,
           class_name: 'Doorkeeper::AccessGrant',
           foreign_key: :resource_owner_id,
           dependent: :destroy

  has_many :access_tokens,
           class_name: 'Doorkeeper::AccessToken',
           foreign_key: :resource_owner_id,
           dependent: :destroy

  def validate_login_uniqueness
    errors.add(:login, :taken) if User.where(login: login).where.not(id: id).exists?
  end

  def check_ldap_email
    if email.blank?
      mail = Devise::LDAP::Adapter.get_ldap_param(login, 'mail')
      self.email = if mail.present?
                     mail.first
                   else # No email, use login
                     login
                   end
    end
    self.is_user = true
  end

  def self.check_ldap_credentials(login, password)
    Devise::LDAP::Adapter.valid_credentials?(login, password)
  end

  # create user with ldap
  def self.create_with_ldap(login)
    user = User.new
    user.login = login

    password = [*'0'..'9', *'a'..'z', *'A'..'Z', *'!'..'?'].sample(16).join
    user.password = password
    user.password_confirmation = password
    user.check_ldap_email
    user.generate_uuid
    user.save
    user
  end

  def generate_uuid
    self.uuid = SecureRandom.uuid
  end

  def update_user_pias_infos
    user_pias = UserPia.where(user_id: id)

    user_pias.each do |user_pia|
      new_value = "#{firstname} #{lastname}"
      pia = user_pia.pia
      case user_pia.role
      when 'author'
        pia.author_name = new_value
      when 'evaluator'
        pia.evaluator_name = new_value
      when 'validator'
        pia.validator_name = new_value
      end
      pia.save
    end
  end
end
