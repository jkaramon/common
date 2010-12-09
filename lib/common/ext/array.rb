require 'set'

class Array
 def distinct(&blk)
   blk ||= lambda {|x| x}
   already_seen = Set.new
   uniq_array = []
   self.each_with_index do |value, i|
     x = blk.call(value)
     unless already_seen.include? x
       already_seen << x
       uniq_array << value
     end
   end
   uniq_array
 end
end
