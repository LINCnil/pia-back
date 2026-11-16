FactoryBot.define do
  factory :comment do
    sequence(:reference_to) { |n| "1.#{n}.1" }
    description { 'Sample comment description' }
    for_measure { false }
    pia
    user

    trait :for_measure do
      for_measure { true }
    end
  end
end
