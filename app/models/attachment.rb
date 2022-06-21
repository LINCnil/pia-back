class Attachment < ApplicationRecord
  mount_base64_uploader :attached_file, FileUploader, file_name: ->(a) { a.name }
  belongs_to :pia, inverse_of: :attachments

  attr_accessor :file, :name, :mime_type
end
