class CreateAttachments < ActiveRecord::Migration[5.0]
  def change
    create_table :attachments do |t|
      t.string :attached_file
      t.boolean :pia_signed, default: false
      t.references :pia, index: true, foreign_key: true

      t.timestamps
    end
  end
end
