module Blockbuster
  # Master file object
  class Master < Package
    include Blockbuster::Extractor
    include Blockbuster::Packager
    include Blockbuster::FileHelpers

    attr_reader :file_name

    def initialize(comparator, config)
      @comparator = comparator
      @file_name  = config.master_tar_file

      super(config)
    end

    def file_path
      master_tar_file_path
    end

    def target_path
      master_tar_file_path
    end
  end
end
