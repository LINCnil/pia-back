class RemoveAttachedFileFromAttachments < ActiveRecord::Migration[8.0]
  def change
    remove_column :attachments, :attached_file
  end
end
