class AddBusinessCodeToInterfaceSenders < ActiveRecord::Migration
  def change
  	add_column :interface_senders, :business_code, :string
  end
end
