require 'rbconfig'

module Nehm

  ##
  # OS module returns information about OS on this computer

  module OS
    def self.mac?
      RbConfig::CONFIG['host_os'] =~ /darwin|mac os/ ? true : false
    end
  end
end
