class CreateImportFiles < ActiveRecord::Migration
  def change
    create_table :import_files do |t|
      t.string :file_name, null: false
      t.string :file_path, null: false, default: ''
      t.datetime :import_date
      t.integer :user_id
      t.integer :unit_id
      t.integer :business_id
      t.boolean :is_process, default: false
      
      t.timestamps
    end
  end
end
