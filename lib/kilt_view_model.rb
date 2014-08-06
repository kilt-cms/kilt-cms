class KiltViewModel

  def self.build input
    this_is_a_collection(input) ? build_view_models_from(input)
                                : build_a_view_model_from(input)
  end

  def initialize subject = {}
    @subject = subject
  end

  def [] id
    @subject[id.to_s] || @subject[id.to_s.to_sym]
  end

  def method_missing(meth, *args, &blk)
    @subject[meth.to_s] || @subject[meth]
  end

  class << self

    private

    def build_a_view_model_from record
      eval("#{record['type']}_view_model".classify).new record
    rescue
      KiltViewModel.new record
    end

    def this_is_a_collection input
      input.is_a?(Array) || input.is_a?(Kilt::ObjectCollection)
    end

    def build_view_models_from records
      records.map { |r| build_a_view_model_from r }
             .sort_by do |x|
               sequence = x.sequence.to_s.to_i
               sequence.to_s == x.sequence.to_s ? sequence : 99999999999
             end
    end

  end

end
