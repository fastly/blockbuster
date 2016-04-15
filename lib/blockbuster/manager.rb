module Blockbuster
  # Manages cassette packaging and unpackaging
  class Manager
    include Blockbuster::OutputHelpers

    attr_accessor :comparator

    def initialize(instance_configuration = Blockbuster::Configuration.new)
      yield configuration if block_given?

      @configuration ||= instance_configuration

      @comparator      = Comparator.new(@configuration)
      @extraction_list = ExtractionList.new(@comparator, @configuration)
    end

    def configuration
      @configuration ||= Blockbuster::Configuration.new
    end

    # extracts cassettes from a tar.gz file
    #
    # tracks a md5 hash of each file in the tarball
    def rent
      master_file_path = @extraction_list.master.file_path

      unless File.exist?(master_file_path)
        silent_puts "File does not exist: #{master_file_path}."
        return false
      end

      remove_existing_cassette_directory if configuration.wipe_cassette_dir

      silent_puts "Extracting VCR cassettes to #{configuration.cassette_dir}"

      @extraction_list.extract_cassettes

      @comparator.store_current_delta_files if configuration.deltas_enabled?
    end

    # repackages cassettes into a compressed tarball
    def drop_off(force: false)
      if comparator.rewind?(configuration.cassette_files) || force
        silent_puts "Recreating cassette file #{@extraction_list.primary.target_path}"
        @extraction_list.primary.create_cassette_file
      end
    end

    alias setup rent
    alias teardown drop_off

    private

    def remove_existing_cassette_directory
      return if configuration.local_mode

      dir = configuration.cassette_dir

      silent_puts "Wiping cassettes directory: #{dir}"
      FileUtils.rm_r(dir) if Dir.exist?(dir)
    end
  end
end
