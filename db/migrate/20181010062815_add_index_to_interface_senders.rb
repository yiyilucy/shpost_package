class AddIndexToInterfaceSenders < ActiveRecord::Migration
  def change
    add_index :interface_senders, :unit_id
    add_index :interface_senders, :business_id
    add_index :interface_senders, :object_id
    add_index :interface_senders, :status
    add_index :interface_senders, :created_at
  end
end
