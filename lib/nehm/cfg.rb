require 'yaml'

module Nehm

  ##
  # Cfg module manipulates with nehm's config file (~/.nehmconfig)

  module Cfg

    FILE_PATH = File.join(ENV['HOME'], '.nehmconfig')

    def self.[](key)
      config_hash[key.to_s]
    end

    def self.[]=(key, value)
      config_hash[key.to_s] = value
      write
    end

    def self.create
      File.open(FILE_PATH, 'w+') { |f| f.write('--- {}\n') }
    end

    def self.exist?
      File.exist?(FILE_PATH)
    end

    def self.key?(key)
      config_hash.to_h.key?(key.to_s)
    end

    module_function

    def config_hash
      @config_hash ||= YAML.load_file(FILE_PATH)
      @config_hash ||= {} if @config_hash.nil?

      @config_hash
    end

    def write
      IO.write(FILE_PATH, config_hash.to_yaml)
    end

  end
end
