class AddLockVersionAttribute < ActiveRecord::Migration[7.0]
  def change
    add_column :pias, :lock_version, :integer, default: 0, null: false
    add_column :answers, :lock_version, :integer, default: 0, null: false
    add_column :measures, :lock_version, :integer, default: 0, null: false
    add_column :knowledge_bases, :lock_version, :integer, default: 0, null: false
    add_column :knowledges, :lock_version, :integer, default: 0, null: false
  end
end
