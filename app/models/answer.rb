class Answer < ApplicationRecord
  include ActionView::Helpers::SanitizeHelper
  belongs_to :pia, inverse_of: :answers
  validates :reference_to, presence: true
  after_initialize :overwrite_to_safety_values

  private

  def overwrite_to_safety_values
    data['text'] = sanitize data['text']
  end
end
