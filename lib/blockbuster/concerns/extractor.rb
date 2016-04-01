module Blockbuster
  # extracts files from gzipped tarballs
  module Extractor
    def extract_cassettes
      File.open(cassette_file_path, 'rb') do |file|
        Zlib::GzipReader.wrap(file) do |gz|
          read_tar(gz) do |tar|
            tar.each do |entry|
              next unless entry.file?
              untar_file(entry)
            end
          end
        end
      end
    end

    def files_to_extract
      # use this to retrieve files to extract based off configuration
    end

    def read_entry_and_hash(entry)
      contents = entry.read

      comparison_hash.add(entry.full_name, tar_digest(contents))
      contents
    end
  end
end
