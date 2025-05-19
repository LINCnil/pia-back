FactoryBot.define do
  factory :user do
    email { 'test@example.com' }
    password { 'Password123-' }
    password_confirmation { 'Password123-' }
    is_technical_admin { true }
    is_functional_admin { true }
    is_user { true }
  end
end
