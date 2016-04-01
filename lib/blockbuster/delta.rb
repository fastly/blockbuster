module Blockbuster
  # Delta file objects
  class Delta
    # nodoc
    class NotEnabledError < StandardError
      def message
        'Deltas are not enabled.  Please enable them via configuration to use them.'
      end
    end

    def self.files
      @files ||= begin
                   test_dir   = Blockbuster.configuration.test_directory
                   delta_dir  = Blockbuster.configuration.delta_directory
                   delta_path = File.join(test_dir, delta_dir)

                   Dir.glob("#{delta_path}/*.tar.gz").sort_by { |x| File.mtime(x) }
                 end
    end

    def self.initialize_for_each
      files.map do |file|
        new(file)
      end
    end

    attr_reader :current

    def initialize(file_name)
      raise NotEnabledError unless Blockbuster.configuration.deltas_enabled?

      @current = true if File.basename(file_name) == Blockbuster.configuration.current_delta_name
    end

    def current
      @current || false
    end

    alias current? current
  end
end
