module Blockbuster
  # Manages blockbuster configuration
  class Configuration
    MASTER_TAR_FILE    = 'vcr_cassettes.tar.gz'.freeze
    CASSETTE_DIRECTORY = 'cassettes'.freeze
    TEST_DIRECTORY     = 'test'.freeze
    WIPE_CASSETTE_DIR  = false
    LOCAL_MODE         = 'local'.freeze
    SILENT             = false

    # @param cassette_directory [String] Name of directory cassette files are stored.
    #  Will be stored under the test directory. default: 'casssettes'
    # @param master_tar_file [String] name of gz cassettes file. default: 'vcr_cassettes.tar.gz'
    # @param test_directory [String] path to test directory where cassete file and cassetes will be stored.
    #  default: 'test'
    # @param silent [Boolean] Silence all output. default: false
    attr_writer :cassette_directory, :master_tar_file, :local_mode, :test_directory, :wipe_cassette_dir, :silent

    def cassette_directory
      @cassette_directory ||= CASSETTE_DIRECTORY
    end

    def master_tar_file
      @master_tar_file ||= MASTER_TAR_FILE
    end

    def test_directory
      @test_directory ||= TEST_DIRECTORY
    end

    def silent
      @silent ||= SILENT
    end

    def wipe_cassette_dir
      @wipe_cassette_dir ||= WIPE_CASSETTE_DIR
    end

    def local_mode
      @local_mode ||= ENV['VCR_MODE'] == LOCAL_MODE
    end
  end
end
