require 'rubygems'
require 'readline'
require File.join(File.dirname(__FILE__), "..", "lib", "perennial")

transport = Perennial::Protocols::PureRuby::JSONTransport.new('localhost', 43241, 10.0)

input = ''

loop do
  line = Readline.readline('input> ')
  break if line.strip.downcase == 'exit'
  transport.write_message(:echo, 'text' => line)
  p transport.read_message
end