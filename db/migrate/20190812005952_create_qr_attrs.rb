class CreateQrAttrs < ActiveRecord::Migration
  def change
    create_table :qr_attrs do |t|
      t.datetime :data_date
      t.datetime :batch_date
      t.string :lmk
      t.string :id_code
      t.string :sn
      t.string :issue_bank
      t.string :name
      t.string :bank_no
      t.string :phone
      t.string :address
      t.references :query_result

      t.timestamps
    end
  end
end
