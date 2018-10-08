class CreateQueryResults < ActiveRecord::Migration
  def change
    create_table :query_results do |t|
      t.string :source
      t.string :registration_no
      t.datetime :order_date
      t.datetime :query_date
      t.string :result
      t.string :status

      t.timestamps
    end
  end
end
