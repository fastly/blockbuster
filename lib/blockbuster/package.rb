module Blockbuster
  class Package
    def initialize(configuration)
      @configuration = configuration
    end

    def cassette_dir
      File.join(@configuration.test_directory, @configuration.cassette_directory)
    end

    def master_tar_file_path
      File.join(@configuration.test_directory, @configuration.master_tar_file)
    end

    def full_delta_directory
      File.join(@configuration.test_directory, @configuration.delta_directory)
    end

    def cassette_files
      Dir.glob("#{cassette_dir}/**/*")
    end
  end
end
