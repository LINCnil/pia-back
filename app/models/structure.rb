class Structure < ApplicationRecord
  has_many :pias, dependent: :nullify
end
