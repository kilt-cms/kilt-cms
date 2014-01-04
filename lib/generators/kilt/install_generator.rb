module Kilt
  module Generators
    class InstallGenerator < Rails::Generators::Base
      
      def install
        # Default to the backend generator
        generate "kilt:backend"
      end
      
    end
  end
end