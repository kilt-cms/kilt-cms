module Kilt
  module Upload
    module S3
      def self.upload type, file_reference
        Kilt::Utils.ensure_s3_bucket_exists
        if file_reference
          begin
            s3 = AWS::S3.new(
              :access_key_id     => Kilt.config.s3.key,
              :secret_access_key => Kilt.config.s3.secret)   
            bucket = s3.buckets[Kilt.config.s3.bucket]
            new_file = bucket.objects["#{type}/#{file_reference.original_filename}"]
            new_file.write(Pathname.new(file_reference.tempfile), :acl => :public_read)
            file_reference.original_filename
          rescue
            ''
          end
        else
          ''
        end
      end
    end
  end
end
