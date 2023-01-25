class KnowledgeSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :name, :slug, :filters, :category, :placeholder, :description, :items, :lock_version, :created_at, :updated_at
end
