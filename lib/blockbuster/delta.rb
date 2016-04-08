module Blockbuster
  # Delta file objects
  class Delta
    # nodoc
    class NotEnabledError < StandardError
      def message
        'Deltas are not enabled.  Please enable them via configuration to use them'
      end
    end

    attr_reader :current, :file_name, :configuration

    def self.file_name_without_timestamp(file_name)
      file_name.sub(/^\d+_/, '')
    end

    attr_reader :current, :file_name, :configuration

    def initialize(file_name, configuration)
      raise NotEnabledError if configuration.deltas_disabled?

      @configuration = configuration
      @file_name     = file_name
      @current       = true if file_name_without_timestamp == configuration.current_delta_name
    end

    def file_name_without_timestamp
      self.class.file_name_without_timestamp(file_name)
    end

    def current
      @current || false
    end

    alias current? current

    def file_path
      File.join(configuration.full_delta_directory, file_name)
    end

    def target_path
      target = [Time.now.to_i, configuration.current_delta_name].join('_')

      File.join(configuration.full_delta_directory, target)
    end
  end
end
