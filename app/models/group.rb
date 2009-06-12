# == Schema Information
# Schema version: 20090608135958
#
# Table name: groups
#
#  user_id    :integer         not null
#  project_id :integer         not null
#

class Group < ActiveRecord::Base
  validates_numericality_of :user_id, :project_id
  belongs_to :user
  belongs_to :project
end
