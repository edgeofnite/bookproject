class UsersController < ApplicationController
  layout 'default'
  before_filter :authorize
	def index
	end
	def profile
		@user = User.find(params[:id])
		@userProjects = @user.owned_projects
		@userCompletedBooks = @user.chapters.map{|c| if c.book.published then c.book end }.compact + @user.edited_books.select{|b| b.published}.compact
		@userCompletedBooks = @userCompletedBooks.uniq
		@currentProjects = @user.projects.select {|p| p.status == Project::NEW or p.status == Project::OPEN or p.status == Project::WRITING or p.status == Project::EDITING }

	end
end
