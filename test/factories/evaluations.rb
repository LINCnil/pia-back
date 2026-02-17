FactoryBot.define do
  factory :evaluation do
    sequence(:reference_to) { |n| "1.#{n}.1" }
    status { 0 }
    action_plan_comment { 'Action plan comment' }
    evaluation_comment { 'Evaluation comment' }
    person_in_charge { 'John Doe' }
    global_status { 0 }
    gauges { {} }
    pia

    trait :validated do
      global_status { 2 }
      evaluation_date { Date.today }
    end

    trait :rejected do
      global_status { 1 }
      evaluation_comment { 'Needs improvements' }
    end

    trait :with_dates do
      evaluation_date { Date.today }
      estimated_implementation_date { Date.today + 30.days }
    end
  end
end
