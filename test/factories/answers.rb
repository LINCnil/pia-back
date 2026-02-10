FactoryBot.define do
  factory :answer do
    sequence(:reference_to) { |n| "1.#{n}.1" }
    data { { 'text' => 'Sample answer text' } }
    pia

    trait :with_gauge do
      data { { 'text' => 'Answer with gauge', 'gauge' => 2 } }
    end

    trait :empty do
      data { {} }
    end
  end
end
