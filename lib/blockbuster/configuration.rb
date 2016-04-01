module Blockbuster
  # Manages blockbuster configuration
  class Configuration
    CASSETTE_FILE      = 'vcr_cassettes.tar.gz'.freeze
    CASSETTE_DIRECTORY = 'cassettes'.freeze
    TEST_DIRECTORY     = 'test'.freeze
    WIPE_CASSETTE_DIR  = false
    LOCAL_MODE         = 'local'.freeze
    SILENT             = false
    ENABLE_DELTAS      = false
    DELTA_DIRECTORY    = 'deltas'.freeze
    CURRENT_DELTA_NAME = 'current_delta.tar.gz'.freeze

    # @param cassette_directory [String] Name of directory cassette files are stored.
    #  Will be stored under the test directory. default: 'casssettes'
    # @param cassette_file [String] name of gz cassettes file. default: 'vcr_cassettes.tar.gz'
    # @param test_directory [String] path to test directory where cassete file and cassetes will be stored.
    #  default: 'test'
    # @param silent [Boolean] Silence all output. default: false
    # @param enable_deltas [Boolean] Enables delta functionality.
    attr_writer :cassette_directory, :cassette_file, :local_mode, :test_directory, :wipe_cassette_dir, :silent, :enable_deltas,
                :delta_directory, :current_delta_name

    def cassette_directory
      @cassette_directory ||= CASSETTE_DIRECTORY
    end

    def cassette_file
      @cassette_file ||= CASSETTE_FILE
    end

    def test_directory
      @test_directory ||= TEST_DIRECTORY
    end

    def silent
      @silent ||= SILENT
    end

    alias silent? silent

    def wipe_cassette_dir
      @wipe_cassette_dir ||= WIPE_CASSETTE_DIR
    end

    def local_mode
      @local_mode ||= ENV['VCR_MODE'] == LOCAL_MODE
    end

    def enable_deltas
      @enable_deltas ||= ENABLE_DELTAS
    end

    alias deltas_enabled? enable_deltas

    def delta_directory
      @delta_directory ||= DELTA_DIRECTORY
    end

    def current_delta_name
      @current_delta_name ||= CURRENT_DELTA_NAME
    end
  end
end
