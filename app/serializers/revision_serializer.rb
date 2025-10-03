# frozen_string_literal: true

class RevisionSerializer < Blueprinter::Base
  identifier :id
  fields :pia_id, :export, :created_at
end
