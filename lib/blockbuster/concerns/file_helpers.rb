module Blockbuster
  # helpers for file/path manipulation
  module FileHelpers
    def key_from_path(file)
      path_array = File.dirname(file).split('/')
      idx = path_array.index(Blockbuster.configuration.cassette_directory)
      path_array[idx..-1].push(File.basename(file)).join('/')
    end

    def file_digest(file)
      Digest::MD5.file(file).hexdigest
    end

    def tar_digest(content)
      Digest::MD5.hexdigest(content)
    end
  end
end
