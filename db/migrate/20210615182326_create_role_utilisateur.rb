class CreateRoleUtilisateur < ActiveRecord::Migration[6.0]
  def change
    create_table :role_utilisateurs do |t|
         t.integer :CategorieRole, null: false
         t.string :CodeRole, null: false
         t.string :NomRole, null: false
    end
  end
end
