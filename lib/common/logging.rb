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

end
