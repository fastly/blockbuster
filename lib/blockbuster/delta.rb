module Blockbuster
  # Delta file objects
  class Delta
    include Blockbuster::Extractor
    include Blockbuster::Packager

    # nodoc
    class NotEnabledError < StandardError
      def message
        'Deltas are not enabled.  Please enable them via configuration to use them.'
      end
    end

    def self.files(directory)
      Dir.glob("#{directory}/*.tar.gz").sort.map! { |file| File.basename(file) }
    end

    def self.initialize_for_each(comparator, configuration)
      setup_directory(configuration.full_delta_directory)

      delta_files = files(configuration.full_delta_directory)

      # If the current delta does not exist we want to add it.
      current_delta = configuration.current_delta_name
      delta_files << "1_#{current_delta}" unless delta_files.any?{ |file| file_name_without_timestamp(file) == current_delta }

      delta_files.map do |file|
        new(file, comparator, configuration)
      end
    end

    def self.setup_directory(directory)
      return if Dir.exist?(directory)

      FileUtils.mkdir_p(directory)
      FileUtils.touch("#{directory}/.keep")
    end

    def self.file_name_without_timestamp(file)
      file.sub(/^\d+_/,'')
    end

    attr_reader :current, :file_name, :configuration

    def initialize(file_name, comparator, configuration)
      raise NotEnabledError if configuration.deltas_disabled?

      @configuration = configuration
      @comparator = comparator
      @file_name  = file_name
      @current    = true if self.class.file_name_without_timestamp(@file_name) == @configuration.current_delta_name
    end

    def current
      @current || false
    end

    def file_path
      File.join(configuration.full_delta_directory, file_name)
    end

    def target_path
      File.join(configuration.full_delta_directory, "#{Time.now.to_i}_#{configuration.current_delta_name}")
    end

    alias current? current
  end
end
