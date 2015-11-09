require 'yaml'

module Nehm

  ##
  # Cfg module manipulates with nehm's config file (~/.nehmconfig)

  module Cfg

    FILE_PATH = File.join(ENV['HOME'], '.nehmconfig')

    def self.[](key)
      config_file[key.to_s]
    end

    def self.[]=(key, value)
      config_file[key.to_s] = value
      write
    end

    def self.create
      File.open(FILE_PATH, 'w+') { |f| f.write('--- {}\n') }
    end

    def self.exist?
      File.exist?(FILE_PATH)
    end

    def self.key?(key)
      config_file.to_h.key?(key.to_s)
    end

    module_function

    def config_file
      @config_file ||= YAML.load_file(FILE_PATH)
      @config_file ||= {} if @config_file.nil?

      @config_file
    end

    def write
      IO.write(FILE_PATH, config_file)
    end

  end
end
