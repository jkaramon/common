require_relative 'plugins/basic_entity_state'
require_relative 'plugins/codelist'
require_relative 'plugins/custom_field'
require_relative 'plugins/custom_field_type'
require_relative 'plugins/id_generator'
require_relative 'plugins/localization'
require_relative 'plugins/nested_attributes'
require_relative 'plugins/search_builder'
require_relative 'plugins/state_terminated'

# install common plugins
module DocumentPluginAddition
  def self.included(model)
    model.plugin MongoMapper::Plugins::IdentityMap
    model.plugin MongoMapper::Plugins::Localization
  end
end
module EmbeddedDocumentPluginAddition
  def self.included(model)
    model.plugin MongoMapper::Plugins::Localization
  end
end

MongoMapper::Document.append_inclusions(DocumentPluginAddition)
MongoMapper::EmbeddedDocument.append_inclusions(EmbeddedDocumentPluginAddition)


