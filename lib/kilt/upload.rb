module Kilt
  class Upload  
    
    def self.file(file_reference)
      self.do('file', file_reference)
    end
    
    def self.image(file_reference)
      self.do('image', file_reference)
    end
    
    def self.do(type, file_reference)
      if Kilt.config.storage.strategy == 'local'
        self.handle_local_upload(type, file_reference)
      #elsif Kilt.config.storage.strategy == 's3'
        #self.handle_s3_upload(type, file_reference)
      end
    end
    
    private
    
    def self.handle_local_upload(type, file_reference)
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
    
    def self.handle_s3_upload(type, file_reference)
      #Kilt::Utils.ensure_s3_bucket_exists
      #if file_reference
        #begin
          #s3 = AWS::S3.new(
            #:access_key_id     => Kilt.config.s3.key,
            #:secret_access_key => Kilt.config.s3.secret)   
          #bucket = s3.buckets[Kilt.config.s3.bucket]
          #new_file = bucket.objects["#{type}/#{file_reference.original_filename}"]
          #new_file.write(Pathname.new(file_reference.tempfile), :acl => :public_read)
          #file_reference.original_filename
        #rescue
          #''
        #end
      #else
        #''
      #end
    end
    
  end
end
