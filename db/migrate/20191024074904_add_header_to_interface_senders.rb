class AddHeaderToInterfaceSenders < ActiveRecord::Migration
  def change
    add_column :interface_senders, :header, :string
  end
end
