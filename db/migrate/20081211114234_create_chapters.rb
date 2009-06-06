class CreateChapters < ActiveRecord::Migration
  def self.up
    create_table :chapters do |t|
      t.column :author_id, :integer, :null =>false
      t.column :book_id,   :integer, :null =>false
      t.column :due_date,  :date
      t.column :contents,  :binary
      t.column :title,     :string,  :limit => 100
      t.column :finished,  :boolean, :default =>0
      t.column :edited,    :boolean, :default =>0
      t.column :number,    :integer, :null => false
    end
  end

  def self.down
    drop_table :chapters
  end
end
