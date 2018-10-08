class CreateImportInfos < ActiveRecord::Migration
  def change
    create_table :import_infos do |t|
      t.string :registration_no
      t.string :postcode
      t.string :desc

      t.timestamps
    end
  end
end
