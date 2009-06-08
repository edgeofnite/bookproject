class AddMoreFieldsToProject < ActiveRecord::Migration
  def self.up
    add_column :projects, :description, :text
    add_column :projects, :start_date, :date
    add_column :projects, :next_due_date, :date
  end

  def self.down
    remove_column :projects, :description
    remove_column :projects, :start_date
    remove_column :projects, :next_due_date
  end
end
