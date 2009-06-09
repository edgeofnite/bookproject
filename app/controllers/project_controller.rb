class ProjectController < ApplicationController
  layout "default"
  before_filter :authorize
  protect_from_forgery :except => :updater

  def newProject
  end

  def projectPage
    @page_title = "Personal Project Page"
    #display projects
    user = session["person"]
    @projects = user.projects + user.edited_books.map{|b| b.project }
    @projects = @projects.uniq

    # this should be the current users active projects
    @currentProjects = @projects.select {|p| p.status == Project::NEW or p.status == Project::OPEN or p.status == Project::WRITING or p.status == Project::EDITING }

    # this should be the current users completed projects
    @oldProjects = @projects.select{|p| p.status >= Project::COMPLETE}

    # this should be all open projects (that can still be joined)
    @activeProjects = Project.find(:all, :conditions => { :status => Project::OPEN})
    # this should be all completed projects
    @completeProjects = Project.find(:all, :conditions => { :status => Project::PUBLISHED})
  end

  def individualProject
    #display books
    @project = Project.find(params[:id])
    @page_title = @project.name
    if request.post?
      if params[:commit] == "Delete Project" and session["person"].id == 1 then
        flash[:notice] = "Project #{@project.name} was deleted"
        @project.delete
        redirect_to :controller => "project", :action => "projectPage"
        return
      end
      old_status = @project.status
      new_status = params[:project][:status].to_i
      if old_status == Project::OPEN and new_status == Project::WRITING then
        if @project.chapters > @project.writers.length then
          flash[:notice] = "There are not enough writers for this project."
          return
        end
      end
      @project.update_attributes(params[:project])
      if old_status == Project::OPEN and new_status == Project::WRITING then
        for book in 0..@project.writers.length do
          b = Book.new(:title => "Book #{book+1}", :published => false, :cur_chapter => 0, :project => @project, :editor => session["person"])
          b.save
        end
        @project.begin_next_chapter
      end
    end
  end

  # setup the next chapter, but don't tell anyone yet!
  def nextChapter
    @project = Project.find(params[:id])
    @project.begin_next_chapter
    @page_title = @project.name

    render :action => "individualProject"
  end

  # finish setting up the most recent chapter and tell everyone!
  def startNextChapter
    @project = Project.find(params[:id])
    @project.start_next_chapter
    @page_title = @project.name

    render :action => "individualProject"
  end

  def projectSignUp
    @project = Project.find(params[:id])
	unless @project.status == Project::OPEN
		redirect_to :controller => "main", :action => "personalPage"
		flash[:notice] = "Cannot sign up to that project"
	end
    if request.post?
      flash[:notice]=""
      if params[:signUp][:writer]=="1"
        if @project.writers.index(session["person"]) then
          flash[:notice]+= "Already signed up to be a writer!<br/>"
        else
          @project.writers.push(session["person"])
          flash[:notice]+= "Successfully signed up to be a writer!<br/>"
        end
      end
      if params[:signUp][:editor]=="1"
        if @project.editors.index(session["person"]) then
          flash[:notice]+= "Already signed up to be a editor!<br/>"
        else
          @project.editors.push(session["person"])
          flash[:notice]+= "Successfully signed up to be an editor!"
        end
      end
      @project.save
      @page_title = @project.name
      render :action => "individualProject"
    end
  end

  def createProject
	if request.post?
		@project= Project.new(params[:project])
		if @project.save
			flash[:notice] = "Project Created"
                        @page_title = @project.name
                        render :action => "individualProject"
		else
			flash[:notice] = "Project Creation Failed"
		end
	end
  end

  def updater
    bookid = params[:row]
    field = params[:field]
    chapterNum = params[:cell].to_i
    value = params[:value]
    book = Book.find(bookid)
    unless session["person"] == book.project.owner or session["person"].username == "admin" then
      result = "permission denied"
      render :text => result
      return
    end

    result = "failed"
    case params[:field]
    when "editors" 
      user = User.find(params[:value])
      book.editor = user
      result = user.username
      book.save
    when "writers" 
      user = User.find(params[:value])
      chapter = book.chapters[chapterNum-2]
      chapter.user = user
      chapter.save
      result = user.username
    end
    render :text => result
    return
    rescue:
      render :text => "failed"
  end

end
