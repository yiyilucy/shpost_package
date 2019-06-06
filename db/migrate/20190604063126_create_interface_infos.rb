class CreateInterfaceInfos < ActiveRecord::Migration
  def change
    create_table :interface_infos do |t|
      t.string   :controller_name
      t.string   :action_name
      t.text     :request_body
      t.text     :response_body
      t.text     :params
      t.string   :business_id
      t.string   :unit_id
      t.string   :request_ip
      t.string   :status
      t.integer  :parent_id
      t.string   :parent_type
      t.string   :business_code
      t.timestamps
    end
  end
end
