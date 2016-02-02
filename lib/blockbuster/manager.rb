module Blockbuster
  # Manages cassette packaging and unpackaging
  class Manager
    include Blockbuster::Packager

    CASSETTE_FILE      = 'vcr_cassettes.tar.gz'.freeze
    CASSETTE_DIRECTORY = 'cassettes'.freeze
    TEST_DIRECTORY     = 'test'.freeze

    attr_reader :cassette_directory, :cassette_file, :test_directory, :silent
    attr_accessor :comparison_hash

    # @param cassette_directory [String] Name of directory cassette files are stored.
    #  Will be stored under the test directory. default: 'casssettes'
    # @param cassette_file [String] name of gz cassettes file. default: 'vcr_cassettes.tar.gz'
    # @param test_directory [String] path to test directory where cassete file and cassetes will be stored.
    #  default: 'test'
    # @param silent [Boolean] Silence all output. default: false
    def initialize(cassette_directory: CASSETTE_DIRECTORY, cassette_file: CASSETTE_FILE, test_directory: TEST_DIRECTORY, silent: false)
      @cassette_directory = cassette_directory
      @cassette_file      = cassette_file
      @test_directory     = test_directory
      @silent             = silent
      @comparison_hash    = {}
    end

    # extracts cassettes from a tar.gz file
    #
    # tracks a md5 hash of each file in the tarball
    def rent
      unless File.exist?(cassette_file_path)
        silent_puts "[Blockbuster] File does not exist #{cassette_file_path}."
        return false
      end
      # return unless File.exist?(cassette_file_path)

      silent_puts "[Blockbuster] Extracting VCR cassettes to #{cassette_dir}"

      extract_cassettes
    end

    # repackages cassettes into a compressed tarball
    def return(force: false)
      if rewind? || force
        silent_puts puts "Recreating cassette file #{CASSETTE_FILE}"
        create_cassette_file
      end
    end

    # performs comparison of files
    #
    # compares the md5 sums of the files in the existing tarball
    # and the cassettes from the cassette directory.
    def rewind?(retval = nil)
      Dir.glob("#{cassette_dir}/**/*").each do |file|
        key = key_from_path(file)
        comp = compare_cassettes(key, file)
        retval ||= comp
      end

      if comparison_hash.keys.size > 0
        silent_puts "Cassettes deleted: #{comparison_hash.keys}"
        retval = true
      end

      retval.nil? ? false : retval
    end

    alias setup rent
    alias teardown return
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

    def key_from_path(file)
      path_array = File.dirname(file).split('/')
      idx = path_array.index(cassette_directory)
      path_array[idx..-1].push(File.basename(file)).join('/')
    end

    def cassette_dir
      File.join(test_directory, cassette_directory)
    end

    def cassette_file_path
      File.join(test_directory, cassette_file)
    end

    def silent?
      silent
    end

    def silent_puts(msg)
      puts "[Blockbuster] #{msg}" unless silent?
    end
  end
end
