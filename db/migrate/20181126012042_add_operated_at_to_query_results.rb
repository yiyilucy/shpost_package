class AddOperatedAtToQueryResults < ActiveRecord::Migration
  def change
    add_column :query_results, :operated_at, :datetime
  end
end
