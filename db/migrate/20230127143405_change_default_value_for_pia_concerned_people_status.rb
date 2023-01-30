class ChangeDefaultValueForPiaConcernedPeopleStatus < ActiveRecord::Migration[7.0]
  def change
    change_column_default :pias, :dpo_status, nil
    change_column_default :pias, :concerned_people_status, nil
    change_column_default :pias, :concerned_people_searched_opinion, nil
  end
end
