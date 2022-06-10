class Comment < ApplicationRecord
  include ActionView::Helpers::SanitizeHelper
  belongs_to :pia, inverse_of: :comments
  validates :reference_to, presence: true
  after_initialize :overwrite_to_safety_values

  private

  def overwrite_to_safety_values
    self.description = sanitize self[:description]
  end
end
