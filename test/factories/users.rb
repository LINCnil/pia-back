FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "test#{n}@example.com" }
    firstname { 'John' }
    lastname { 'Doe' }
    password { 'Password123-' }
    password_confirmation { 'Password123-' }
    is_technical_admin { true }
    is_functional_admin { true }
    is_user { true }
  end
end
