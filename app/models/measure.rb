class Measure < ApplicationRecord
  include ActionView::Helpers::SanitizeHelper
  belongs_to :pia, inverse_of: :measures
  after_initialize :overwrite_to_safety_values

  private

  def overwrite_to_safety_values
    self.title = sanitize read_attribute(:title)
    self.content = sanitize read_attribute(:content)
    self.placeholder = sanitize read_attribute(:placeholder)
  end
end
