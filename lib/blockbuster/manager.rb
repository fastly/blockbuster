module Blockbuster
  class Manager
    CASSETTE_FILE      = 'vcr_cassettes.tar.gz'.freeze
    CASSETTE_DIRECTORY = 'cassettes'.freeze
    TEST_DIRECTORY     = 'test'.freeze

    attr_reader :cassette_directory, :cassette_file, :test_directory

    def initialize(cassette_directory: CASSETTE_DIRECTORY, cassette_file: CASSETTE_FILE, test_directory: TEST_DIRECTORY)
      @cassette_directory = cassette_directory
      @cassette_file      = cassette_file
      @test_directory     = test_directory
    end

    def rent

    end

    def return

    end

    alias_method :setup, :rent
    alias_method :teardown, :return

    private

    def cassette_dir
      "#{test_directory}/#{CASSETTE_DIR_NAME}"
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

  def cassette_file_path
    "#{base}/#{CASSETTE_FILE}"
  end

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

