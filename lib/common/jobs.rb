module Jobs
  require_relative 'jobs/configuration/base_configuration'
  require_relative 'jobs/synchronization/full_text'
  require_relative 'jobs/tracking/base_tracker'
  require_relative 'jobs/tracking/queue_processor_tracker'
  require_relative 'jobs/base'
  require_relative 'jobs/queue_processor'
end
