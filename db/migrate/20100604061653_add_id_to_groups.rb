class AddIdToGroups < ActiveRecord::Migration
  def self.up
	add_column :groups, :id, :primary_key
  end

  def self.down
	remote_column :groups, :id
  end
end
