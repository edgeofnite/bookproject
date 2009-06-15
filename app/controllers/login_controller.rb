class LoginController < ApplicationController
  layout 'default'
  before_filter :authorize, :except => [:login, :add_user]

  def index
  end

  # just display the form and wait for user to
  # enter a name and password

  def login
    session[:user_id] = nil
    if request.post?
      if session["person"] = User.authenticate(params[:name], params[:password])
        session[:user_id] = session["person"].id
        uri = session[:original_uri]
        session[:original_uri] = nil
        redirect_to(uri || { :controller => "main", :action => "personalPage" })
      else
        flash.now[:notice] = "Invalid user/password combination"
      end
    end
  end

  def add_user
    @user = User.new(params[:user])
    if request.post? and @user.save
      flash.now[:notice] = "User #{@user.username} created"
      session["person"] = @user
      session[:user_id] = session["person"].id
      @user = User.new
      if defined? uri
        redirect_to(uri || { :controller => "main", :action => "personalPage" })
      else
        redirect_to({ :controller => "main", :action => "personalPage" })
      end
    end
  end

  def delete_user
    if request.post?
      if session["person"].id == 1
        user = User.find(params[:id])
        begin
          user.safe_delete
          flash[:notice] = "User #{user.username} deleted"
        rescue Exception => e
          flash[:notice] = e.message
        end
      else
        flash[:notice] = "Only the administrator can remove users"
      end
      redirect_to(:action => :list_users)
    end
  end

  def list_users
    @all_users = User.find(:all)
  end

  def logout
    session["person"] = nil
    session[:user_id] = nil
    flash[:notice] = "Logged out"
    redirect_to(:controller => "main")
  end

end
