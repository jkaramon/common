# -*- coding: utf-8 -*-
require 'net/pop'
require 'net/protocol'

Net::POP3Command.class_eval do    #:nodoc: internal use only
  def starttls
    getok 'STLS'
  end

  # Existing connection stablished?
  def initialize(sock, existing = false)
    @socket = sock
    @error_occured = false
    if not existing
      res = check_response(critical { recv_response() })
      @apop_stamp = res.slice(/<[!-~]+@[!-~]+>/)
    end
  end
  
end   # class POP3Command

Net::POP3.class_eval do 

  def use_tls?
    @use_tls
  end

  def enable_tls
    @use_tls = true
  end

  def disable_tls
    @use_tls = false
  end

  def enable_ssl(verify_or_params = {}, certs = nil, port = nil)
    begin
      @ssl_params = verify_or_params.to_hash.dup
      @port = @ssl_params.delete(:port) || @port
    rescue NoMethodError
      @ssl_params = POP3.create_ssl_params(verify_or_params, certs)
      @port = port || @port
    end
  end
  
  def do_start(account, password)
    s = timeout(@open_timeout) { TCPSocket.open(@address, port) }
    ssl_connection = lambda do |socket|
      context = OpenSSL::SSL::SSLContext.new
      context.set_params(@ssl_params)
      s = OpenSSL::SSL::SSLSocket.new(socket, context)
      s.sync_close = true
      s.connect
      if context.verify_mode != OpenSSL::SSL::VERIFY_NONE
        s.post_connection_check(@address)
      end
      s
    end
    if use_ssl? or use_tls?
        raise 'openssl library not installed' unless defined?(OpenSSL)
    end

    if use_ssl? and not use_tls?
      ssl_connection.call(s)
    end
    
    @socket = Net::InternetMessageIO.new(s)
    logging "POP session started: #{@address}:#{@port} (#{@apop ? 'APOP' : 'POP'})"
    @socket.read_timeout = @read_timeout
    @socket.debug_output = @debug_output
    on_connect
    @command = Net::POP3Command.new(@socket)
    if apop?
      if use_tls?
        @command.starttls
        @socket = ssl_connection.call(s)
        @command = Net::POP3Command.new(@socket = Net::InternetMessageIO.new(s), true)
      end
      @command.apop account, password
    else
      if use_tls?
        @command.starttls
        @socket = ssl_connection.call(s)
        @command = Net::POP3Command.new(@socket = Net::InternetMessageIO.new(s), true)
      end
      @command.auth account, password
    end
    @started = true
  ensure
    # Authentication failed, clean up connection.
    unless @started
      s.close if s and not s.closed?
      @socket = nil
      @command = nil
    end
  end

end   # class POP3


# Mail library monkeypatch
#Mail::POP3.class_eval do 
#    # Start a POP3 session and ensures that it will be closed in any case.
#    def start(config = Mail::Configuration.instance, &block)
#      raise ArgumentError.new("Mail::Retrievable#pop3_start takes a block") unless block_given?
#
#      pop3 = Net::POP3.new(settings[:address], settings[:port], isapop = false)
#      pop3.enable_ssl({ :verify_mode => OpenSSL::SSL::VERIFY_NONE }, nil, settings[:port]) if settings[:enable_ssl]
#      pop3.start(settings[:user_name], settings[:password])
#    
#      yield pop3
#    ensure
#      if defined?(pop3) && pop3 && pop3.started?
#        pop3.reset # This clears all "deleted" marks from messages.
#        pop3.finish
#      end
#    end
#end
