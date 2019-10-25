class AddIsSentToQueryResults < ActiveRecord::Migration
  def change
    add_column :query_results, :is_sent, :boolean
    # add_column :query_results, :is_queried, :boolean
    add_column :query_results, :to_send, :boolean
    # add_column :query_results, :iqueried, :boolean
  end
end
