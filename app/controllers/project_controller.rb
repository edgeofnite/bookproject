class ProjectController < ApplicationController
  layout "default"
  before_filter :authorize

  def newProject
  end

  def projectPage
    @page_title = "Personal Project Page"
    #display projects
    user = User.find(session[:user_id])
    @projects = user.projects + user.edited_books.map{|b| b.project }
    @projects = @projects.uniq

    # this should be the current users active projects
    @currentProjects = @projects.select {|p| p.status == Project::WRITING || p.status == Project::EDITING }

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

  def signUp
    
  end

  def addUserToProject
    
  end
end
