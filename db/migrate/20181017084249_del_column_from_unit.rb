class DelColumnFromUnit < ActiveRecord::Migration
  def up
  	remove_column :units, :parent_id
  end
  def down
  	remove_column :units, :parent_id, :integer
  end
end
