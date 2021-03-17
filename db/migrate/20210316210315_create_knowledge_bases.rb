class CreateKnowledgeBases < ActiveRecord::Migration[6.0]
  def change
    create_table :knowledge_bases do |t|
      t.string :name, null: false
      t.string :author, null: false
      t.string :contributors, null: false
      t.boolean :is_example, null: false, default: false

      t.timestamps
    end
  end
end
