class StructureSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id,
             :name,
             :sector_name,
             :data,
             :created_at,
             :updated_at
end
