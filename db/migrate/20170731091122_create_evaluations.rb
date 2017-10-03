class CreateEvaluations < ActiveRecord::Migration[5.0]
  def change
    create_table :evaluations do |t|
      t.integer :status, default: 0
      t.string :reference_to, null: false
      t.text :action_plan_comment, default: ''
      t.text :evaluation_comment, default: ''
      t.datetime :evaluation_date
      t.jsonb :gauges, default: {}
      t.datetime :estimated_implementation_date
      t.string :person_in_charge, default: ''
      t.references :pia, index: true, foreign_key: true

      t.timestamps
    end
  end
end
