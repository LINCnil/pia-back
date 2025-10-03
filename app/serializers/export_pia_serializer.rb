# frozen_string_literal: true

class ExportPiaSerializer < Blueprinter::Base
  identifier :id
  fields :status,
         :name,
         :author_name,
         :evaluator_name,
         :validator_name,
         :dpo_status,
         :dpo_opinion,
         :concerned_people_opinion,
         :concerned_people_status,
         :rejection_reason,
         :applied_adjustments,
         :created_at,
         :updated_at
  association :answers, blueprint: AnswerSerializer
  association :evaluations, blueprint: EvaluationSerializer
  association :comments, blueprint: CommentSerializer
  association :measures, blueprint: MeasureSerializer
end
