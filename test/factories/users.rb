FactoryBot.define do
  factory :user do
    email { 'test@example.com' }
    password { 'Password123-' }
    password_confirmation { 'Password123-' }
  end
end
