class AddColumnsToUsers < ActiveRecord::Migration
  def change
  	add_column :users, :locked_at, :datetime
  	add_column :users, :failed_attempts, :integer, default: 0
  end
end
