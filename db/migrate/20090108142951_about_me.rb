class AboutMe < ActiveRecord::Migration
  def self.up
    add_column :users, :aboutMe, :string
  end

  def self.down
    remove_column :users, :aboutMe
  end
end
