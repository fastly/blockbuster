module Blockbuster
  # Manages cassette packaging and unpackaging
  class Manager
    CASSETTE_FILE      = 'vcr_cassettes.tar.gz'.freeze
    CASSETTE_DIRECTORY = 'cassettes'.freeze
    TEST_DIRECTORY     = 'test'.freeze

    attr_reader :cassette_directory, :cassette_file, :test_directory, :silent

    # creates a new manager
    #
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
    end

    def rent
      return false if ENV['VCR_MODE'] == 'local'
      unless File.exist?(cassette_file_path)
        silent_puts "File does not exist #{cassette_file_path}"
        return false
      end
      # return unless File.exist?(cassette_file_path)

      silent_puts "Extracting VCR cassettes to #{cassette_dir}"

      extract_cassettes
    end

    def return
    end

    alias setup rent
    alias teardown return

    private

    def cassette_dir
      File.join(test_directory, cassette_directory)
    end

    def cassette_file_path
      File.join(test_directory, cassette_file)
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

    def write_file(entry)
      destination = File.join test_directory, entry.full_name
      FileUtils.mkdir_p(File.dirname(destination))
      File.open(destination, 'wb') do |cass|
        cass.write(entry.read)
      end
      File.chmod(entry.header.mode, destination)
    end

    def silent?
      silent
    end

    def silent_puts(msg)
      puts msg unless silent?
    end
  end
end

=begin
  def setup
    return if ENV['VCR_MODE'] == 'local'
    unless File.exist?(cassette_file_path)
      puts "File does not exist #{cassette_file_path}"
      puts "PWD #{FileUtils.pwd}"
      return
    end
    # return unless File.exist?(cassette_file_path)

    puts "Extracting VCR cassettes to #{cassette_dir}"
    status = system("tar -xzvf #{cassette_file_path} -C #{base}/ > /dev/null")
    puts 'WARN: could not extract cassettes' unless status
  end

  def teardown
    if File.exist?(cassette_file_path)
      compare_cassettes
    else
      create_cassette_file
    end
  end

  private


  def compare_cassettes
    Dir.mkdir(tmpdir) unless Dir.exist?(tmpdir)

    `tar -xzf #{cassette_file_path} -C #{tmpdir}`
    status = system("diff -arq  #{cassette_dir} #{tmpdir}/#{CASSETTE_DIR_NAME}")

    unless status
      puts "Cassettes are different. Recreating cassette file #{CASSETTE_FILE}"
      create_cassette_file
    end

    FileUtils.remove_dir(tmpdir)
  end

  def create_cassette_file
    `cd #{base} && tar -czvf #{CASSETTE_FILE} #{CASSETTE_DIR_NAME}`
  end

  def tmpdir
    "#{base}/tmp"
  end
end

=end

