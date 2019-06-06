class AddBusinessCodeToQueryResults < ActiveRecord::Migration
  def change
    add_column :query_results, :business_code, :string 
  end
end
