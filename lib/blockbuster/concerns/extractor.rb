module Blockbuster
  # extracts files from gzipped tarballs
  module Extractor
    def extract_cassettes
      return unless File.exist?(file_path)
      File.open(file_path, 'rb') do |file|
        Zlib::GzipReader.wrap(file) do |gz|
          Gem::Package::TarReader.new(gz) do |tar|
            tar.each do |entry|
              untar_file(entry) if entry.file?
            end
          end
        end
      end
    end

    def untar_file(entry)
      contents = entry.read
      @comparator.add(entry.full_name, configuration.tar_digest(contents), file_name)

      save_to_disk(entry, contents) unless configuration.local_mode
    end

    def save_to_disk(entry, contents)
      destination = File.join configuration.test_directory, entry.full_name

      FileUtils.mkdir_p(File.dirname(destination))
      File.open(destination, 'wb') do |cass|
        cass.write(contents)
      end
      File.chmod(entry.header.mode, destination)
    end
  end
end
