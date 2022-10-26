class CommentSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :pia_id, :description, :reference_to, :for_measure, :user, :created_at, :updated_at
end
