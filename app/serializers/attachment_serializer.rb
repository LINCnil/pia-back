class AttachmentSerializer < ActiveModel::Serializer
  attributes :id, :pia_id, :attached_file, :created_at, :updated_at

  def attached_file
    {
      url: object.attached_file.url,
      name: File.basename(object.attached_file.url),
      content_type: object.attached_file.content_type
    }
  end
end
