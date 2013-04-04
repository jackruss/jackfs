require 'base64'
require 'fileutils'

begin
  require 'sequel/no_core_ext'
rescue LoadError
  puts 'sequel gem is required to use file store'
end


module Jackfs
  class DbAdapter
    TEMP_PATH = File.join('tmp','fs_cache')

    attr_accessor :connection, :table_name, :dbase, :app_root, :app_env

    def initialize(app_root, app_env)
      @app_root = app_root
      @app_env = app_env

      FileUtils.mkdir_p temp_file_path

      @connection = ENV["JACKFS_DB_URL"]
      @table_name = ENV["JACKFS_TABLE_NAME"]

      # Clean up temp files
      FileUtils.remove_file(File.join(temp_file_path,'/*'), true)
    end

    def store(f, name)
      body = Base64.encode64(f.read)
      data.insert(
        :name       => name,
        :body       => body,
        :created_at => Time.now,
        :updated_at => Time.now
      )
    end

    def get(name)
      record = data.where(:name => name).order(:name).first
      unique_name = UUIDTools::UUID.random_create.to_s
      # Write Body to generated tmp file
      f = temp_file_path + unique_name
      open(File.join(f), 'wb') { |file| file.write Base64.decode64(record[:body]) }
      f
    end

    def data
      db = Sequel.connect(@connection)
      make_table(db) unless db.tables.include?(@table_name.to_sym)
      db[@table_name.to_sym]
    end

    def make_table(db)
      db.create_table @table_name do
        primary_key :id
        string :name
        text :body
        timestamp :created_at
        timestamp :updated_at
      end
    rescue
      # table exists
    end

    def temp_file_path
      File.join(@app_root, TEMP_PATH)
    end
  end
end
