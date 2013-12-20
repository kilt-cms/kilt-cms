module Kilt
  module Generators
    class InstallGenerator < Rails::Generators::Base
      
      def install
        #run all kilt generators
        generate "kilt:backend"
        generate "kilt:frontend"
      end
      
    end
  end
end