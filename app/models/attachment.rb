class Attachment < ApplicationRecord
  mount_base64_uploader :attached_file, FileUploader, file_name: -> (a) { a.filename }
  belongs_to :pia, inverse_of: :attachments

  attr_accessor :filename
end
