module Blockbuster
  # file helper methods
  module FileHelpers
    def file_digest(file)
      Digest::MD5.file(file).hexdigest
    end

    def tar_digest(content)
      Digest::MD5.hexdigest(content)
    end
  end
end
