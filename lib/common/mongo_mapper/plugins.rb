require 'mongo_mapper'
require_relative 'plugins/basic_entity_state'
require_relative 'plugins/actives_or_self'
require_relative 'plugins/codelist'
require_relative 'plugins/custom_field'
require_relative 'plugins/custom_field_type'
require_relative 'plugins/id_generator'
require_relative 'plugins/localization'
require_relative 'plugins/nested_attributes'
require_relative 'plugins/search_builder'
require_relative 'plugins/search_field_items'
require_relative 'plugins/sf_synchronizer'
require_relative 'plugins/state_terminated'
require_relative 'plugins/archivable'
require_relative 'plugins/hierachical_entity'
require_relative 'plugins/concurrency_check'
require_relative 'plugins/state_history'
require_relative 'plugins/extended_pagination'

# install common plugins
MongoMapper::Document.plugin(MongoMapper::Plugins::Localization)
MongoMapper::Document.plugin(MongoMapper::Plugins::ExtendedPagination)



