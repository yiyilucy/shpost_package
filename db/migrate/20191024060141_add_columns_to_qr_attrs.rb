class AddColumnsToQrAttrs < ActiveRecord::Migration
  def change
  	add_column :qr_attrs, :id_num, :string
  	add_column :qr_attrs, :receive_date, :datetime
  	add_column :qr_attrs, :province, :string
  	add_column :qr_attrs, :city, :string
  	add_column :qr_attrs, :district, :string
  	add_column :qr_attrs, :weight, :decimal, :precision => 10, :scale => 2
  	add_column :qr_attrs, :price, :decimal, :precision => 10, :scale => 2
  end
end
