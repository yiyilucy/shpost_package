class AddNoToBusinesses < ActiveRecord::Migration
  def change
    add_column :businesses, :no, :string 
  end
end
