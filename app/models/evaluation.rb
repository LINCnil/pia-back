class Evaluation < ApplicationRecord
  belongs_to :pia, inverse_of: :evaluations
  validates :reference_to, presence: true
end
