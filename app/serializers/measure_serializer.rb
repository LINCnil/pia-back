class MeasureSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :pia_id, :title, :content, :placeholder
end
