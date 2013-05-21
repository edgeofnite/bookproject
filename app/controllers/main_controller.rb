class MainController < ApplicationController
  layout 'default'
  before_filter :authorize, :only => :personalPage

  def index
    if @currentUser
        redirect_to({ :controller => "main", :action => "personalPage" })
    end
  end

  def personalPage
    #display about me and books
    # calculate any tasks that this person needs to do.
    # All book chapters assigned but not done
    # All books for which we are an editor and there are completed chapters
    @me = @currentUser
    @chaptersToWrite = @me.chapters.select {|c| c.user == @me and (c.writing? or c.rejected?)}
    @chaptersToEdit = @me.edited_books.collect{|b| b.chapters.select{|c| c.editing?}}.flatten
    @myProjects = @me.owned_projects
    @myCompletedBooks = @me.chapters.map{|c| if c.book.published then c.book end }.compact + @me.edited_books.select{|b| b.published}.compact
    @myCompletedBooks = @myCompletedBooks.uniq
    @currentProjects = @me.projects.select {|p| p.status == Project::NEW or p.status == Project::OPEN or p.status == Project::WRITING or p.status == Project::EDITING }
    if request.post?
      if ! params[:user].nil? then
        @me = @currentUser
        unless @me.update_attribute(:aboutMe, params[:user][:aboutMe])
          errmsg = ""
          @me.errors.each_full { |msg| errmsg = errmsg + msg + ": "}
          flash[:notice] = errmsg
        else
          flash[:notice] = "Your About Me text has been updated."
        end
      end
    end
  end
end
