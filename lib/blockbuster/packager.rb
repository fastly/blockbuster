module Blockbuster
  # pure ruby implmentation of tar gzip and diff
  module Packager
    private

    def create_cassette_file
      FileUtils.rm(cassette_file_path) if File.exist?(cassette_file_path)
      File.open(cassette_file_path, 'wb') do |file|
        Zlib::GzipWriter.wrap(file) do |gz|
          Gem::Package::TarWriter.new(gz) do |tar|
            Dir.glob(File.join(cassette_dir, '**/*')).each do |cass|
              tar_file(tar, cass)
            end
          end
        end
      end
    end

    def extract_cassettes
      File.open(cassette_file_path, 'rb') do |file|
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

    def file_digest(file)
      Digest::MD5.file(file).hexdigest
    end

    def read_entry_and_hash(entry)
      contents = entry.read

      comparison_hash.add(entry.full_name, Digest::MD5.hexdigest(contents))
      contents
    end

    def tar_file(tar, file)
      mode = File.stat(file).mode
      rel_path = key_from_path(file)

      if File.directory?(file)
        tar.mkdir rel_path, mode
      else
        tar.add_file_simple rel_path, mode, File.size(file) do |io|
          File.open(file, 'rb') { |f| io.write f.read }
        end
      end
    end

    def untar_file(entry)
      destination = File.join test_directory, entry.full_name

      contents = read_entry_and_hash(entry)

      return if @local_mode

      FileUtils.mkdir_p(File.dirname(destination))
      File.open(destination, 'wb') do |cass|
        cass.write(contents)
      end
      File.chmod(entry.header.mode, destination)
    end
  end
end
