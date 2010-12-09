require 'cancan'
module CanCan
  class ControllerResource # :nodoc:
    # PATCH: get error if existing resource not found 
    def find_resource
      if @options[:singleton] && resource_base.respond_to?(name)
        resource_base.send(name)
      else
        @options[:find_by] ? resource_base.send("find_by_#{@options[:find_by]}!", id_param) : resource_base.find!(id_param)
      end
    end
  end
end
