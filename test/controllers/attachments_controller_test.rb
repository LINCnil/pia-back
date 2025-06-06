require 'test_helper'

class AttachmentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @attachment = FactoryBot.create(:attachment)
    @pia = @attachment.pia
  end

  test 'should get index' do
    get pia_attachments_url(@pia), headers: { 'Authorization' => "Bearer #{doorkeeper_token}" }, as: :json
    assert_response :success
  end

  test "should create attachment" do
    assert_difference('Attachment.count') do
      post pia_attachments_url(@pia),
           params: { attachment: { file: Rack::Test::UploadedFile.new(Rails.root.join('test', 'fixtures', 'files', 'test_file.txt')) } },
           headers: { 'Authorization' => "Bearer #{doorkeeper_token}" },
           as: :json
    end

    assert_response 201
  end

  test 'should show attachment' do
    get pia_attachment_url(id: @attachment.id, pia_id: @pia.id), headers: { 'Authorization' => "Bearer #{doorkeeper_token}" }, as: :json
    assert_response :success
  end

  test 'should destroy attachment' do
    assert_difference('Attachment.count', -1) do
      delete pia_attachment_url(id: @attachment.id, pia_id: @pia.id), headers: { 'Authorization' => "Bearer #{doorkeeper_token}" }, as: :json
    end

    assert_response 204
  end
end
