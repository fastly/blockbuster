module Blockbuster
  # helpers for outputting to STDOUT
  module OutputHelpers
    def silent_puts(msg)
      puts "[Blockbuster] #{msg}" unless configuration.silent?
    end
  end
end
