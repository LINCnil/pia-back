# frozen_string_literal: true

class EvaluationSerializer < Blueprinter::Base
  identifier :id
  fields :pia_id,
         :status,
         :reference_to,
         :action_plan_comment,
         :evaluation_comment,
         :evaluation_date,
         :gauges,
         :estimated_implementation_date,
         :person_in_charge,
         :global_status,
         :created_at,
         :updated_at
end
