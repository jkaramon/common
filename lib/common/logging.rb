module Logging
  attr_accessor :logger
  
  def info(message)
    puts message
    logger.info(message) if @logger
  end

  def error(message)
    puts message
    logger.error(message) if @logger
  end

  def format_exception(exception)
    "\n#{exception.message}\nBacktrace:\n#{exception.backtrace.join("\n")}" 
  end

  def log_exception(message, exception)
    "#{message} #{exception}"
    error(message)
  end



end
