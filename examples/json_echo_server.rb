require 'rubygems'
require 'eventmachine'
require File.join(File.dirname(__FILE__), "..", "lib", "perennial")

module MyAwesomeApp

  include Perennial
  
  manifest do |m, l|
    Settings.root = __FILE__.to_pathname.dirname
  end

  class JSONEchoServer < EventMachine::Connection
    include Perennial::Protocols::JSONTransport
  
    on_action :echo, :echo_data
  
    def echo_data(d)
      puts "Got data: #{d.inspect}"
      reply :echoed_back, d
    end
  
  end
  
end

EM.run do
  puts "Starting..."
  EM.start_server "localhost", 43241, MyAwesomeApp::JSONEchoServer
end