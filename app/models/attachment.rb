class Attachment < ApplicationRecord
  mount_uploader :attached_file, FileUploader
  belongs_to :pia, inverse_of: :attachments
end
