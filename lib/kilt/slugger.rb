module Kilt

  module Slugger

    def self.slug_for object
      slug = possibly_duplicate_slug_for object
      slug_is_unique_for?(slug, object) ? slug
                                        : make_slug_unique(slug)
    end

    class << self

      def slug_is_unique_for? slug, object
        result = Utils.database_for(nil).find(slug)
        return true if result.nil?

        "#{result['unique_id']}" == "#{object['unique_id']}"
      end

      def make_slug_unique slug
        "#{slug}-#{(Time.now.to_f * 1000).to_i}"
      end

      def possibly_duplicate_slug_for object
        if object['slug'].to_s.strip == ''
          if prefix = prefix_for(object)
            "#{prefix}-#{slugified_value_for(object)}"
          else
            slugified_value_for(object)
          end
        else
          "#{object['slug']}"
        end
      end

      def slugified_value_for object
        Utils.slugify(object['name'])
      end

      def prefix_for object
        return nil unless prefix = lookup_the_suggested_prefix_for(object)
        slug = slugified_value_for object
        slug.starts_with?(prefix) && slug != prefix ? nil
                                                    : prefix
      end

      def lookup_the_suggested_prefix_for object
        Kilt.send(object['type'].to_sym)['slug_prefix']
      end

    end

  end

end
