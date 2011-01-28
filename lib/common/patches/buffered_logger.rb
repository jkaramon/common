require 'active_support'

module ActiveSupport
  class ActiveSupport::BufferedLogger
    def add(severity, message = nil, progname = nil, &block)
      return if @level > severity
      message = (format_message(severity, message) || (block && block.call) || progname).to_s
      # If a newline is necessary then create a new message ending with a newline.
      # Ensures that the original message is not mutated.
      message = "#{message}\n"  unless message[-1] == ?\n
      buffer << message
      auto_flush
      message
    end
    
    def format_message(severity, msg)
      msg.gsub!(/\/n/, "\n")
      "[#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}] #{severity_name(severity)}  #{msg}\n"
    end

    def severity_name(severity)
      case severity
        when 0 then "DEBUG"
        when 1 then "INFO"
        when 2 then "WARN"
        when 3 then "ERROR"
        when 4 then "FATAL"
        else "UNKNOWN"
      end

    end
    
  end
end

