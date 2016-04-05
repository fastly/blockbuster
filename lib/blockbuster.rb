require 'fileutils'
require 'rubygems/package'
require 'zlib'

require 'blockbuster/configuration'
require 'blockbuster/concerns/file_helpers'
require 'blockbuster/concerns/extractor'
require 'blockbuster/concerns/output_helpers'
require 'blockbuster/concerns/packager'
require 'blockbuster/comparator'

require 'blockbuster/package'
require 'blockbuster/master'
require 'blockbuster/delta'
require 'blockbuster/extraction_list'

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
