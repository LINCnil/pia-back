FactoryBot.define do
  factory :user do
    firstname {'user'}
    lastname {'nothing'}
    password {[*'0'..'9', *'a'..'z', *'A'..'Z', *'!'..'?'].sample(16).join}
    password_confirmation {password}
    is_user { true }
    email { 'user@nothing.com' }

    factory :user_admin do
      is_functional_admin { true }
      is_technical_admin { true }
    end

    factory :user_functional do
      is_functional_admin { true }
      is_technical_admin { false }
    end
  end
end
