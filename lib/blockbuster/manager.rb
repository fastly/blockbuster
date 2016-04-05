module Blockbuster
  # Manages cassette packaging and unpackaging
  class Manager
    include Blockbuster::OutputHelpers
    extend Forwardable

    # def_delegators :configuration, :cassette_directory, :master_tar_file, :local_mode, :test_directory, :silent, :wipe_cassette_dir

    def initialize(local_configuration = Blockbuster::Configuration.new)
      yield configuration if block_given?

      @configuration ||= local_configuration

      @comparator = Comparator.new(@configuration)
      @extraction_list = ExtractionList.new(@comparator, @configuration)
    end

    def configuration
      @configuration ||= Blockbuster::Configuration.new
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

      silent_puts "Extracting VCR cassettes to #{configuration.cassette_dir}"

      @extraction_list.extract_cassettes

      if configuration.deltas_enabled?
        @comparator.store_current_delta_files
      end
    end

    # repackages cassettes into a compressed tarball
    def drop_off(force: false)
      if @comparator.rewind?(configuration.cassette_files) || force
        silent_puts "Recreating cassette file #{@extraction_list.primary.file_name}"
        @extraction_list.primary.create_cassette_file
      end
    end

    alias setup rent
    alias teardown drop_off

    private

    def remove_existing_cassette_directory
      return if configuration.local_mode

      silent_puts "Wiping cassettes directory: #{configuration.cassette_dir}"
      FileUtils.rm_r(configuration.cassette_dir) if Dir.exist?(configuration.cassette_dir)
    end
  end
end
