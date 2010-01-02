# Most of the code here, esp. the nifty code to handle protocol
# errors is from the memcache-client gem. for the appropriate license,
# see licenses/memcache-client.txt

require 'digest/sha2'
require 'socket'
require 'net/protocol'
require 'json' unless defined?(JSON)

# Nasty module declaration out of the way.
module Perennial; module Protocols; module PureRuby
end; end; end

begin
  if defined?(JRUBY_VERSION) || (RUBY_VERSION >= '1.9')
    require 'timeout'
    Perennial::TimerImplementation = Timeout
  else
    require 'system_timer'
    Perennial::TimerImplementation = SystemTimer
  end
rescue LoadError => e
  require 'timeout'
  Perennial::TimerImplementation = Timeout
end

class Perennial::Protocols::PureRuby::JSONTransport
  
  class Error < StandardError; end
  class NoConnection < Error; end
  
  @@callbacks = {}
  
  RETRY_DELAY = 30.0
  SEPERATOR   = "\r\n".freeze
  
  attr_reader :host, :port, :retry
  
  def initialize(host, port, timeout = nil)
    @host = host
    @port = port
    @timeout = timeout
  end
  
  def write_message(action, payload = {}, &callback)
    # TODO: Print message.
    message = JSON.dump({
      "action"  => action.to_s,
      "payload" => payload,
      "sent-at" => Time.now
    }.merge(callback_options(callback))) + SEPERATOR
    with_socket do |s|
      raise NoConnection, "no connection the server at #{@host}:#{@port}" if s.nil?
      s.write(message)
    end
  end
  
  def read_message(timeout = nil)
    with_socket do |s|
      raise NoConnection, "no connection the server at #{@host}:#{@port}" if s.nil?
      message = nil
      begin
        Perennial::TimerImplementation.timeout(timeout || @timeout) do
          message = JSON.parse(s.gets.strip)
        end
      rescue Timeout::Error
        return nil, nil
      end
      return nil, nil if !message.is_a?(Hash)
      action, payload = message["action"], message["payload"]
      return nil, nil if !action.is_a?(String)
      payload = {} unless payload.is_a?(Hash)
      # We have a processed callback - huzzah!
      if payload.has_key?("callback-id")
        callback = @@callbacks.delete(payload["callback-id"])
        callback.call(action, payload) if callback
      end
      return action, payload
    end
  end
  
  def alive?
    !!socket
  end
  
  def close
    @socket.close if @socket && !@socket.closed?
    @socket = nil
    @retry = nil
  end
  
  protected
  
  def callback_options(blk)
    return {} if blk.nil?
    callback_id = Digest::SHA256.hexdigest("#{self.class.name}-#{Time.now.to_f}-#{rand(1_000_000_000)}")
    @@callbacks[callback_id] = blk
    {"callback-id" => callback_id}
  end
  
  def with_socket(&blk)
    blk.call(socket)
  rescue SocketError, Errno::EAGAIN, Timeout::Error
    dead!
  rescue SystemCallError, IOError
    retried = true
    retry
  end
  
  def dead!
    close
    @retry = Time.now + RETRY_DELAY
  end
  
  def socket
    return @socket if @socket and not @socket.closed?
    @socket = nil
    return if @retry and @retry > Time.now
    begin
      @socket = socket_for(@host, @port, @timeout)
      @socket.setsockopt Socket::IPPROTO_TCP, Socket::TCP_NODELAY, 1
      @retry = nil
    rescue SocketError, SystemCallError, IOError, Timeout::Error => err
      dead!
    end
    @socket
  end
  
  def socket_for(host = @host, port = @port, timeout = nil)
    socket = nil
    if timeout
      Perennial::TimerImplementation.timeout(timeout) do
        socket = TCPSocket.new(host, port)
      end
    else
      socket = TCPSocket.new(host, port)
    end
    io = BufferedIO.new(socket)
    io.read_timeout = timeout
    if timeout
      secs = Integer(timeout)
      if timeout
        secs = Integer(timeout)
        usecs = Integer((timeout - secs) * 1_000_000)
        optval = [secs, usecs].pack("l_2")
        begin
          io.setsockopt Socket::SOL_SOCKET, Socket::SO_RCVTIMEO, optval
          io.setsockopt Socket::SOL_SOCKET, Socket::SO_SNDTIMEO, optval
        rescue Exception => ex
          # Solaris, for one, does not like/support socket timeouts.
        end
      end
    end
    io
  end
  
  class BufferedIO < Net::BufferedIO # :nodoc:
    BUFSIZE = 1024 * 16

    if RUBY_VERSION < '1.9.1'
      def rbuf_fill
        begin
          @rbuf << @io.read_nonblock(BUFSIZE)
        rescue Errno::EWOULDBLOCK
          retry unless @read_timeout
          if IO.select([@io], nil, nil, @read_timeout)
            retry
          else
            raise Timeout::Error, 'IO timeout'
          end
        end
      end
    end

    def setsockopt(*args)
      @io.setsockopt(*args)
    end

    def gets
      readuntil(SEPERATOR)
    end
  end
  
end