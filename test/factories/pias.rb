FactoryBot.define do
  factory :pia do
    status { 0 }
    name { 'PIA ONE' }
    author_name { 'William S. Burroughs' }
    evaluator_name { 'William Lee' }
    validator_name { 'Norman Mailer' }
    dpo_status { 0 }
    dpo_opinion { 'Hard to beat' }
    concerned_people_opinion { 'Beat too hard' }
    rejection_reason { 'Lack of coherency' }
    applied_adjustments { 'Cut up method' }
    is_example { 0 }
    dpos_names { 'Pierre, Paul, Jacques, Daniel' }
    people_names { 'Lise, Bloody, Marie' }
    concerned_people_searched_opinion { false }
    concerned_people_searched_content { 'Content concerned people' }
  end
end
