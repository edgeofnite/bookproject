#!/usr/bin/env ruby
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")

# Delete a project
# WARNING: THIS IS DANGEROUS!!!!!
# ARGUMENTS: <Project Name> <true>
# if the second argument is unspecified or is not "true", then this 
# operation makes no changes to the database.

# this project has never been run.  Use at your own risk

p = Project.find_by_name(ARGV[0])
print "Project: ", p.name, ", id: ", p.id, "\n"
b = Book.find(:all, :conditions => { :project_id => p.id })
b.each do |book|
  print "Book: ", book.title, ", id: ", book.id, "\n"
  c = Chapter.find(:all, :conditions => { :book_id => book.id })
  c.each do |chapter|
    print "Chapter ",chapter.number, ": ", chapter.title, "\n"
  end
  if ARGV[1] == ("true"):
     Chapter.delete_all({:book_id => book.id})
  end
end
if ARGV[1] == ("true"):
  Book.delete_all({:project_id => p.id})
end
u = Uber.find(:all, :conditions => { :project_id => p.id })
u.each do |uber|
  print "Uber: ", uber.user_id, "\n"
end
if ARGV[1] == ("true"):
  Uber.delete_all({:project_id => p.id})
end
w = Group.find(:all, :conditions => { :project_id => p.id })
w.each do |writer|
  print "Writer: ", writer.user_id, "\n"
end
if ARGV[1] == ("true"):
  Group.delete_all({:project_id => p.id})
end
if ARGV[1] == ("true"):
  Project.delete(p.id)
end
