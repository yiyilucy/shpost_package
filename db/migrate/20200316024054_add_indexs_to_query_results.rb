class AddIndexsToQueryResults < ActiveRecord::Migration
  def change
  	add_index :query_results, :order_date
  	add_index :query_results, :business_id
  	add_index :query_results, :status
  end
end
