class CreateBooks < ActiveRecord::Migration
  def self.up
    create_table :books do |t|
      t.column :title,       :string, :null =>false, :unique =>true, :limit => 100
      t.column :keywords,    :text
      t.column :published,   :boolean, :default => 0, :null =>false
      t.column :cur_chapter, :integer, :default => 1, :null =>false
      t.column :chapters,    :integer, :default => 8, :null =>false
      t.column :uber_id,     :integer, :null => false
      t.column :project_id,  :integer, :null => false
    end
  end

  def self.down
    drop_table :books
  end
end
