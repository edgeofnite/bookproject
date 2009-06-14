# == Schema Information
# Schema version: 20090608135958
#
# Table name: users
#
#  id              :integer         not null, primary key
#  username        :string(20)      not null
#  hashed_password :string(30)      not null
#  age             :integer
#  aboutMe         :string(255)
#  salt            :string(255)
#  email           :string(255)
#

require 'digest/sha1'

class User < ActiveRecord::Base
  has_many :groups
  has_many :ubers
  has_many :projects, :through => :groups, :uniq => true
  has_many :editing_projects, :through => :ubers, :source => :user, :uniq => true
  has_many :edited_books, :class_name => "Book", :foreign_key => "uber_id", :uniq => true
  has_many :written_books, :through => :chapters, :source => :book, :uniq => true
  has_many :chapters, :foreign_key => "author_id", :order => :book_id
  has_many :owned_projects, :class_name => "Project", :foreign_key => :owner_id

  validates_presence_of :password, :username
  validates_uniqueness_of :username
  validates_length_of :username, :minimum => 4
  validates_length_of :password, :minimum => 5, :message => "should be at least 5 characters long"

  attr_accessor :password_confirmation
  validates_confirmation_of :password

  # Passwords must be at least 6 characters long

  def self.authenticate(name, password)
    user = self.find_by_username(name)
    if user
      expected_password = encrypted_password(password, user.salt)
      if user.hashed_password != expected_password
        user = nil
      end
    end
    user
  end
 
  # 'password' is a virtual attribute
  
  def password
    @password
  end
  
  def password=(pwd)
    @password = pwd
    create_new_salt
    self.hashed_password = User.encrypted_password(@password, self.salt)
  end
 
  # make sure we leave at least one user in the database
  def safe_delete
    transaction do
    destroy
      if User.count.zero?
        raise "Cant delete last user"
      end
    end
  end
  
  private
  def create_new_salt
    self.salt = [Array.new(6){rand(256).chr}.join].pack("m").chomp
  end
 
  def self.encrypted_password(password, salt)
    string_to_hash = password + "wibble" + salt
    Digest::SHA1.hexdigest(string_to_hash)
  end
  
end
