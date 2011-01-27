# Error notifications - sends errors to the exception aggregator service  
module ErrorNotifier
  # exc - error which should be send
  # additional_data - Hash to provide additional error info.
  def notify_error(exc, additional_data = {})
    HoptoadNotifier.notify(
      :error_class   => exc.class.to_s,
      :error_message => "#{exc.message}\n#{exc.backtrace}",
      :parameters    => additional_data
    )
  end 
end
