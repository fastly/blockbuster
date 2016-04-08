require 'fileutils'
require 'rubygems/package'
require 'zlib'

require 'blockbuster/configuration'
require 'blockbuster/master'
require 'blockbuster/delta'
require 'blockbuster/concerns/file_helpers'
require 'blockbuster/concerns/output_helpers'
require 'blockbuster/concerns/packager'
require 'blockbuster/comparator'

require 'blockbuster/manager'
require 'blockbuster/version'

# nodoc
module Blockbuster
end
