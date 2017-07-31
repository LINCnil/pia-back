class Measure < ApplicationRecord
  belongs_to :pia, inverse_of: :measures
end
