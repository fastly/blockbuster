module Blockbuster
  # pure ruby implmentation of tar gzip and diff
  module Packager
    def create_cassette_file
      FileUtils.rm(file_path) if File.exist?(file_path)
      File.open(target_path, 'wb') do |file|
        Zlib::GzipWriter.wrap(file) do |gz|
          Gem::Package::TarWriter.new(gz) do |tar|
            cassette_files.each do |cass|
              tar_file(tar, cass)
            end
          end
        end
      end
    end

    def tar_file(tar, file)
      rel_path = key_from_path(file)

      if Blockbuster.configuration.deltas_enabled?
        return unless @comparator.edited?(rel_path)
      end

      write_to_disk(tar, file)
    end

    def write_to_disk(tar, file)
      mode     = File.stat(file).mode
      rel_path = key_from_path(file)

      if File.directory?(file)
        tar.mkdir rel_path, mode
      else
        tar.add_file_simple rel_path, mode, File.size(file) do |io|
          File.open(file, 'rb') { |f| io.write f.read }
        end
      end
    end
  end
end
