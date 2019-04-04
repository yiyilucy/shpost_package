class AddTypeToImportFiles < ActiveRecord::Migration
  def change
  	add_column :import_files, :import_type, :string
  end
end
