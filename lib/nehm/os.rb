require 'rbconfig'
module OS
  def self.linux?
    host_os = RbConfig::CONFIG['host_os']
    host_os =~ /linux/ ? true : false
  end
end
