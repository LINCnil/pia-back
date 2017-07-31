class Answer < ApplicationRecord
  belongs_to :pia, inverse_of: :answers
  validates :reference_to, presence: true
end
