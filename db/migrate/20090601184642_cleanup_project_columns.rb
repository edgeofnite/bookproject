class CleanupProjectColumns < ActiveRecord::Migration
  def self.up
     remove_column :projects, :active
     remove_column :projects, :phase
     add_column :projects, :owner_id, :integer, :default => 1
     Project.reset_column_information()
  end

  def self.down
     add_column :projects, :active, :boolean, :default => true
     add_column :projects, :phase, :integer, :default => 0
     remove_column :projects, :owner
     Project.reset_column_information()
  end
end
