class CreatePias < ActiveRecord::Migration[5.0]
  def change
    create_table :pias do |t|
      t.integer :status, default: 0
      t.string :name, null: false
      t.string :author_name, default: ''
      t.string :evaluator_name, default: ''
      t.string :validator_name, default: ''
      t.integer :dpo_status, default: 0
      t.text :dpo_opinion, default: ''
      t.text :concerned_people_opinion, default: ''
      t.integer :concerned_people_status, default: 0
      t.text :rejection_reason, default: ''
      t.text :applied_adjustments, default: ''

      t.timestamps
    end
  end
end
