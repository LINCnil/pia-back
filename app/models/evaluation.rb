class Evaluation < ApplicationRecord
  include ActionView::Helpers::SanitizeHelper
  belongs_to :pia, inverse_of: :evaluations
  validates :reference_to, presence: true
  attr_accessor :evaluation_infos

  after_create :email_for_evaluation! if ENV['ENABLE_AUTHENTICATION'].present?
  after_update :email_for_validation! if ENV['ENABLE_AUTHENTICATION'].present?

  after_initialize :overwrite_to_safety_values

  def email_for_evaluation!
    return unless evaluation_infos.present?

    infos = evaluation_infos
    evaluation_mode = infos['evaluation_mode']
    questions = infos['questions']
    evaluator_relation = pia.user_pias.find_by({ role: 'evaluator' })
    evaluator = evaluator_relation.user if evaluator_relation.present? && evaluator_relation.user.present?

    unless global_status == 2 && (evaluation_mode === 'item' || (evaluation_mode === 'question' && questions.present? && questions[0]['id'] == reference_to.split('.').last.to_i))
      return
    end

    UserMailer.with(evaluator: evaluator, pia: pia).section_ready_for_evaluation.deliver_now if evaluator.present?
  end

  def email_for_validation!
    return unless evaluation_infos.present?

    infos = evaluation_infos
    evaluation_mode = infos['evaluation_mode']
    questions = infos['questions']
    validator_relation = pia.user_pias.find_by({ role: 'validator' })
    validator = validator_relation.user if validator_relation.present? && validator_relation.user.present?

    unless global_status == 2 &&
      (evaluation_mode === 'item' || (evaluation_mode === 'question' && questions.present? && questions[0]['id'] == reference_to.split('.').last.to_i) || infos['is_measure'].present?)
      return
    end

    UserMailer.with(validator: validator, pia: pia).section_ready_for_validation.deliver_now if validator.present?
  end

  private

  def overwrite_to_safety_values
    self.action_plan_comment = sanitize self[:action_plan_comment]
    self.evaluation_comment = sanitize self[:evaluation_comment]
  end
end
