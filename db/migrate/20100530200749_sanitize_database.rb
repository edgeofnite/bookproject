class SanitizeDatabase < ActiveRecord::Migration
  def self.up
    chapters = Chapter.find(:all)
    chapters.each { |c| c.clean_up_contents() }
    chapters.each { |c| c.save }
  end

  def self.down
  end
end
