module Blockbuster
  # Master file object
  class Master
    include Blockbuster::Packager

    attr_reader :file_name, :configuration

    def initialize(comparator, configuration)
      @configuration = configuration
      @comparator    = comparator
      @file_name     = configuration.master_tar_file
    end

    # read path
    def file_path
      configuration.master_tar_file_path
    end

    # write path (master will always write to the same file name)
    def target_path
      file_path
    end
  end
end
