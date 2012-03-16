require 'fileutils'

begin
  require 'aws/s3'
rescue LoadError
  puts 'aws-s3 gem is required to use file store'
end

module Jackfs
  class S3Adapter

    TEMP_PATH = File.join('tmp','fs_cache')

    attr_accessor :access_key, :secret_key, :bucket, :app_root, :app_env
    
    def initialize(app_root, app_env)
      @app_root = app_root
      @app_env = app_env
      
      FileUtils.mkdir_p(full_temp_path)

      yml = YAML.load_file(config_file)[@app_env.to_s]
      @access_key = yml["access_key"]
      @secret_key = yml["secret_key"]
      @bucket = yml["bucket"]

      # Clean up temp files
      FileUtils.remove_file(File.join(full_temp_path,'/*'), true)

    end
    
    
    def store(f, name)
      find_or_create_bucket
      AWS::S3::S3Object.store(name, f, @bucket)
      name
    end
    
    def get(name)
      unique_name = UUIDTools::UUID.random_create.to_s
      # Write Body to generated tmp file
      open(File.join(full_temp_path, unique_name), 'wb') do |file| 
        AWS::S3::S3Object.stream(name, @bucket) do |chunk|
          file.write chunk
        end
      end
      # Open and return Temp File
      open(File.join(full_temp_path,unique_name), 'rb')

      
    end
      
    def establish_connection
      AWS::S3::Base.establish_connection!(
          :access_key_id     => @access_key,
          :secret_access_key => @secret_key
        )      
    end
    
    def find_or_create_bucket
      establish_connection
      AWS::S3::Bucket.create(@bucket) unless bucket = AWS::S3::Bucket.find(@bucket)
      true
    end
    
    def full_temp_path
      File.join(@app_root, TEMP_PATH)      
    end
    
    def config_file
      File.join(@app_root, Jackfs::FileStore::CONFIG_FILE)      
    end
    
    
  end
  
end
