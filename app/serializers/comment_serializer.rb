# frozen_string_literal: true

class CommentSerializer < Blueprinter::Base
  identifier :id
  fields :pia_id, :description, :reference_to, :for_measure, :user, :created_at, :updated_at
end
