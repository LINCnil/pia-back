class Evaluation < ApplicationRecord
  belongs_to :pia, inverse_of: :evaluations
  validates :reference_to, presence: true
  attr_accessor :evaluation_infos

  after_create :email_for_evaluation! if ENV['ENABLE_AUTHENTICATION'].present?

  def email_for_evaluation!
    infos = self.evaluation_infos
    evaluation_mode = infos["evaluation_mode"]
    questions = infos["questions"]
    author = self.pia.user_pias.find_by({role: "author"}).user
    evaluator = self.pia.user_pias.find_by({role: "evaluator"}).user

    if evaluation_mode === 'item' || 
      (evaluation_mode === 'question' && questions[0]["id"] == self.reference_to.split(".").last.to_i)
      UserMailer.with(evaluator: evaluator, pia: self.pia).section_ready_for_evaluation.deliver_now
    end
    byebug
  end
end
