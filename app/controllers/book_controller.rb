
class BookController < ApplicationController
  layout "default"
  before_filter :authorize, :except => [:index, :read]

  def editBook
	@book = Book.find(params[:id])
	if session["person"].edited_books.include?(@book)
		@max_chapter = @book.chapters.length-1
	elsif session["person"].written_books.include?(@book)
		@max_chapter = @book.chapters.select {|v| v.user == session["person"]}[0].number #WARNING single user writing multiple chapters in special circumstances?
		if @max_chapter == @book.cur_chapter
			@max_chapter -=1		#don't display last chapter if it is the widgedit one
		end
	end
	if @max_chapter.nil?
		flash[:notice] = "You do not have permission to edit that book"
		redirect_to :controller => "main", :action => "personalPage"
	end
	@page_title = "Reviewing and Editing Book " + @book.title
    @chapter = Chapter.find(:first, :conditions => { :book_id => @book.id, :number => @book.cur_chapter})
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
