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
    @next_state = @project.compute_next_state()
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
      unless @project.update_attributes(params[:project])
          errmsg = ""
          @project.errors.each_full { |msg| errmsg = errmsg + msg + ": "}
          flash[:notice] = errmsg
          return        
      end
      redirect_to :controller => "project", :action => "individualProject", :id => @project.id
    end
  end

  def advanceProject
    @project = Project.find(params[:id])
    @next_state = params[:next_state]
    if (not @next_state.nil? and @next_state == @project.compute_next_state()) 
      case @next_state
      when "open"
        @project.begin_project!
      when "writing"
        @project.begin_writing!
      when "editing"
        @project.done_writing!
      when "complete"
        @project.done_editing!
      when "publish"
        @project.publish!
      end
    end
    redirect_to :controller => "project", :action => "individualProject", :id => @project.id
    rescue Exception => exc
      render :text => "failed: #{exc.message}"
  end

  # setup the next chapter, but don't tell anyone yet!
  def nextChapter
    @project = Project.find(params[:id])
    if session["person"].id == 1 or session["person"]==@project.owner
      @project.begin_next_chapter
      @page_title = @project.name
    else
      flash[:notice]="Error. You do not have the power to do that."
    end

    redirect_to :action => "individualProject", :id => params[:id]
  end

  # finish setting up the most recent chapter and tell everyone!
  def startNextChapter
    @project = Project.find(params[:id])
    if (session["person"].id == 1 or session["person"]==@project.owner) and (@project.start?)
    @project.start_next_chapter
    @page_title = @project.name
  else
    flash[:notice]="Error. You do not have the power to do that."
  end
    redirect_to :action => "individualProject", :id => @project.id
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
      redirect_to :action => "individualProject", :id => @project.id
    end
  end

  def createProject
	if request.post?
		@project= Project.new(params[:project])
		if @project.save
			flash[:notice] = "Project Created"
                        @page_title = @project.name
                        redirect_to :action => "individualProject", :id => @project.id
		else
			flash[:notice] = "Project Creation Failed"
		end
	end
  end

  def updater
    bookid = params[:id]
    field = params[:field]
    chapterNum = params[:cell].to_i-3   # chapter is offset by two in the table and then by one because its one based and not zero based.
    value = params[:value]
    book = Book.find(bookid)
    unless session["person"].id == book.project.owner.id or session["person"].username == "admin" then
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
      chapter = book.chapters[chapterNum]
      chapter.user = user
      unless chapter.save
          errmsg = ""
          chapter.errors.each_full { |msg| errmsg = errmsg + msg + ": "}
          result = errmsg
      else
          result = user.username
      end
    end
    render :text => result
    return
    rescue Exception => exc:
      render :text => "failed: #{exc.message}"
  end

end
