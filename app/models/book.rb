# == Schema Information
# Schema version: 20090608135958
#
# Table name: books
#
#  id          :integer         not null, primary key
#  title       :string(100)     not null
#  keywords    :text
#  published   :boolean         not null
#  cur_chapter :integer         default(1), not null
#  uber_id     :integer         not null
#  project_id  :integer         not null
#

class Book < ActiveRecord::Base
  has_many :chapters, :order => "number"
  belongs_to :editor, :class_name => "User", :foreign_key => "uber_id"
  validates_presence_of :uber_id, :project_id, :title  
  belongs_to :project
  
  def self.find_books
    find(:all, :order => "title")
  end

  # set up the next chapter for this book
  def next_chapter
    self.cur_chapter += 1
    c = Chapter.new(:user => self.editor, :book => self, :due_date => self.project.next_due_date, :title => "Chapter #{self.cur_chapter}", :finished => false, :edited => false, :number => self.cur_chapter, :state => "new")
    if c.save then
      self.save
    else 
      flash[:notice] = "Failed to save new chapter in book #{self}"
    end
  end
end
