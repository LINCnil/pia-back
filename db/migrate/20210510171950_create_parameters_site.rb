class CreateParametersSite < ActiveRecord::Migration[6.0]
  def change
    create_table :parameters_sites do |t|
        t.string :code_param, null: false
        t.string :value_param, null: false

        t.timestamps
    end
  end
end
