module Kilt
  module Upload  

    def self.uploadable_types
      ['file', 'image']
    end
    
    def self.do(type, file_reference)
      uploader = begin
                   strategy = Kilt.config.storage.strategy.to_s
                   "Kilt::Upload::#{strategy.classify}".constantize
                 rescue
                   nil
                 end
      uploader.upload(type, file_reference) if uploader
    end

    class << self
      def method_missing(meth, *args, &blk)
        self.do meth.to_s, args[0]
      end
    end

  end
end
