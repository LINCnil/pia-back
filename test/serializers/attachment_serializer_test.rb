require 'test_helper'

class AttachmentSerializerTest < ActiveSupport::TestCase
  include FactoryBot::Syntax::Methods

  def setup
    @attachment = create(:attachment)
  end

  test "serializes basic attachment attributes" do
    data = AttachmentSerializer.render_as_hash(@attachment)

    assert_equal @attachment.id, data[:id]
    assert_equal @attachment.pia_id, data[:pia_id]
    assert_equal @attachment.pia_signed, data[:pia_signed]
    assert_equal @attachment.comment, data[:comment]
    assert_equal @attachment.created_at, data[:created_at]
    assert_equal @attachment.updated_at, data[:updated_at]
  end

  test "serializes nil file attributes when no file is attached" do
    attachment_without_file = create(:attachment, file: nil)
    data = AttachmentSerializer.render_as_hash(attachment_without_file)

    assert_nil data[:file]
    assert_nil data[:name]
    assert_nil data[:mime_type]
  end
end
