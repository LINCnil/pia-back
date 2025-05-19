class Attachment < ApplicationRecord
  has_one_attached :file
  belongs_to :pia, inverse_of: :attachments
end
