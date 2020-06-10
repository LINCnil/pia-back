class RevisionSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :pia_id, :export, :created_at
end
