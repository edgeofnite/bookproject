class CreateUbers < ActiveRecord::Migration
  def self.up
    create_table :ubers do |t|
      t.column :user_id, :integer, :null => false, :unique =>true
    end
  end

  def self.down
    drop_table :ubers
  end
end
