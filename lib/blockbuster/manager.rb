module Blockbuster
  # Manages cassette packaging and unpackaging
  class Manager
    include Blockbuster::FileHelpers
    include Blockbuster::OutputHelpers
    extend Forwardable

    def_delegators :configuration, :cassette_directory, :master_tar_file, :local_mode, :test_directory, :silent, :wipe_cassette_dir

    def initialize
      @comparator = Comparator.new
      @extraction_list = ExtractionList.new(@comparator)
    end

    def configuration
      Blockbuster.configuration
    end

    # extracts cassettes from a tar.gz file
    #
    # tracks a md5 hash of each file in the tarball
    def rent
      unless File.exist?(@extraction_list.master.file_path)
        silent_puts "File does not exist: #{@extraction_list.master.file_path}."
        return false
      end

      remove_existing_cassette_directory if configuration.wipe_cassette_dir

      silent_puts "Extracting VCR cassettes to #{cassette_dir}"

      @extraction_list.extract_cassettes

      if Blockbuster.configuration.deltas_enabled?
        @comparator.store_current_delta_files
      end
    end

    # repackages cassettes into a compressed tarball
    def drop_off(force: false)
      if @comparator.rewind?(cassette_files) || force
        silent_puts "Recreating cassette file #{@extraction_list.primary.file_name}"
        @extraction_list.primary.create_cassette_file
      end
    end

    alias setup rent
    alias teardown drop_off

    private

    def remove_existing_cassette_directory
      return if Blockbuster.configuration.local_mode

      silent_puts "Wiping cassettes directory: #{cassette_dir}"
      FileUtils.rm_r(cassette_dir) if Dir.exist?(cassette_dir)
    end
  end
end
