module Perennial
  # General Perennial exceptions.
  class Error < StandardError;         end
  class HaltHandlerProcessing < Error; end
end