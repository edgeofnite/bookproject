class AddCommentToChapters < ActiveRecord::Migration
  def self.up
    add_column :chapters, :comment, :text
  end

  def self.down
    remove_column :chapters, :comment
  end
end
