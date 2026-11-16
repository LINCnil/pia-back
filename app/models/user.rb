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

  RANDOM_PASSWORD_CHARS = [*'a'..'z', *'A'..'Z', *'0'..'9', *'!@#$%^&*()-_=+[]{}<>?'.chars].freeze
  RANDOM_PASSWORD_LENGTH = 64
  RANDOM_PASSWORD_ATTEMPTS = 10

  # Uniformly random password, drawn again until the model's own password rules accept it, so they are not
  # restated here. Gives up rather than looping forever when the rules cannot be met with these characters.
  def self.random_password(random: SecureRandom)
    RANDOM_PASSWORD_ATTEMPTS.times do
      password = random.alphanumeric(RANDOM_PASSWORD_LENGTH, chars: RANDOM_PASSWORD_CHARS)
      return password if password_accepted?(password)
    end

    raise 'Could not generate a random password accepted by the password rules'
  end

  # Devise hashes a password as soon as it is assigned, so each candidate costs one hash.
  def self.password_accepted?(password)
    candidate = new(password: password, password_confirmation: password)
    candidate.validate
    candidate.errors[:password].empty?
  end
  private_class_method :password_accepted?

  def self.create_with_ldap(login, email)
    password = random_password
    create!(
      login: login,
      email: email.presence || login,
      password: password,
      password_confirmation: password,
      is_user: true
    )
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
