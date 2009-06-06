class AddStateToChapter < ActiveRecord::Migration
  def self.up
    add_column :chapters, :state, :string, :null => false, :default => "new"
  end

  def self.down
    remove_column :chapters, :state
  end
end
