class AddIsUpdateToImportFiles < ActiveRecord::Migration
  def change
  	add_column :import_files, :is_update, :boolean
  end
end
