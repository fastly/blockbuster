module Blockbuster
  # pure ruby implmentation of tar gzip and diff
  module Packager
    private

    def create_cassette_file
      FileUtils.rm(master_tar_file_path) if File.exist?(master_tar_file_path)
      File.open(master_tar_file_path, 'wb') do |file|
        Zlib::GzipWriter.wrap(file) do |gz|
          create_tar(gz) do |tar|
            Dir.glob(File.join(cassette_dir, '**/*')).each do |cass|
              tar_file(tar, cass)
            end
          end
        end
      end
    end
  end
end
