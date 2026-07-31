class CreateTaxPrices < ActiveRecord::Migration
  def change
    create_table :tax_prices do |t|
      t.string   "tax_code"
      t.string   "tax_name"
      t.integer  "piece_amount", precision: 38, scale: 0
      t.integer  "piece_weight", precision: 38, scale: 0
      t.integer  "box_amount",   precision: 38, scale: 0
      t.integer  "box_weight",   precision: 38, scale: 0
      
      t.timestamps
    end
  end
end
