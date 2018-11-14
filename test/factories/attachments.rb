FactoryBot.define do
  factory :attachment do
    pia
    attached_file { Rack::Test::UploadedFile.new(Rails.root.join('test', 'files', 'test_file.txt'), 'text/plain') }
  end
end
