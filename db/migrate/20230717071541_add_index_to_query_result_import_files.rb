class AddIndexToQueryResultImportFiles < ActiveRecord::Migration
  def change
    add_index :query_result_import_files, :query_result_id
  end
end
