module Blockbuster
  # Delta file objects
  class Delta < Package
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

    # Dir.glob returns the full path for a file, dir/time_delta_name.tar.gz, so we strip out
    # the directory path and then drop the first 11 characters (epoch time + _) to get the delta
    # tar name. This will break in the 2200s because epoch will be 11 characters instead of 10.
    def self.files
      Dir.glob("#{full_delta_directory}/*.tar.gz").sort.map! { |file| File.basename(file)[11..-1] }
    end

    def self.initialize_for_each(comparator, config)
      delta_dir_path = File.join(config.test_directory, config.delta_directory)
      setup_directory(delta_dir_path)

      delta_files = files

      # If the current delta does not exist we want to add it.
      delta_files << config.current_delta_name unless delta_files.include?(config.current_delta_name)

      delta_files.map do |file|
        new(file, comparator, config)
      end
    end

    def self.setup_directory(dir)
      return if Dir.exist?(dir)

      FileUtils.mkdir_p(dir)
      FileUtils.touch("#{dir}/.keep")
    end

    attr_reader :current, :file_name

    def initialize(file_name, comparator, config)
      @current_delta_name = config.current_delta_name

      @comparator = comparator
      @file_name  = file_name
      @current    = true if @file_name == config.current_delta_name

      super(config)
    end

    def current
      @current || false
    end

    def file_path
      File.join(full_delta_directory, file_name)
    end

    def target_path
      File.join(full_delta_directory, "#{Time.now.to_i}_#{@current_delta_name}")
    end

    alias current? current
  end
end
