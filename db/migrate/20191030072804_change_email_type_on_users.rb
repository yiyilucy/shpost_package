class ChangeEmailTypeOnUsers < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.change :email, :string, :null => false
    end
  end
end
