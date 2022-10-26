class AddBelongsToUserToComments < ActiveRecord::Migration[7.0]
  def change
    add_reference :comments, :user, foreign_key: true
  end
end
