RailsConfig.setup do |config|
  config.const_name = "Settings"
end

# Pull in the database configs
Settings.add_source!("#{Rails.root}/config/kilt/config.yml")
Settings.add_source!("#{Rails.root}/config/kilt/creds.yml")
Settings.reload!

# Attach the Kilt config the content pulled in by RailsConfig
Kilt.config = Settings