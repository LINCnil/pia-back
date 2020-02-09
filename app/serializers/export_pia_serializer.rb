class ExportPiaSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id,
             :status,
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
  has_many :answers
  has_many :evaluations
  has_many :comments
  has_many :measures
end
