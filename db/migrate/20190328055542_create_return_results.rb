class CreateReturnResults < ActiveRecord::Migration
  def change
    create_table :return_results do |t|
      t.string :source
      t.string :registration_no, :null => false, :unique => true
      t.string :postcode
      t.datetime :order_date
      t.datetime :query_date
      t.datetime :operated_at
      t.string :result
      t.string :status
      t.integer :unit_id
      t.integer :business_id

      t.timestamps
    end

    add_index :return_results, :registration_no, unique: true
  end
end
