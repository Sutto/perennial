module Perennial
  module JewelerExt
    # Adds in utility messages to make it easier to manage versioning.
    
    class << self
      attr_accessor :version_array, :library_file
    end
    
    module Versioning
      
      def write
        contents = File.read(main_library_file)
        contents.gsub!(/(VERSION\s+=\s+)(\[\d+\,\s*\d+\,\s*\d+(?:\,\s*\d+)?\])/) do |m|
          "#{$1}#{array.inspect}"
        end
        File.open(main_library_file, "w+") do |f|
          f.write(contents)
        end
      end
      
      def array
        [major, minor, patch, build]
      end
      
      def main_library_file
        Perennial::JewelerExt.library_file
      end
      
      def parse_version
        parts = Perennial::JewelerExt.version_array
        puts 'Version array: ' + parts.inspect
        @major = parts[0]
        @minor = parts[1]
        @patch = parts[2]
        @build = parts[3]
      end
      
      def refresh
        parse_version
      end
      
      def path
        nil
      end
      
    end
  end
end

require 'jeweler' unless defined?(Jeweler)

# Overrides Jeweler to version using our stuff

def Jeweler.versioning_via(file, version_array)
  Perennial::JewelerExt.library_file  = file
  Perennial::JewelerExt.version_array = version_array
  # Extend with the Perennial extensions
  Jeweler::VersionHelper.class_eval do
    def initialize(base_dir)
      extend Perennial::JewelerExt::Versioning
      parse_version
    end
  end
  # Ensure version exists
  Jeweler.class_eval do
    def version_exists?
      true
    end
  end
end