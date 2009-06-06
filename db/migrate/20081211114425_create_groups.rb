class CreateGroups < ActiveRecord::Migration
  def self.up
    create_table :groups, :id => false do |t|
      t.column :user_id,    :integer, :null => false
      t.column :project_id, :integer, :null =>false
    end
  end

  def self.down
    drop_table :groups
  end
end
