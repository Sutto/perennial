module Perennial
  # General Perennial exceptions.
  class Error < StandardError;         end
  # Called to halt handler processing.
  class HaltHandlerProcessing < Error; end
end