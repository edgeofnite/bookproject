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
    @me = User.find(session[:user_id])
    @chaptersToWrite = @me.chapters.select {|c| c.writing? == true}
    @chaptersToEdit = @me.chapters.select {|c| c.editing? == true}
    @myProjects = @me.owned_projects
  end
end
