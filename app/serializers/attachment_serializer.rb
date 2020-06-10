class AttachmentSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :pia_id, :comment, :created_at, :updated_at

  attribute :file do |answer|
    file_base64 = {}
    file = answer.attached_file
    if file.present? && file.url.present?
      file_path = File.join(Rails.root, file.url)
      if File.exist? file_path
        content = File.binread(file_path)
        file_base64 = "data:#{answer.attached_file&.content_type};base64," + Base64.encode64(content)
      end
    end
    file_base64
  end

  attribute :name do |answer|
    answer.attached_file&.file&.filename
  end

  attribute :mime_type do |answer|
    answer.attached_file&.content_type
  end
end
