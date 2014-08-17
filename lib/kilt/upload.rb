module Kilt
  module Upload  

    def self.uploadable_fields
      types = ['file', 'image'] + Kilt.config.uploadable_fields.to_s.split(',').map { |x| x.strip }
      types.group_by { |x| x }.map { |x| x[0] }
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
