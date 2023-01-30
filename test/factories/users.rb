FactoryBot.define do
  factory :user do
    transient do
      is_user { true }
      is_functional_admin { false }
      is_technical_admin { false }
    end

    email { "user#{role.present? ? '+' +  role : nil}@test.com" }
    firstname {'user'}
    lastname {role ? role : 'nothing'}
    is_user {is_user}
    is_functional_admin {is_functional_admin}
    is_technical_admin {is_technical_admin}
  end
end
