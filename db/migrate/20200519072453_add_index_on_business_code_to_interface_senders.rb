class AddIndexOnBusinessCodeToInterfaceSenders < ActiveRecord::Migration
  def change
  	add_index :interface_senders, :business_code
  end
end
