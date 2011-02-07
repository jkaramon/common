require_relative 'plugins/basic_entity_state'
require_relative 'plugins/actives_or_self'
require_relative 'plugins/codelist'
require_relative 'plugins/custom_field'
require_relative 'plugins/custom_field_type'
require_relative 'plugins/id_generator'
require_relative 'plugins/localization'
require_relative 'plugins/nested_attributes'
require_relative 'plugins/search_builder'
require_relative 'plugins/state_terminated'
require_relative 'plugins/archivable'
require_relative 'plugins/hierachical_entity'
require_relative 'plugins/concurrency_check'
require_relative 'plugins/state_history'

# install common plugins
module DocumentPluginAddition
  def self.included(model)
    
    # Disable IdentityMap plugin because it is not thread safe
    # and we have issues with job server
    # model.plugin MongoMapper::Plugins::IdentityMap
    model.plugin MongoMapper::Plugins::Localization
    model.plugin MongoMapper::Plugins::StateHistory
  end
end
module EmbeddedDocumentPluginAddition
  def self.included(model)
    model.plugin MongoMapper::Plugins::Localization
  end
end

MongoMapper::Document.append_inclusions(DocumentPluginAddition)
MongoMapper::EmbeddedDocument.append_inclusions(EmbeddedDocumentPluginAddition)


