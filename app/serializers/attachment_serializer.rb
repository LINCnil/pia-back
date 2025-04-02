class AttachmentSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :pia_id, :pia_signed, :comment, :created_at, :updated_at

  attribute :file do |object|
    object.file.url if object.file.attached?
  end

  attribute :name do |object|
    object.file.filename.to_s if object.file.attached?
  end

  attribute :mime_type do |object|
    object.file.content_type if object.file.attached?
  end
end
