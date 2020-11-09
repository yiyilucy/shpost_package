class AddImportFileIdToQueryResults < ActiveRecord::Migration
  def change
  	add_column :query_results, :import_file_id, :integer
  end
end
