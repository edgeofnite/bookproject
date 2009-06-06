class AddFieldsToProject < ActiveRecord::Migration
  def self.up
	 add_column :projects, :active, :boolean, :default => true
	 add_column :projects, :status, :integer, :default => 0
	 add_column :projects, :phase, :integer, :default => 0
	 add_column :projects, :name, :string
  end

  def self.down
	remove_column :projects, :active
	remove_column :projects, :status
	remove_column :projects, :phase
	remove_column :projects, :name
  end
end
