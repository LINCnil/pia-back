require 'test_helper'

class AttachmentTest < ActiveSupport::TestCase
  setup do
    @pia = FactoryBot.create(:pia)
    @test_file = Rack::Test::UploadedFile.new(Rails.root.join('test', 'fixtures', 'files', 'test_file.txt'), 'text/plain')
  end

  test "should have file" do
    attachment = FactoryBot.create(:attachment, pia: @pia)
    assert attachment.file.attached?
    assert_equal 'test_file.txt', attachment.file.filename.to_s
    assert_equal 'text/plain', attachment.file.content_type
  end

  test "should attach a file" do
    attachment = Attachment.new(pia: @pia)
    attachment.file.attach(@test_file)

    assert attachment.file.attached?
    assert_equal 'test_file.txt', attachment.file.filename.to_s
    assert_equal 'text/plain', attachment.file.content_type
  end

  test "should replace attached file" do
    attachment = FactoryBot.create(:attachment, pia: @pia)
    original_blob_id = attachment.file.blob.id

    # Attach a new file
    new_file = Rack::Test::UploadedFile.new(Rails.root.join('test', 'fixtures',  'files', 'test_file.txt'), 'text/plain')
    attachment.file.attach(new_file)

    # Reload to ensure we're getting the latest data
    attachment.reload

    assert attachment.file.attached?
    assert_not_equal original_blob_id, attachment.file.blob.id
  end

  test "should purge attached file" do
    attachment = FactoryBot.create(:attachment, pia: @pia)
    assert attachment.file.attached?

    attachment.file.purge
    attachment.reload

    assert_not attachment.file.attached?
  end

  test "should read file content" do
    attachment = FactoryBot.create(:attachment, pia: @pia)

    content = attachment.file.download
    assert_equal "This is a test\nThis is a test\n", content
  end
end
