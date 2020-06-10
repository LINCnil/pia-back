class CreateRevisions < ActiveRecord::Migration[6.0]
  def change
    create_table :revisions do |t|
      t.jsonb :export, null: false
      t.references :pia, null: false, foreign_key: true

      t.timestamps
    end
  end
end
