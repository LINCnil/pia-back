class UpdateReferenceToFromAnswers < ActiveRecord::Migration[8.0]
  def change
    change_column :answers, :reference_to, :integer, using: 'reference_to::integer'
  end
end
