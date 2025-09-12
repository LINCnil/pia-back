FactoryBot.define do
  factory :user_pia do
    association :user
    association :pia
    role { 'author' }
  end
end