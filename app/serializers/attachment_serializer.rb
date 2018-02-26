class AttachmentSerializer < ActiveModel::Serializer
  attributes :id, :pia_id, :file, :name, :mime_type, :comment, :created_at, :updated_at

  def file
    file = object.attached_file
    return {} if file.blank? || file.url.blank?
    file_path = File.join(Rails.root, file.url)
    return {} unless File.exist? file_path
    content = File.binread(file_path)
    "data:#{object.attached_file&.content_type};base64," + Base64.encode64(content)
  end

  def name
    object.attached_file&.file&.filename
  end

  def mime_type
    object.attached_file&.content_type
  end
end
