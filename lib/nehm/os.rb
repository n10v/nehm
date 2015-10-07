require 'rbconfig'

module Nehm

  ##
  # OS module returns information about OS on this computer

  module OS
    def self.linux?
      RbConfig::CONFIG['host_os'] =~ /linux/ ? true : false
    end
  end
end
