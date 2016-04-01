module Blockbuster
  # Object that holds all cassettes and their latest checksum
  class Comparator
    include Blockbuster::OutputHelpers

    def initialize
      @hash = {}
    end

    def add(key, value)
      @hash[key] = value
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
      digest = @hash.delete(key)

      if digest.nil?
        silent_puts "New cassette: #{key}"
        return true
      elsif digest != new_digest
        silent_puts "Cassette changed: #{key}"
        return true
      end
    end
  end
end
