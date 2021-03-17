FactoryBot.define do
  factory :knowledge do
    name { "MyString" }
    slug { "MyString" }
    filters { "MyString" }
    category { "MyString" }
    placeholder { "MyString" }
    description { "MyText" }
    items { [1,2,3] }
    knowledge_base
  end
end
