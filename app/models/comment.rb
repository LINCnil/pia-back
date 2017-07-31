class Comment < ApplicationRecord
  belongs_to :pia, inverse_of: :comments
  validates :reference_to, presence: true
end
