module Kilt
  module Upload  
    
    def self.file(file_reference)
      self.do('file', file_reference)
    end
    
    def self.image(file_reference)
      self.do('image', file_reference)
    end
    
    def self.do(type, file_reference)
      if Kilt.config.storage.strategy == 'local'
        ::Kilt::Upload::Local.upload type, file_reference
      elsif Kilt.config.storage.strategy == 's3'
        ::Kilt::Upload::S3.upload type, file_reference
      end
    end
  end
end
