# == Schema Information
# Schema version: 20090608135958
#
# Table name: chapters
#
#  id        :integer         not null, primary key
#  author_id :integer         not null
#  book_id   :integer         not null
#  due_date  :date
#  contents  :binary
#  title     :string(100)
#  finished  :boolean
#  edited    :boolean
#  number    :integer         not null
#  comment   :text
#  state     :string(255)     default("new"), not null
#

class Chapter < ActiveRecord::Base
  validates_numericality_of :author_id, :number, :book_id, :only_integer => true
  validates_presence_of :due_date
  belongs_to :user, :foreign_key => :author_id
  belongs_to :book

  #### Constants for the :status field of a chapter.
  # Chapter State Transitions: (Transitions are not monotonic) [ chapter.status ]
  #  Writing: - The "owner" is writing this chapter
  #  Editing: - The "owner" has finished writing and the editor now owns this chapter
  #  Accepted: - The editor accepts this chapter and passes the book on to the next chapter writer

  state_machine :state, :initial => :new do
    event :begin_writing do
      transition :new => :writing, :editing => :writing
    end

    event :begin_editing do
      transition :writing => :editing
    end

    event :done_editing do
      transition :editing => :accepted
    end
  end

end
