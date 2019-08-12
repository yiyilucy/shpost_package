class AddIsPostingToQuerResults < ActiveRecord::Migration
  def change
    add_column :query_results, :is_posting, :boolean 
  end
end
