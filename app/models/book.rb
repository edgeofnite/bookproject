# == Schema Information
# Schema version: 20090605083306
#
# Table name: books
#
#  id          :integer         not null, primary key
#  title       :string(100)     not null
#  keywords    :text
#  published   :boolean         not null
#  cur_chapter :integer         default(1), not null
#  chapters    :integer         default(8), not null
#  uber_id     :integer         not null
#  project_id  :integer         not null
#

class Book < ActiveRecord::Base
  has_many :chapters, :order => "number" #WARNING!!! BOOKS has both chapters as array and as database entry for number of chapters. Delete number of chapters and use chapters.length
  belongs_to :editor, :class_name => "User", :foreign_key => "uber_id"
  validates_presence_of :uber_id, :project_id, :chapters, :title  
  belongs_to :project
  
  def self.find_books
    find(:all, :order => "title")
  end

end
