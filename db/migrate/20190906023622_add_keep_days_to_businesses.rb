class AddKeepDaysToBusinesses < ActiveRecord::Migration
  def change
    add_column :businesses, :keep_days, :integer
  end
end
