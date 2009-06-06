class AddProjectToUbers < ActiveRecord::Migration
  def self.up
    add_column :ubers, :project_id, :integer
  end

  def self.down
    remove_column :ubers, :project_id
  end
end
