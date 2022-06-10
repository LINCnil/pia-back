class Knowledge < ApplicationRecord
  include ActionView::Helpers::SanitizeHelper
  belongs_to :knowledge_base

  validates :name, presence: true
  validates :knowledge_base, presence: true
  after_initialize :overwrite_to_safety_values

  private

  def overwrite_to_safety_values
    self.name = sanitize self[:name]
  end
end
