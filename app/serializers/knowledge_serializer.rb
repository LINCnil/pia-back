# frozen_string_literal: true

class KnowledgeSerializer < Blueprinter::Base
  identifier :id
  fields :name, :slug, :filters, :category, :placeholder, :description, :items, :lock_version, :created_at, :updated_at
end
