class AddGlobalStatusToEvaluations < ActiveRecord::Migration[5.0]
  def change
    add_column :evaluations, :global_status, :integer, default: 0
  end
end
