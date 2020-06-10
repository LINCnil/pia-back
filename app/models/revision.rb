class Revision < ApplicationRecord
  belongs_to :pia

  validates :pia, presence: true
  validates :export, presence: true
end
