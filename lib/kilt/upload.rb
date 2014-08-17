module Kilt
  module Upload  
    
    def self.do(type, file_reference)
      if Kilt.config.storage.strategy == 'local'
        ::Kilt::Upload::Local.upload type, file_reference
      elsif Kilt.config.storage.strategy == 's3'
        ::Kilt::Upload::S3.upload type, file_reference
      end
    end

    class << self
      def method_missing(meth, *args, &blk)
        self.do meth.to_s, args[0]
      end
    end

  end
end
