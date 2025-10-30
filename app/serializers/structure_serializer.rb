# frozen_string_literal: true

class StructureSerializer < Blueprinter::Base
  identifier :id
  fields :name, :sector_name, :data, :created_at, :updated_at
end
