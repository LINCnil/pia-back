# frozen_string_literal: true

class AttachmentSerializer < Blueprinter::Base
  identifier :id
  fields :pia_id, :pia_signed, :comment, :created_at, :updated_at

  field :file do |attachment|
    attachment.file.url if attachment.file.attached?
  end

  field :name do |attachment|
    attachment.file.filename.to_s if attachment.file.attached?
  end

  field :mime_type do |attachment|
    attachment.file.content_type if attachment.file.attached?
  end
end
