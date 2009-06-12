class RemoveConfusingChaptersFromBooks < ActiveRecord::Migration
  def self.up
    remove_column :books, :chapters
  end

  def self.down
    add_column :books, :chapters, :integer
  end
end
