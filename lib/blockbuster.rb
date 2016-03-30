require 'fileutils'
require 'rubygems/package'
require 'zlib'

require 'blockbuster/configuration'
require 'blockbuster/packager'

require 'blockbuster/manager'
require 'blockbuster/version'

# nodoc
module Blockbuster
  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield configuration if block_given?
  end
end
