module Blockbuster
  # helpers for working with tarballs
  module TarballHelpers
    def create_tar(tar)
      yield Gem::Package::TarWriter.new(tar)
    end

    def read_tar(tar)
      yield Gem::Package::TarReader.new(tar)
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

    def tar_digest(content)
      Digest::MD5.hexdigest(content)
    end
  end
end
