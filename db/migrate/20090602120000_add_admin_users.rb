class AddAdminUsers < ActiveRecord::Migration
  def self.up
    a = User.new(:username => "admin", :password => "adminadmin", :age => 31, :aboutMe => "I am the owner and adminsistrator of this system.")
    a.save
 end

  def self.down
    a = User.find_by_username('admin')
    if a
      a.delete
    end
  end
end
