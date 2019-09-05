class AddUserIdToReturnResults < ActiveRecord::Migration
  def change
  	add_column :return_results, :user_id, :integer
  end
end
