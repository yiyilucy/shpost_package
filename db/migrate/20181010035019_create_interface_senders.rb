class CreateInterfaceSenders < ActiveRecord::Migration
  def change
    create_table :interface_senders do |t|
      t.string :url
      t.string :host
      t.string :port
      # t.text :params
      t.string :interface_type
      t.string :http_type
      t.string :callback_class
      t.string :callback_method
      t.text :callback_params
      t.string :status
      t.integer :send_times
      t.timestamp :next_time
      t.text :body
      t.timestamp :last_time
      t.text :last_response
      t.string :interface_code
      t.integer :max_times
      t.integer :interval
      t.text :error_msg
      t.string :object_class
      t.integer :object_id
      t.integer :unit_id
      t.integer :business_id

      t.timestamps
    end
  end
end
