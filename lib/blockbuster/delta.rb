module Blockbuster
  # Delta file objects
  class Delta
    include Blockbuster::Extractor
    include Blockbuster::Packager
    include Blockbuster::FileHelpers
    extend Blockbuster::FileHelpers

    # nodoc
    class NotEnabledError < StandardError
      def message
        'Deltas are not enabled.  Please enable them via configuration to use them.'
      end
    end

    def self.files
      Dir.glob("#{full_delta_directory}/*.tar.gz").sort
    end

    def self.initialize_for_each
      setup_directory

      delta_files = files

      # If the current delta does not exist we want to add it.
      current_delta_path = "#{full_delta_directory}/#{Blockbuster.configuration.current_delta_name}"
      delta_files << current_delta_path unless delta_files.grep(/#{Blockbuster.configuration.current_delta_name}/).first

      delta_files.map do |file|
        new(file)
      end
    end

    def self.setup_directory
      return if Dir.exist?(full_delta_directory)

      FileUtils.mkdir_p(full_delta_directory)
      FileUtils.touch("#{full_delta_directory}/.keep")
    end

    attr_reader :current, :file_name

    def initialize(file_name)
      raise NotEnabledError if Blockbuster.configuration.deltas_disabled?

      @file_name = File.basename(file_name)
      @current   = true if @file_name =~ /#{Blockbuster.configuration.current_delta_name}/
    end

    def current
      @current || false
    end

    def file_path
      File.join(full_delta_directory, file_name)
    end

    def target_path
      File.join(full_delta_directory, "#{Time.now.to_i}_#{Blockbuster.configuration.current_delta_name}")
    end

    alias current? current
  end
end
