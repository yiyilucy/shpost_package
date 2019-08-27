class AddIsQueryToImportFiles < ActiveRecord::Migration
  def change
  	add_column :import_files, :is_query, :boolean
  end
end
