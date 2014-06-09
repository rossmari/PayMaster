require "paymaster/version"

module Paymaster

  mattr_reader :interface_class

  def self.interface_class
    Paymaster::Interface
  end

  class Engine < Rails::Engine
    config.autoload_paths += %W(#{config.root}/lib)
  end

end
