class AddRowsToImportFiles < ActiveRecord::Migration
  def change
  	add_column :import_files, :total_rows, :string
  	add_column :import_files, :finish_rows, :string
  end
end
