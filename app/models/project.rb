# == Schema Information
# Schema version: 20090608135958
#
# Table name: projects
#
#  id               :integer         not null, primary key
#  signing_date     :date
#  days_per_chapter :integer         default(7), not null
#  chapters         :integer         default(8), not null
#  status           :integer         default(0)
#  name             :string(255)
#  owner_id         :integer         default(1)
#  private          :boolean
#  max_writers      :integer
#  description      :text
#  start_date       :date
#  next_due_date    :date
#

class Project < ActiveRecord::Base
  validates_numericality_of :chapters, :days_per_chapter, :status
  belongs_to :owner, :class_name => "User", :foreign_key => "owner_id"
  has_many :writers, :through => :groups, :source => :user, :uniq => true
  has_many :editors, :through => :ubers, :source => :user, :uniq => true
  has_many :ubers
  has_many :groups
  has_many :books, :order => :id
  #### Constants for the :status field of a project.
  # Project State Transitions: (all transitions are one-way)  [ project.status ]
  #  Initial: New     - the project is not yet open for participants.
  #  Open:    - participants may join the project, there are no books yet.  A starting date has been published
  #  Writing: - participants are writing chapters.  The most recent chapter is recorded in the project record
  #  Editing:  - All chapters are complete, the editors can review and ask writers to fix or rewrite portions of their chapters.
  #  Complete: - Editing is done.  Editors and Writers can view and read the books
  #  Published: - Non-project members can read the books
  NEW = 0
  OPEN = 1
  WRITING = 2
  EDITING = 3
  COMPLETE = 4
  PUBLISHED = 5

  state_machine :status, :initial => :new do
    state :new, :value => Project::NEW
    state :open, :value => Project::OPEN
    state :writing, :value => Project::WRITING
    state :editing, :value => Project::EDITING
    state :complete, :value => Project::COMPLETE
    state :published, :value => Project::PUBLISHED

    event :begin_project do
      transition :new => :open
    end

    event :begin_writing do
      transition :open => :writing
    end

    event :done_writing do
      transition :writing => :editing
    end

    event :done_editing do
      transition :editing => :complete
    end

    event :publish do
      transition :complete => :published
    end
  end

  def phase
    return case status
           when Project::NEW then "new"
           when Project::OPEN then "open for participants"
           when Project::WRITING then "being written"
           when Project::EDITING then "being edited"
           when Project::COMPLETE then "complete"
           when Project::PUBLISHED then "published"
    end
  end

  # setup the next chapter, but don't tell anyone
  def begin_next_chapter
    if books[0].cur_chapter<chapters
        for book in self.books do
          book.begin_next_chapter
      end
  end
 end

  # finish setting up the the next chapter
  def start_next_chapter
        for book in self.books do
          book.start_next_chapter
        end
  end
  def start?
    return books[0].chapters[books[0].cur_chapter-1].new? 
  end

end
