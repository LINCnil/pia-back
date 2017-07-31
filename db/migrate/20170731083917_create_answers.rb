class CreateAnswers < ActiveRecord::Migration[5.0]
  def change
    create_table :answers do |t|
      t.string :reference_to, null: false
      t.jsonb :data, default: {}
      t.references :pia, index: true, foreign_key: true

      t.timestamps
    end
  end
end
