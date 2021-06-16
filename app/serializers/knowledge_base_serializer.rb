class KnowledgeBaseSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :name, :author, :contributors, :is_example, :created_at, :updated_at
end
