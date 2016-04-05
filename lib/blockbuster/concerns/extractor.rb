module Blockbuster
  # extracts files from gzipped tarballs
  module Extractor
    def extract_cassettes
      File.open(file_path, 'rb') do |file|
        Zlib::GzipReader.wrap(file) do |gz|
          Gem::Package::TarReader.new(gz) do |tar|
            tar.each do |entry|
              next unless entry.file?
              untar_file(entry)
            end
          end
        end
      end
    end

    def untar_file(entry)
      contents = entry.read

      is_primary = self.instance_of?(Blockbuster::Master) || current?
      @comparator.add(entry.full_name, tar_digest(contents), file_name, is_primary)

      save_to_disk(entry, contents) unless @local_mode
    end

    def save_to_disk(entry, contents)
      destination = File.join Blockbuster.configuration.test_directory, entry.full_name

      FileUtils.mkdir_p(File.dirname(destination))
      File.open(destination, 'wb') do |cass|
        cass.write(contents)
      end
      File.chmod(entry.header.mode, destination)
    end
  end
end
