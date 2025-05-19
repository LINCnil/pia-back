FactoryBot.define do
  factory :attachment do
    pia
    file { Rack::Test::UploadedFile.new(Rails.root.join('test', 'fixtures', 'files', 'test_file.txt'), 'text/plain') }
  end
end
