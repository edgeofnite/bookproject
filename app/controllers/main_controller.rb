class MainController < ApplicationController
  layout 'default'
  before_filter :authorize, :except => :index

  def index
  end

  def personalPage
    #display about me and books
    # calculate any tasks that this person needs to do.
    # All book chapters assigned but not done
    # All books for which we are an editor and there are completed chapters
    @me = session["person"]
    @chaptersToWrite = @me.chapters.select {|c| c.user == @me and c.writing? == true}
    @chaptersToEdit = @me.edited_books.collect{|b| b.chapters.select{|c| c.editing?}}.flatten
    @myProjects = @me.owned_projects
    @myCompletedBooks = @me.chapters.map{|c| if c.book.published then c.book end }.compact + @me.edited_books.select{|
b| b.published}
    @currentProjects = @me.projects.select {|p| p.status == Project::NEW or p.status == Project::OPEN or p.status == Project::WRITING or p.status == Project::EDITING }
    if request.post?
      if ! params[:user].nil? then
        @me = User.find(session["person"].id)
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
