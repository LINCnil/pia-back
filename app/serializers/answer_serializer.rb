# frozen_string_literal: true

class AnswerSerializer < Blueprinter::Base
  identifier :id
  fields :pia_id, :reference_to, :data, :lock_version, :created_at, :updated_at
end
