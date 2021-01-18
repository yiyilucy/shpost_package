class AddColumnsToQrAttr < ActiveRecord::Migration
  def change
  	add_column :qr_attrs, :branch_no, :string
  	add_column :qr_attrs, :branch_name, :string
  	add_column :qr_attrs, :match_branch, :string
  	add_column :qr_attrs, :mistake_num, :integer
  end
end
