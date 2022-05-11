class KnowledgeBase < ApplicationRecord
  include ActionView::Helpers::SanitizeHelper
  validates :name, presence: true
  validates :author, presence: true
  validates :contributors, presence: true
  has_many :knowledges, dependent: :destroy
  after_initialize :overwrite_to_safety_values

  private

  def overwrite_to_safety_values
    self.name = sanitize read_attribute(:name)
    self.author = sanitize read_attribute(:author)
    self.contributors = sanitize read_attribute(:contributors)
  end
end
