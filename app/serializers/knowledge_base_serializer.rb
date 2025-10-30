# frozen_string_literal: true

class KnowledgeBaseSerializer < Blueprinter::Base
  identifier :id
  fields :name, :author, :contributors, :is_example, :lock_version, :created_at, :updated_at
end
