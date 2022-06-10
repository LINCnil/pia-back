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
             :progress

  attribute :is_archive do |pia|
    pia.is_archive ? 1 : 0
  end

  attribute :guests do |pia|
    res = []
    guests = pia.user_pias.where(role: 0)

    if guests.present?
      guests.each do |up|
        user = User.find(up.user_id)
        res << user
      end
    end
    res
  end

  attribute :user_pias do |pia|
    res = []
    user_pias = pia.user_pias

    if user_pias.present?
      user_pias.each do |up|
        user = { user: up.user, role: up.role }
        res << user
      end
    end
    res
  end
end
