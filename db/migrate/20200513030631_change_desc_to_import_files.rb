class ChangeDescToImportFiles < ActiveRecord::Migration
  def change
  	change_column :import_files, :desc, :string, :limit => 4000
  end
end
