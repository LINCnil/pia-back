class AnswerSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :pia_id, :reference_to, :data, :lock_version, :created_at, :updated_at
end
