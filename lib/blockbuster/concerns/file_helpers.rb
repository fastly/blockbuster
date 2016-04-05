module Blockbuster
  # helpers for file/path manipulation
  module FileHelpers
    def key_from_path(file)
      path_array = File.dirname(file).split('/')
      idx = path_array.index(cassette_directory)
      path_array[idx..-1].push(File.basename(file)).join('/')
    end

    def file_digest(file)
      Digest::MD5.file(file).hexdigest
    end

    def tar_digest(content)
      Digest::MD5.hexdigest(content)
    end

    def cassette_dir
      File.join(test_directory, cassette_directory)
    end

    def master_tar_file_path
      File.join(test_directory, master_tar_file)
    end

    def full_delta_directory
      File.join(test_directory, delta_directory)
    end

    def cassette_files
      Dir.glob("#{cassette_dir}/**/*")
    end
  end
end
