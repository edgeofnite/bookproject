class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.column :username, :string, :null => false, :limit =>20, :unique => true
      t.column :password, :string, :null => false, :limit =>30
      t.column :age,      :integer 
    end
  end

  def self.down
    drop_table :users
  end
end
