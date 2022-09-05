class AddLocalFirstToBusinesses < ActiveRecord::Migration
  def change
  	add_column :businesses, :local_first, :boolean, default: false
  end
end
