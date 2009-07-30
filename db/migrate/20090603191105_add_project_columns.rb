class AddProjectColumns < ActiveRecord::Migration
  def self.up
	add_column :projects, :private, :boolean
	add_column :projects, :max_writers, :integer
  end

  def self.down
  	delete_column :projects, :private
	delete_column :projects, :max_writers
  end
end
