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
  NEW = 0
  OPEN = 1
  WRITING = 2
  EDITING = 3
  COMPLETE = 4
  PUBLISHED = 5

  def phase
    return case
           when status = Project::NEW
             "new"
           when status = Project::OPEN
             "open for participants"
           when status = Project::WRITING
             "being writen"
           when status = Project::EDITING
             "being edited"
           when status = Project::COMPLETE
             "complete"
           when status = Project::PUBLISHED
             "published"
           end
  end

end
