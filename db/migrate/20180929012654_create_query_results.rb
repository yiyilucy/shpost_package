class CreateQueryResults < ActiveRecord::Migration
  def change
    create_table :query_results do |t|
      t.string :source
      t.string :registration_no, :null => false, :unique => true
      t.string :postcode
      t.datetime :order_date
      t.datetime :query_date
      t.string :result
      t.string :status, default: 'waiting'
      t.integer :unit_id
      t.integer :business_id

      t.timestamps
    end
  end
end
