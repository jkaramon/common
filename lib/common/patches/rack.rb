module Rack
  
  module Utils
    # Unicode aware escape
    def escape(s)
      ustr = s.to_s.dup.force_encoding("UTF-8")
      ustr.to_s.gsub(/([^ a-zA-Z0-9_.-]+)/u) {
        '%'+$1.unpack('H2'*bytesize($1)).join('%').upcase
      }.tr(' ', '+')
    end
    module_function :escape
  end

end
