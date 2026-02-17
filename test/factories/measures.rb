FactoryBot.define do
  factory :measure do
    sequence(:title) { |n| "Measure #{n}" }
    content { 'Measure content describing the action to take' }
    placeholder { 'Enter measure details here' }
    pia

    trait :empty do
      content { '' }
    end
  end
end
