class AddFetchStatusToImportFiles < ActiveRecord::Migration
  def change
  	add_column :import_files, :fetch_status, :string, default: "waiting"
  end
end
