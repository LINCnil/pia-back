class Structure < ApplicationRecord
  include ActionView::Helpers::SanitizeHelper
  has_many :pias, dependent: :nullify
  after_initialize :overwrite_to_safety_values

  private

  def overwrite_to_safety_values
    self.name = sanitize read_attribute(:name)
    self.sector_name = sanitize read_attribute(:sector_name)
  end
end
