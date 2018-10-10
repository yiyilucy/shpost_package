class CreateBusinesses < ActiveRecord::Migration
  def change
    create_table :businesses do |t|
      t.string :name, null: false, default: ''
      t.string :start_date
      t.string :end_date
      t.integer :unit_id

      t.timestamps
    end
  end
end
