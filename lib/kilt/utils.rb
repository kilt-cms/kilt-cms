module Kilt
  class Utils
    
    # Set up the database
    def self.rethink_setup_db
      Kilt::Database.new(Kilt.config.db).setup!
    end
    
    def self.database
      @database ||= Kilt::Database.new Kilt.config.db
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
      puts s3 
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
      ret.gsub! /\s*[^A-Za-z0-9\.\_]\s*/, '-'  

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
    
    # Print a list of objects, functions, etc.
    def self.tips
      lines = []
      if !Kilt.config.empty? && Kilt.config.db
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
    
  end
end
