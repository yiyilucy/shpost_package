class CreateReturnReasons < ActiveRecord::Migration
  def change
    create_table :return_reasons do |t|
      t.string :reason
      t.integer :unit_id

      t.timestamps
    end
  end
end
