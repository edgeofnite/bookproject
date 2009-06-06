
class BookController < ApplicationController
  layout "default"
  before_filter :authorize, :except => [:index, :read]

  def editBook
    @book = Book.find(params[:id])
    @page_title = "Reviewing and Editing Book " + @book.title
    @chapter = Chapter.find(:first, :conditions => { :book_id => @book.id, :number => @book.cur_chapter})
    @value='';
    unless @chapter.nil?
      @value=@chapter.contents
    end
    if request.post?
      @chapter.contents = params[:chapter][:contents]
      @chapter.title = params[:chapter][:title]
      @chapter.finished = (params[:chapter][:finished] == 'true')
      @chapter.edited = (params[:chapter][:edited] == 'true')
      @chapter.comment = params[:chapter][:comment]
      unless @chapter.save
        redirect_to :action => :read
      end
    end
  end

  def index
        @books = Book.find_books
  end
  def writeBook
    
  end
  def read
    @book = Book.find(params[:id])
    @page_title = @book.title
  end
end
