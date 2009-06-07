class ProjectController < ApplicationController
  layout "default"
  before_filter :authorize
  protect_from_forgery :except => :updater

  def newProject
  end

  def projectPage
    @page_title = "Personal Project Page"
    #display projects
    user = User.find(session[:user_id])
    @projects = user.projects + user.edited_books.map{|b| b.project }
    @projects = @projects.uniq

    # this should be the current users active projects
    @currentProjects = @projects.select {|p| p.status == Project::NEW or p.status == Project.OPEN or p.status == Project::WRITING or p.status == Project::EDITING }

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
  end

  def manageUbers
    #display current ubers
  end

  def projectSignUp
    @project = Project.find(params[:id])
	unless @project.status == Project::NEW
		redirect_to :controller => "main", :action => "personalPage"
		flash[:notice] = "Cannot sign up to that project"
	end
    if request.post?
      flash[:notice]=""
      if params[:signUp][:writer]=="1"
        @project.writers.push(session["person"])
        flash[:notice]+= "Successfully signed up to be a writer!<br/>"
      end
      if params[:signUp][:editor]=="1"
        @project.editors.push(session["person"])
        flash[:notice]+= "Successfully signed up to be an editor!"
      end
      @project.save
    end
  end

  def createProject
	if request.post?
		@project= Project.new(params[:project])
		@project.owner_id=session[:user_id]
		if @project.save
			flash[:notice] = "Project Created"
			redirect_to(:action => "individualProject", :id => @project.id)
		else
			flash[:notice] = "Project Creation Failed"
		end
	end
  end
  def addUserToProject
    
  end

  def updater
    bookid = params[:row]
    field = params[:field]
    value = params[:value]
    book = Book.find(bookid)
    result = "failed"
    case params[:field]
    when "editors" 
      user = User.find(params[:value])
      book.editor = user
      result = user.username
      book.save
    end
    render :text => result
    return
    rescue:
      render :text => "failed"
  end

end
