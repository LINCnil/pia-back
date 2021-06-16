class KnowledgeBase < ApplicationRecord
  validates :name, presence: true
  validates :author, presence: true
  validates :contributors, presence: true
  has_many :knowledges
end
