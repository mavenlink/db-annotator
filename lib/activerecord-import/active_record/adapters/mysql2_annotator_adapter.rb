# This file exists so active record import will work with the db-annotator
# See https://github.com/zdennis/activerecord-import in section `Additional Adapters`

require "active_record/connection_adapters/mysql2_annotator_adapter"
require "active_record/import/mysql2_adapter"

class ActiveRecord::ConnectionAdapters::Mysql2AnnotatorAdapter
  include ActiveRecord::Import::Mysql2Adapter
end
