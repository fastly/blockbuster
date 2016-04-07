module Blockbuster
  # Object that holds all cassettes and their latest checksum
  class Comparator
    include Blockbuster::OutputHelpers

    attr_reader :configuration, :hash, :edited, :current_delta_files

    def initialize(configuration)
      @configuration = configuration
      @hash   = {}
      @delete = {}

      @edited              = []
      @current_delta_files = []
    end

    def add(key, value, source)
      @hash[key] = { 'content' => value, 'source' => source }
    end

    def delete(key)
      @hash.delete(key)
    end

    def keys
      @hash.keys
    end

    def present?
      !@hash.keys.empty?
    end

    # returns true for any differences or changes in cassette files
    def compare(key, new_digest)
      digest = @hash[key]

      if digest.nil?
        silent_puts "New cassette: #{key}"
        return true
      elsif digest['content'] != new_digest
        silent_puts "Cassette changed: #{key}"
        return true
      end
    end

    def edited?(file)
      (@edited + @current_delta_files).include?(file)
    end

    def store_current_delta_files
      @hash.each do |k, v|
        @current_delta_files << k if v['source'].sub(/^\d+_/, '') == configuration.current_delta_name
      end
    end

    # compares the md5 sums of the files in the existing tarball
    # and the cassettes from the cassette directory.
    def rewind?(files) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength
      files.each do |file|
        next unless File.file?(file)
        key = configuration.key_from_path(file)
        @edited << key if compare(key, configuration.file_digest(file))
      end

      base_files = files.map { |file| configuration.key_from_path(file) }
      deleted =  @hash.keys - base_files

      if !deleted.empty? && configuration.deltas_disabled?
        silent_puts "Cassettes deleted: #{keys}"
        return true
      end

      if configuration.deltas_enabled? && !(@current_delta_files & deleted).empty?
        @current_delta_files -= deleted
        silent_puts "Cassettes deleted: #{keys}"
        return true
      end

      !@edited.empty?
    end
  end
end
