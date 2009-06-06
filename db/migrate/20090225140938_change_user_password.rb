class ChangeUserPassword < ActiveRecord::Migration
  def self.up
    rename_column "users", "password", "hashed_password" 
    add_column "users", "salt", :string
    User.reset_column_information()
  end

  def self.down
    rename_column "users", "hashed_password", "password"
    remove_column "users", "salt"
    User.reset_column_information()
  end
end
