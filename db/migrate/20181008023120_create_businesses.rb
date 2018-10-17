class CreateBusinesses < ActiveRecord::Migration
  def change
    create_table :businesses do |t|
      t.string :name, null: false, default: ''
      t.integer :start_date
      t.integer :end_date
      t.integer :unit_id

      t.timestamps
    end
  end
end
