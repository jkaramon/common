class TestLogger
  attr_accessor :infos
  attr_accessor :errors

  def initialize
    @infos = []
    @errors = []
  end

  def info(message)
    @infos << message
  end

  def error(message)
    @errors << message
  end
end
