class AddSecretKeyToBusinesses < ActiveRecord::Migration
  def change
    add_column :businesses, :secret_key, :string 
  end
end
