module Jackfs
  class FileAdapter
    attr_accessor :location, :app_root, :app_env

    def initialize(app_root, app_env)
      @app_root = app_root
      @app_env = app_env
      begin
        @location = YAML.load_file(File.join(@app_root, Jackfs::FileStore::CONFIG_FILE))[@app_env.to_s]["location"]
      rescue
        raise InvalidFileStore
      end
    end

    def store(this_file, name)
      File.open(File.join(@app_root, @location, name), 'w') { |file| file.write this_file.read }
      name
    end

    def get(name)
      File.open(File.join(app_root, @location, name), 'r')
    end

  end
end
