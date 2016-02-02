module Blockbuster
  # Manages cassette packaging and unpackaging
  class Manager
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
    def return
      if rewind?
        silent_puts puts "Recreating cassette file #{CASSETTE_FILE}"
        create_cassette_file if rewind
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

    alias setup rent
    alias teardown return
    alias compare rewind?

    private

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

    def create_cassette_file

    end

    def extract_cassettes
      File.open(cassette_file_path, 'rb') do |file|
        Zlib::GzipReader.wrap(file) do |gz|
          Gem::Package::TarReader.new(gz) do |tar|
            tar.each do |entry|
              next unless entry.file?
              write_file(entry)
            end
          end
        end
      end
    end

    def file_digest(file)
      Digest::MD5.file(file).hexdigest
    end

    def read_entry_and_hash(entry)
      contents = entry.read

      comparison_hash[entry.full_name] = Digest::MD5.hexdigest(contents)
      contents
    end

    def silent?
      silent
    end

    def silent_puts(msg)
      puts "[Blockbuster] #{msg}" unless silent?
    end

    def write_file(entry)
      destination = File.join test_directory, entry.full_name

      contents = read_entry_and_hash(entry)

      return if ENV['VCR_MODE'] == 'local'

      FileUtils.mkdir_p(File.dirname(destination))
      File.open(destination, 'wb') do |cass|
        cass.write(contents)
      end
      File.chmod(entry.header.mode, destination)
    end
  end
end
