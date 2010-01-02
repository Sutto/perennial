require 'digest/sha2'
require 'json' unless defined?(JSON)

module Perennial
  module Protocols
    module JSONTransport
      
      SEPERATOR = "\r\n".freeze
      
      def self.included(parent)
        parent.class_eval do |parent|
          is :loggable
          
          cattr_accessor :event_handlers
          
          include InstanceMethods
          extend  ClassMethods
          
          self.event_handlers = Hash.new { |h,k| h[k] = [] }
          
          # Simple built in Methods, applicable both ways.
          on_action :exception,   :handle_exception
          on_action :noop,        :handle_noop
          on_action :enable_ssl,  :handle_enable_ssl
          on_action :enabled_ssl,  :handle_enabled_ssl
          
        end
      end
      
      module InstanceMethods
        
        def receive_data(data)
          protocol_buffer.extract(data).each do |part|
            receive_line(part)
          end
        end
        
        def receive_line(line)
          line.strip!
          response = JSON.parse(line)
          handle_response(response)
        rescue Exception => e
          # Typically a problem parsing JSON
          handle_receiving_exception(e)
        end
        
        # Typically you'd log a backtrace
        def handle_receiving_exception(e)
        end
        
        def host_with_port
          @host_with_port ||= begin
            port, ip = Socket.unpack_sockaddr_in(get_peername)
            "#{ip}:#{port}"
          end
        end
        
        def message(name, data = {}, &blk)
          payload = {
            "action"  => name.to_s,
            "payload" => data,
            "sent-at" => Time.now
          }
          payload.merge!(options_for_callback(blk))
          send_data "#{JSON.dump(payload)}#{SEPERATOR}"
        end
        
        def reply(name, data = {}, &blk)
          data = data.merge("callback-id" => @callback_id) if instance_variable_defined?(:@callback_id) && @callback_id.present?
          message(name, data, &blk)
        end
        
        def use_ssl=(value)
          @should_use_ssl = value
          enable_ssl if connected?
        end
        
        def post_connect
        end
        
        def post_init
          if !connected? && !ssl_enabled?
            @connected = true
            post_connect
          end
        end
        
        def ssl_handshake_complete
          if !connected?
            @connected = true
            post_connect
          end
        end
        
        def handle_enable_ssl(data)
          reply :enabled_ssl
          enable_ssl
        end
        
        def handle_enabled_ssl(data)
          enable_ssl
        end
        
        # Do Nothing
        def handle_noop(data)
        end
        
        # A remote exception in the processing
        def handle_exception(data)
          logger.warn "Got exception from remote call of #{data["action"]}: #{data["message"]}"
        end
        
        protected
        
        def should_use_ssl?
          instance_variable_defined?(:@should_use_ssl) && @should_use_ssl
        end
        
        def ssl_enabled?
          instance_variable_defined?(:@ssl_enabled) && @ssl_enabled
        end
        
        def options_for_callback(blk)
          return {} if blk.nil?
          cb_id = "callback-#{self.object_id}-#{Time.now.to_f}"
          full_id, count = nil, 0
          while full_id.nil? || @callbacks.has_key?(full_id)
            count += 1
            full_id = callback_id(base, count)
          end
          self.callbacks[full_id] = blk
          {"callback-id" => full_id}
        end
        
        def process_callback(data)
          if data.is_a?(Hash) && data.has_key?("callback-id")
            callback = @callbacks.delete(data["callback-id"])
            callback.call(self, data) if callback.present?
          end
        end
        
        def callback_id(base, count)
          Digest::SHA256.hexdigest([base, count].compact.join("-"))
        end
        
        def protocol_buffer
          @protocol_buffer ||= BufferedTokenizer.new(SEPERATOR)
        end
        
        def callbacks
          @callbacks ||= {}
        end
        
        def connected?
          instance_variable_defined?(:@connected) && @connected
        end
        
        def handle_response(response)
          return unless response.is_a?(Hash) && response.has_key?("action")
          payload = response["payload"] || {}
          @callback_id = response.delete("callback-id")
          process_callback(payload)
          process_action(response["action"], payload)
          @callback_id = nil
        end
        
        def process_action(name, data)
          self.event_handlers[name.to_s].each do |handler|
            if handler.respond_to?(:call)
              handler.call(data, self)
            elsif handler.respond_to?(:handle)
              handler.handle(data)
            else
              self.send(handler, data)
            end
          end
        rescue Exception => e
          reply :exception, :name => e.class.name, :message => e.message,
                :action => name, :payload => data
        end
        
      end
      
      module ClassMethods
        
        def on_action(name, handler = nil, &blk)
          real_name = name.to_s
          self.event_handlers[real_name] << blk     if blk.present?
          self.event_handlers[real_name] << handler if handler.present?
        end
        
      end
      
    end
  end
end