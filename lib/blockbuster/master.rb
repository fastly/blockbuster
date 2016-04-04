module Blockbuster
  # Master file object
  class Master
    include Blockbuster::Extractor
    include Blockbuster::Packager
    include Blockbuster::FileHelpers

    attr_reader :file_name

    def initialize
      @file_name = Blockbuster.configuration.master_tar_file
    end

    def file_path
      master_tar_file_path
    end

    def target_path
      master_tar_file_path
    end
  end
end
