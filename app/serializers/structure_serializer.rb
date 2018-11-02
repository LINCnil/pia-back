class StructureSerializer < ActiveModel::Serializer
  attributes :id,
             :name,
             :sector_name,
             :data,
             :created_at,
             :updated_at
end
