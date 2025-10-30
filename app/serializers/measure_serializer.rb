# frozen_string_literal: true

class MeasureSerializer < Blueprinter::Base
  identifier :id
  fields :pia_id, :title, :content, :placeholder, :lock_version
end
