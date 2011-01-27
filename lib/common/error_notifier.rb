# Error notifications - sends errors to the exception aggregator service  
module ErrorNotifier
  # exc - error which should be send
  # additional_data - Hash to provide additional error info.
  def notify_error(exc, additional_data = {})
    additional_data[:backtrace] ||= exception.backtrace.join("\n")
    HoptoadNotifier.notify(
      :error_class   => exc.class.to_s,
      :error_message => exc.message,
      :parameters    => additional_data
    )
  end 
end
