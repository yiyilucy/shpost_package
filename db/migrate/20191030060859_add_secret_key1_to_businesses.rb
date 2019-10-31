class AddSecretKey1ToBusinesses < ActiveRecord::Migration
  def change
    add_column :businesses, :secret_key1, :string
  end
end
