class AddPkpToUnits < ActiveRecord::Migration
  def change
  	add_column :units, :pkp, :string
  end
end
