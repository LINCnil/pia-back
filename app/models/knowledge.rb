class Knowledge < ApplicationRecord
  belongs_to :knowledge_base

  validates :name, presence: true
  validates :knowledge_base, presence: true
end
