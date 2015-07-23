require 'rbconfig'
module OS
  def self.linux?
    RbConfig::CONFIG['host_os'] =~ /linux/ ? true : false
  end
end
