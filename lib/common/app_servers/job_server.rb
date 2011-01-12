require 'servolux'
module AppServers

  # Defines base abstract class to run jobs in server. Inherits from Servolux::Server.
  # Each Job is run as the forked subprocess.
  # Server is implemented with "fail-fast" idea. Is something goes wrong (parent or some child process died) then 
  # try to gracefully terminate other jobs and terminate ASAP.
  # Therefore - job server should be monitored via some process monitoring tool - Monit, God, ... 
  #
  # Inherited classes should implement #register_jobs method to register jobs.
  # Example:
  # def register_job
  #   run_job(:every => 60) do
  #     Jobs::NotificationProcessor.execute
  #   end
  # end
  #
  # Server startup:
  # ENV["RAILS_ENV"] ||= 'development' 
  # require_relative '../config/boot'
  # require_relative "../config/environment"
  # 
  # Process.daemon
  # server = SDJobs.new('SDJobs', :logger => Logger.new('/tmp/sd_jobs.log'))
  # server.startup
  # 
  #
  class JobServer < ::Servolux::Server
    attr_accessor :pids

    def initialize(name, options = {})
      Process.daemon
      options[:interval] = 10
      super(name, options)
    end

    # Inherited classes should implement this method to register jobs.
    # Example (define in #register_jobs):
    #  run_job(:every => 60) do
    #    Jobs::NotificationProcessor.execute
    #  end
    # @param [Hash] options 
    # @option options :interval (60) - interval (seconds), in which job are rerun
    def run_job(options)
      job_klass = options[:job_klass]
      interval = options[:every] || 60
      parent_pid = Process.pid
      @pids << fork do
        @terminating = false 
        @worker_thread = Thread.current
        trap('INT') do
          @terminating = true
          @worker_thread.run
        end

        loop do
          # Clear Identity Map before running job
          # TODO: It is not thread safe, but this is problem of the IdentityMap implementation
          if Rails.configuration.cache_classes 
            MongoMapper::Plugins::IdentityMap.clear 
          else 
            MongoMapper::Document.descendants.clear 
            MongoMapper::Plugins::IdentityMap.models.clear 
          end 

          yield unless @terminating
          if @terminating
            exit
          end
          shallow_sleep(interval, parent_pid)
        end
      end
      Process.detach @pids.last
    end

    def run
      if some_job_died? 
        info "some child process died, so I don't want live anymore too .. "
        shutdown
      end
    end

    def before_starting
      @pids = []
      register_jobs
    end

    def before_stopping
      stop_jobs
    end


    private

    def info(message)
      logger.info message
    end



    # wakes up periodically to enable processing iINT
    def shallow_sleep(secs, parent_pid)
      start = Time.now
      loop do
        wakeup = (Time.now - start) > secs
        @terminating = true unless alive?(parent_pid)
        return if wakeup or @terminating      
        sleep 3
      end
    end



    def some_job_died?
      @pids.any? { |pid| not alive?(pid) }
    end

    def alive?(pid) 
      pid = Integer("#{ pid }") 
      begin 
        Process.kill 0, pid 
        true 
      rescue Errno::ESRCH 
        info "Process #{ pid } died."
        false 
      end 
    end


    def stop_jobs
      return  if @stopping_jobs
      @stopping_jobs = true
      @pids.each do |pid|

        info "Stopping #{pid}"
        if alive?(pid) 
          Process.kill "INT", pid
          info "INT sent #{pid}"
          begin
            Process.wait2 pid
          rescue Errno::ECHILD 
          end
          info "Terminated #{pid}"
          pause
        end
      end
    end


    def pause
      sleep(0.1 + 0.3*rand)
    end



  end
end
