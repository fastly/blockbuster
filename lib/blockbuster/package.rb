module Blockbuster
  class Package
    def initialize(config_object)
      @config_object = config_object
    end

    def cassette_dir
      File.join(@config_object.test_directory, @config_object.cassette_directory)
    end

    def master_tar_file_path
      File.join(@config_object.test_directory, @config_object.master_tar_file)
    end

    def full_delta_directory
      File.join(@config_object.test_directory, @config_object.delta_directory)
    end

    def cassette_files
      Dir.glob("#{cassette_dir}/**/*")
    end
  end
end
