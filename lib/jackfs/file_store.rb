begin
  require 'uuidtools'
rescue LoadError
  puts 'gem uuidtools is required'
end

require File.dirname(__FILE__) + '/adapters/file_adapter'
require File.dirname(__FILE__) + '/adapters/s3_adapter'
require File.dirname(__FILE__) + '/adapters/db_adapter'

module Jackfs
  class FileStore
    CONFIG_FILE = File.join('config','filestore.yml')
    
    attr_accessor :file, :guid, :adapter, :app_root, :app_env
    
    def initialize(app_root, app_env)
      @app_root = app_root
      @app_env = app_env
      @adapter = load_adapter
    end
    
    def store(this_file)
      @file = this_file
      @guid = create_guid
      # call adapter passing the file and guid as file identifier
      @adapter.store(this_file, @guid)
    end
    
    def get(guid)
      # Need call adapter passing the guid and returning the file
      @adapter.get(guid)
    end
    
    def create_guid
      UUIDTools::UUID.random_create.to_s
    end
    
    def load_adapter
      adapter_type = YAML.load_file(File.join(@app_root,CONFIG_FILE))[@app_env.to_s]["adapter"].to_sym
      case adapter_type
        when :s3 then Jackfs::S3Adapter.new(@app_root, @app_env)
        when :db then Jackfs::DbAdapter.new(@app_root, @app_env)
        else Jackfs::FileAdapter.new(@app_root, @app_env)
      end
    end
  end
  
end
