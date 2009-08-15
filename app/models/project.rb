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

    after_transition :open => :writing do |project, transition|
      project.transition_state_from_open_to_writing
    end

    after_transition :complete => :published do |project, transition|
      project.transition_state_from_complete_to_published
    end

    event :begin_project do
      transition :new => :open
    end

    event :begin_writing do
      transition :open => :writing, :if => :test_transition_open_to_writing?
    end

    event :done_writing do
      transition :writing => :editing, :if => :test_transition_writing_to_editing?
    end

    event :done_editing do
      transition :editing => :complete, :if => :test_transition_editing_to_complete?
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
    if self.books[0].cur_chapter<chapters
        for book in self.books do
          book.begin_next_chapter
        end
    end
    self.reload
    assign_chapters(self.books, self.writers, 0)
  end

  # finish setting up the the next chapter
  def start_next_chapter
    for book in self.books do
      book.start_next_chapter
    end
  end

  # recursive function to assign new writers to the latest chapter in
  # each book of the project.
  # books is the list of books that are as yet unassigned
  # writers is the list of authors that are as yet unassigned
  def assign_chapters(books, writers, level)
    if books.empty? then 
      return true 
    end
    userIndex = 0
    thisbook = books[0]
    otherbooks = books - [books[0]]
    while userIndex < writers.length do
      if thisbook.assign(writers[userIndex]) then
        newWriters = writers - [writers[userIndex]]
        if assign_chapters(otherbooks, newWriters, level + 1) == true then
          return true
        else
          userIndex = userIndex + 1
        end
      else
        userIndex = userIndex + 1
      end
    end
    # if we get here, it means that we failed to assign all the users
    return false
  end

  def start?
    return books[0].chapters[books[0].cur_chapter-1].new? 
  end

  # Transition functions to make sure that everything is kosher
  def test_transition_open_to_writing?
    if self.chapters > self.writers.length then
      return false
    else
      return true
    end
  end

  def test_transition_writing_to_editing?
    # test to make sure the every chapter is written or edited
    for book in self.books do
      for chapter in book.chapters do
        if chapter.new? or chapter.writing? or chapter.rejected? then
          return false
        end
      end
    end
    return true
  end

  def test_transition_editing_to_complete?
    # test to make sure the every chapter is accepted
    for book in self.books do
      for chapter in book.chapters do
        if not chapter.accepted? then
          return false
        end
      end
    end
    return true
  end

  def transition_state_from_open_to_writing
    for book in 0..self.writers.length-1 do
      b = Book.new(:title => "Book #{book+1}", :published => false, :cur_chapter => 0, :project => self, :editor => self.owner)
      b.save
    end
    self.begin_next_chapter
  end

  def transition_state_from_complete_to_published
    puts "TRANSITION!"
    for book in self.books do
      book.published = true
      book.save
    end
  end

  def compute_next_state
    case self.status
    when Project::NEW
      return "open"
    when Project::OPEN
      if self.test_transition_open_to_writing? then
        return "writing"
      end
    when Project::WRITING
      if self.test_transition_writing_to_editing? then
        return "editing"
      end
    when Project::EDITING
      if self.test_transition_editing_to_complete? then
        return "complete"
      end
    when Project::COMPLETE
      return "publish"
    when Project::PUBLISHED
      return nil
    end
    return nil
  end
end
