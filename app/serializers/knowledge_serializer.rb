class KnowledgeSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :name, :slug, :filters, :category, :placeholder, :description, :items, :created_at, :updated_at
end
