FactoryBot.define do
  factory :structure do
    sequence(:name) { |n| "Structure #{n}" }
    sequence(:sector_name) { |n| "Sector #{n}" }
    data { { "sections": [{ "items": [{ "questions": {} }] }] } }

    trait :with_complex_data do
      data do
        {
          "sections": [
            {
              "id": 1,
              "title": "Context",
              "items": [
                {
                  "id": 1,
                  "questions": {
                    "question1": "What is the purpose?",
                    "question2": "Who are the stakeholders?"
                  }
                }
              ]
            }
          ]
        }
      end
    end

    trait :minimal do
      data { {} }
    end
  end
end
