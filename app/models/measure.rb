class Measure < ApplicationRecord
  include ActionView::Helpers::SanitizeHelper
  belongs_to :pia, inverse_of: :measures
  after_initialize :overwrite_to_safety_values

  private

  def overwrite_to_safety_values
    self.title = sanitize self[:title]
    self.content = sanitize self[:content]
    self.placeholder = sanitize self[:placeholder]
  end
end
