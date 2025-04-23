desc "Task to migrate from Carrierwave to ActiveStorage"
task active_storage_migration: :environment do
  puts "Starting migration from Carrierwave to ActiveStorage..."
  Dir.glob(Rails.root.join('data/attachment/attached_file/*')).each do |file_path|
    Dir.glob("#{file_path}/*").each do |file|
      path = file.split('/')
      attachment_id, filename = path.last(2)
      attachment = Attachment.find_by(id: attachment_id.to_i)
      next unless attachment
      if attachment.file.attached?
        puts "Error: Attachment with ID #{attachment_id} already has an attached file."
      else
        attachment.file.attach(io: File.open(file), filename:)
        puts "Attached file #{filename} to attachment with ID #{attachment_id}."
      end
    end
  end
  puts "Migration completed."
end
