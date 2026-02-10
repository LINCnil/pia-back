FactoryBot.define do
  factory :revision do
    export { { 'pia' => { 'name' => 'Sample PIA', 'status' => 0 } }.to_json }
    pia

    trait :with_full_export do
      export do
        {
          'pia' => {
            'name' => 'Complete PIA Export',
            'status' => 1,
            'answers' => [],
            'evaluations' => [],
            'measures' => [],
            'comments' => []
          }
        }.to_json
      end
    end

    trait :minimal do
      export { '{}' }
    end
  end
end
