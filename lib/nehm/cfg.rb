require 'bogy'


module Nehm
  # Cfg module manipulates with nehm's config file (~/.nehmconfig)
  module Cfg
    FILE_PATH = File.join(ENV['HOME'], '.nehmconfig')
    CONFIG_FILE = Bogy.new(file: FILE_PATH)

    def self.[](key)
      CONFIG_FILE[key.to_s]
    end

    def self.[]=(key, value)
      CONFIG_FILE[key.to_s] = value
    end

    def self.create
      File.open(FILE_PATH, 'w+') { |f| f.write("---\napp: nehm") }
    end

    def self.exist?
      File.exist?(FILE_PATH)
    end

    def self.key?(key)
      CONFIG_FILE.to_h.key?(key.to_s)
    end
  end
end
