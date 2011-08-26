require 'representable/xml'

Representable::XML::ObjectBinding.class_eval do
  def serialize(object)
    object.to_xml(:name => name)
  end
end 
