class PiaSerializer < Blueprinter::Base
  identifier :id
  fields :status, :name, :author_name, :evaluator_name, :validator_name,
         :dpo_status, :dpo_opinion, :dpos_names, :people_names, :concerned_people_opinion,
         :concerned_people_status, :rejection_reason, :applied_adjustments,
         :is_example, :created_at, :updated_at, :concerned_people_searched_opinion,
         :concerned_people_searched_content, :structure_id, :structure_name,
         :structure_sector_name, :structure_data, :category, :progress, :lock_version

  field :is_archive do |pia|
    pia.is_archive? ? 1 : 0
  end

  field :user_pias do |pia|
    pia.user_pias.map do |user_pia|
      {
        user: UserSerializer.render_as_hash(user_pia.user, view: :restricted),
        role: user_pia.role
      }
    end
  end
end
