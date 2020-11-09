class AddRowsToImportFiles < ActiveRecord::Migration
  def change
  	add_column :import_files, :total_rows, :string, :default => "0"
  	add_column :import_files, :finish_rows, :string, :default => "0"
  end
end
