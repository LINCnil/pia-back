class KnowledgeBase < ApplicationRecord
  include ActionView::Helpers::SanitizeHelper
  validates :name, presence: true
  validates :author, presence: true
  validates :contributors, presence: true
  has_many :knowledges, dependent: :destroy
  after_initialize :overwrite_to_safety_values

  private

  def overwrite_to_safety_values
    self.name = sanitize self[:name]
    self.author = sanitize self[:author]
    self.contributors = sanitize self[:contributors]
  end
end
