class CreateUnit < ActiveRecord::Migration
  def change
    create_table :units do |t|
    	t.string   :name
        t.string   :desc
        t.string   :no
    	t.string   :short_name
    	t.string   :tcbd_khdh
    	t.integer  :level
    	t.integer  :parent_id
        t.timestamps
    end

    add_index :units, :name, :unique => true
  end
end
