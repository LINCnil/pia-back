class AddConcernedPeopleSearchedOpinionToPia < ActiveRecord::Migration[5.0]
  def change
    add_column :pias, :concerned_people_searched_opinion, :boolean, default: false
    add_column :pias, :concerned_people_searched_content, :string
  end
end
