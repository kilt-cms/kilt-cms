ENV['RAILS_ENV'] = 'test'
require 'rails'
require 'action_pack'
require 'action_view'
require 'active_support'
require File.expand_path(File.dirname(__FILE__) + '/../lib/kilt')
require 'minitest/autorun'
require 'minitest/spec'
require 'minitest/pride'
require 'hashie'
require 'timecop'
require 'mocha/setup'

def default_test_config
  config         = Hashie::Mash.new

  config.test         = Hashie::Mash.new
  config.test.db      = Hashie::Mash.new(db: 'kilt_test', host: '127.0.0.1', port: '28015')

  config.name    = 'Test App'
  config.objects = Hashie::Mash.new(cat: Hashie::Mash.new(fields: { name: 'text', size: 'text', headshot: 'image', resume: 'file' } ),
                                    dog: Hashie::Mash.new(fields: { name: 'text', size: 'text', headshot: 'image', resume: 'file' } ),
                                    no_namey: Hashie::Mash.new(fields: { } ))
  config
end

def setup_the_database
  setup_the_database_with default_test_config
end

def setup_the_database_with config
  Kilt.config = config
  Kilt::Utils.setup_db
end

def clear_out_the_database
  Kilt::Utils.database.execute do
    r.db(Kilt.config.test.db.db).table('objects').delete().run
  end
end

setup_the_database
