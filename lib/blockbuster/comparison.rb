module Blockbuster
  # Object that holds all cassettes and their latest checksum
  class Comparison
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
  end
end
