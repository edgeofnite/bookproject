class CreateProjects < ActiveRecord::Migration
  def self.up
    create_table :projects do |t|
      t.column :signing_date,     :date
      t.column :days_per_chapter, :integer, :null =>false, :default => 7
      t.column :chapters,         :integer, :null =>false, :default => 8
    end
  end

  def self.down
    drop_table :projects
  end
end
