module Blockbuster
  # Manages cassette packaging and unpackaging
  class Manager
    include Blockbuster::Extractor
    include Blockbuster::FileHelpers
    include Blockbuster::OutputHelpers
    include Blockbuster::Packager
    include Blockbuster::TarballHelpers
    extend Forwardable

    def_delegators :configuration, :cassette_directory, :cassette_file, :local_mode, :test_directory, :silent, :wipe_cassette_dir
    attr_accessor :comparison_hash

    def configuration
      Blockbuster.configuration
    end

    def initialize
      @comparison_hash = Comparator.new
    end

    # extracts cassettes from a tar.gz file
    #
    # tracks a md5 hash of each file in the tarball
    def rent
      unless File.exist?(cassette_file_path)
        silent_puts "File does not exist: #{cassette_file_path}."
        return false
      end

      remove_existing_cassette_directory if wipe_cassette_dir

      silent_puts "Extracting VCR cassettes to #{cassette_dir}"

      extract_cassettes
    end

    # repackages cassettes into a compressed tarball
    def drop_off(force: false)
      if rewind? || force
        silent_puts "Recreating cassette file #{cassette_file}"
        create_cassette_file
      end
    end

    # performs comparison of files
    #
    # compares the md5 sums of the files in the existing tarball
    # and the cassettes from the cassette directory.
    def rewind?(retval = nil)
      Dir.glob("#{cassette_dir}/**/*").each do |file|
        next unless File.file?(file)
        comp = comparison_hash.compare(key_from_path(file), file_digest(file))
        retval ||= comp
      end

      if comparison_hash.present?
        silent_puts "Cassettes deleted: #{comparison_hash.keys}"
        retval = true
      end

      retval.nil? ? false : retval
    end

    alias setup rent
    alias teardown drop_off
    alias compare rewind?

    private

    def remove_existing_cassette_directory
      return if @local_mode

      silent_puts "Wiping cassettes directory: #{cassette_dir}"
      FileUtils.rm_r(cassette_dir) if Dir.exist?(cassette_dir)
    end
  end
end
