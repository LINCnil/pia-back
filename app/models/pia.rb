class Pia < ApplicationRecord
  has_many :answers, inverse_of: :pia
  has_many :comments, inverse_of: :pia
  has_many :evaluations, inverse_of: :pia
  has_many :measures, inverse_of: :pia
  validates :name, presence: true
end
