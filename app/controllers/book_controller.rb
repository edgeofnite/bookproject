
class BookController < ApplicationController
  layout "default"
  before_filter :authorize, :except => [:index, :read, :print]

  def editBook
    @book = Book.find(params[:id])
    @page_title = @book.title
    @project = @book.project
    if (@project.status == Project::COMPLETE or @project.status == Project::PUBLISHED) and @currentUser.id != 1 and @currentUser.id != @project.owner.id
      render :action => :read
      return
    end
    if @currentUser.id == 1  or @currentUser.id == @book.editor.id
      @lastChapterThisBook = @book.cur_chapter
      @lastVisibleChapter = @book.cur_chapter
    else
      @lastChapterThisBook = @currentUser.chapters.select{|c| c.book == @book}.max{|a,b| a.number <=> b.number}
      # The admin can see all!
      if @lastChapterThisBook.nil?
        flash[:notice] = "You cannot see this book yet!"
        @book = nil
        render :action => "editBook"
        return
      else
        @lastChapterThisBook = @lastChapterThisBook.number
      end
      # the lowest chapter yet to be written by this user in this project
      @lastVisibleChapter = @currentUser.chapters.select{|c| c.writing? and c.book.project == @project}.min{|a,b| a.number <=> b.number}
      if @lastVisibleChapter.nil?
        @lastVisibleChapter = @book.cur_chapter
      else
        @lastVisibleChapter = @lastVisibleChapter.number
      end
    end
    @page_title = "Reviewing and Editing Book "
    if request.post?
      if ! params[:book].nil? then
        unless @book.update_attributes(params[:book])
          errmsg = ""
          @book.errors.each_full { |msg| errmsg = errmsg + msg + ": "}
          flash[:notice] = errmsg
          return
        end
      end
      if ! params[:chapter].nil? then
        @chapter = Chapter.find(params[:chapter_id])
        unless @chapter.update_attributes(params[:chapter])
          errmsg = ""
          @chapter.errors.each_full { |msg| errmsg = errmsg + msg + ": "}
          flash[:notice] = errmsg
        end
        if params[:commit] == "Save Chapter and send to the editor" then
          @chapter.finished = true
          @chapter.edited = false
          @chapter.begin_editing
        end
        if params[:commit] == "Send this chapter back to the writer" then
          @chapter.finished = false
          @chapter.edited = false
          @chapter.begin_writing
        end
        if params[:commit] == "Finish Editing Chapter #{@chapter.number}" then
          @chapter.finished = true
          @chapter.edited = true
          @chapter.done_editing
        end
	@chapter.clean_up_contents
        unless @chapter.save
          render :action => :read
        end
      end
    end
  end

  def index
    @books = Book.find(:all, {:conditions => { :published => true }, :order => :title})
  end

  def read
    @book = Book.find(params[:id])
    @page_title = @book.title
    unless @book.published or @currentUser.id == 1 or @currentUser.id == @book.project.owner.id or @currentUser.id == @book.editor.id then
      @book = nil
      flash[:notice] = "This book has not been published yet."
    end
    @title = @book.title
  end

  def print
    @book = Book.find(params[:id])
    @page_title = @book.title
    unless @book.published or @currentUser.id == 1 or @currentUser.id == @book.project.owner.id or @currentUser.id == @book.editor.id then
      @book = nil
      flash[:notice] = "This book has not been published yet."
    end
    @title = @book.title
    render :layout => "print"
  end
end
