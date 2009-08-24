class UsersController < ApplicationController
  layout 'default'
  before_filter :authorize, :only => :profile

  def help
  end

  def profile
    @user = User.find(params[:id])
    @userProjects = @user.owned_projects
    @userCompletedBooks = @user.chapters.map{|c| if c.book.published then c.book end }.compact + @user.edited_books.select{|b| b.published}.compact
    @userCompletedBooks = @userCompletedBooks.uniq
    @currentProjects = @user.projects.select {|p| p.status == Project::NEW or p.status == Project::OPEN or p.status == Project::WRITING or p.status == Project::EDITING }
 end

 def recover
    user = User.find_by_username(params[:name])
    if user
      Notifier.deliver_recover_password(:key => Crypto.encrypt("#{user.id}:#{user.salt}"),
                              :email => user.email,
                              :domain => request.env['HTTP_HOST'])
      flash[:notice] = "Please check your email for further instructions"
      redirect_to(root_url)
    else
      flash[:notice] = "Your account could not be found"
      redirect_to(controller => "users", :action => "help")
    end
  end
  
end
