class ChangeTypeValueProgress < ActiveRecord::Migration[7.0]
  def change
    change_column :pias, :progress, :float, default: 0.0
  end
end
