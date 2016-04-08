module Blockbuster
  # Manages cassette packaging and unpackaging
  class Manager
    include Blockbuster::Packager

    attr_accessor :comparison_hash

    def configuration
      @configuration ||= Blockbuster::Configuration.new
    end

    def initialize(instance_configuration = Blockbuster::Configuration.new)
      yield configuration if block_given?

      @configuration ||= instance_configuration

      @comparison_hash = {}
    end

    # extracts cassettes from a tar.gz file
    #
    # tracks a md5 hash of each file in the tarball
    def rent
      unless File.exist?(configuration.cassette_file_path)
        silent_puts "File does not exist: #{configuration.cassette_file_path}."
        return false
      end

      remove_existing_cassette_directory if configuration.wipe_cassette_dir

      silent_puts "Extracting VCR cassettes to #{configuration.cassette_dir}"

      extract_cassettes
    end

    # repackages cassettes into a compressed tarball
    def drop_off(force: false)
      if rewind? || force
        silent_puts "Recreating cassette file #{configuration.master_tar_file}"
        create_cassette_file
      end
    end

    # performs comparison of files
    #
    # compares the md5 sums of the files in the existing tarball
    # and the cassettes from the cassette directory.
    def rewind?(retval = nil)
      Dir.glob("#{configuration.cassette_dir}/**/*").each do |file|
        next unless File.file?(file)
        comp = compare_cassettes(configuration.key_from_path(file), file)
        retval ||= comp
      end

      unless comparison_hash.keys.empty?
        silent_puts "Cassettes deleted: #{comparison_hash.keys}"
        retval = true
      end

      retval.nil? ? false : retval
    end

    alias setup rent
    alias teardown drop_off
    alias compare rewind?

    private

    # returns true for any differences or changes in cassette files
    def compare_cassettes(key, file)
      orig_key = comparison_hash.delete(key)
      if orig_key.nil?
        silent_puts "New cassette: #{key}"
        return true
      elsif orig_key != file_digest(file)
        silent_puts "Cassette changed: #{key}"
        return true
      end
    end

    def remove_existing_cassette_directory
      return if configuration.local_mode

      dir = configuration.cassette_dir

      silent_puts "Wiping cassettes directory: #{dir}"
      FileUtils.rm_r(dir) if Dir.exist?(dir)
    end

    def silent_puts(msg)
      puts "[Blockbuster] #{msg}" unless configuration.silent?
    end
  end
end
