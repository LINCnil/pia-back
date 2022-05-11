class Evaluation < ApplicationRecord
  include ActionView::Helpers::SanitizeHelper
  belongs_to :pia, inverse_of: :evaluations
  validates :reference_to, presence: true
  after_initialize :overwrite_to_safety_values

  private

  def overwrite_to_safety_values
    self.action_plan_comment = sanitize read_attribute(:action_plan_comment)
    self.evaluation_comment = sanitize read_attribute(:evaluation_comment)
  end
end
