class AddIndexUnitIdToQueryResults < ActiveRecord::Migration
  def change
  	add_index :query_results, :unit_id
  end
end
