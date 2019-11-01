class AddIndexToQrAttrs < ActiveRecord::Migration
  def change
  	add_index :qr_attrs, :query_result_id, unique: true
  end
end
