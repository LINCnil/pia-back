class AnswerSerializer < ActiveModel::Serializer
  attributes :id, :pia_id, :reference_to, :data, :created_at, :updated_at
end
