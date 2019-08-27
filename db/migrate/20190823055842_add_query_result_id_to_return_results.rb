class AddQueryResultIdToReturnResults < ActiveRecord::Migration
  def change
  	add_column :return_results, :query_result_id, :integer
  	add_column :return_results, :reason, :string
  end
end
