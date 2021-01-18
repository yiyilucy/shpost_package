class QueryResultImportFile < ActiveRecord::Base
	belongs_to :query_result
	belongs_to :import_file
end
