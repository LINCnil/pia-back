FactoryBot.define do
  factory :knowledge do
    name { "MyString" }
    slug { "MyString" }
    filters { "MyString" }
    category { "MyString" }
    placeholder { "MyString" }
    description { "MyText" }
    items { "" }
    knowledge_base { nil }
  end
end
