class AddIndexToQueryResults < ActiveRecord::Migration
  def change
  	add_index :query_results, :registration_no, unique: true
  end
end
