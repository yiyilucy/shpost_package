class AddSendIdToBusinesses < ActiveRecord::Migration
  def change
    add_column :businesses, :send_id, :string
  end
end
