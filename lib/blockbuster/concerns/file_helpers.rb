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

    def cassette_dir
      File.join(test_directory, cassette_directory)
    end

    def cassette_file_path
      File.join(test_directory, cassette_file)
    end
  end
end
