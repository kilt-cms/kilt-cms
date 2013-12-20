module Kilt
  class ConfigError   < StandardError; end
  class DatabaseError < StandardError; end
  
  class NoConfigError < ConfigError; end
 
  class NoDatabaseConfigError       < DatabaseError; end
  class CantConnectToDatabaseError  < DatabaseError; end
  class CantSetupDatabaseError      < DatabaseError; end
end