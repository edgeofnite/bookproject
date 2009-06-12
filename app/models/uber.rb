# == Schema Information
# Schema version: 20090608135958
#
# Table name: ubers
#
#  id         :integer         not null, primary key
#  user_id    :integer         not null
#  project_id :integer
#

class Uber < ActiveRecord::Base
  validates_numericality_of :user_id, :project_id
  belongs_to :user
  belongs_to :project
end
