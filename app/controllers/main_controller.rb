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
    @myCompletedBooks = @me.chapters.map{|c| if c.book.published then c.book end }.compact + @me.edited_books.select{|b| b.published}
    if request.post?
      if ! params[:user].nil? then
        @me.update_attributes(params[:user])
        @me.save
      end
    end
  end
end
