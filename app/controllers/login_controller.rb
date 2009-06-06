class LoginController < ApplicationController
  layout 'default'
  before_filter :authorize, :except => :login
  
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
        redirect_to(uri || { :action => "index" }) 
      else
        flash.now[:notice] = "Invalid user/password combination"
      end
    end
  end
  
  def add_user
    @user = User.new(params[:user])
    if request.post? and @user.save
      flash.now[:notice] = "User #{@user.name} created"
      @user = User.new
    end
  end

  def delete_user
    if request.post?
      user = User.find(params[:id])
      begin
        user.destroy
        flash[:notice] = "User #{user.name} deleted"
      rescue Exception => e
        flash[:notice] = e.message
      end
    end
    redirect_to(:action => :list_users)
  end
  
  def list_users
    @all_users = User.find(:all)
  end
  
  def logout
    session["person"] = nil
    session[:user_id] = nil
    flash[:notice] = "Logged out"
    redirect_to(:action => "index")
  end

end
