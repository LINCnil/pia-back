FactoryBot.define do
  factory :knowledge do
    sequence(:name) { |n| "Knowledge Item #{n}" }
    sequence(:slug) { |n| "knowledge-item-#{n}" }
    filters { 'category1,category2' }
    category { 'General' }
    placeholder { 'Enter knowledge details' }
    description { 'This is a knowledge base item description' }
    items { [
      { 'title' => 'Item 1', 'content' => 'Content 1' },
      { 'title' => 'Item 2', 'content' => 'Content 2' }
    ] }
    knowledge_base

    trait :with_links do
      items { [
        { 'title' => 'Documentation', 'link' => 'https://example.com/docs' },
        { 'title' => 'Guide', 'link' => 'https://example.com/guide' }
      ] }
    end

    trait :minimal do
      items { [] }
      description { '' }
    end
  end
end
