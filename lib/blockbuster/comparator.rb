module Blockbuster
  # Data store for files, sources, states, and checksums
  class Comparator
    include Blockbuster::FileHelpers
    include Blockbuster::OutputHelpers

    CONTENT = 'content'.freeze
    SOURCE  = 'source'.freeze

    attr_reader :configuration, :inventory, :edited, :current_delta_files

    def initialize(configuration)
      @configuration       = configuration
      @inventory           = {}
      @edited              = []
      @current_delta_files = []
      @deleted             = []
    end

    def add(key, value, source)
      inventory[key] = { CONTENT => value, SOURCE => source }
    end

    def delete(key)
      inventory.delete(key)
    end

    def keys
      inventory.keys
    end

    def present?
      !keys.empty?
    end

    def edited?(file)
      (edited + current_delta_files).include?(file)
    end

    def store_current_delta_files
      inventory.each do |k, v|
        scrubbed = Blockbuster::Delta.file_name_without_timestamp(v[SOURCE])
        current_delta_files << k if scrubbed == configuration.current_delta_name
      end
    end

    def compare(key, new_digest)
      digest = inventory[key]

      if digest.nil?
        silent_puts "New cassette: #{key}"
        return true
      elsif digest[CONTENT] != new_digest
        silent_puts "Cassette changed: #{key}"
        return true
      end
    end

    def rewind?(files) # rubocop:disable Metrics/AbcSize
      base_files = []

      files.each do |file|
        next unless File.file?(file)

        key = configuration.key_from_path(file)
        base_files << key

        edited << key if compare(key, file_digest(file))
      end

      @deleted = keys - base_files

      return true if any_deleted?

      !edited.empty?
    end

    def any_deleted?
      if configuration.deltas_disabled? && !@deleted.empty?
        silent_puts "Cassettes deleted: #{@deleted}"
        return true
      elsif configuration.deltas_enabled? && !(current_delta_files & @deleted).empty?
        silent_puts "Cassettes deleted: #{@deleted}"
        return true
      end

      false
    end
  end
end
