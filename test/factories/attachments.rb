FactoryBot.define do
  factory :attachment do
    pia
    pia_signed { false }
    comment { nil }
    file { Rack::Test::UploadedFile.new(Rails.root.join('test', 'fixtures', 'files', 'test_file.txt'), 'text/plain') }

    trait :signed do
      pia_signed { true }
      comment { 'PIA signed and approved' }
    end

    trait :without_file do
      file { nil }
    end

    trait :with_comment do
      comment { 'Additional comment on this attachment' }
    end
  end
end
