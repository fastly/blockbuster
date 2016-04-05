module Blockbuster
  # helpers for output
  module OutputHelpers
    def silent_puts(msg)
      puts "[Blockbuster] #{msg}" unless configuration.silent?
    end
  end
end
