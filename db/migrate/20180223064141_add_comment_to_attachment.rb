class AddCommentToAttachment < ActiveRecord::Migration[5.0]
  def change
    add_column :attachments, :comment, :text
  end
end
