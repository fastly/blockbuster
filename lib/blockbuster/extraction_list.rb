module Blockbuster
  # generates an ordered collection of files to extract
  class ExtractionList
    attr_reader :files

    def initialize(comparator, config)
      @comparator    = comparator
      @config        = config

      list = [master]

      list << deltas if @config.deltas_enabled?

      @files = list.flatten
    end

    def current_delta
      @deltas.find(&:current?)
    end

    def deltas
      @deltas ||= Delta.initialize_for_each(@comparator, @config)
    end

    def extract_cassettes
      files.map(&:extract_cassettes)
    end

    def master
      @master ||= Master.new(@comparator, @config)
    end

    # determines what file representation to return for writing to
    #
    # 1.  master when deltas are disabled
    #
    # 2.  master when master does not exist.  This handles two scenarios:
    #     - master does not exist (if this happens, we should always regenerate master)
    #     - we want to regenerate master (this assumes some other mechanism is responsible
    #       for deleting master to make this work)
    #
    # 3.  current_delta
    def primary
      return master unless @config.deltas_enabled?

      return master unless File.exist?(master.file_path)

      current_delta
    end
  end
end
