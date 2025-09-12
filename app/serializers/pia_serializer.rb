class PiaSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id,
             :status,
             :name,
             :author_name,
             :evaluator_name,
             :validator_name,
             :dpo_status,
             :dpo_opinion,
             :dpos_names,
             :people_names,
             :concerned_people_opinion,
             :concerned_people_status,
             :rejection_reason,
             :applied_adjustments,
             :is_example,
             :created_at,
             :updated_at,
             :concerned_people_searched_opinion,
             :concerned_people_searched_content,
             :structure_id,
             :structure_name,
             :structure_sector_name,
             :structure_data,
             :category,
             :progress,
             :lock_version

  attribute :is_archive do |pia|
    pia.is_archive ? 1 : 0
  end

  attribute :user_pias do |pia|
    res = []
    user_pias = pia.user_pias

    if user_pias.present?
      user_pias.each do |user_pia|
        res << { user: UserSerializer.new(user_pia.user)
                                     .serializable_hash
                                     .dig(:data, :attributes)
                                     .except(:access_type, :user_pias, :access_locked),
                 role: user_pia.role }
      end
    end
    res
  end
end
