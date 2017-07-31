class EvaluationSerializer < ActiveModel::Serializer
  attributes :id,
             :status,
             :reference_to,
             :action_plan_comment,
             :evaluation_comment,
             :evaluation_date,
             :gauges,
             :estimated_implementation_date,
             :person_in_charge,
             :created_at,
             :updated_at
end
