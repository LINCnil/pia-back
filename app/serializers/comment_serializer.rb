class CommentSerializer < ActiveModel::Serializer
  attributes :id, :description, :reference_to, :for_measure, :created_at, :updated_at
end
