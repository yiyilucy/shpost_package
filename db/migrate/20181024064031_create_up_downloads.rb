class CreateUpDownloads < ActiveRecord::Migration
  def change
    create_table :up_downloads do |t|
      t.string :name
      t.string :use
      t.string :desc
      t.string :ver_no
      t.string :url
      t.datetime :oper_date

      t.timestamps
    end
  end
end
