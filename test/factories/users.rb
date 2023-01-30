FactoryBot.define do
  factory :user do
    transient do
      role {nil}
      is_user { true }
      is_functional_admin { false }
      is_technical_admin { false }
    end

    email { "user#{role.present? ? '+' +  role : nil}@test.com" }
    firstname {'user'}
    lastname {role ? role : 'nothing'}
    password {[*'0'..'9', *'a'..'z', *'A'..'Z', *'!'..'?'].sample(16).join}
    password_confirmation {password}
  end
end
