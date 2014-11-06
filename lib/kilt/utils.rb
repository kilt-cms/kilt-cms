module Kilt
  class Utils
    
    def self.setup_db
      return unless current_db_config
      if db_type = current_db_config[:type]
        use_db(db_type.to_sym)
      end
      database_for(nil).setup!
    end

    def self.use_db db_type
      return if @db_type == db_type
      @db_type = db_type
      @database = nil
    end

    def self.register_database_for type, &block
      @special_types ||= {}
      type = make_consistent type
      @special_types[type] = block
    end

    def self.databases
      [database_for(nil)]
    end

    def self.database_for type
      @special_types ||= {}
      type = make_consistent(type)
      return @special_types[type].call if @special_types[type]
      Kilt::DB::ActiveRecord.new
    end

    def self.current_db_config
      current_environment = (ENV['RAILS_ENV'].to_s == '' ? 'development' : ENV['RAILS_ENV']).to_sym
      Kilt.config[current_environment][:db]
    rescue
      Kilt.config[:db]
    end
    
    # Ensure we have local storage dirs
    def self.ensure_local_storage_dir_exists
      Dir.mkdir(Rails.root.join('public', 'uploads'))         unless File.exists?(Rails.root.join('public', 'uploads'))  
      Dir.mkdir(Rails.root.join('public', 'uploads', 'file')) unless File.exists?(Rails.root.join('public', 'uploads', 'file')) 
      Dir.mkdir(Rails.root.join('public', 'uploads', 'image')) unless File.exists?(Rails.root.join('public', 'uploads', 'image'))  
    end
    
    # Ensure we have an s3 bucket
    def self.ensure_s3_bucket_exists
      s3 = AWS::S3.new(
        :access_key_id     => Kilt.config.s3.key,
        :secret_access_key => Kilt.config.s3.secret)  
      bucket = s3.buckets[Kilt.config.s3.bucket]
      if !bucket.exists?
        bucket = s3.buckets.create(Kilt.config.s3.bucket, :acl => :public_read)
      end
    end
    
    # Get a file download URL
    def self.download_location(type, value)
      if Kilt.config.storage.strategy == 'local'
        "/uploads/#{type.to_s}/#{value.to_s}"
      elsif Kilt.config.storage.strategy == 's3'
        "http://#{Kilt.config.s3.bucket}.s3.amazonaws.com/#{type.to_s}/#{value.to_s}"
      end
    end
    
    # Determine if the string passed in is singular or not
    def self.is_singular?(str)
      str.pluralize != str && str.singularize == str
    end
    
    # Create a slug
    def self.slugify(str)
      #strip the string
      ret = str.strip

      #blow away apostrophes
      ret.gsub! /['`]/,""

      # @ --> at, and & --> and
      ret.gsub! /\s*@\s*/, " at "
      ret.gsub! /\s*&\s*/, " and "

      #replace all non alphanumeric, underscore or periods with dash
      ret.gsub! /\s*[^A-Za-z0-9]\s*/, '-'  

      #convert double dash to single
      ret.gsub! /-+/, "-"

      #strip off leading/trailing dash
      ret.gsub! /\A[-\.]+|[-\.]+\z/, ""

      #return a downcase string
      ret.downcase
    end
    
    # Break down a slug
    def self.deslugify(str)
      ret = str.to_s
      ret.gsub! /_/, " "   
      ret.capitalize
    end

    def self.config_is_valid?
      Kilt.config.empty? == false && current_db_config
      #!(Kilt.config.empty? || !Kilt.config.db)
      #!Kilt.config.empty? && Kilt.config.db
    end
    
    # Print a list of objects, functions, etc.
    def self.tips
      lines = []
      if config_is_valid?
        lines << ''
        
        # Store the first type so we can use it down below
        first_type = nil
        Kilt.types.each do |type|
          
          if !first_type
            first_type = type
          end
          
          lines << "#{type.capitalize}: "
          lines << "  Kilt.#{type} -> Type definition"
          lines << "  Kilt.#{type}.fields -> List of fields"
          lines << "  Kilt.#{type.pluralize} -> Array of all #{type.capitalize} objects in natural order"
          lines << "  Kilt.#{type.pluralize}.order -> Array of all #{type.capitalize} objects ordered by 'name' field"
          lines << "  Kilt.#{type.pluralize}.order('age') -> Array of all #{type.capitalize} objects ordered by 'age' field"
          lines << "  Kilt.#{type.pluralize}.order('age').group('section') -> Array of all #{type.capitalize} objects ordered by 'age' field, then grouped by the 'section' field"
        end
        lines << ''
        lines << 'Get object:'
        lines << '  Kilt.get(\'some-slug\')'
        lines << ''
        lines << 'Loop through objects:'
        lines << "  Kilt.#{first_type.pluralize}.each do |#{first_type}|"
        lines << "    puts #{first_type}['name']"
        lines << '  end'
        lines << ''
        lines << 'Loop through objects ordered by field \'age\':'
        lines << "  Kilt.#{first_type.pluralize}.order('age').each do |#{first_type}|"
        lines << "    puts #{first_type}['name']"
        lines << '  end'        
        lines << ''
        lines << 'Loop through objects ordered by field \'name\' (the default), then grouped by field \'section\':'
        lines << "  Kilt.#{first_type.pluralize}.order.group(\'section\').each do |section, #{first_type.downcase.pluralize}|"
        lines << '    puts section'
        lines << "    #{first_type.downcase.pluralize}.each do |#{first_type.downcase}|"
        lines << "      puts #{first_type.downcase}['name']"
        lines << "    end"
        lines << '  end'
      else
        lines << 'The Kilt gem has been installed, but you haven\'t configured it yet.'
        lines << 'Start configuring Kilt by running the following command:'
        lines << ''
        lines << '   rails g kilt:backend'
        lines << ''
        lines << 'Then open config/kilt/config.yml and config/kilt/creds.yml, add your database information, define your data model, start Rails, and visit http://&lt;your_app&gt;/admin'
      end
      lines.join("\n")
    end

    class << self
      private
      def make_consistent type
        type.to_s.underscore
      end
    end
    
  end
end
