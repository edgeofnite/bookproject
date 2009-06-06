# == Schema Information
# Schema version: 20090605083306
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
#

class Project < ActiveRecord::Base
  validates_numericality_of :chapters, :days_per_chapter, :status
  belongs_to :owner, :class_name => "User", :foreign_key => "owner_id"
  has_many :writers, :through => :groups, :source => :user, :uniq => true
  has_many :editors, :through => :ubers, :source => :user, :uniq => true
  has_many :ubers
  has_many :groups
  has_many :books

  #### Constants for the :status field of a project.
  # Project State Transitions: (all transitions are one-way)  [ project.status ]
  #  Initial: New     - the project is not yet open for participants.
  #  Open:    - participants may join the project, there are no books yet.  A starting date has been published
  #  Writing: - participants are writing chapters.  The most recent chapter is recorded in the project record
  #  Editing:  - All chapters are complete, the editors can review and ask writers to fix or rewrite portions of their chapters.
  #  Complete: - Editing is done.  Editors and Writers can view and read the books
  #  Published: - Non-project members can read the books
  state_machine :status, :initial => :new do
    state :new, :value => 0
    state :open, :value => 1
    state :writing, :value => 2
    state :editing, :value => 3
    state :complete, :value => 4
    state :published, :value => 5

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


  def phase
    return case status
           when :new then "new"
           when :open then "open for participants"
           when :writing then "being writen"
           when :editing then "being edited"
           when :complete then "complete"
           when :published then "published"
           end
  end

end
