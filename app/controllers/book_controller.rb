
class BookController < ApplicationController
  layout "default"
  before_filter :authorize, :except => [:index, :read]

  def editBook
    @book = Book.find(params[:id])
    @page_title = "Reviewing and Editing Book "
    if request.post?
      if ! params[:book].nil? then
        @book.update_attributes(params[:book])
        unless @book.save
          redirect_to :action => :read
        end
      else 
        if ! params[:chapter].nil? then
          @chapter = Chapter.find(params[:chapter_id])
          @chapter.update_attributes(params[:chapter])
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
          unless @chapter.save
            redirect_to :action => :read
          end
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
  end
end
