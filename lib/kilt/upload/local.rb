module Kilt
  module Upload
    module Local
      def self.upload type, file_reference
        Kilt::Utils.ensure_local_storage_dir_exists
        if file_reference
          File.open(Rails.root.join('public', 'uploads', type, file_reference.original_filename), 'wb') do |file|
            file.write(file_reference.read)
          end
          file_reference.original_filename
        else
          ''
        end
      end
    end
  end
end
