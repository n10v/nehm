require 'yaml'

module Config
  # Public

  def self.[](key)
    config_hash = load_config
    config_hash[key.to_s]
  end

  def self.[]=(key, value)
    config_hash = load_config
    config_hash[key.to_s] = value
    save_config(config_hash)
  end

  def self.create
    File.open(file_path, 'w+') { |f| f.write("---\napp: nehm")}
  end

  def self.exist?
    File.exist?(file_path)
  end

  def self.key?(key)
    load_config.key?(key.to_s)
  end

  # Private

  module_function

  def file_path
    File.join(ENV['HOME'], '.nehmconfig')
  end

  def load_config
    file = file_path
    YAML.load_file(file)
  end

  def save_config(config_hash)
    file = file_path
    IO.write(file, config_hash.to_yaml)
  end
end
