class CreateQueryResultImportFiles < ActiveRecord::Migration
  def change
    create_table :query_result_import_files do |t|
      t.integer :query_result_id
      t.integer :import_file_id
      t.boolean :is_sent, default: false
      
      t.timestamps
    end
  end
end
